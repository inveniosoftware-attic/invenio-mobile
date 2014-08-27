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
	###
	Provides methods for interacting with an offline record store.
	###
	
	constructor: (@taffyStoreName) ->
		###
		Creates an offline store, loading data from the database if it already
		exists.

		:param taffyStoreName: The name to give the store in ``localStorage``.
		:type taffyStoreName: string
		###
		this._db = TAFFY()
		this._db.store(taffyStoreName)

	getAllEntries: ->
		### :returns: Array -- A list of all entries in the store. ###
		return this._db().get()

	contains: (sourceID, recordID) ->
		###
		Checks whether a record has been saved in the store.

		:param sourceID: The ID of the source to which the record belongs.
		:type sourceID: string
		:param recordID: The ID of the record.
		:type recordID: string
		:returns: boolean -- ``true`` if the record has been saved.
		###
		return this._db({sourceID: sourceID, recordID: recordID}).count() > 0

	getEntry: (sourceID, recordID) ->
		###
		Returns the entry for a record in the store.

		:param sourceID: The ID of the source to which the record belongs.
		:type sourceID: string
		:param recordID: The ID of the record.
		:type recordID: string

		:returns:
			Object -- The entry for the record in the store (or ``null`` if the
			record is not stored). The entry has the following properties:

			``sourceID``
				The ID of the source to which the record belongs.
			``recordID``
				The ID of the record.
			``usRecord``
				The record itself.
			``usSavedFileNames``
				A list of the names of the files which have been saved with this
				record.
		###
		entries = this._db({sourceID: sourceID, recordID: recordID}).get()
		if entries.length is 1
			return entries[0]
		else if entries.length is 0
			return null
		else
			throw new Error("#{entries.length} entries for ID #{recordID} from #{sourceID}.")

	removeEntry: (sourceID, recordID) ->
		###
		Removes an entry from the store, and any files which were saved with it.

		:param sourceID: The ID of the source to which the record belongs.
		:type sourceID: string
		:param recordID: The ID of the record.
		:type recordID: string
		###
		this._db({sourceID: sourceID, recordID: recordID}).remove()

		app.removeDirectory("#{getStorageDirectory()}#{sourceID}/#{recordID}")

	saveRecord: (connector, usRecord, usFiles, successCallback, errorCallback) ->
		###
		Saves a record to the store, optionally downloading files.

		:param connector: The connector object to use.
		:type connector: Connector
		:param usRecord: The record to save.
		:type usRecord: Object
		:param usFiles: A list of file names to save with the record.
		:type usFiles: Array
		:param successCallback: A function to call when saving is complete.
		:type successCallback: function
		:param errorCallback:
			A function to call if an error occurs. The first argument will be a
			``FileTransferError`` object.

			see:: http://plugins.cordova.io/#/package/org.apache.cordova.file-transfer

		:type errorCallback: function
		###
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
	###
	Provides a connector-like interface for accessing offline records. Extends
	:class:`Connector`.
	###

	## Instance methods ##

	compileQuery: (queryArray) ->

	performQuery: (query, sort, pageStart, pageSize, callback) ->

	getRecord: (id, success, error) ->
		###
		Retrieves a record from the offline store, as JSON.

		:param id:
			The ID of the source to which the record originally belonged, and
			the record ID, separated by a slash, e.g. ``ch.cern.cds/55``.
		:type id: string
		:param success: A function to be called when the record is retrieved.
			The record is passed as the first argument.
		:type success: function
		:param error: A function to be called if an error occurs. The arguments
			are those passed by the jQuery.ajax function.
		:type error: function
		###
		[sourceID, recordID] = id.split('/')
		entry = app.offlineStore.getEntry(sourceID, recordID)
		unless entry?
			error()
			return

		usRecord = entry.usRecord

		if usRecord.files?
			for usFile in usRecord.files
				usFile._availableOffline = (usFile.name in entry.usSavedFileNames)

		success(usRecord)

	getFileURL: (recordID, fileName) ->

	# Overrides #

	getStorageDirectory: -> getStorageDirectory()

	openFile: (recordID, usFileName, fileType, errorCallback) ->
		###
		Opens a file which was saved offline. Parameters other than
		``recordID`` are the same as those on the :class:`Connector` class.

		:param recordID:
			The ID of the source to which the record originally belonged, and
			the record ID, separated by a slash, e.g. ``ch.cern.cds/55``.
		:type recordID: string 
		###
		usPath = "#{this.getStorageDirectory()}#{recordID}/#{usFileName}"

		app.openFile(usPath, fileType, (args...) -> errorCallback('open', args...))


registerConnector('offline', OfflineStoreConnector)
