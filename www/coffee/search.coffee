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

## Source list ##

sourcesListTemplate = jinja.compile($('#sources_listTemplate').html())

app.onceSettingsLoaded ->
	[source, index] = app.settings.getSelectedSource()

	$('#sources').expandingButtonList(sourcesListTemplate,
		app.settings.getSourceList(), index,
		(i) -> app.settings.setSelectedSource(i))

## Clauses ##

clauseTemplate = jinja.compile($('#clauseTemplate').html())

addClause = ->
	$newClause = $(clauseTemplate.render())
	$newClause.appendTo('#clauses')

	$dropdown = $newClause.find('.dropdown')
	$dropdown.dropdown().dropdownSelect()

$('#addClauseButton').click(addClause)

addClause()

## Performing the query ##

createQueryJSON = ->
	array = []
	first = true
	for clause in $('#clauses .clause')
		$clause = $(clause)
		field = $clause.find('.dropdown').attr('data-value')
		array.push({
			operation: 'AND' unless first
			value: $clause.find('.clause_fieldValue').val()
			field: field if field isnt ''
		})
		first = false

	return array

$('#searchButton').click ->
	array = createQueryJSON()
	[source, index] = app.settings.getSelectedSource()
	connector = getConnector(source)
	query = connector.compileQuery(array)
	
	window.location.hash = "#/results?query=#{query}"
