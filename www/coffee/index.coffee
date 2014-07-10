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

@go = (url) ->
	$('#main').load(url)

$ -> FastClick.attach(document.body)

@app = new InvenioMobileApp()
go('./pages/home.html')
