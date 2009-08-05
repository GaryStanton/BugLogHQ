<cfparam name="request.requestState.stInfo" default="#structNew()#">
<cfparam name="request.requestState.aRules" default="#arrayNew(1)#">
<cfparam name="request.requestState.aReports" default="#arrayNew(1)#">
<cfparam name="request.requestState.aActiveRules" default="#arrayNew(1)#">
<cfparam name="request.requestState.aActiveReports" default="#arrayNew(1)#">

<cfset currentUser = request.requestState.currentUser>
<cfset rs = request.requestState>

<style type="text/css">
.extensionItem {
	background-color:#ebebeb;
	border-bottom:1px solid #666;
	border-right:1px solid #666;
	border-top:1px solid silver;
	border-left:1px solid silver;
	font-size:14px;
	margin-bottom:15px;
	padding:5px;
}
.extensionItem:hover {
	background-color:#f5f5f5;
}
.extensionItem table {
	margin-top:10px;
	border-collapse:collapse;
}
.extensionItem td {
	padding:5px;
	font-size:11px;
	border:1px solid silver;
}
</style>
<script type="text/javascript"> 
	function confirmDeleteRule(index) {
		if(confirm("Are you sure you wish to remove the rule")) {
			document.location='index.cfm?event=ehExtensions.doDeleteRule&index='+index;
		}
	}
</script>


<cfoutput>
<h2 style="margin-bottom:3px;">BugLog Rules</h2>
<cfinclude template="../includes/menu.cfm">

<p>
	Rules are processes that are executed as each bug report is processed. Use rules to perform tasks such
	as monitoring for specific error messages, or messages coming from specific applications.<br />
	
	<cfif currentUser.getIsAdmin()>
		<b style="color:red;">NOTE: Any changes to extensions will only become effective after restarting the bugLog service.</b>
	<cfelse>
		<b style="color:red;">NOTE: Only an administrator can create or modify rules</b>
	</cfif>
</p>


<h3>Active Rules</h3>
<cfloop from="1" to="#arrayLen(rs.aActiveRules)#" index="i">
	<cfset item = rs.aActiveRules[i]>
	<cfset ruleName = listLast(item.component,".")>
	<cfset lstProps = listSort(structKeyList(item.config),"textnocase")>
	
	<div class="extensionItem">
		<b>#ruleName#</b>
		<cfif currentUser.getIsAdmin()>
			( <a href="##" onclick="confirmDeleteRule(#i#)" style="font-size:10px;">Remove</a> )
			( <a href="index.cfm?event=ehExtensions.dspRule&index=#i#&ruleName=#ruleName#" style="font-size:10px;">Modify</a> )
		</cfif>
		
		<div style="margin-top:5px;">
			#item.description#
		</div>
		
		<table cellpadding="0" cellspacing="0">
			<tr>
				<cfloop list="#lstProps#" index="fld">
					<td><b>#fld#</b></td>
				</cfloop>
			</tr>
			<tr>
				<cfloop list="#lstProps#" index="fld">
					<td>#item.config[fld]#</td>
				</cfloop>
			</tr>
		</table>
	</div>
</cfloop>
<cfif arrayLen(rs.aActiveRules) eq 0>
	<em>There are no active rules</em>
</cfif>

<cfif currentUser.getIsAdmin()>
	<hr />
	<br />
	<form name="frm" method="post" action="index.cfm">
		<strong>Create rule of type: </strong>
		<select name="ruleName">
			<cfloop from="1" to="#arrayLen(rs.aRules)#" index="i">
				<cfset ruleName = listLast(rs.aRules[i].name,".")>
				<option value="#ruleName#">#ruleName#</option>
			</cfloop>
		</select>
		<input type="hidden" name="event" value="ehExtensions.dspRule">
		<input type="submit" value="GO">
	</form>
</cfif>	
	
</cfoutput>
