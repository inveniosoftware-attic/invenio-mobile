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

$sourceName = $('#sourceName')
$sourcesList = $('#sourcesList')
$queryTextBox = $('#queryTextBox')
$spinner = $('.spinner')
$scrollPane = $('#scrollPane')
$resultsList = $('#resultsList')

sourcesListTemplate = jinja.compile($('#sources_listTemplate').html())


# Page methods #

initSourcesPopover = (callback) ->
	source = app.settings.getSelectedSource()
	sources = app.settings.getSourceList()

	$sourceName.text(source.name)
	$sourcesList.html(sourcesListTemplate.render(data: sources, selected: source.id))
	$sourcesList.find('a[data-source-id]').click ->
		id = $(this).attr('data-source-id')
		if source.id != id
			source = app.settings.setSelectedSource(id)
			$sourceName.text(source.name)
			callback(id)

		# Hide the popover
		$('.backdrop')[0].dispatchEvent(new CustomEvent('touchend'))

filters = {
	# DO NOT add `safe` to this object.
	date: (dateString) -> new Date(dateString).toLocaleDateString()
	joinList: (list) -> list.join("; ")
}

displayResults = (usResults, usLines) ->
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
	for usLine in usLines
		sClassAttr = sGenerateClassAttr(usLine.classes)
		sField = sCleanField(usLine.field)

		sFilter = if filters[usLine.filter]? then usLine.filter

		sItemLines += if sFilter?
				"<div class='#{sClassAttr}'>{{result['#{sField}'] | #{sFilter}}}</div>"
			else
				"<div class='#{sClassAttr}'>{{result['#{sField}']}}</div>"

	itemsTemplate = jinja.compile("""
		<li class="listItem table-view-cell">
			<a href="#/record?id={{result.id}}" data-ignore="push">
				<div class="listItem_title">{{result.title}}</div>
				#{sItemLines}
			</a>
		</li>
		""")

	for usResult in usResults
		$resultsList.append(itemsTemplate.render({result: usResult}, filters: filters))

displayError = (message) ->
	$spinner.text "Could not fetch results: #{message}"
	$spinner.show()


# Logic #

PAGE_SIZE = 50

params = parseHashParameters()
params.sort ?= 'date'

loading = false
numResults = 0
nextPageStart = 0

getSearchResults = (first) ->
	$spinner.show()
	loading = true

	success = (usResults, usLines, paging) ->
		displayResults(usResults, usLines)

		numResults = paging.count
		nextPageStart = paging.pageStart + usResults.length

		loading = false
		$spinner.hide()

	error = (jqXHR, textStatus, errorThrown) ->
		console.error "Could not fetch results: #{JSON.stringify(jqXHR)}"
		displayError "#{errorThrown} (#{jqXHR.status})"

	source = app.settings.getSelectedSource()
	connector = getConnector(source)
	connector.performQuery(params.query, params.sort, first, PAGE_SIZE, success, error)

doSearch = ->
	$resultsList.empty()
	$queryTextBox.val(params.query)

	nextPageStart = 0
	getSearchResults(nextPageStart)

loadNextPage = ->
	if nextPageStart < numResults
		console.log "Scrolled to bottom, loading more results"
		getSearchResults(nextPageStart)
	else
		console.log "No more results."


# Event handlers #

sourceChanged = (id) ->
	doSearch()

sortOptionClicked = (value) ->
	params.sort = value
	doSearch()
	updateHashParameters(params)

$queryTextBox.keypress (e) ->
	if e.which is 13 or e.keyCode is 13
		params.query = $queryTextBox.val()
		updateHashParameters(params)
		doSearch()

$scrollPane.scroll ->
	if $scrollPane.scrollTop() + $scrollPane.innerHeight() >= $scrollPane.prop('scrollHeight')
		loadNextPage() unless loading


# On load #

$('#sortDropdown').dropdown().dropdownSelect(sortOptionClicked)
$('#sortDropdown ul').find("a[data-value=#{params.sort}]").parent().addClass('active')

app.onceSettingsLoaded ->
	doSearch()

	initSourcesPopover(sourceChanged)
