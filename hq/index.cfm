<!---
	BugLog HQ 
--->

<!--- create main application controller --->
<cfset app = createObject("component","bugLog.core.coreApp") />


<!--- Framework Settings --->
<cfset app.paths.app = "/bugLog/hq">
<cfset app.paths.core = "/bugLog/core">
<cfset app.paths.coreImages = "../core/images">

<cfset app.dirs.handlers = "handlers">
<cfset app.dirs.layouts = "layouts">
<cfset app.dirs.views = "views">

<cfset app.mainHandler = "ehGeneral">
<cfset app.defaultEvent = "dspMain">
<cfset app.defaultLayout = "Layout.Main">
<cfset app.configDoc = "config/config.xml.cfm">


<!--- Invoke controller --->
<cfset app.onRequestStart()>


<!--- Render view --->
<cfinclude template="/bugLog/core/core.cfm">
