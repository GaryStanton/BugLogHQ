<cfparam name="request.requestState.oEntry">
<cfparam name="request.requestState.jiraEnabled">

<cfset oEntry = request.requestState.oEntry>
<cfset oApp = oEntry.getApplication()>
<cfset oHost = oEntry.getHost()>
<cfset oSource = oEntry.getSource()>
<cfset oSeverity = oEntry.getSeverity()>

<cfset entryID = oEntry.getEntryID()>

<cfset jiraEnabled = request.requestState.jiraEnabled>
<cfset ruleTypes = request.requestState.ruleTypes>

<cfset tmpCreateRuleURL = "?event=extensions.rule&application=#oApp.getCode()#&host=#oHost.getHostName()#&severity=#oSeverity.getCode()#">

<cfset tmpSeverity = oSeverity.getCode()>
<cfset htmlReport = oEntry.getHTMLReport()>
<cfif oEntry.getMessage() eq "">
	<cfset tmpMessage = "<em>No message</em>">
<cfelse>		
	<cfset tmpMessage = HtmlEditFormat(oEntry.getMessage())>
</cfif>

<cfquery name="qryEntriesOthers" dbtype="query">
	SELECT *
		FROM rs.qryEntriesAll
		WHERE entryID < <cfqueryparam cfsqltype="cf_sql_numeric" value="#entryID#">
		ORDER BY createdOn DESC
</cfquery>
<cfquery name="qryHosts" dbtype="query">
	SELECT hostID, hostName, count(hostID) as numEntries
		FROM rs.qryEntriesLast24
		GROUP BY hostID, hostName
</cfquery>
<cfquery name="qryUAEntries" dbtype="query">
	SELECT *
		FROM rs.qryEntriesUA
		WHERE entryID <> <cfqueryparam cfsqltype="cf_sql_numeric" value="#entryID#">
		ORDER BY createdOn DESC
</cfquery>


<cfinclude template="../includes/udf.cfm">

<cfoutput>
<h2>Bug ###entryID# : <span style="color:##cc0000;">#tmpMessage#</span></h2>

<p>
	<table width="100%" class="criteriaTable" cellpadding="0" cellspacing="0">
		<tr>
			<td style="border-right:1px solid ##ccc;">
				<img alt="" width="16" height="16" src="#rs.assetsPath#images/icons/arrow_undo.png" align="absmiddle" />
				<a href="index.cfm">Return To Log</a>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<img width="16" height="16" src="#rs.assetsPath#images/icons/email.png" align="absmiddle" />
				<a href="##" id="sendToEmailLink">Send to email</a>
				
				<cfif isBoolean(jiraEnabled) and jiraEnabled>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<img width="16" height="16" src="#rs.assetsPath#images/icons/jira.png" align="absmiddle" />
					<a href="index.cfm?event=jira.sendToJira&entryID=#entryID#">Send to JIRA</a>
				</cfif>

				&nbsp;&nbsp;&nbsp;&nbsp;
				<select name="ruleName" style="width:100px;" onchange="if(this.value!='') document.location='#tmpCreateRuleURL#&ruleName='+this.value">
					<option value="">Create rule...</option>
					<cfloop array="#ruleTypes#" index="rule">
						<cfset ruleName = listLast(rule.name,".")>
						<option value="#ruleName#">#ruleName#</option>
					</cfloop>
				</select>
			</td>
			<cfif tmpSeverity neq "">
				<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##ccc;width:100px;">
					<cfset tmpImgURL = getSeverityIconURL(tmpSeverity)>
					<cfset color_code_severity = getColorCodeBySeverity(tmpSeverity)>
					<span class="badge badge-#color_code_severity#">
						<img src="#tmpImgURL#" align="absmiddle" alt="#tmpSeverity#" title="#tmpSeverity#">
						#lcase(tmpSeverity)#
					</span>
				</td>
			</cfif>
			<td align="center" style="border-left:1px solid ##fff;border-right:1px solid ##ccc;width:200px;">
				<span class="label">Application:</span>
				<a href="index.cfm?event=main&applicationID=#oApp.getApplicationID()#">#oApp.getCode()#</a>
			</td>
			<td align="center" style="border-left:1px solid ##fff;width:200px;">
				<span class="label">Host:</span>
				<a href="index.cfm?event=main&hostID=#oHost.getHostID()#">#oHost.getHostname()#</a>
			</td>
		</tr>
	</table>
</p>

<!--- Send to email form --->
<div id="dSendForm" style="display:none;background-color:##f9f9f9;" class="criteriaTable">
	<div style="margin:10px;padding-top:10px;">
	<form name="frmSend" action="index.cfm" method="post" style="padding:0px;margin:0px;">
		<input type="hidden" name="event" value="doSend">
		<input type="hidden" name="entryID" value="#oEntry.getEntryID()#">
		<strong>Recipient(s):</strong><br />
		<input type="text" name="to" value="" style="width:90%;">
		<br><br>
		<strong>Comments:</strong><br />
		<textarea name="comment" rows="4" style="width:90%;padding:2px;">Hi, can you take a look at this?</textarea>
		<br><br>
		<input type="submit" value="Send" name="btnSubmit">
	</form>
	</div>
