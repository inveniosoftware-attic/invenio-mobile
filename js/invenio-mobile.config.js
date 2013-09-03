/*
    ## This file is part of Invenio.
    ## Copyright (C) 2012, 2013 CERN.
    ##
    ## Invenio is free software; you can redistribute it and/or
    ## modify it under the terms of the GNU General Public License as
    ## published by the Free Software Foundation; either version 2 of the
    ## License, or (at your option) any later version.
    ##
    ## Invenio is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details.
    ##
    ## You should have received a copy of the GNU General Public License
    ## along with Invenio; if not, write to the Free Software Foundation, Inc.,
    ## 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/

// JavaScript Document

var INVENIO_DEVICE_NAME = "";
var INVENIO_DEVICE_TYPE = "";
var INVENIO_CACHE_DURATION = 24;
var INVENIO_INITIAL_DOMAIN_ID = "cds";


if(INVENIO_DEVICE_NAME == "" || INVENIO_DEVICE_TYPE == "")
{
	//test id save in the session
	if(sessionStorage.INVENIO_DEVICE_NAME && sessionStorage.INVENIO_DEVICE_TYPE)
	{
		INVENIO_DEVICE_NAME = sessionStorage.INVENIO_DEVICE_NAME;
		INVENIO_DEVICE_TYPE = sessionStorage.INVENIO_DEVICE_TYPE;
	}	
	else 
	{
		var nav = navigator.userAgent;
		if(/iPhone/i.test(nav)){
			INVENIO_DEVICE_NAME = "iphone";
			INVENIO_DEVICE_TYPE = "phone";
		}
		else if(/iPad/i.test(nav)){
			INVENIO_DEVICE_NAME = "ipad";
			INVENIO_DEVICE_TYPE = "tablet";
		}
		else{
		INVENIO_DEVICE_NAME = "android";
		INVENIO_DEVICE_TYPE = "phone";
		}
		 
		
		sessionStorage.INVENIO_DEVICE_NAME = INVENIO_DEVICE_NAME;
		sessionStorage.INVENIO_DEVICE_TYPE = INVENIO_DEVICE_TYPE;
	}
}



