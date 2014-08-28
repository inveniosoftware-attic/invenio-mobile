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

$.fn.tabBar = (tabClickedCallback) ->
	###
	Adds functionality to a `Ratchet tab bar
	<http://goratchet.com/components/#bars>`.

	The element's ``data-target`` attribute should be a jQuery selector of the
	element into which content is loaded.

	Each tab's ``tab-item`` element should have a ``data-tab-href`` attribute,
	containing the URL of the tab's content. When a tab is clicked, its content
	will be loaded into the target element, and it will be set as the active
	tab. When the function is called, the content of the tab with the ``active``
	class will be loaded.
	###
	$tabBar = this
	$tabs = this.find('.tab-item')
	$target = $(this.attr('data-target'))

	go = (url) ->
		if $target.attr('data-current-tab-href') isnt url
			$target.load(url)
			$target.attr('data-current-tab-href', url)

	$tabs.click ->
		$this = $(this)
		go($this.attr('data-tab-href'))

		$tabs.removeClass('active')
		$this.addClass('active')

		tabClickedCallback($this.attr('data-tab-name')) if tabClickedCallback?

	go(this.find('.active').attr('data-tab-href'))

	return this
