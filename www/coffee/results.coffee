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

filters = {
	# DO NOT add `safe` to this object.
	date: (dateString) -> new Date(dateString).toLocaleDateString()
	joinList: (list) -> list.join("; ")
}

displayResults = (data) ->
	cleanField = (field) ->
		return field.split('\'').join('')

	itemLines = ""
	for line in data.lines
		if line.classes? and line.classes.length > 0
			classAttr = if typeof line.classes is 'string'
					'result_' + escape(line.classes)
				else
					('result_' + escape(cssClass) for cssClass in line.classes).join(' ')
		else
			classAttr = ''

		field = cleanField(line.field)

		filter = if filters[line.filter]? then line.filter

		itemLines += if filter?
				"<div class='#{classAttr}'>{{result['#{field}'] | #{filter}}}</div>"
			else
				"<div class='#{classAttr}'>{{result['#{field}']}}</div>"

	itemsTemplate = jinja.compile("""
		{% for result in results %}
		<a class="listItem list-group-item" href="#/record?id={{result.id}}">
			<div class="title">{{result.title}}</div>
			#{itemLines}
		</a>
		{% endfor %}
		""")

	$resultsList.html(itemsTemplate.render(data, filters: filters))

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
