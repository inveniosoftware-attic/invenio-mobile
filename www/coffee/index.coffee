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

class InvenioMobileApp
	constructor: ->
		this.bindEvents()
		this.settingsLoaded = false
		this._settingsLoadedEvent = new Event('settingsLoaded')

	# Bind any events that are required on startup. Common events are:
	# 'load', 'deviceready', 'offline', and 'online'.
	bindEvents: ->
		document.addEventListener('deviceready', this.onDeviceReady, false)

	## Settings ##

	onDeviceReady: =>
		console.log "Received deviceready event."

		if localStorage['version']?
			this.sources = JSON.parse(localStorage['sources'])
			this.selectedSourceIndex = parseInt(localStorage['selectedSourceIndex'])
		else
			this.createDefaultSettings()

		console.log "Settings loaded."
		this.settingsLoaded = true
		document.dispatchEvent(this._settingsLoadedEvent)

	onceSettingsLoaded: (callback) ->
		if this.settingsLoaded
			callback()
		else
			$(document).on('settingsLoaded', callback)

	createDefaultSettings: ->
		console.log "First run; creating default settings."
		this.sources = [
			{
				id: 'ch.cern.pcuds47',
				name: "Imposter",
				url: 'http://pcuds47.cern.ch:5000/'
			},
			{
				name: "Atlantis Institute of Fictive Science"
			},
			{
				name: "CDS"
			},
			{
				name: "INSPIRE"
			},
			{
				name: "Labordoc"
			},
		]
		this.selectedSourceIndex = 0

		localStorage['version'] = '0.0.0'
		localStorage['sources'] = JSON.stringify(this.sources)
		localStorage['selectedSourceIndex'] = this.selectedSourceIndex

	setSelectedSourceIndex: (value) ->
		this.selectedSourceIndex = value
		localStorage['selectedSourceIndex'] = value

	## Files ##
	
	###*
		Opens a file, downloading it if it does not exist.

		@param {string} url       The URL from which to download the file.
		@param {string} usPath    The path at which to store the file on the device.
		@param {string} fileType  The MIME type of the file.
	###
	openFile: (url, usPath, fileType, errorCallback) ->
		# TODO: remove old files from the cache directory
		sCleanPath = (usPath) -> usPath.split('../').join('\\.\\./')

		sPath = sCleanPath(usPath)

		open = (fileEntry) ->
			console.log "Opening #{sPath}..."
			cordova.plugins.fileOpener2.open(sPath, fileType, error: errorCallback)
			# TODO: test on Android <4

		download = (e) ->
			fileTransfer = new FileTransfer()
			fileTransfer.download(url, sPath, open, errorCallback)

		window.resolveLocalFileSystemURL(sPath, open, download)

$ -> FastClick.attach(document.body)

@app = new InvenioMobileApp()

## Hash and history handling ##

currentPage = null

###*
	@returns {Object} the parameters passed in the hash, as an object.
###
@parseHashParameters = ->
	[page, params] = window.location.hash.split('?')
	obj = {}
	return obj unless params?

	for param in params.split('&')
		splitAt = param.indexOf('=')
		key = param[...splitAt]
		value = param[splitAt + 1..]
		obj[key] = value
	
	return obj

@updateHashParameters = (params) ->
	newURL = "#/#{currentPage}?#{$.param(params)}"
	history.replaceState(null, null, newURL)

$(window).on 'hashchange', ->
	hash = window.location.hash.substr(2)
	[page, params] = hash.split('?')
	unless page is currentPage
		$('#main').load("./pages/#{page}.html")
		currentPage = page

window.location.hash = '#/home'
