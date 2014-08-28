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

# Utility methods #

formatDate = (dateString) ->
	return new Date(dateString).toLocaleDateString()


# Page elements #

$downloadButton = $('#downloadButton')
$spinner = $('.spinner')

recordTemplate = jinja.compile($('#recordTemplate').html())


# Page methods #

displayError = (message) ->
	$spinner.text "Could not fetch record: #{message}"
	$spinner.show()

displayRecord = (usRecord) ->
	$downloadButton.show()
	if params.offline is 'true' or app.offlineStore.contains(source.id, params.id)
		$downloadButton.removeClass('icon-download').addClass('icon-compose')

	$('.content').html(recordTemplate.render(usRecord, filters: {formatDate: formatDate}))
	$('.record_filesButton').dropdown()
	$('.record_file').click(fileClicked)


# Logic #

params = parseHashParameters()


# Event handlers #

fileClicked = ->
	$this = $(this)
	return if $this.parent().hasClass('disabled')

	usFileName = $this.attr('data-file-name')
	fileType = $this.attr('data-file-type')

	error = (type, e) ->
		console.error "#{type} error: #{JSON.stringify(e)}"
		message = switch type
			when 'download'
				"Could not download the file. Please check your network connection."
			when 'open'
				if e.message.indexOf('Activity not found') is 0
					"No application on your device can open this file."
				else
					"An error occurred while opening the file."
			else "An unknown error occurred."

		navigator.notification.alert(message, (->), "Error")

	id = if params.offline is 'true'
			params.sourceID + '/' + params.id
		else
			params.id
	connector.openFile(id, usFileName, fileType, error)


# On load #

if params.offline is 'true'
	source = app.offlineSource
	originalSourceID = params.sourceID

	error = ->
		# Record has been removed
		history.back()

	connector = getConnector(app.offlineSource)
	connector.getRecord(params.sourceID + '/' + params.id, displayRecord, error)

else
	error = (jqXHR, textStatus, errorThrown) ->
		console.error "Could not fetch record: #{JSON.stringify(jqXHR)}"
		displayError "#{errorThrown} (#{jqXHR.status})"

	source = app.settings.getSelectedSource()
	connector = getConnector(source)
	connector.getRecord(params.id, displayRecord, error)

$downloadButton.attr('href', "#/download?sourceID=#{originalSourceID ? source.id}&id=#{params.id}")
$('.bar-nav .title').text source.name

