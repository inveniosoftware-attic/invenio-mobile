$(window).on("hashchange",function(){
						

	$(".jqm-content").off("scroll");
	if(preventBack && hashParam("page")!="record"){
		if(!confirm("If you leave the recording will be canceled. Do you want to leave?"))
		{ 
			history.forward();
			return 0;
		}
	}
	else if(preventBack && hashParam("page")=="record")
	{
		$(".back2Shadow").removeClass("back2Shadow");
		return 0;
	}
	preventBack =false;
	$("#domain-list").hide();
	if($(".ui-panel-content-wrap-open").is(":visible"))
		$( ".jqm-navmenu-panel" ).panel("close");
	var page = hashParam("page");

	if(hashParam("domain") && sessionStorage.domain && hashParam("domain")!=sessionStorage.domain)
	{
		changedomain(hashParam("domain"));

		// if change domain but keep a request	
		if(sessionStorage.page && sessionStorage.page=="search" && hashParam("page")=="home"){
			document.location.href= "#page=search&domain="+hashParam("domain")+"&q="+encodeURI(sessionStorage.q);
			sessionStorage.domain = hashParam("domain");
			//$(document).trigger("hashchange");
			return 0;
		}
		sessionStorage.domain = hashParam("domain");
	}
	sessionStorage.page = page;
	if(page && page!="home")
	{	
		sessionStorage.rm  ="";
		sessionStorage.q = "";
		if(hashParam("q"))
			sessionStorage.q = decodeURI(hashParam("q"));
		else if(hashParam("f")&& hashParam("p"))
			sessionStorage.q =hashParam("f")+':"'+hashParam("p")+'"';

		if(hashParam("rec"))
			sessionStorage.rec = decodeURIComponent(hashParam("rec"));
		if(hashParam("file"))
			sessionStorage.file = decodeURIComponent(hashParam("file"));
		if(hashParam("rm"))
			sessionStorage.rm = hashParam("rm");
		if(hashParam("title"))
			sessionStorage.title = decodeURIComponent(hashParam("title"));
		if(hashParam("folder"))
			sessionStorage.folder = decodeURIComponent(hashParam("folder"));	
		loadLink("./pages/"+page+".html");
	}
	else
	{	
		loadLink("./pages/home.html");
	}
	
})
$(window).on("orientationchange", function(){
	//document.location.reload(true);
	changeWindowsHeight();
	
});


function cleanALL(id_content){
	cleanScript(id_content)
	cleanURL(id_content)
}


function cleanScript(id_content){
	
	$(id_content).find("script").each(function(index, element) {
        element.remove();
    });
	
	//reload content and ignor script
    $(id_content).html($(id_content).html());
}
function cleanURL(id_content){
	//find all link
	$(id_content+' a[href]').each(function()
	{
		if(this.href.indexOf("/search?")>=0)
		{	
		//search link
			var query = this.href.split("search?")[1]
			
			
			$(this).on("click", function(){
				sessionStorage.q =$.urlParam("f",this.href)+":"+$.urlParam("p",this.href);
				});
			this.href = "#page=search&"+query;
			this.rel = "external";
			
		}
		else if(this.href.indexOf("/record/")>=0)
		{	
			if(this.href.indexOf(".jpg")>=0 || this.href.indexOf(".jpeg")>=0 || this.href.indexOf(".webm")>=0)
			{	
				//don't change
			}
			else
			{
				this.href = "#page=record&rec="+encodeURIComponent("http://"+config.domain+"/record/"+this.href.split("/record/")[1]);
			}
			
		}
		else
		{
			this.href="";
		}
	});
}
function replaceAll(text,before,after){
	while(text.indexOf(before)>0)
	 	text =text.replace(before,after);
	return text;
}
function cleanFileName(name){
	name = $.trim(name);
	name = replaceAll(name,"%","");
	name = replaceAll(name,"&nbsp;","");	
	name = replaceAll(name," ","");	
	return name;
}

function removeFolder(folder){
	folder.removeRecursively(successRemoveFolder, failRemoveFolder);
	function successRemoveFolder(entry) {
			console.log("Removal folder succeeded");
	}
	
	function failRemoveFolder(error) {
		console.log('Error removing folder: ' + error.code);
	}
}

function httpURL(){
	var base = $( "base" ).attr( "href" ).split( "docs" )[0];
	return base.split( "index." )[0] + "docs" + "/";
}
function httpsURL(){
	return httpURL().replace("http:","https:");
}

// urlParam
$.urlParam = function(parm, url){
	if(!url) url = 	window.location.href ;
	parm = parm.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");  
	var regexS = "[\\?&]"+parm+"=([^&#]*)";  
	var regex = new RegExp( regexS );  
	var results = regex.exec( url ); 
	 if( results == null )    return "";  
	else    return results[1];
}

