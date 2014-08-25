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

sCleanPath = (usPath) -> usPath.split('../').join('\\.\\./')

class Settings
	constructor: ->
		if localStorage['version']?
			this._sources = JSON.parse(localStorage['sources'])
			this._selectedSourceID = localStorage['selectedSourceID']
		else
			this.createDefaultSettings()

		console.log "Settings loaded."

	save: ->
		localStorage['version'] = app.version
		localStorage['sources'] = JSON.stringify(this._sources)
		localStorage['selectedSourceID'] = this._selectedSourceID

	createDefaultSettings: ->
		console.log "First run; creating default settings."
		this._sources = {
			'ch.cern.invenio-demo-next': {
				id: 'ch.cern.invenio-demo-next'
				name: "Atlantis Institute of Fictive Science"
			},
			'ch.cern.cds': {
				id: 'ch.cern.cds'
				name: "CDS"
			},
			'net.inspirehep': {
				id: 'net.inspirehep'
				name: "INSPIRE"
			},
			'org.ilo.labordoc': {
				id: 'org.ilo.labordoc'
				name: "Labordoc"
			},
		}
		this._selectedSourceID = 'ch.cern.invenio-demo-next'
		this.save()

	getSources: -> this._sources

	getSourceList: -> (this._sources[id] for id in Object.keys(this._sources))

	getSourceByID: (sourceID) -> this._sources[sourceID]

	getNumSources: -> Object.keys(this._sources).length

	getSelectedSource: ->
		return this._sources[this._selectedSourceID]

	setSelectedSource: (id) ->
		this._selectedSourceID = id
		localStorage['selectedSourceID'] = id
		return this.getSelectedSource()

	addSource: (source) ->
		this._sources[source.id] = source
		localStorage['sources'] = JSON.stringify(this._sources)

	removeSource: (id) ->
		delete this._sources[id]
		this.save()


class InvenioMobileApp
	version: '1.0.0 Beta'

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
		id: '__offline__'
		name: "On Device"
	}

	## Files ##

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

	removeFile: (usPath) ->
		sPath = sCleanPath(usPath)
		resolved = (entry) -> entry.remove()
		error = (e) -> console.error(JSON.stringify(e))
		window.resolveLocalFileSystemURL(sPath, resolved, error)

	removeDirectory: (usPath) ->
		sPath = sCleanPath(usPath)
		resolved = (entry) -> entry.removeRecursively()
		error = (e) -> console.error(JSON.stringify(e))
		window.resolveLocalFileSystemURL(sPath, resolved, error)

	## Other utility methods ##
	
	parseParamString: (params) ->
		obj = {}

		for param in params.split('&')
			splitAt = param.indexOf('=')
			key = param[...splitAt]
			value = param[splitAt + 1..]
			obj[key] = value
		
		return obj

$ -> FastClick.attach(document.body)

@app = new InvenioMobileApp()

## Hash and history handling ##

currentPage = null

###*
	@returns {Object} the parameters passed in the hash, as an object.
###
@parseHashParameters = ->
	[page, params] = window.location.hash.split('?')
	return if params? then app.parseParamString(params) else {}

@updateHashParameters = (params) ->
	newURL = "#/#{currentPage}?#{$.param(params)}"
	history.replaceState(null, null, newURL)

checkForBackButton = ->
	$('#backButton').click -> history.back()

$(window).on 'hashchange', ->
	return unless window.location.hash[1] is '/'
	hash = window.location.hash.substr(2)
	[page, params] = hash.split('?')
	unless page is currentPage
		$('#main').load "./pages/#{page}.html", ->
			currentPage = page
			checkForBackButton()

window.location.hash = '#/home'
