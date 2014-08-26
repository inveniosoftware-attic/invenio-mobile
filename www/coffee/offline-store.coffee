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

getStorageDirectory = ->
	return cordova.file.externalApplicationStorageDirectory + 'saved-files/'

class @OfflineStore
	constructor: (@taffyStoreName) ->
		this._db = TAFFY()
		this._db.store(taffyStoreName)

	getAllEntries: -> this._db().get()

	contains: (sourceID, recordID) ->
		return this._db({sourceID: sourceID, recordID: recordID}).count() > 0

	getEntry: (sourceID, recordID) ->
		entries = this._db({sourceID: sourceID, recordID: recordID}).get()
		if entries.length is 1
			return entries[0]
		else if entries.length is 0
			return null
		else
			throw new Error("#{entries.length} entries for ID #{recordID} from #{sourceID}.")

	removeEntry: (sourceID, recordID) ->
		this._db({sourceID: sourceID, recordID: recordID}).remove()

		app.removeDirectory("#{getStorageDirectory()}#{sourceID}/#{recordID}")

	saveRecord: (connector, usRecord, usFiles, successCallback, errorCallback) ->
		sourceID = connector.source.id

		oldEntry = this.getEntry(sourceID, usRecord.id)
		if oldEntry?
			for usFileName in oldEntry.usSavedFileNames
				if usFileName not in usFiles
					usPath = "#{getStorageDirectory()}#{sourceID}/#{usRecord.id}/#{usFileName}"
					app.removeFile(usPath)

			this._db({sourceID: sourceID, recordID: usRecord.id}).remove()

		entry = {
			sourceID: sourceID
			recordID: usRecord.id
			usRecord: usRecord
			usSavedFileNames: []
		}

		entryQuery = this._db.insert(entry)

		usPath = "#{getStorageDirectory()}#{sourceID}/#{usRecord.id}/"
		downloadRecursive = (index) ->
			if index >= usFiles.length
				successCallback()
				return

			usFileName = usFiles[index]
			success = ->
				entryQuery.update ->
					# Clone the array so that TaffyDB notices that it's changed.
					# This can be tidied when the TaffyDB GitHub issue #85 is
					# fixed. (https://github.com/typicaljoe/taffydb/issues/85)
					this.usSavedFileNames = this.usSavedFileNames.slice(0)
					this.usSavedFileNames.push(usFileName)
					return this

				downloadRecursive(index + 1)

			console.log "Downloading #{usFileName} (#{index})..."
			connector.downloadFile(usRecord.id, usFileName, usPath + usFileName, success,
				errorCallback)

		downloadRecursive(0)


class OfflineStoreConnector extends Connector
	## Instance methods ##

	compileQuery: (queryArray) ->

	performQuery: (query, sort, pageStart, pageSize, callback) ->

	getRecord: (id, callback, error) ->
		[sourceID, recordID] = id.split('/')
		entry = app.offlineStore.getEntry(sourceID, recordID)
		unless entry?
			error()
			return

		usRecord = entry.usRecord

		if usRecord.files?
			for usFile in usRecord.files
				usFile._availableOffline = (usFile.name in entry.usSavedFileNames)

		callback(usRecord)

	getFileURL: (recordID, fileName) ->

	# Overrides #

	getStorageDirectory: -> getStorageDirectory()

	openFile: (recordID, usFileName, fileType, errorCallback) ->
		usPath = "#{this.getStorageDirectory()}#{recordID}/#{usFileName}"

		app.openFile(usPath, fileType, (args...) -> errorCallback('open', args...))


registerConnector('offline', OfflineStoreConnector)
