/**************************************************************/	
/* BugLogHQ  (v1.4)										  */
/* http://buglogHQ.riaforge.org
/**************************************************************/	

/*
  Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)

  Licensed under the Apache License, Version 2.0 (the "License"); 
  you may not use this file except in compliance with the License. 
  You may obtain a copy of the License at 

	http://www.apache.org/licenses/LICENSE-2.0 

  Unless required by applicable law or agreed to in writing, software 
  distributed under the License is distributed on an "AS IS" BASIS, 
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
  See the License for the specific language governing permissions and 
  limitations under the License. 

*/ 

-----------------------------------------------------------------------
Contents:
-----------------------------------------------------------------------
1. About BugLogHQ
2. Release Notes
3. Integrating BugLogHQ into your Applications
4. BugLogHQ Interface
5. Installation and Usage Notes:
6. Supported Databases
7. Acknowledgements / Thanks / Credits
8. Bugs, suggestions



-----------------------------------------------------------------------
1. About BugLogHQ
-----------------------------------------------------------------------
BugLogHQ is a tool to centralize the handling of automated bug reports from 
multiple applications. BugLogHQ provides a unified view of error messages
sent from any number of applications, allowing the developer to search,
graph, forward, and explore the bug reports submitted by the applications. 
All bug reports received by BugLogHQ are stored on a normalized database, thus 
providing the option to the developers to further extend the application
to leverage this information.



-----------------------------------------------------------------------
2. Release Notes
-----------------------------------------------------------------------
 > New in 1.3
