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

$.fn.dropdownSelect = (callback) ->
	###
	Adds behaviour to a dropdown to make it behave like a <select> element.

	The <div> should have an element of class ``dropdownSelect_label`` which will
	display the text of the selected option, and an element of class
	``dropdownMenu`` containing the menu items. When a menu item is clicked, the
	``data-value`` attribute of the dropdown <div> will be set to the that of the
	clicked item. If a menu item has no ``data-value`` attribute, it will be
	ignored.
	###
	$dropdownSelect = this
	$label = this.find('.dropdownSelect_label')
	$menu = this.find('.dropdownMenu')
	$optionLinks = $menu.find('li > a[data-value]')
	$optionLinks.click ->
		$this = $(this)
		value = $this.attr('data-value')

		$dropdownSelect.attr('data-value', value)
		$label.text($this.text())

		$optionLinks.parent().removeClass('active')
		$this.parent().addClass('active')

		callback(value) if callback?
	
	return this