// Hash tag Param
function hashParam(parm, url){
	if(!url) url = 	location.hash ;
	
	if(url.indexOf("#")<0)
		return false;
	if(url.indexOf(parm)<0)
		return false;	
		
	url = url.replace("#","?");
	parm = parm.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");  
	var regexS = "[\\?&]"+parm+"=([^&#]*)";  
	var regex = new RegExp( regexS );  
	var results = regex.exec( url ); 
	 if( results == null )    return "";  
	else    return results[1];
}

function openDocument(docs){
	
	if(device.platform=="Android"){
		console.log("Android open doc :"+docs);
		window.plugins.fileOpener.open(docs);
	}else{
		console.log("Open doc :"+docs);
		window.open(encodeURI(docs), '_blank', 'enableViewportScale=yes,location=no');
	}
}

function changeWindowsHeight(){ 
	function clean(){
		$(".jqm-content").css({"height" : $(window).height()-$(".jqm-content").offset().top-10+"px"} );
		
		//$(".ui-page").css({"height" : $(window).height()+"px"} );
		//$(".ui-page").css({"max-height" : $(window).height()+"px"} );
		
		
		$(".jqm-nav-panel .jqm-list").css({"max-height" : ($(window).height()-100)+"px"} );
		$(".jqm-nav-panel .jqm-list").css({"height" : ($(window).height()-100)+"px"} );
		
		$(".jqm-nav-panel ").css({"max-height" : ($(window).height()-100)+"px"} );
		$(".jqm-nav-panel ").css({"min-height" : ($(window).height()-100)+"px"} );
		$(".jqm-nav-panel ").css({"height" : ($(window).height()-100)+"px"} );
		
		$(".ui-panel-display-overlay").css({"min-height" : ($(window).height()-54)+"px"} );
		$(".ui-panel-display-overlay").css({"height" : ($(window).height()-54)+"px"} );	
		
		$( ".jqm-navmenu-panel" ).trigger( "updatelayout" );
		}
	setTimeout(clean,500);
	setTimeout(clean,3000);
}


function loadLink(url){
		
		displayAutocomplete("");
				
		$("#trash").fadeOut();
		$('<div />').load(url, function(){
		var content = $(this).html();
		$(".jqm-content, #content-right-UI").scrollTop();
		$(".jqm-content, #content-right-UI").hide(0,function(){
			  var icon_account = '<div id="account_area"><div id="menuIcon"></div><div class="account account_default item-menu-icon account_'+config.id+'"></div><div class="item-menu-icon accountName ">'+config.name+'</div></div>';			
			
			//icon_account += '</select></div></div>';
			if(!sessionStorage.history)
				sessionStorage.history=0;
			sessionStorage.history = parseInt(sessionStorage.history)+1;
			var icon_back = "";
			if($("#back2").is(".back2Shadow"))
				var icon_back ='<div id="back2" class="item-menu-icon back2Shadow"></div>';
			else
				var icon_back ='<div id="back2" class="item-menu-icon"></div>';
			if(parseInt(sessionStorage.history)==1)
				icon_back = '<div id="back" class="item-menu-icon"></div>';
			var icon_setting ='<div id="button-settings" class="item-menu-icon"></div>';
			
			$(".top_icons_left").html(icon_account+icon_back);
			$(".top_icons_right").html(icon_back+icon_setting);
			
			
			// Decide if the content go on the right or left side
			var side = "right";
			if(url=="./pages/ipad_main_menu.html")
				side = "left";
			
			
			if(url=="./pages/record.html" && $("#content-right-UI .result-search").length>0){
				$("#content-left-UI").html($("#content-right-UI").html());
			}
			
			// Display in the correct side.
			if(side == "right")
				$(".jqm-content, #content-right-UI").html(content);
			else
				$(".jqm-content, #content-left-UI").html(content);
			
			
			
			// Display the tablet header
			if(INVENIO_DEVICE_TYPE=="tablet")
			{
				if($(".tablet-header").length>0)
					$("#header-right-center").html($(".tablet-header").html());
				else
					$("#header-right-center").html("");
					
				$(".tablet-header").html("")
			}
			
			// Display or not search zone
			if( $(".search-zone-enable").length>0 ){
				$(".search-zone").show();
				sessionStorage.searchZone =true;
				$(".jqm-content").css({"margin-top":"45px"});
			}
			else{
				$(".search-zone").hide();
				sessionStorage.searchZone =false;
				$(".jqm-content").css({"margin-top":"5px"});
			}
			
			// Execute the jquery mobile element of the page
			$(".jqm-content, #content-right-UI, #content-left-UI").trigger("create");
			changeWindowsHeight();
			
			// If the page contain an init fonction -> run it.
			if(typeof(localInit) == 'function')
			{
				localInit();
			}
						
			if($("#content-left-UI").length>0)
			{
				if(side=="right"){
				switch(url){
					case "./pages/home.html": 
						$("#header-left-content").html("<div class='header-left-text'>"+config.name+"</div>");
						loadLink("./pages/ipad_main_menu.html");
						break;
					case "./pages/search.html": 
						loadLink("./pages/ipad_main_menu.html");
						break; 
					default:
						break; 
					}
				}
			}
			
			setTimeout(function(){
				$(".jqm-content, #content-right-UI").show();
				$("#splashscreen").addClass("out");

			},50);
			
			$("#account_area").on("vclick",function(event){
				event.stopImmediatePropagation();
				$("#account_area").removeClass("onPressDown");
				$("#domain-list").toggle();
				if( debugAndroid ||  device.platform == "Android" ) 
				{ 
					if($(".jqm-navmenu-panel").is(".ui-panel-open"))
						$( ".jqm-navmenu-panel" ).panel("close");
					else 
						$( ".jqm-navmenu-panel" ).panel("open");
				}
			})
			
			$("body").on("vclick", function(event) {
				$( ".onPressDown").removeClass("onPressDown");
				if($("#domain-list").is(":visible") || $("#tools-menu").is(":visible")){
					event.stopImmediatePropagation();
					$("#domain-list").hide();
					$("#tools-menu").hide();
				}
				
			});	
			$("#domain-list a").on("vclick",function(event){
				event.preventDefault();
				event.stopImmediatePropagation();
				window.location =$(event.target).parents("a").attr("href")
			});
			$("#tools-menu a").on("vclick",function(event){
				event.stopImmediatePropagation();
				$( ".onPressDown").removeClass("onPressDown");
				window.location =(event.target);
				$("#tools-menu").hide();
			});
			$("#button-settings").on("vclick",function(event){
				event.stopImmediatePropagation();
				$( ".onPressDown").removeClass("onPressDown");
				$("#tools-menu").toggle();
			});
		});
	});
}

