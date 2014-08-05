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

sCleanPath = (usPath) -> usPath.split('../').join('\\.\\./')

class Settings
	constructor: ->
		if localStorage['version']?
			this._sources = JSON.parse(localStorage['sources'])
			this._selectedSourceIndex = parseInt(localStorage['selectedSourceIndex'])
		else
			this.createDefaultSettings()

		this._buildIDMap()

		console.log "Settings loaded."

	_buildIDMap: ->
		this._idMap = {}
		for source in this._sources
			this._idMap[source.id] = source

	save: ->
		localStorage['version'] = '0.0.0'
		localStorage['sources'] = JSON.stringify(this._sources)
		localStorage['selectedSourceIndex'] = this._selectedSourceIndex

	createDefaultSettings: ->
		console.log "First run; creating default settings."
		this._sources = [
			{
				id: 'ch.cern.invenio-demo-next'
				name: "Atlantis Institute of Fictive Science"
			},
			{
				id: 'ch.cern.cds'
				name: "CDS"
			},
			{
				id: 'net.inspirehep'
				name: "INSPIRE"
			},
			{
				id: 'org.ilo.labordoc'
				name: "Labordoc"
			},
		]
		this._selectedSourceIndex = 0
		this.save()

	getSourceList: -> this._sources

	getSourceByID: (sourceID) -> this._idMap[sourceID]

	getSelectedSource: ->
		return [this._sources[this._selectedSourceIndex], this._selectedSourceIndex]

	setSelectedSource: (index) ->
		this._selectedSourceIndex = index
		localStorage['selectedSourceIndex'] = index
		return this.getSelectedSource()

	addSource: (source) ->
		index = this._sources.push(source) - 1
		localStorage['sources'] = JSON.stringify(this._sources)
		this._buildIDMap()
		return index


class InvenioMobileApp
	constructor: ->
		this.bindEvents()
		this._settingsLoaded = false
		this._settingsLoadedEvent = new Event('settingsLoaded')

	# Bind any events that are required on startup. Common events are:
	# 'load', 'deviceready', 'offline', and 'online'.
	bindEvents: ->
		document.addEventListener('deviceready', this.onDeviceReady, false)

	## Settings ##

	onDeviceReady: =>
		console.log "Received deviceready event."

		this.offlineStore = new OfflineStore('offlineRecords')

		this.settings = new Settings()
		this._settingsLoaded = true
		document.dispatchEvent(this._settingsLoadedEvent)

	onceSettingsLoaded: (callback) ->
		if this._settingsLoaded
			callback()
		else
			$(document).on('settingsLoaded', callback)

	offlineSource: {
		type: 'offline'
		name: "On Device"
	}

	## Files ##
	
	downloadFile: (url, usPath, successCallback, errorCallback) ->
		sPath = sCleanPath(usPath)

		fileTransfer = new FileTransfer()
		fileTransfer.download(url, sPath, successCallback, errorCallback)
	
	###*
		Opens a file from the local file system.

		@param {string} usPath   The path of the file.
		@param {string} fileType The MIME type of the file.
	###
	openFile: (usPath, fileType, errorCallback) ->
		sPath = sCleanPath(usPath)

		console.log "Opening #{sPath}..."
		cordova.plugins.fileOpener2.open(sPath, fileType, error: errorCallback)
		# TODO: test on Android <4

	###*
		Opens a file, downloading it if it does not exist.

		@param {string} url       The URL from which to download the file.
		@param {string} usPath    The path at which to store the file on the device.
		@param {string} fileType  The MIME type of the file.
	###
	downloadAndOpenFile: (url, usPath, fileType, errorCallback) ->
		# TODO: remove old files from the cache directory
		sPath = sCleanPath(usPath)

		open = (fileEntry) => this.openFile(sPath, fileType, errorCallback)

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
