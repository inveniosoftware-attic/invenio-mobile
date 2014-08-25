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
		invenio_api_version: usSource.invenio_api_version
		name: $('<div/>').text(usSource.name).html()
	}
	if usSource.authentication_url?
		sSource.authentication_url = usSource.authentication_url

	return sSource

displayError = (message) ->
	$('#urlErrorMessage').text(message)
	$('#urlForm').addClass('hasError')

clearError = ->
	$('#urlForm').removeClass('hasError')

url = null
source = null

locateSource = ->
	url = normalizeURL($urlInput.val())
	clearError()
	$('#urlForm .spinner').show()
	success = (usSource) ->
		source = sCleanSource(usSource)
		$('#sourceInfo_name').text(usSource.name)
		$('#sourceInfo_description').text(usSource.description)

		if usSource.authentication_url?
			$('#addButton').hide()
			$('#authQuestion').show()

		$('#urlForm').hide()
		$('#sourceInfo').show()

	error = (jqXHR, textStatus, errorThrown) ->
		debugObj = { jqXHR: jqXHR, errorThrown: errorThrown }
		console.error "Error while fetching source info: #{JSON.stringify(debugObj)}"
		$('.spinner').hide()
		if jqXHR.status is 404 or textStatus is 'parsererror'
			displayError "The URL you entered is not of an Invenio server which supports this app."
		else
			displayError "An error occurred. Please check the URL is correct and that you have an Internet connection."

	InvenioConnector.getSourceFromURL(url, success, error)

addSource = ->
	source.url = url
	index = app.settings.addSource(source)
	app.settings.setSelectedSource(index)

authenticate = ->
	connector = getConnector(source)
	success = ->
		app.settings.save()
		$('#authMessage').hide()
		$('#authErrorButtons').hide()
		$('#authStage .spinner').show()
		connector.testAccessToken (successful) ->
			# TODO: deal with access test failure
			console.log "Test successful." if successful
			history.back()

	error = (cause, type, message) ->
		console.error "#{cause} error while authenticating: #{type}, #{message}"
		switch cause
			when 'browser' then return
			when 'redirect'
				if type is 'access_denied'
					history.back()

		$('#authMessage').addClass('negative').text "An error occurred during authentication."

	connector.authenticate(success, error)

$urlInput.on 'input', ->
	if $urlInput.val().length > 0
		$locateButton.removeAttr('disabled')
	else
		$locateButton.attr('disabled', '')

$locateButton.click(locateSource)
$urlInput.keypress (e) ->
	locateSource() if e.which is 13 or e.keyCode is 13

addAndClose = ->
	addSource()
	history.back()

$('#addButton').click(addAndClose)
$('#noButton').click(addAndClose)
$('#yesButton').click ->
	addSource()
	$('#sourceInfo').hide()
	$('#authStage').show()
	authenticate()

$('#continueButton').click -> history.back()
$('#retryButton').click(authenticate)
