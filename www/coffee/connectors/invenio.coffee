###
# This file is part of Invenio Mobile.
# Copyright (C) 2014 CERN.
#
# Invenio Mobile is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# Invenio Mobile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Invenio Mobile; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
###

class @InvenioConnector extends Connector
	###
	Provides an interface to the Invenio REST API. Extends :class:`Connector`.
	###

	## Static methods ##

	@getSourceFromURL = (url, callback, error) ->
		###
		Fetches information about an Invenio source, given its URL.

		:param url: The URL of the source.
		:type url: string
		:param callback:
			Success callback, passed a source object containing the source
			information.
		:type callback: function
		:param error:
			Error callback. The arguments are the same as those to a jQuery.ajax
			callback, except that textStatus will also be 'parsererror' if the
			server exists but is not an Invenio server.
		:type error: function
		###
		checkData = (data) ->
			unless data.invenio_api_version?
				error(jqXHR, 'parsererror', "invenio_api_version was not defined.")
				return

			callback(data)

		jqXHR = $.ajax(url: "#{url}api/info", success: checkData, error: error, dataType: 'json')

	## Instance methods ##

	authenticate: (success, error) ->
		###
		Runs through the process for retrieving an access token for the source.
		Once retrieved, the token is stored in the source object. For the token
		to persist, the application's settings must be saved once retrieval is
		complete.

		:param success: A function to run when finished.
		:type success: function
		:param error:
			A function to be called if an error occurs. The first argument is
			the cause of the error.

			If the error occurs in the browser, the cause will be ``'browser'``
			and the second argument will be an InAppBrowserEvent (see
			http://plugins.cordova.io/#/package/org.apache.cordova.inappbrowser).

			If the cause is ``'state'``, the CSRF token that was received does
			not match the one that was sent.

			If the cause is ``'redirect'`` then the OAuth2 server returned an
			error in a redirect. The second argument is the error (such as
			``'access_denied'``).

		:type error: function
		###
		unless @source.authentication_url?
			throw new Error("The source does not support authentication.")

		state = Math.floor(Math.random() * Math.pow(2, 32)).toString()
		stateSHA = new jsSHA(state, 'TEXT')
		stateHash = stateSHA.getHash('SHA-256', 'B64')

		url = @source.authentication_url.replace('{STATE}', stateHash)

		authBrowser = window.open(url, '_blank')
		authBrowser.addEventListener 'loadstart', (e) =>
			# Work out whether this is the success redirect
			indexOfHash = e.url.indexOf('#')
			if indexOfHash is -1
				# Check for rejection or other error
				indexOfQuestionMark = e.url.indexOf('?')
				return if indexOfQuestionMark is -1

				query = e.url[indexOfQuestionMark+1..]
				return if query.indexOf('error=') is -1

				queryArgs = app.parseParamString(query)
				error('redirect', queryArgs.error) if queryArgs.error?
				authBrowser.close()
				return

			hash = e.url[indexOfHash+1..]
			return if hash.indexOf('access_token=') is -1

			response = app.parseParamString(hash)
			return unless response.access_token?

			response.state = decodeURIComponent(response.state)
			if response.state isnt stateHash
				console.error "State error: #{response.state} != #{stateHash}."
				error('state')
				authBrowser.close()
				return

			response.access_token = decodeURIComponent(response.access_token)
			console.log "Token received."
			authBrowser.close()

			@source.access_token = response.access_token
			success()

		authBrowser.addEventListener 'loaderror', (e) ->
			error('browser', e.code, e.message)

	testAccessToken: (callback) ->
		###
		Tests the access token associated with the connector's source.

		:param callback:
			Called when the test is complete, with a boolean indicating success.
		:type callback: function
		###
		unless @source.access_token?
			throw new Error("The source has no access token to test.")

		success = (data, textStatus, jqXHR) ->
			console.dir(data: data, textStatus: textStatus, jqXHR: jqXHR)
			callback(data.ping is 'pong')

		error = (jqXHR, textStatus, errorThrown) ->
			console.dir(jqXHR: jqXHR, textStatus: textStatus, errorThrown: errorThrown)
			callback(false)

		console.log "Testing token."
		$.ajax("http://localhost:4000/oauth/ping",
			headers: {'Authorization': 'Bearer '+ @source.access_token},
			dataType: 'json',
			success: success,
			error: error
		)

	compileQuery: (queryArray) ->
		###
		Turns a JSON query structure from the Search screen into a query string
		suitable for submitting to the source via :meth:`performQuery`.
		###
		query = ''
		for clause in queryArray
			query += clause.operation + ' ' if clause.operation?
			query += clause.field + ':' if clause.field?
			query += clause.value + ' '

		return query.trim()

	performQuery: (query, sort, pageStart, pageSize, successCallback, error) ->
		###
		Sends a search query to the server.

		:param query: The query to send.
		:type query: string
		:param sort:
			The sort parameter. Valid values are ``'relevance'``, ``'date'`` or
			``'citations'``.
		:type sort: string
		:param pageStart:
			The zero-based index of the first result to be returned.
		:type pageStart: number
		:param pageSize: The number of results to return.
		:type pageSize: number
		:param successCallback:
			A function to call when the results are retrieved. The arguments
			are: an array of results; an array of line specifications; and an
			object containing paging information.
		:type successCallback: function
		:param error:
			A function to call if an error occurs. The arguments are those
			passed by the jQuery.ajax function.
		:type error: function
		###
		options = {
			query: escape(query),
			sort: sort
		}
		options.page_start = pageStart if pageStart?
		options.page_size  = pageSize  if pageSize?

		success = (usData) ->
			paging = {
				pageStart: parseInt(usData.paging.page_start),
				count: parseInt(usData.paging.count)
			}
			successCallback(usData.results, usData.lines, paging)

		$.ajax(
			url: "#{@source.url}api/search?#{$.param(options)}",
			headers: {
				'Authorization': 'Bearer ' + @source.access_token if @source.access_token?
			},
			success: success,
			error: error,
			dataType: 'json',
		)

	getRecord: (id, success, error) ->
		###
		Retrieves a record from the server, as JSON.

		:param id: The ID of the record to retrieve.
		:type id: string
		:param success: A function to be called when the record is retrieved.
			The record is passed as the first argument.
		:type success: function
		:param error: A function to be called if an error occurs. The arguments
			are those passed by the jQuery.ajax function.
		:type error: function
		###
		$.ajax(
			url: "#{@source.url}api/record/#{id}",
			headers: {
				'Authorization': 'Bearer ' + @source.access_token if @source.access_token?
			},
			success: success,
			error: error,
			dataType: 'json',
		)

	getFileURL: (recordID, fileName) ->
		###
		Returns the URL of a file associated with the given record.

		:param recordID: The ID of the record.
		:type recordID: string
		:param fileName: The name of the file.
		:type fileName: string
		###
		return "#{@source.url}api/record/#{recordID}/files/#{fileName}"


registerConnector('invenio', InvenioConnector)
