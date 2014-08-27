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
	### Manages the storage of settings in ``localStorage``. ###

	constructor: ->
		if localStorage['version']?
			this._sources = JSON.parse(localStorage['sources'])
			this._selectedSourceID = localStorage['selectedSourceID']
		else
			this._createDefaultSettings()

		console.log "Settings loaded."

	_createDefaultSettings: ->
		###
		Changes the settings to the defaults and saves them.
		###
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

	save: ->
		###
		Saves changes that have been made to any of the stored source objects.
		It is automatically called when changes are made using any of the
		methods of the :class:`Settings` object.
		###
		localStorage['version'] = app.version
		localStorage['sources'] = JSON.stringify(this._sources)
		localStorage['selectedSourceID'] = this._selectedSourceID

	getSources: ->
		###
		:returns: Object -- a dictionary of the saved sources, where the keys
			are the source IDs.
		###
		return this._sources

	getSourceList: ->
		### :returns: Array -- a list of the saved sources. ###
		return (this._sources[id] for id in Object.keys(this._sources))

	getSourceByID: (sourceID) ->
		###
		Get a saved source by its ID.

		:param sourceID: a string identifying the source, typically in reverse
			domain name notation.
		:type sourceID: string
		:returns: Object
		###
		return this._sources[sourceID]

	getNumSources: ->
		### :returns: number -- the number of saved sources. ###
		return Object.keys(this._sources).length

	getSelectedSource: ->
		### :returns: Object -- the currently selected source. ###
		return this._sources[this._selectedSourceID]

	setSelectedSource: (id) ->
		###
		Selects a source as the one currently in use.

		:param id: the ID of the source to select.
		:type id: string
		:returns: Object -- the newly selected source.
		###
		this._selectedSourceID = id
		localStorage['selectedSourceID'] = id
		return this.getSelectedSource()

	addSource: (source) ->
		###
		Saves a source for use by the application.
		:param source: the source to save.
		:type source: Object
		###
		this._sources[source.id] = source
		localStorage['sources'] = JSON.stringify(this._sources)

	removeSource: (id) ->
		###
		Removes a source.
		:param id: the ID of the source to remove.
		:type id: string
		###
		delete this._sources[id]
		this.save()


class InvenioMobileApp
	###
	Provides utility methods for the rest of the application, and loads
	settings.

	All paths passed to file system utility methods are checked for directory
	traversal attacks before use.
	###

	version: '1.0.0 Beta'

	constructor: ->
		document.addEventListener('deviceready', this._onDeviceReady, false)
		this._settingsLoaded = false
		this._settingsLoadedEvent = new Event('settingsLoaded')

	## Settings ##

	_onDeviceReady: =>
		console.log "Received deviceready event."

		this.offlineStore = new OfflineStore('offlineRecords')

		this.settings = new Settings()
		this._settingsLoaded = true
		document.dispatchEvent(this._settingsLoadedEvent)

	onceSettingsLoaded: (callback) ->
		###
		Calls a function when the application's settings have loaded.

		:param callback: the function to call.
		:type callback: function
		###
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

	openFile: (usPath, fileType, errorCallback) ->
		###
		Opens a file from the local file system.

		:param usPath: The path of the file.
		:type usPath: string
		:param fileType: The MIME type of the file.
		:type fileType: string
		###
		sPath = sCleanPath(usPath)

		console.log "Opening #{sPath}..."
		cordova.plugins.fileOpener2.open(sPath, fileType, error: errorCallback)
		# TODO: test on Android <4

	removeFile: (usPath) ->
		###
		Deletes a file from the file system.

		:param usPath: the path of the file to delete.
		:type usPath: string
		###
		sPath = sCleanPath(usPath)
		resolved = (entry) -> entry.remove()
		error = (e) -> console.error(JSON.stringify(e))
		window.resolveLocalFileSystemURL(sPath, resolved, error)

	removeDirectory: (usPath) ->
		###
		Deletes a directory from the file system.

		:param usPath: the path of the directory to delete.
		:type usPath: string
		###
		sPath = sCleanPath(usPath)
		resolved = (entry) -> entry.removeRecursively()
		error = (e) -> console.error(JSON.stringify(e))
		window.resolveLocalFileSystemURL(sPath, resolved, error)

	## Other utility methods ##
	
	parseParamString: (params) ->
		###
		Turn a URL query string into a object of parameters.

		:param params: the query string to parse.
		:type params: string
		:return: Object -- keys and values of the parameters.
		###
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

@parseHashParameters = ->
	###
	:returns: Object -- the parameters passed in the URL hash, as an object.
	###
	[page, params] = window.location.hash.split('?')
	return if params? then app.parseParamString(params) else {}

@updateHashParameters = (params) ->
	###
	Updates the parameters in the URL hash from an object, overwriting the
	current entry in the browser's history.

	:param params: the keys and values of the parameters.
	:type params: Object
	###
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
