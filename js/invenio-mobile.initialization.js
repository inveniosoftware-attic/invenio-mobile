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

$( document ).on( "pageinit", function() {
	//
	// Initialization on the startup of the app
	// ========================================= 
	
	var page = $( this );
 	//navigator.splashscreen.show();
	// Active panel button
	$("#navbutton").on("vclick",function(event) {
		if($(".ui-panel-content-wrap-open").length==0){
			$( ".jqm-navmenu-panel" ).panel("open");
			$(".content-shadow").fadeIn(500);
		}
	});
	
	// Enable blue search bar
	$( this ).find( ".jqm-search ul.jqm-list" ).listview({
		globalNav: "docs",
		inset: true,
		theme: "d",
		dividerTheme: "d",
		icon: false,
		filter: true,
		filterReveal: true,
		filterPlaceholder: "Advanced search",
		autodividers: true,
		autodividersSelector: function ( li ) {
    		return "";
  		},
  		arrowKeyNav: true,
  		enterToNav: true,
  		highlight: true,
	});
	
	// Enable blue search bar event
	$(".jqm-search form").on("submit",function(){
		var param = $(".jqm-search input").val();
		while (param.indexOf("&")>=0)
				{
				   param = param.replace("&","AND");
				}
		window.location ="#page=search&domain="+config.id+"&q="+encodeURI(param);
	})
	
	// Remove jquery/browser limiation
	$.mobile.allowCrossDomainPages = true;
	$.mobile.pushStateEnabled = false;
	$.mobile.ajaxEnabled = false;
	$.mobile.ignoreContentEnabled=true;
	$.mobile.pushStateEnabled = false;
});

$( document ).on( "pageshow", ".jqm-demos:not(.ui-page-header-fixed)", function() {
	var page = $( this ), 
		panelInnerHeight = page.find( ".jqm-nav-panel.ui-panel-position-left" ).outerHeight() + 30,
		minPageHeight = $.mobile.getScreenHeight();

	if ( panelInnerHeight > minPageHeight ) {
		setTimeout(function() {
			page.css( "min-height", panelInnerHeight );
		}, 50 );
	}
});

function setDomainInMenu(domain){
	 
	// Set the domain in the menus
	// ===================================================
	if(domain.enable){
		selected = ""
		if(domain.id==INVENIO_INITIAL_DOMAIN_ID)
			selected = ' select ';
		$("#domain-list ul").append('<a href="#page=home&domain='+domain.id+'" class="domain_link"><li class="'+selected+'list-domain-'+domain.id+'"><img src="img/'+domain.favicon+'" width="16" height="16"><span>'+domain.name+'</span></li></a>');
		$(".list-service").after('<li> <a href="#page=home&domain='+domain.id+'" rel="external"><div class="account_default account_'+domain.id+' panel-item-icon"></div>'+domain.name+'</a> </li>');
		$(".jqm-list").listview('refresh');
	}
}

function loadPersonalDomainFile() {
	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onPersonalDomainFileSuccess, onPersonalDomainFileFail);
}
function onPersonalDomainFileSuccess(fileSystem) {
	//Read only the recorder folder
	var directoryReader = fileSystem.root.createReader();
	directoryReader.readEntries(
		function(entries){
			for(var i=0; i<entries.length; ++i){ 
			var entry = entries[i];
			if( entry.isDirectory && entry.name == 'Invenio' )
				foundPersonalDomainFile(entry);
			}
		}
	)
}

function onPersonalDomainFileFail(evt) {
	console.log(evt.target.error.code);
}
function foundPersonalDomainFile(directoryEntry){ 
   	if( !directoryEntry.isDirectory ) console.log('listDir incorrect type');
			
	var directoryReader = directoryEntry.createReader();
	directoryReader.readEntries(
		function(entries){			
			for(var i=0; i<entries.length; ++i){ // sort entries
			var entry = entries[i];
			if( entry.isFile && entry.name[0] != '.' ) 
			{
				if(entry.name=="settings.domain.json")
				{
				$.ajax({ url: entry.fullPath, dataType: 'json',error: function(error){console.log( error );} ,success: function (response)					{	
					sessionStorage.personalDomains = JSON.stringify(response);
					$(response).each(function(i,v){
						
						setDomainInMenu(v);
					});
					}
				});
				}
			}
			}
		}
	);
}
function globalInit(){
	//
	// Initialization on the startup (after pageInit Event)
	// return the device configuration
	// =====================================================
	
	//navigator.splashscreen.show();
	
	// Display the resquest in the Search bar
	if(sessionStorage.q)
		$(".search-zone .ui-input-text").val(unescape(sessionStorage.q));

	loadSettings();
	// Load Default domain list
	jsonURL =  window.location.pathname.split( "docs" )[0];
	jsonURL = jsonURL.split( "index." )[0] + "js" + "/invenio-mobile.domain.json";
	var config = "";
	$.ajax({ url: jsonURL, async: false, dataType: 'json',success: function (response) {
		sessionStorage.domains=JSON.stringify(response.domain);
		$(response.domain).each(function(i,v){
			if(v.id==INVENIO_INITIAL_DOMAIN_ID){
				config=v;	
				$(".domain_name").html(v.name); 
				sessionStorage.domain =INVENIO_INITIAL_DOMAIN_ID;
			}
			setDomainInMenu(v);
		}); 
	  }
	});
	
	document.addEventListener("deviceready", loadPersonalDomainFile, false);
	
	// Enable autocomplete detection
	$( ".autocomplete" ).on( "listviewbeforefilter", function ( e, data ) {	
		var $input = $( data.input ),
		value = $input.val();
		autocomplete($input.val());
	});
	
	// Enable swipe right detection
	$(".jqm-header").on("swiperight", function() {
		event.stopImmediatePropagation();
		$( ".onPressDown").removeClass("onPressDown");
		$( ".jqm-navmenu-panel" ).panel("open");
		$(".content-shadow").fadeIn(500);
	})

	
	
	return config;
}


