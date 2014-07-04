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

function loadSettings(){
	
	//default value;
	sessionStorage.debugMode = "false";
	sessionStorage.displaylist = "rich";	
	
	// Wait for Cordova to load
    document.addEventListener("deviceready", loadSettingsFile, false);
}

// Cordova is ready
function loadSettingsFile() {
	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onSettingsFileSuccess, onSettingsFileFail);
}

function onSettingsFileSuccess(fileSystem) {
	//Read only the recorder folder
	var directoryReader = fileSystem.root.createReader();
	directoryReader.readEntries(
		function(entries){
			for(var i=0; i<entries.length; ++i){ 
			var entry = entries[i];
			if( entry.isDirectory && entry.name == 'Invenio' )
				foundSettingFile(entry);
			}
		}
	)
}

function onSettingsFileFail(evt) {
	console.log(evt.target.error.code);
}
	
function foundSettingFile(directoryEntry){ 
   	if( !directoryEntry.isDirectory ) console.log('listDir incorrect type');
			
	var directoryReader = directoryEntry.createReader();
	directoryReader.readEntries(
		function(entries){			
			for(var i=0; i<entries.length; ++i){ // sort entries
			var entry = entries[i];
			if( entry.isFile && entry.name[0] != '.' ) 
			{
				if(entry.name=="settings.json")
				{
				$.ajax({ url: entry.fullPath, dataType: 'json',error: function(error){console.log( error );} ,success: function (response)
					{	
						if(response.debugMode) sessionStorage.debugMode = response.debugMode;
						if(response.displaylist) sessionStorage.displaylist = response.displaylist;
					}
				});
				}
			}
			}
		}
	);
}

function SaveSettings(){
	var c = {};
	c['debugMode']=sessionStorage.debugMode;
	c['displaylist']=sessionStorage.displaylist;
	
	var content = JSON.stringify(c);
	writeFile("./Invenio/","settings.json", content);
}
