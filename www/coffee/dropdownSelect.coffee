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

###*
	Adds behaviour to a Bootstrap dropdown to make it behave like a <select>
	element (because <select> elements cannot be properly styled).

	The <div> should be a Bootstrap dropdown
	(http://getbootstrap.com/components/#dropdowns) with an element of class
	`.dropdownSelect_label` which will display the text of the selected option.
	When a menu item is clicked, the `data-value` attribute of the dropdown
	<div> will be set to the `data-value` attribute of the clicked item. If a
	menu item has no `data-value` attribute, it will be ignored.
###
$.fn.dropdownSelect = ->
	$dropdownSelect = this
	$label = this.find('.dropdownSelect_label')
	$menu = this.find('.dropdown-menu')
	$menu.find('li > a[data-value]').click ->
		$this = $(this)
		$dropdownSelect.attr('data-value', $this.attr('data-value'))
		$label.text($this.text())
	
	return this
