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

	contains: (sourceID, recordID) ->
		return this._db({sourceID: sourceID, recordID: recordID}).count() > 0
	
	saveRecord: (sourceConnector, usRecord, files) ->
		sourceID = sourceConnector.source.id
		entry = {
			sourceID: sourceID
			recordID: usRecord.id
			usRecord: usRecord
		}
		if this.contains(sourceID, usRecord.id)
			this._db({sourceID: sourceID, recordID: usRecord.id}).update(entry)
		else
			this._db.insert(entry)

		console.log "TODO: download files #{files.toString()}."
		
		# Dump the database to the log for debugging
		console.log "Offline store state:"
		console.dir this._db().get()