-----------------------------------------------------------------------
* This is a release of mostly internal changes. The entire data access layer
has been refactored to use an improved mechanism that makes it easier to work
with different backend data storages.
See: 
http://www.oscararevalo.com/index.cfm/2007/11/28/Using-Polymorphism-and-Inheritance-to-Build-a-Switchable-Data-Access-Layer
* The BugLogHQ application (where you go to see the bug reports) has also been updated 
to improve performance and use the new DAO layer.
* Configuration of data storage is now done via a config xml on the /buglog/config directory.
The file is dao-config.xml.cfm. Here is where you can set the DSN, user, password and
dbtype. From here, you can also change the storage mechanism from a database to simple XML files
(maybe for a quick test drive)
* Fixed bug that would throw errors if the email addresses for top-level error reporting were
not defined.
* Added a directory /bugLog/tests that contains files to test both the client and server side of buglog,
and also can be used as a refence as to how to implement the client side of bugLog.
* BugLogListener now uses memory caching to improve performance and process bug reports faster
* Fixed sql scripts for MSSQL, all tables should now be configured with primary keys defined as numeric identity values
* bl_source table no longer needs to be populated with pre-defined values. The listener will insert these as needed.
* Added bugLogProxy.cfm for integration with BugLogMini ( http://buglogmini.riaforge.org/ )



-----------------------------------------------------------------------
 > New in 1.2
-----------------------------------------------------------------------
* Support for a configurable and extensible rules system. Rules are processes that are applied
to each bug report as it is received. Rules can be defined for tasks such as sending notifications
when a bug of given conditions is received; when the amount of bugs received in 
a given timeframe is greater than a defined threshold, etc. The rules system is
extensible in the sense that each rule is implemented as a CFC with a common interface.
For more info on rules see:
http://www.oscararevalo.com/index.cfm/2007/10/2/BugLogHQ-New-Rules-feature



-----------------------------------------------------------------------
3. Integrating BugLogHQ into your Applications
-----------------------------------------------------------------------
Applications can send bug reports to BugLogHQ via three different ways:
* webservice call
* http post
* direct CFC call

BugLogHQ provides a CFC that can be used to send the bug reports. This CFC is 
located in /bugLog/client/bugLogService.cfc. This is the only file that needs
to be distributed with any application that wants to submit reports to BugLogHQ.

You may instantiate and keep the instance of this CFC in some a scope
such as Application and then just call the "notifyService" method in it whenever
the application needs to submit a bug report.

To initialize the bugLogService, call the Init method. This method takes three
parameters:
* bugLogListener:	The location of the listener where to send the bug reports
* bugEmailRecipients:  A comma-delimited list of email addresses to which send the 
						bug reports in case there is an error submitting the report
						to the bugLog listener.
* bugEmailSender:	The sender address to use when sending the emails mentioned above.

The bugLogListener parameter can be any of:
* WSDL pointing to /bugLog/listeners/bugLogListenerWS.cfc (to submit the report using a webservice), 
* Full URL pointing to /bugLog/listeners/bugLogListenerREST.cfm (to submit as an http post)
* path to /bugLog/listeners/bugLogListenerWS.cfc in dot notation (i.e. bugLog.listeners.bugLogListenerWS)

If an error occurs while submitting the report to the listener, then bugLogService will automatically
send the same information as an email to the addresses provided in the Init() method.

TIP: Check the file /bugLog/test/client.cfm for an example of how to use the bugLog client CFC



-----------------------------------------------------------------------
4. BugLogHQ Interface
-----------------------------------------------------------------------
To access the BugLogHQ interface, go to /bugLog/ on your bugLog server; the interface is
password protected. The default username and password is: admin / admin.
From here you can have an overview of every bug report that has been received. Everything
is pretty self-explanatory, and there are lots of things you can click to visualize the
data in different ways.



-----------------------------------------------------------------------
5. Installation and Usage Notes:
--------------------------------------------------------------------------------------
* To install BugLog just unpack the zip file into the root of your webserver. BugLogHQ assumes it will be
installed on a directory or mapping named /bugLog.

* Run the corresponding SQL script for your database. The script can be found in the /install directory. This 
will create the necessary tables.

* By default bugLogHQ uses a datasource named "bugLog" with no password, to change this go to:
		/bugLog/config/dao-config.xml.cfm
	Change the appropriate <property /> tags.
	
	NOTE: You can test drive bugLog without setting up a database by setting the <dataProviderType /> tag value
		to "xml" and uncommenting the <dataRoot /> tag (this tag points to a directory where the data files will
		be stored). BugLog can work normally with XML files, but this is not scalable and who know what may 
		happen if the XML files get too big!!
	
* To access the bugLogHQ interface, go to /bugLog. The default username/password is:
		username: admin
		password: admin
	IMPORTANT: To change the admin password, you must edit the bl_Users table directly.

* You may also want to setup proper email addresses for sending bug reports when things do not work as they should: 
		/bugLog/hq/Application.cfc (lines 13-14)
		/bugLog/hq/config/config.xml (lines 5-6)
	(this step is optional)

* After installation use your browser to go to /bugLog/test and follow the links to test both the client 
	and server side of buglog.



-----------------------------------------------------------------------
6. Supported Databases:
--------------------------------------------------------------------------------------
Currently BugLogHQ supports the following databases:
* MySQL
* Microsoft SQL Server 2000
* Microsoft SQL Server 2005
* Microsoft Access
* XML files


-----------------------------------------------------------------------
7. Acknowledgements / Thanks / Credits
---------------------------------------------------------------------------
* BugLogHQ uses rss.cfc by Raymond Camden (http://cfrss.riaforge.org/)
* Lots of icons from the "Silk" icon set by Mark James (http://www.famfamfam.com/)
* Thanks to Tom DeManincor for creating the SQL script for MSSQL
* Thanks to Chuck Weidler for updating and providing the SQL scripts for Access, MS SQL Server 2000, MSSQL Server 2005



-----------------------------------------------------------------------
8. Bugs, suggestions, criticisms, well-wishes, good vibrations, etc
---------------------------------------------------------------------------
Please send to oarevalo@gmail.com or share them on the forum at http://bugloghq.riaforge.org/







