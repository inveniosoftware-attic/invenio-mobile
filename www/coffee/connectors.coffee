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

class @Connector
	###
	Base class for Connector objects.
	###

	constructor: (@source) ->
		###
		Creates a new Connector for a source object.

		:param source: the source object.
		:type source: Object
		###

	getStorageDirectory: ->
		### :returns: string -- The directory the source stores files in. ###
		return cordova.file.externalApplicationStorageDirectory + 'cache/'

	downloadFile: (recordID, usFileName, usDestination, success, error) ->
		###
		Downloads a file from the source.

		:param recordID: The record ID which the file belongs to.
		:type recordID: string
		:param usFileName: The name of the file.
		:type usFileName: string
		:param usPath: The location at which to save the file.
		:type usPath: string
		###
		sPath = sCleanPath(usDestination)

		if @source.access_token?
			options = {
				headers: {'Authorization': 'Bearer ' + @source.access_token}
			}

		fileTransfer = new FileTransfer()
		fileTransfer.download(this.getFileURL(recordID, usFileName), sPath,
			success, error, false, options)

	openFile: (recordID, usFileName, fileType, errorCallback) ->
		###
		Opens a file from the source.

		:param recordID: The record ID which the file belongs to.
		:type recordID: string 
		:param usFileName: The name of the file.
		:type usFileName: string
		:param fileType: The MIME type of the file.
		:type fileType: string
		:param errorCallback:
			A function to call if an error occurs.
			
			If the error occurs when downloading the file, the first parameter
			will be ``download`` and the second a ``FileTransferError``.

			If the error occurs when opening the file, the first parameter will
			be ``open`` and the second an object with a ``message`` field.

			see:: http://plugins.cordova.io/#/package/org.apache.cordova.file-transfer
		:type errorCallback: function
		###
		usPath = "#{this.getStorageDirectory()}#{this.source.id}/#{recordID}/#{usFileName}"

		url = this.getFileURL(recordID, usFileName)
		sPath = sCleanPath(usPath)

		error = (type) -> (args...) -> errorCallback(type, args...)

		open = (fileEntry) -> app.openFile(sPath, fileType, error('open'))

		download = (e) =>
			this.downloadFile(recordID, usFileName, sPath, open, error('download'))

		window.resolveLocalFileSystemURL(sPath, open, download)


connectors = {}

@getConnector = (source) ->
	###
	Get a :class:`Connector` object for the given source.

	:param source: The source to get a connector for.
	:type source: Object
	:returns: Connector -- a :class:`Connector` for the source.
	:throws Error: if no connector has been registered for the source type.
	###
	connectorClass = connectors[source.type ? 'invenio']
	if not connectorClass?
		throw new Error("No connector for source type #{source.type} is installed.")

	return new connectorClass(source)

@registerConnector = (sourceType, connectorClass) ->
	###
	Register a class as a connector object.

	:param sourceType: the source type which this connector class handles.
	:type sourceType: string
	:param connectorClass: the connector class.
	:type connectorClass: Connector
	###
	connectors[sourceType] = connectorClass

