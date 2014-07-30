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

$urlInput = $('#urlInput')
$locateButton = $('#locateButton')

normalizeURL = (url) ->
	if url[0..7] isnt 'http://' and url[0..8] isnt 'https://'
		url = 'http://' + url

	if url[-1..] isnt '/'
		url += '/'


sCleanSource = (usSource) ->
	sSource = {
		id: usSource.id
		name: $('<div/>').text(usSource.name).html()
	}

url = null
source = null

$urlInput.on 'input', ->
	if $urlInput.val().length > 0
		$locateButton.removeAttr('disabled')
	else
		$locateButton.attr('disabled', '')

$locateButton.click ->
	url = normalizeURL($urlInput.val())
	$('.spinner').removeClass('hidden')
	InvenioConnector.getSourceFromURL url, (usSource) ->
		source = sCleanSource(usSource)
		$('#sourceInfo_name').text(usSource.name)
		$('#sourceInfo_description').text(usSource.description)
		$('#urlForm').addClass('hidden')
		$('#sourceInfo').removeClass('hidden')

$('#addButton').click ->
	source.url = url
	index = app.settings.addSource(source)
	app.settings.setSelectedSource(index)

	history.back()
