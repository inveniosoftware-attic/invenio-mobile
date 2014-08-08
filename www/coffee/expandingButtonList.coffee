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
	Adds behaviour to an expanding button list, as can be found within the
	#sources div in pages/search.html. 
	
	The list items are placed in the descendant element with the class
	`.ebl_list`.
	
	@param {Object}   template
		The Jinja.js template to use to create the menu. The data will be
		passed as the `data` parameter.
	@param {Array}    data
		An array of objects to display in the list. The `name` value of each
		object will be used as its label.
	@param {number}   selectedIndex
		The index of the object to be initially selected.
	@param {function} callback
		A function to be called when the selection is changed. The first
		argument passed will be the index of the selected item.
###
$.fn.expandingButtonList = (template, data, selectedIndex, callback) ->
	$expandingButtonList = this
	$button = this.children('.ebl_button')
	$list = this.find('.ebl_list')

	$list.html(template.render(data: data, selected: selectedIndex))

	selectItem = (index) ->
		newLabel = data[index].name
		$button.find('.ebl_name').text(newLabel)

		$list.children('a[data-index]').removeClass('active')
		$list.children("a[data-index=#{index}]").addClass('active')

		selectedIndex = index

	selectItem(selectedIndex)

	$button.click ->
		$expandingButtonList.addClass('expanded')

	$list.find('a[data-index]').click ->
		$expandingButtonList.removeClass('expanded')

		index = parseInt($(this).attr('data-index'))
		if index != selectedIndex
			selectItem(index)
			callback(index)

	return this
