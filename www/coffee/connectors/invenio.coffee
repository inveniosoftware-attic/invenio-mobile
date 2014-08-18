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
	
	@getSourceFromURL = (url, callback, error) ->
		checkData = (data) ->
			unless data.invenio_api_version?
				error(jqXHR, 'parsererror', "invenio_api_version was not defined.")
				return

			callback(data)

		jqXHR = $.ajax(url: "#{url}api/info", success: checkData, error: error, dataType: 'json')
	
	## Instance methods ##

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

		$.get("#{@source.url}api/search?#{$.param(options)}", success, 'json')

	getRecord: (id, callback, error) ->
		$.ajax(
			url: "#{@source.url}api/record/#{id}",
			success: callback,
			error: error,
			dataType: 'json',
		)
	
	getFileURL: (recordID, fileName) ->
		return "#{@source.url}api/record/#{recordID}/files/#{fileName}"


registerConnector('invenio', InvenioConnector)
