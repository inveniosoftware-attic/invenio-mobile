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

$licenseModal = $('#licenseModal')
$websiteLink = $licenseModal.find('.website')
$licenseModalContent = $licenseModal.find('.license')

$('#appVersion').text(app.version)

$licenseModal.find('.closeButton').click ->
	history.back()

$websiteLink.click ->
	window.open($(this).attr('data-href'), '_system')

$('a[data-license]').on 'touchend', ->
		# `touchend` not `click` because `click` mysteriously fails on Android
	$this = $(this)
	$licenseModal.find('.title').text($this.text())
	if $this.attr('data-website')
		$websiteLink.attr('data-href', $this.attr('data-website')).show()
	else
		$websiteLink.hide()

	$licenseModal.find('.licenseName').text($this.attr('data-license-name'))
	$licenseModal.find('.license').load $this.attr('data-license'), ->
		$licenseModal.find('.content').scrollTop(0)
	
	$licenseModal.addClass('active')
	window.location.hash = '#licenseModal'

$(window).on 'hashchange', ->
	if window.location.hash is '#/about'
		$licenseModal.removeClass('active')
