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
	constructor: (@source) ->

	getStorageDirectory: -> cordova.file.externalApplicationStorageDirectory + 'cache/'

	###*
		Downloads a file from the source.

		@param {string} recordID       The record ID which the file belongs to.
		@param {string} usFilePath     The path of the file belonging to the record.
		@param {string} usDestination  The location at which to save the file.
	###
	downloadFile: (recordID, usFilePath, usDestination, success, error) ->
		sPath = sCleanPath(usDestination)

		if @source.access_token?
			options = {
				headers: {'Authorization': 'Bearer ' + @source.access_token}
			}

		fileTransfer = new FileTransfer()
		fileTransfer.download(this.getFileURL(recordID, usFilePath), sPath,
			success, error, false, options)

	###*
		Opens a file from the source.

		@param {string} recordID    The record ID which the file belongs to.
		@param {string} usFilePath  The path of the file belonging to the record.
		@param {string} fileType    The MIME type of the file.
	###
	openFile: (recordID, usFilePath, fileType, error) ->
		usPath = "#{this.getStorageDirectory()}#{this.source.id}/#{recordID}/#{usFilePath}"

		url = this.getFileURL(recordID, usFilePath)
		sPath = sCleanPath(usPath)

		open = (fileEntry) -> app.openFile(sPath, fileType, error)

		download = (e) =>
			this.downloadFile(recordID, usFilePath, sPath, open, error)

		window.resolveLocalFileSystemURL(sPath, open, download)


connectors = {}

@getConnector = (source) ->
	connectorClass = connectors[source.type ? 'invenio']
	if not connectorClass?
		# TODO: an error message
		console.error("No connector for source type #{source.type} is installed.")
		return

	return new connectorClass(source)

@registerConnector = (sourceType, connectorClass) ->
	connectors[sourceType] = connectorClass

