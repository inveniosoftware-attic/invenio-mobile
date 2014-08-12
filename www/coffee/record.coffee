###
## This file is part of Invenio.
## Copyright (C) 2014 CERN.
##
## Invenio is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 2 of the
## License, or (at your option) any later version.
##
## Invenio is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Invenio; if not, write to the Free Software Foundation, Inc.,
## 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
###

$downloadButton = $('#downloadButton')

params = parseHashParameters()

recordTemplate = jinja.compile($('#recordTemplate').html())

formatDate = (dateString) ->
	return new Date(dateString).toLocaleDateString()

displayRecord = (usRecord) ->
	$downloadButton.show()
	if params.offline is 'true' or app.offlineStore.contains(source.id, params.id)
		$downloadButton.children('.icon').removeClass('icon-download')
		                                      .addClass('icon-compose')

	$('.content').html(recordTemplate.render(usRecord, filters: {formatDate: formatDate}))
	$('.record_filesButton').dropdown()
	$('.record_file').click ->
		usFilePath = $(this).attr('data-file-path')
		fileType = $(this).attr('data-file-type')

		error = (e) ->
			console.error "Error in download or opening: #{JSON.stringify(e)}"
			# TODO: show nice error messages to the user

		id = if params.offline is 'true'
				params.sourceID + '/' + params.id
			else
				params.id
		connector.openFile(id, usFilePath, fileType, error)


if params.offline is 'true'
	source = app.offlineSource
	originalSourceID = params.sourceID

	error = ->
		# Record has been removed
		history.back()

	connector = getConnector(app.offlineSource)
	connector.getRecord(params.sourceID + '/' + params.id, displayRecord, error)

else
	[source, sourceIndex] = app.settings.getSelectedSource()
	connector = getConnector(source)
	connector.getRecord(params.id, displayRecord)

$downloadButton.attr('href', "#/download?sourceID=#{originalSourceID ? source.id}&id=#{params.id}")
$('.bar-nav .title').text source.name

