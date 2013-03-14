<cfset oUser = request.requestState.oUser>
<cfset userID = val(oUser.getUserID())>
<cfset userName = oUser.getUsername()>
<cfset password = oUser.getPassword()>
<cfset isAdmin = oUser.getIsAdmin()>
<cfset email = oUser.getEmail()>

<cfset userAppIDs = []>
<cfloop array="#rs.userApps#" index="i">
	<cfset arrayAppend(userAppIds,i.getApplicationID())>
</cfloop>

<cfoutput>
	<cfinclude template="../includes/menu.cfm">
	
	<form name="frmDelete" action="index.cfm" method="post">
		<input type="hidden" name="event" value="admin.doSaveUser">
		<input type="hidden" name="userID" value="#userID#">
		<br />
		<table>
			<tr>
				<td><b>Username:</b></td>
				<td><input type="text" name="username" value="#username#" class="formField"></td>
			</tr>
			<cfif userID eq 0>
				<tr>
					<td><b>Password:</b></td>
					<td><input type="text" name="password" value="#password#" class="formField"></td>
				</tr>
			</cfif>
			<tr>
				<td><b>Email:</b></td>
				<td><input type="text" name="email" value="#email#" class="formField"></td>
			</tr>
			<tr>
				<td><b>Administrator?:</b></td>
				<td>
					<input type="radio" name="isadmin" value="1" <cfif isAdmin>checked</cfif>>Yes 
					<input type="radio" name="isadmin" value="0" <cfif not isAdmin>checked</cfif>>No
				</td>
			</tr>
			<tr valign="top">
				<td><b>Allowed Applications:</b></td>
				<td>
					<select name="applicationIDList" multiple="true" size="5" <cfif isAdmin>disabled</cfif>>
						<cfloop query="rs.apps">
							<option value="#rs.apps.applicationID#" <cfif arrayFind(userAppIds,rs.apps.applicationID)>selected</cfif>>#rs.apps.code#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<br /><br />
		<input type="submit" name="btngo" value="Apply Changes">
		&nbsp;&nbsp;
		<a href="index.cfm?event=admin.main&panel=userManagement">Go Back</a>
	
	</form>
</cfoutput>
