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

	## Static methods ##

	###*
		Fetches information about an Invenio source, given its URL.

		@param {string}   url      The URL of the source.
		@param {function} callback Success callback. The first argument will be
			a source object containing the source information.
		@param {function} error    Error callback. The arguments are the same as
			those to a jQuery.ajax callback, except that textStatus will equal
			'parsererror' if the server exists but is not an Invenio server.
	###
	@getSourceFromURL = (url, callback, error) ->
		checkData = (data) ->
			unless data.invenio_api_version?
				error(jqXHR, 'parsererror', "invenio_api_version was not defined.")
				return

			callback(data)

		jqXHR = $.ajax(url: "#{url}api/info", success: checkData, error: error, dataType: 'json')

	## Instance methods ##

	###*
		Runs through the process for retrieving an access token for the source.
		Once retrieved, the token is stored in the source object. For the token
		to persist, the application's settings must be saved once retrieval is
		complete.

		@param {function} success  A function to run when finished.
	###
	authenticate: (success) ->
		unless @source.authentication_url?
			throw new Error("The source does not support authentication.")

		state = Math.floor(Math.random() * Math.pow(2, 32)).toString()
		stateSHA = new jsSHA(state, 'TEXT')
		stateHash = stateSHA.getHash('SHA-256', 'B64')

		url = @source.authentication_url.replace('{STATE}', stateHash)

		authBrowser = window.open(url, '_blank')
		authBrowser.addEventListener 'loadstart', (e) =>
			# Work out whether this is the success redirect
			# TODO: check for rejection
			indexOfHash = e.url.indexOf('#')
			return if indexOfHash is -1

			hash = e.url[indexOfHash+1..]
			return if hash.indexOf('access_token=') is -1

			response = app.parseParamString(hash)
			return unless response.access_token?

			response.state = decodeURIComponent(response.state)
			if response.state isnt stateHash
				console.error "State error: #{response.state} != #{stateHash}."
				return

			response.access_token = decodeURIComponent(response.access_token)
			console.log "Token received."
			authBrowser.close()

			@source.access_token = response.access_token
			success()

	###*
		Tests the access token associated with the connector's source.

		@param {function} callback  Called when the test is complete, with a boolean
			indicating success.
	###
	testAccessToken: (callback) ->
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
		query = ''
		for clause in queryArray
			query += clause.operation + ' ' if clause.operation?
			query += clause.field + ':' if clause.field?
			query += clause.value + ' '

		return query.trim()

	performQuery: (query, sort, pageStart, pageSize, callback) ->
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
			callback(usData.results, usData.lines, paging)

		$.ajax(
			url: "#{@source.url}api/search?#{$.param(options)}",
			headers: {
				'Authorization': 'Bearer ' + @source.access_token if @source.access_token?
			},
			success: success,
			dataType: 'json',
		)

	getRecord: (id, callback, error) ->
		$.ajax(
			url: "#{@source.url}api/record/#{id}",
			headers: {
				'Authorization': 'Bearer ' + @source.access_token if @source.access_token?
			},
			success: callback,
			error: error,
			dataType: 'json',
		)

	getFileURL: (recordID, fileName) ->
		return "#{@source.url}api/record/#{recordID}/files/#{fileName}"


registerConnector('invenio', InvenioConnector)