</div>
<br />

<table id="entry-content">
<tr valign="top">
	<td id="entry-details">
		<table class="table table-condensed table-bordered table-striped">
			<tbody>
				<tr>
					<td style="width:115px;"><b>Date/Time:</b></td>
					<td>#lsDateFormat(oEntry.getCreatedOn(),"long")# - #lsTimeFormat(oEntry.getCreatedOn())#</td>
				</tr>
				<tr>
					<td><b>User Agent:</b></td>
					<td>
						#oEntry.getUserAgent()#
						<cfif qryUAEntries.recordCount gt 0>
							<cfset maxUAEntries = 10>
							<br /><a href="##" onclick="$('##uaentries').slideToggle()"><b>#rs.qryEntriesUA.recordCount#</b> other reports from the same user agent (last 24hrs)</a>
							<ul id="uaentries" style="display:none;margin-top:5px;">
								<cfloop query="qryUAEntries" startrow="1" endrow="#min(maxUAEntries,qryUAEntries.recordCount)#">
									<li>
										<cfif qryUAEntries.entryID eq oEntry.getEntryID()><span class="label label-info">This</span> </cfif>
										#dateFormat(qryUAEntries.createdOn,"m/d")# #timeFormat(qryUAEntries.createdOn,"hh:mm tt")#: 
										<b>#qryUAEntries.applicationCode#</b> on
										<b>#qryUAEntries.hostName#</b> :
										<a href="index.cfm?event=entry&entryID=#qryUAEntries.entryID#">#htmlEditFormat(qryUAEntries.message)#</a></li>
								</cfloop>
								<cfif qryUAEntries.recordCount gt maxUAEntries>
									<li>... #qryUAEntries.recordCount-maxUAEntries# more (not shown)</li>
								</cfif>
							</ul>
						</cfif>
					</td>
				</tr>
				<cfif oEntry.getTemplate_Path() neq "">
					<tr>
						<td><b>Template Path:</b></td>
						<td>#oEntry.getTemplate_Path()#</td>
					</tr>
				</cfif>
				<tr>
					<td><b>Exception Message:</b></td>
					<td>#HtmlEditFormat(oEntry.getExceptionMessage())#</td>
				</tr>
				<tr>
					<td><b>Exception Detail:</b></td>
					<td id="exceptiondetail">#HtmlCodeFormat(oEntry.getExceptionDetails())#</td>
				</tr>
				<cfif oEntry.getCFID() neq "" or oEntry.getCFTOKEN() neq "">
					<tr>
						<td><b>CFID / CFTOKEN:</b></td>
						<td>#oEntry.getCFID()# &nbsp;&nbsp;/&nbsp;&nbsp; #oEntry.getCFTOKEN()#</td>
					</tr>
				</cfif>
				<tr>
					<td><b>Received via:</b></td>
					<td>#oSource.getName()#</td>
				</tr>
			</tbody>
		</table>
	</td>
	<td style="width:5px;"></td>
	<td id="entry-stats">
		<div class="well">
			<h3>Stats</h3>
			<ul>
			<cfif rs.qryEntriesLast24.recordCount gt 1>
				<li><b>#rs.qryEntriesLast24.recordCount#</b> reports with the 
				<a href="index.cfm?event=log&numDays=1&msgFromEntryID=#entryID#&applicationID=0&hostID=0&severityID=0"><b>same message</b></a>
				have been reported in the last 24 hours.</li>
			<cfelse>
				<li>This is the <b>first time</b> this message has ocurred in the last 24 hours.</li>
			</cfif>
			<cfif qryEntriesOthers.recordCount gt 1>
				<li>
					The previous time this bug was reported was on 
					<a href="index.cfm?event=entry&entryID=#qryEntriesOthers.entryID#"><b>#lsDateFormat(qryEntriesOthers.createdOn,"long")# #lsTimeFormat(qryEntriesOthers.createdOn)#</b></a>
				</li>
			</cfif>
			</ul>
			<div style="margin-top:5px;">
				<b>Host Distribution:</b><br />
				<table class="table table-condensed">
					<cfset totalEntries = arraySum(listToArray(valueList(qryHosts.numEntries)))>
					<cfloop query="qryHosts">
						<tr>
							<td><a href="index.cfm?event=log&numDays=1&msgFromEntryID=#entryID#&applicationID=0&hostID=#hostID#">#hostName#</a></td>
							<td>#numEntries# (#round(numEntries/totalEntries*100)#%)</td>
						</tr>
					</cfloop>
				</table>
			</div>
		</div>	
	</td>
</tr>
</table>


<cfif htmlReport neq "">
	<h2>HTML Report</h2>
	#htmlReport#
</cfif>
</cfoutput>
<br>
<br>
<p>
	<a href="index.cfm"><strong>Return To Log</strong></a>
</p>	