function changedomain(domain){
	console.log(sessionStorage.domains);
	//reset history
	sessionStorage.history=0;
	$(JSON.parse(sessionStorage.domains)).each(function(i,v){
		if(v.id==domain){
			config=v;	
			$(".domain_name").html(v.name);
			$("#header-left-content").html("<div class='header-left-text'>"+v.name+"</div>");
			$(".domain_link li").removeClass("select");
			$(".list-domain-"+v.id).addClass("select");
		}
	});
	

}

function fastClick(selector, param, condition, funct){
	
	var mobile   = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent); 
	var action_start = mobile ? "touchstart" : "mousedown";
	var action_stop = mobile ? "touchend" : "mouseup";

	param = param === null ? "" : param;
	condition = condition === null ? function(){return true;} : condition;
	
	$(selector).on(action_start,param, function(event){
		var test_finish = false
		if(condition()){	
			if(test_finish)
			{
				funct(event);
			}
			test_finish=true;
		}
		else{
			$(selector).off(action_stop,param);
		}
		
		$(selector).on(action_stop,param, function(event){
			
			if(test_finish){
				funct(event);
			}
			else{
				test_finish=true;
			}
			$(selector).off(action_stop,param);
		})
	})
}
function fastClickDown(selector, param, condition, funct){
	var mobile   = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent); 
	var action_start = mobile ? "touchstart" : "mousedown";

	param = param === null ? "" : param;
	condition = condition === null ? function(){return true;} : condition;
	
	$(selector).on(action_start,param, function(event){
		var test_finish = false
		if(condition()){	
			funct(event);
		}
	})
}

function isFileExist(file){
	
	var res = false
$.ajax({
    url:file,
	async: false,
    type:'HEAD',
    error: function()
    {
       res = false;
    },
    success: function()
    {
		res = true;
    }
});
return res;
}


function creatFolder(folder){

	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onRequestFileSystemSuccess, null); 
	function onRequestFileSystemSuccess(fileSystem) { 
		
		var entry=fileSystem.root; 
		entry.getDirectory(folder, {create: true, exclusive: false}, onGetDirectorySuccess, onGetDirectoryFail); 
	} 
	
	function onGetDirectorySuccess(dir) { 
		console.log("Created dir "+dir.name); 
	} 
	
	function onGetDirectoryFail(error) { 
		console.log("Error creating directory "+error.code); 
	}
}

function fail(evt) {
	console.log(evt.target.error.code);
}

