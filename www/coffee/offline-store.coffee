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

class @OfflineStore
	constructor: (@taffyStoreName) ->
		this._db = TAFFY()
		this._db.store(taffyStoreName)

	getAllEntries: -> this._db().get()

	contains: (sourceID, recordID) ->
		return this._db({sourceID: sourceID, recordID: recordID}).count() > 0

	usGetEntry: (sourceID, recordID) ->
		entries = this._db({sourceID: sourceID, recordID: recordID}).get()
		if entries.length is 1
			return entries[0]
		else
			console.error "#{entries.length} entries for ID #{recordID} from #{sourceID}."
	
	saveRecord: (connector, usRecord, usFiles, successCallback, errorCallback) ->
		sourceID = connector.source.id
		entry = {
			sourceID: sourceID
			recordID: usRecord.id
			usRecord: usRecord
			usSavedFilePaths: []
		}
		if this.contains(sourceID, usRecord.id)
			entryQuery = this._db({sourceID: sourceID, recordID: usRecord.id}).update(entry)
		else
			entryQuery = this._db.insert(entry)

		usPath = "#{cordova.file.externalDataDirectory}#{sourceID}/#{usRecord.id}/"
		downloadRecursive = (index) ->
			if index >= usFiles.length
				successCallback()
				return

			usFilePath = usFiles[index]
			success = ->
				entryQuery.update(-> this.usSavedFilePaths.push(usFilePath))
				downloadRecursive(index + 1)

			console.log "Downloading #{usFilePath} (#{index})..."
			app.downloadFile(connector.getFileURL(usRecord.id, usFilePath),
					usPath + usFilePath, success, errorCallback)

		downloadRecursive(0)


class OfflineStoreConnector extends Connector
	## Instance methods ##

	compileQuery: (queryArray) ->

	performQuery: (query, sort, pageStart, pageSize, callback) ->

	getRecord: (id, callback) ->
		[sourceID, recordID] = id.split('/')
		entry = app.offlineStore.usGetEntry(sourceID, recordID)
		usRecord = entry.usRecord

		for usFile in usRecord.files
			usFile._availableOffline = (usFile.path in entry.usSavedFilePaths)

		callback(usRecord)

	getFileURL: (recordID, fileName) ->

	# Overrides #

	getStorageDirectory: -> cordova.file.externalDataDirectory

	openFile: (recordID, usFilePath, fileType, errorCallback) ->
		usPath = "#{this.getStorageDirectory()}#{recordID}/#{usFilePath}"

		app.openFile(usPath, fileType, errorCallback)


registerConnector('offline', OfflineStoreConnector)
