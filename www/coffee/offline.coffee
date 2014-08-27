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

# Page elements #

$recordList = $('#recordList')
recordTemplate = jinja.compile($('#recordTemplate').html())


# Page methods #

filters = {
	sourceIDToName: (sourceID) -> app.settings.getSourceByID(sourceID).name
}

displayEntries = (entries) ->
	if entries.length > 0
		$recordList.empty()
		for entry in entries
			$recordList.append(recordTemplate.render(entry, filters: filters))
	else
		$('.emptyListMessage').show()


# On load #

app.onceSettingsLoaded ->
	compareTitles = (a, b) -> a.usRecord.title > b.usRecord.title
	entries = app.offlineStore.getAllEntries().sort(compareTitles)
	displayEntries(entries)
