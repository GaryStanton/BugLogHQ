<cfscript>
	datePartName = "";
	switch(rs.criteria.numDays) {
		case "120": 
			units=6;
			datePartName = "month"; 
			break;
		case "360": 
			units=12;
			datePartName = "month"; 
			break;
		case "7": 
			units=7;
			datePartName = "day"; 
			break;
		case "30": 
			units=30;
			datePartName = "day"; 
			break;
		case "60": 
			units=60;
			datePartName = "day"; 
			break;
		case "1": 
			units=24;
			datePartName = "hour"; 
			break;
	}
</cfscript>

<cfif datePartName neq "">
	<cfset qryChart = queryNew("datePartValue,numCount")>
	<cfset theDate = rs.criteria.startDate>

	<cfloop from="1" to="#units#" index="i">
		<cfquery name="qryTimeline" dbtype="query">
			SELECT count(*) as numCount
				FROM qryData
				WHERE 
					<cfswitch expression="#datePartName#">
						<cfcase value="hour">
							entry_hour=#hour(theDate)#
							and entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = timeFormat(theDate,"hh:00 tt")>
							<cfset theDate = dateAdd("h",1,theDate)>
						</cfcase>
						<cfcase value="day">
							entry_day = #day(theDate)#
							and entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = dateFormat(theDate,"Mmm d")>
							<cfset theDate = dateAdd("d",1,theDate)>
						</cfcase>
						<cfcase value="month">
							entry_month = #month(theDate)#
							and entry_year = #year(theDate)#
							<cfset datePartValue = dateFormat(theDate,"mmm")>
							<cfset theDate = dateAdd("m",1,theDate)>
						</cfcase>
					</cfswitch>
		</cfquery>
		<cfset queryAddRow(qryChart)>
		<cfset querySetCell(qryChart,"datePartValue",datePartValue)>
		<cfset querySetCell(qryChart,"numCount",val(qryTimeline.numCount))>
	</cfloop>

	<cfoutput>
		<style>
		##chart_container {
		        position: relative;
		        font-family: Arial, Helvetica, sans-serif;
		}
		##chart {
		        position: relative;
		        left: 40px;
		}
		##y_axis {
		        position: absolute;
		        top: 0;
		        bottom: 0;
		        width: 40px;
		}
		</style>
		
		<div id="chart_container">
			<div id="y_axis"></div>
		    <div id="chart"></div>
		</div>
		 
		<script> 
		var graph = new Rickshaw.Graph( {
		    element: document.querySelector("##chart"), 
			height:200,
			stroke: true,
			renderer: 'bar',
		    series: [{
		        color: '##cae2f7',
		        data: [ 
					<cfloop query="qryChart">
						{x:#qryChart.currentrow#, y:#qryChart.numCount#},
					</cfloop>
					]
		    }]
		});
		var y_axis = new Rickshaw.Graph.Axis.Y( {
		        graph: graph,
		        orientation: 'left',
		        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
				ticks:10,
		        element: document.getElementById('y_axis'),
		} );
		graph.render();
		</script> 	
	<!---
		<cfchart chartwidth="600" markersize="5" xaxistitle="#datePartName#"  yaxistitle="Count" title="Timeline" sortXAxis="no">
			<cfchartseries query="qryChart" type="curve"
							paintStyle="plain"
							markerStyle="circle"
							itemcolumn="DatePartValue" 
							valuecolumn="numcount">
		</cfchart>
		--->
	</cfoutput>
</cfif>

