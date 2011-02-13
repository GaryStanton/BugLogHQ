<?xml version="1.0" encoding="UTF-8"?>
<config>
	<setting name="general.adminEmail">admin@somedomain.org</setting>
	<setting name="general.externalURL"></setting>
	<setting name="general.dateFormat">mm/dd/yy</setting>
	
	<setting name="db.dsn">bugLog</setting>
	<setting name="db.dbtype">mysql</setting>
	<setting name="db.username"></setting>
	<setting name="db.password"></setting>

	<setting name="service.serviceCFC">bugLog.components.bugLogListenerAsync</setting>
	<setting name="service.autoStart">true</setting>
	<setting name="service.requireAPIKey">false</setting>
	<setting name="service.API">2CF20630-DD24-491F-BA44314842183AFC</setting>
	<setting name="service.maxQueueSize">1000</setting>
	<setting name="service.maxLogSize">20</setting>
	<setting name="service.schedulerIntervalSecs">120</setting>

	<setting name="jira.enabled">false</setting>
	<setting name="jira.wsdl"></setting>
	<setting name="jira.username"></setting>
	<setting name="jira.password"></setting>

	<setting name="purging.numberOfDays">90</setting>
	<setting name="purging.enabled">false</setting>
	
	<!-- Environment-specific Settings: 
		
		You can override any of the above settings for specific environments. 
		The environment can be given in any of the following ways:
			1. Create a file named "serverkey.txt" on the same directory as your config file.
				This file should contain only a single word to use as the environment name (i.e. "dev", "production1", "test", etc)
			2. Pass the environment name using the configKey argument to the init() method on config.cfc whenever is created
			3. Pass the path to a file containing the environment key to config.cfc
		NOTE: the first method is way more easier since there are at least 3 places where the config.cfc object is created
			and you would need to update all three if you use method #2 or #3
			
	<envSettings name="dev">
		<setting name="db.dsn">bugLog_dev</setting>
		<setting name="general.adminEmail">devteam@somedomain.org</setting>
	</envSettings>

	<envSettings name="qa">
		<setting name="db.dsn">bugLog_qa</setting>
		<setting name="general.adminEmail">qateam@somedomain.org</setting>
	</envSettings>

	-->

</config>