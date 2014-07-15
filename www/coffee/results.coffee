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

$queryBar = $('#queryBar')
$spinner = $('#spinner')
$resultsList = $('#resultsList')

displayResults = (data) ->
	itemLines = ""
	for classes, i in data.lineStyles
		if typeof classes is 'string'
			classAttr = if classes.length > 0 then 'record_' + escape(classes) else ''
		else
			classAttr = ('record_' + escape(cssClass) for cssClass in classes).join(' ')

		itemLines += "<div class='#{classAttr}'>{{record.lines[#{i}]}}</div>"

	itemsTemplate = jinja.compile("""
		{% for record in records %}
		<a class="record list-group-item" href="javascript:;">
			<div class="title">{{record.title}}</div>
			#{itemLines}
		</a>
		{% endfor %}
		""")

	$resultsList.html(itemsTemplate.render(data))

doSearch = (source, query) ->
	$resultsList.hide()
	$queryBar.text(query)
	$spinner.show()

	connector = getConnector(source)
	connector.performQuery query, (data) ->
		displayResults(data)

		$spinner.hide()
		$resultsList.show()

params = parseHashParameters()
query = params.query
app.onceSettingsLoaded ->
	source = app.sources[app.selectedSourceIndex]
	doSearch(source, query)

## Sources dropdown ##

sourcesListTemplate = jinja.compile($('#sources_listTemplate').html())

selectedSourceIndex = null

app.onceSettingsLoaded ->
	selectedSourceIndex = app.selectedSourceIndex

	$('#sources').expandingButtonList(sourcesListTemplate, app.sources, selectedSourceIndex, (index) ->
		selectedSourceIndex = index
		app.setSelectedSourceIndex(index)

		source = app.sources[index]
		doSearch(source, query)
	)

	$('#sources_add').click ->
		# TODO
