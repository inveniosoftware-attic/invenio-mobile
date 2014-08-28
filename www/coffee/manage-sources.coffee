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

$sourceList = $('#sourceList')
$sourceModal = $('#sourceModal')

sourceTemplate = jinja.compile($('#sourceTemplate').html())


# Page methods #

modalSourceID = null

displaySourceModal = (id) ->
	modalSourceID = id
	source = app.settings.getSourceByID(id)
	$sourceModal.find('.title').text(source.name)
	$sourceModal.find('.website').text(source.url)

	$sourceModal.find('.authStatus').text(
		if source.access_token
			"You are logged in to this source."
		else if source.authentication_url
			"You are not logged in to this source."
		else
			"This source does not support authentication."
	)

	if app.settings.getNumSources() is 1
		$sourceModal.find('.removeButton').hide()
		$sourceModal.find('.cannotRemoveNotice').show()
	else
		$sourceModal.find('.cannotRemoveNotice').hide()
		$sourceModal.find('.removeButton').show()

	$sourceModal.addClass('active')
	window.location.hash = '#sourceModal'

displaySources = ->
	$sourceList.empty()
	for source in app.settings.getSourceList()
		$sourceList.append(sourceTemplate.render(source))

	$sourceList.find('li > a').click(sourceClicked)

# Event handlers #

sourceClicked = ->
	displaySourceModal($(this).attr('data-source-id'))

$sourceModal.find('.closeButton').click -> history.back()

$sourceModal.find('.website').click ->
	window.open(app.settings.getSourceByID(modalSourceID).url, '_system')

$sourceModal.find('.removeButton').click ->
	app.settings.removeSource(modalSourceID)
	displaySources()
	history.back()

$(window).on 'hashchange', ->
	if window.location.hash is '#/manage-sources'
		$sourceModal.removeClass('active')


# On load #

displaySources()

