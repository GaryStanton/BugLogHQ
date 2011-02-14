<cfcomponent extends="eventHandler">

	<cfset variables.extensionsXMLPath = "/bugLog/config/extensions-config.xml.cfm">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			try {
				aRules = getService("app").getRules();
				aActiveRules = getService("app").getActiveRules();
	
				setValue("hasExtensionsXMLFile", fileExists(expandPath(variables.extensionsXMLPath)));
				setValue("aRules", aRules);
				setValue("aActiveRules", aActiveRules);
	
				setView("vwExtensions");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehGeneral.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspRule" access="public" returntype="void">
		<cfscript>
			var index = getValue("index",0);
			var ruleName = getValue("ruleName","");
			var app = getService("app");

			try {
				if(ruleName eq "") throw("Please select a valid rule type","validation");
				
				stRule = app.getRuleInfo(ruleName);
	
				setValue("qryApplications", app.getApplications());
				setValue("qryHosts", app.getHosts());
				setValue("qrySeverities", app.getSeverities());

				if(getValue("currentUser").getEmail() neq "")
					setValue("defaultEmail", getValue("currentUser").getEmail());
				else
					setValue("defaultEmail", getService("config").getSetting("general.adminEmail",""));

				setValue("stRule", stRule);
				setValue("index", index);
				setValue("ruleName", ruleName);
				
				if(index gt 0) {
					aActiveRules = app.getActiveRules();
					setValue("aActiveRule", aActiveRules[index]);
				}

				setView("vwRule");

			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("ehExtensions.dspMain");

			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
				setNextEvent("ehExtensions.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspRulesLog" access="public" returntype="void">
		<cfscript>
			var logcontents = "";
			var logsdir = getValue("logsdir");
			var logpath = "";

			if(logsdir eq "") {
				if(structKeyExists(cookie,"logsdir"))
					logsdir = cookie.logsdir;
				else {
					logsdir = Server.ColdFusion.RootDir & "/logs/";
					writeCookie("logsdir",logsdir,180);
				}
			} else {
				writeCookie("logsdir",logsdir,180);
			}

			logpath = logsdir & "bugLog_ruleProcessor.log";

			if(fileExists(logpath))
				logcontents = fileRead(logpath,"utf-8");
			else 
				setMessage("warning","Cannot find rule Processor log file. Make sure you enter the correct path to your logs directory. It may also be that the log has not been created yet. The log file is automatically created once a rule is fired.");

			setValue("logcontents", logcontents);
			setValue("logsdir", logsdir);
			setView("vwRulesLog");
		</cfscript>
	</cffunction>
		
	<cffunction name="doSaveRule" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			var args = {};
			var lstIgnoreFields = "event,fieldnames,btnSave";
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to create or modify a rule"); setNextEvent("ehExtensions.dspMain");}
				for(fld in form) {
					if(!listFindNoCase(lstIgnoreFields,fld)) {
						if(structKeyExists(form,fld & "_other")) {
							if(form[fld] eq "__OTHER__")
								args[fld] = form[fld & "_other"];
							else
								args[fld] = form[fld];
						} else if(listLast(fld,"_") eq "other" and structKeyExists(form,listDeleteAt(fld,listLen(fld,"_"),"_"))){
							// this is the 'other' field, ignore it
						} else {
							args[fld] = form[fld];
						}
					}
				}
				getService("app").saveRule(argumentCollection = args);
				setMessage("info","Rule saved. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteRule" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to delete a rule"); setNextEvent("ehExtensions.dspMain");}
				getService("app").deleteRule(index);
				setMessage("info","Rule has been removed. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doDisableRule" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to enable or disable a rule"); setNextEvent("ehExtensions.dspMain");}
				getService("app").disableRule(index);
				setMessage("info","Rule has been disabled. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doEnableRule" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to enable or disable a rule"); setNextEvent("ehExtensions.dspMain");}
				getService("app").enableRule(index);
				setMessage("info","Rule has been enabled. Changes will be effective the next time the listener service is started.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>	

	<cffunction name="doMigrateExtensionsXML" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to do this"); setNextEvent("ehExtensions.dspMain");}
				if(!fileExists(expandPath(variables.extensionsXMLPath))) {
					setMessage("warning","The file '#variables.extensionsXMLPath#' could not be found.");
					setNextEvent("ehExtensions.dspMain");
				}
	
				// read file
				xmlDoc = xmlParse(expandPath(variables.extensionsXMLPath));

				// get rule definitions
				aNodes = xmlSearch(xmlDoc, "//rules/rule");
			
				for(i=1;i lte arrayLen(aNodes);i=i+1) {
					xmlNode = aNodes[i];
					
					// build rule info node
					st = structNew();
					st.ruleName = xmlNode.xmlAttributes.name;
					st.description = xmlNode.xmlText;
					st.enabled = true;
	
					// check the enabled/disabled flag; if not specified all rules are enabled by default
					if(structKeyExists(xmlNode.xmlAttributes,"enabled") and isBoolean(xmlNode.xmlAttributes.enabled) and not xmlNode.xmlAttributes.enabled)
						st.enabled = false;
					
					// each child of a rule tag becomes an argument for the rule constructor
					// this is how each rule instance is configured
					for(j=1;j lte arrayLen(xmlNode.xmlChildren);j=j+1) {
						xmlChildNode = xmlNode.xmlChildren[j];
						st[xmlChildNode.xmlName] = xmlChildNode.xmlText;
					}				
					
					getService("app").saveRule(argumentCollection = st);
				}
							
				// now delete file
				fileDelete(expandPath(variables.extensionsXMLPath));

				setMessage("info","Rules have been migrated.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteExtensionsXML" access="public" returntype="void">
		<cfscript>
			var user = getValue("currentUser");
			
			try {
				if(not user.getIsAdmin()) {setMessage("warning","You must be an administrator to do this"); setNextEvent("ehExtensions.dspMain");}
				if(fileExists(expandPath(variables.extensionsXMLPath))) {
					fileDelete(expandPath(variables.extensionsXMLPath));
				}
				setMessage("info","The extensions XML file has been deleted.");
			
			} catch(any e) {
				setMessage("error",e.message);
				getService("bugTracker").notifyService(e.message, e);
			}

			setNextEvent("ehExtensions.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="writeCookie" access="private">
		<cfargument name="name" type="string">
		<cfargument name="value" type="string">
		<cfargument name="expires" type="string">
		<cfcookie name="#arguments.name#" value="#arguments.value#" expires="#arguments.expires#">
	</cffunction>
		
</cfcomponent>