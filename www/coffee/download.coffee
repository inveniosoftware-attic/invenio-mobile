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

# Page elements #

$spinner = $('.spinner')
$filesList = $('#filesList')
fileItemTemplate = jinja.compile($('#fileItemTemplate').html())


# Page methods #

displayRecord = (usData) ->
	$('#record').show()
	$('#recordTitle').text usData.title
	if usData.files?
		for usFile in usData.files
			$filesList.append(fileItemTemplate.render(usFile))

		bindListItemHandlers()

displayError = (message) ->
	$spinner.text "Could not fetch record: #{message}"
	$spinner.show()

## Files list ##

toggleListItem = ($listItem) ->
	return if $listItem.hasClass('disabled')
	$checkbox = $listItem.find('input[type=checkbox]')
	if $checkbox.prop('checked')
		$checkbox.prop('checked', false)
		$listItem.removeClass('selected')
	else
		$checkbox.prop('checked', true)
		$listItem.addClass('selected')

bindListItemHandlers = ->
	$filesList.find('.listItem').click -> toggleListItem($(this))
	$filesList.find('.listItem > input[type=checkbox]').click ->
		toggleListItem($(this).parent())

selectItems = (values) ->
	for listItem in $filesList.children('.listItem')
		$listItem = $(listItem)
		if $listItem.attr('data-value') in values
			$listItem.addClass('selected')
			$listItem.find('input[type=checkbox]').prop('checked', 'true')

getSelectedItems = ->
	items = []
	for listItem in $filesList.children('.listItem')
		$listItem = $(listItem)
		if $listItem.find('input[type=checkbox]').prop('checked')
			items.push($listItem.attr('data-value'))
	
	return items

hideUnselectedItems = ->
	$filesList.find('input[type=checkbox]:not(:checked)').parent().hide()
	$filesList.children('.listItem').removeClass('selected')

disableAllItems = ->
	$filesList.children('.listItem').addClass('disabled')
	$filesList.find('input[type=checkbox]').attr('disabled', 'true')

# Logic #

params = parseHashParameters()
source = app.settings.getSourceByID(params.sourceID)
connector = getConnector(source)
usRecord = null



# Event handlers #

$('#downloadButton').click ->
	$('#downloadButton').attr('disabled', 'true')
	files = getSelectedItems()
	hideUnselectedItems()

	success = ->
		console.log "Record downloaded."
		history.back()
	error = (e) -> console.error(JSON.stringify(e))
	app.offlineStore.saveRecord(connector, usRecord, files, success, error)

$('#removeButton').click ->
	app.offlineStore.removeEntry(source.id, params.id)
	history.back()


# On load #

$('.bar-nav .title').text source.name

error = (jqXHR, textStatus, errorThrown) ->
	console.error "Could not fetch record: #{JSON.stringify(jqXHR)}"
	displayError "#{errorThrown} (#{jqXHR.status})"

offlineEntry = app.offlineStore.getEntry(source.id, params.id)
if navigator.connection.type is Connection.NONE
	$('#message').text "Cannot download new files while offline."
	usRecord = offlineEntry.usRecord
	displayRecord(usRecord)
	selectItems(offlineEntry.usSavedFileNames)
	disableAllItems()

	$('#removeButton').show()
	$('#downloadButton').hide()

else if offlineEntry?
	$('#message').text "This record is already saved. To change which files are
		stored with it, choose them from this list:"

	success = (usData) ->
		usRecord = usData
		displayRecord(usData)
		selectItems(offlineEntry.usSavedFileNames)
	
	connector.getRecord(params.id, success, error)

	$('#removeButton').show()
	$('#downloadButton .text').text "Update"

else
	success = (usData) ->
		usRecord = usData
		displayRecord(usData)

	connector.getRecord(params.id, success, error)

