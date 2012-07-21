<cfset bugLogListener.soap = "#rs.bugLogHREF#listeners/bugLogListenerWS.cfc?wsdl">
<cfset bugLogListener.rest = "#rs.bugLogHREF#listeners/bugLogListenerREST.cfm">
<cfset bugLogListener.cfc = "bugLog.listeners.bugLogListenerWS">

<cfoutput>
	<h3>Change Password:</h3>
	<div style="margin-left:30px;line-height:24px;">
		You can use the following BugLog listeners for this server:<br /><br />
		
		<b>SOAP / Webservice:</b> ( <a href="../test/client.cfm?protocol=soap">Test</a> )<br />
		<a href="#bugLogListener.soap#">#bugLogListener.soap#</a><br /><br />
		
		<b>HTTP POST / REST:</b> ( <a href="../test/client.cfm?protocol=rest">Test</a> )<br />
		<a href="#bugLogListener.rest#">#bugLogListener.rest#</a><br /><br />

		<b>CFC:</b> ( <a href="../test/client.cfm?protocol=cfc">Test</a> )<br />
		<a href="#bugLogListener.cfc#">#bugLogListener.cfc#</a>
	</div>
</cfoutput>