function writeFile(folder, file, content){

	creatFolder(folder);
	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onRequestFileSuccess, null); 
	
	function onRequestFileSuccess(fileSystem) { 
		fileSystem.root.getFile(folder+file, {create: true, exclusive: false}, gotFileEntry, fail);; 
	}
	
	function gotFileWriter(writer) 
	{
		writer.onwriteend = function(evt) { }
		writer.onerror = function(evt) { }
		writer.write(content);
	}
	
	function gotFileEntry(fileEntry) { 
		fileEntry.createWriter(gotFileWriter, fail);
	}
}
function fileName(src){
	var file_name = src.split("/")[src.split("/").length-1];
	
	if(file_name.split("?")[1]){
		file_name = (file_name.split(".")[0]+"-"+file_name.split("?")[1]+"."+(file_name.split(".")[1]).split("?")[0]).replace("=","-");
	}
	return cleanFileName(file_name);
}
function folderName(folder){
	if(device.platform == "iOS")
        return "file://"+folder;
	else 
		return folder;
}

function downloadFileList(list, percentarea, nbfile){
		if(nbfile == null && list.length > 0)
			nbfile=list.length;
		
		var downloadItem = list.pop();
		var src = downloadItem[0];
		var dest = downloadItem[1];
		var fs="";
		window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onRequestFileSystemSuccess, null); 
		function onRequestFileSystemSuccess(fileSystem) { 
		fs  = fileSystem.root.fullPath;
		
		var ft = new FileTransfer();
		

		var file_name = fileName(src)
		console.log("download: "+fs+dest+"/"+file_name);
		ft.onprogress = function(progressEvent){
			if (percentarea != null && progressEvent.lengthComputable){
				var loaded= progressEvent.loaded 
				if( device.platform == "Android" ) 
					loaded = loaded/2;
				var percent = Math.round((loaded / progressEvent.total/nbfile+(nbfile-(list.length+1))/nbfile)*100);
				
				percentarea.text(percent+"%");
			}
			};
		ft.download(
			src,
			fs+dest+"/"+file_name,
			function(entry) {
				console.log("download complete: " + entry.fullPath);
				writeIndexFile();
				if(list.length > 0)
					downloadFileList(list,percentarea, nbfile)
				else
				preventBack = false;
			},
			function(error) {
				preventBack = false;
				console.log("download error source " + error.source);
				console.log("download error target " + error.target);
				console.log("upload error code" + error.code);
			}
		);
	}
}

function downloadFile(src, dest){
		
		var fs="";
		window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onRequestFileSystemSuccess, null); 
		function onRequestFileSystemSuccess(fileSystem) { 
		fs  = fileSystem.root.fullPath;
		
		var ft = new FileTransfer();
		

		var file_name = fileName(src)
		console.log("download: "+fs+dest+"/"+file_name);
		ft.onprogress = function(progressEvent){
			};
		ft.download(
			src,
			fs+dest+"/"+file_name,
			function(entry) {
				console.log("download complete: " + entry.fullPath);
				writeIndexFile();
			},
			function(error) {
				console.log("download error source " + error.source);
				console.log("download error target " + error.target);
				console.log("upload error code" + error.code);
			}
		);
	}
}

function CopyValueInSearch(e){
	//
	// Copy Value the Autocomplete in the search form
	// ===============================================
	
	$(".jqm-search input").val($(e).text());
	$(".jqm-search input").focus();
	
	displayAutocomplete("");//Disable Autocomplet popup
}

function displayAutocomplete(msg){
	//
	// Display the value in autocomplete popup
	// ========================================
	
	$(".autocomplete").html(msg);
	if(msg != "")
	{
		$(".autocomplete").listview( "refresh" );
		$(".autocomplete").trigger( "updatelayout");
	}
}
function autocomplete(input){	
	var result ="";
	var tags=["year", "author" ,"journal", "keyword", "reportnumber", "reference", "abstract", "fulltext", "title"].sort();
	
	var link=["and", "and not" ,"or"].sort();
   
	var inputsplit = input.toLowerCase().split(" ");
	var lastinput = inputsplit[inputsplit.length-1];
	
	
	if(lastinput.length>=1)
	{
		for (var i in link)
		{
			if(link[i].indexOf(lastinput)!=-1)
			   result +=  "<li><a href=\"#\" onclick='CopyValueInSearch(this)'>"+input.substring(0,input.length-lastinput.length)+link[i].toUpperCase()+" </a></li>";
		}
		for (var i in tags)
		{
			if(tags[i].indexOf(lastinput)!=-1)
				result +=  "<li><a href=\"#\" onclick='CopyValueInSearch(this)'>"+input.substring(0,input.length-lastinput.length)+tags[i]+":</a></li>";
		}
	}
	displayAutocomplete(result);
} 