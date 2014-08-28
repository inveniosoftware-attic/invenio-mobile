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

$.fn.dropdown = ->
	###
	Adds functionality to a dropdown menu.

	The subelement with the attribute ``data-toggle="dropdown"`` will act as
	the dropdown toggle, and a list of ``<li>`` elements containing links will
	become the menu items.
	###
	$dropdown = this
	this.find('[data-toggle=dropdown]').click ->
		$dropdown.toggleClass('open')

	$dropdown.find('li > a').click ->
		return if $(this).parent().hasClass('disabled')
		$dropdown.removeClass('open')

	return this
