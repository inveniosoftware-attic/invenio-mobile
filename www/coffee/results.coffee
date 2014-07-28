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

displayResults = (usData) ->
	# Hungarian notation: variables prefixed with `us` contain unsafe data.
	# `s` variables are safe.
	# See http://joelonsoftware.com/articles/Wrong.html
	
	sGenerateClassAttr = (usClasses) ->
		return '' unless usClasses? and usClasses.length > 0
		if typeof usClasses is 'string'
			return 'result_' + escape(usClasses)
		else
			return ('result_' + escape(usClass) for usClass in usClasses).join(' ')

	sCleanField = (usField) -> usField.split('\'').join('')

	sItemLines = ""
	for usLine in usData.lines
		sClassAttr = sGenerateClassAttr(usLine.classes)
		sField = sCleanField(usLine.field)

		sFilter = if filters[usLine.filter]? then usLine.filter

		sItemLines += if sFilter?
				"<div class='#{sClassAttr}'>{{result['#{sField}'] | #{sFilter}}}</div>"
			else
				"<div class='#{sClassAttr}'>{{result['#{sField}']}}</div>"

	itemsTemplate = jinja.compile("""
		{% for result in results %}
		<a class="listItem list-group-item" href="#/record?id={{result.id}}">
			<div class="title">{{result.title}}</div>
			#{sItemLines}
		</a>
		{% endfor %}
		""")

	$resultsList.html(itemsTemplate.render(usData, filters: filters))

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
