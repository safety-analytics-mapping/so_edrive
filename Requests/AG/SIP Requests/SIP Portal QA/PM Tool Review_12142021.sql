/*
SIP PM Tool Review

* = Functions Properly
*! = Error

Header to test:

http://dotdevgisiis02/SIPPortal
1.	Home button  *    
2.	Project button *
3.	Sheets button *
4.	Docs button *
5.	About button *
6.	Account *

http://dotdevgisiis02/SIPPortal
1. Home Page to test:

Projects Status By Unit 
1.	2018 *
	a.	Hover *
	b.	Backend Query *
	
--Backend Query -------------------------------------
SELECT * FROM sip_projects
WHERE sip_year = 2018 and status::int = 15
-----------------------------------------------------

2.	2019
	a.	Hover *
	
--Backend Query-------------------------------------
SELECT * FROM sip_projects
WHERE sip_year = 2019 and status::int = 15
-----------------------------------------------------

3.	2020
	a.	Hover *
	
--Backend Query-------------------------------------
SELECT * FROM sip_projects
WHERE sip_year = 2020 and status::int = 15
-----------------------------------------------------

4.	2021
	a.	Hover *
	
--Backend Query-------------------------------------
SELECT * FROM sip_projects
WHERE sip_year = 2021 and status::int = 15
-----------------------------------------------------

5.	2022 *
	a.	Hover *
	
--Backend Query-------------------------------------
SELECT * FROM sip_projects
WHERE sip_year = 2022 and status::int = 15
-----------------------------------------------------

6.	2023 *
	a.	Hover *
	
--Backend Query-------------------------------------
SELECT * FROM sip_projects
WHERE sip_year = 2023 and status::int = 15
-----------------------------------------------------

Quick Links
1.	VZV *
2.	NYPD Open Data *
3.	Traffic Stat * This site cant be reached
4.	Safety Viewer *
5.	SIP Tracker *

Recent SIP Links
1.	SIP PID *
	a.	Search *
		i.	My Projects *
			1.	PID * 
		ii.	Search
			1.	SIP #
			2.	SIP Year
			3.	Borough
			4.	SIP PM
			5.	Status
			6.	Unit
			7.	Clear Refresh
	b.	Reload
	c.	Save
	d.	Close
	e.	Find Field to Edit
		i.	Find
		ii.	Clear
	f.	Documents
		i.	Upload Document
	g.	Concrete Work
		i.	New Elements
			1.	Reset All
			2.  Plastic Bus Board Islands
			3.	# of Concrete Median Ext.
				a.	Reset	
			4.	# of Islands, Triangls or Elements not Attached to Sidewalk
				a.	Reset
			5.	Number of Intersections in Project area with Concrete Work
				a.	Reset
			6.	Number of new individual Ped Islands
				a.	Reset
			7.	Number of New Sidewalks 
				a.	Reset
			8.	Number of Expanded Sidewalks
				a.	Reset 
					ii.	Other Materials
						1.	Reset All
						2.	 Jersey Barriers 
							a.	Reset
					iii.	Pedestrain Ramps and Detectable Surfaces
						1.	Reset All
	h.	Descriptive Info
		i.	Reset all
		ii.	ICU 
			1.	Yes 
			2.	No
			3.	Already Complete
		iii.	Exisiting CitiBike Station?
		iv.	In a Citibike Expansion Zone?
		v.	On Route
			1.	On Truck Route
			2.	Intersections Truck Route
			3.	None
			4.	Reset
		vi.	Conflicts with Truck Priority Safety Corridor
			1.	On TPSC
			2.	Intersects TPSC
			3.	None
			4.	Reset
		vii.	VZ Priority Geography
			1.	On VZP
			2.	Intersects VZP
			3.	None
		viii.	Turn Restrictions on Truck Routes
			1.	Ban on Truck Route
			2.	None
			3.	Reset
	i.	Signals and Stop Controls
		i.	New Stop Controls (Signals or Stop signs)
			1.	Reset All
			2.	New Enchanced Crossings 
				a.	Reset
			3.	New Signal or All-Way stop?
				a.	Reset
			4.	New Stop Controls
				a.	Reset
		ii.	Signal Construction
			1.	Reset All
			2.	Will Project trigger APS with anticipated # of intersections
			3.	Count of intersections with Hardware Signal Changes
				a.	Reset
			4.	List of Signal Construction Work
				a.	Reset
			5.	New Signalized intersections/crossings
				a.	Reset
			6.	Number of intersections with major singal work that therefore trigger APS
		iii.	Signal Timing
			1.	Reset All
			2.	Count of intersections with Signal Timing Changes
				a.	Reset
			3.	Number of new LPS’s 
				a.	Reset
	j.	Work/Cost Estimate
		i.	Reset All
		ii.	Number of new neckdowns/curb extensions 
			1.	Reset
	iii.	Grant PINs
	iv.	Bikes
		1.	Reset All

--Bikes

	v.	Freight
		1.	Freight/Trucking Industry review
			a.	On a truck route
			b.	In a BZ
			c.	Truck ban on truck route
			d.	Near distribution center
	vi.	Markings
		1.	Reset All
	vii.	Outreach
		1.	Open to Street Ambassadors?
		2.	Open to Web Portal?
	viii.	Parking
		1.	Reset All
	ix.	Parks
		1.	Reset All
		2.	Coordiantion with Parks?
	x.	Project Overlap
		1.	Reset All
		2.	Captial need for constructions?
		3.	RRM Repaving?
			a.	Reset
		4.	RRM Patch Patch Paving? (removing a median to create a slip lane)
		5.	Capital or DEP conflict.
		6.	Requires removal/relocation of Citibike station
		7.	Is this project over a subway, a rail tunnel, or under an elevated train?
	xi.	Street Access Changes
		1.	Reset All
		2.	Number of turn bans
			a.	Reset
		3.	Street Conversions/Reversals
			a.	Reset
	xii.	Street Furniture
		1.	Reset All
	xiii.	Transit Improvements
		1.	New ADA accessible Bus Stop or replacement
k.	Workflow Tracking
	i.	Reset All
	ii.	Proposed/Ideal start dates for implementation units
	iii.	FDNY Review Required
	iv.	FDNY Submitted Date
	v.	FDNY Approval Date
	vi.	MTA/NYCT Review
	vii.	DSNY Review
	viii.	Constructability Check
	ix.	First CB Meeting
	x.	CB Outreach Complete (for all CBs)
	xi.	If only CB notification is needed, last date of notification submission
	xii.	CAD Drawing Started
	xiii.	Submitted Drawing to GD for Review
	xiv.	Synchro Analysis Completed 
	xv.	Concrete Start date
	xvi.	Concrete End date
	xvii.	Future Capital needed
	xviii.	Signal Approval Date
	xix.	Enhanced Crossing Approval Date
	xx.	Borough Engineers Approval Date
	xxi.	Official Project Imagery
		1.	Completion of Before photo OPI
		2.	OPI gallery finalized and approved?


2. Project Page to Test:

1.	Project Search
	a.	My Projects
		i.	PID
	b.	Search
		i.	SIP#
		ii.	SIP YEAR
		iii. BOROUGH
		iv.	SIP PM
		v.	STATUS
		vi.	UNIT
		vii.	Clear 
		viii.	Refresh
		ix.	PID

3. Sheets Page to test

1.	Add New Private Sheet
	a.	SIP Year *
	b.	Tracking Sheet Name *
	c.	Owner *
	d.	Icon *
		i.	SIP
		ii.	SIMS
		iii.	Freight
		iv.	PED
		v.	None
	e.	READONLY COLUMNS 
		i.	SIP Columns
			1.	Find
			2.	Clear
		ii.	Shared Columns
		iii.	All ->
		iv.	Sel ->
		v.	<- Sel
		vi.	<- All
		vii.	Up Arrow
		viii.	Down Arrow
	f.	USER-DEFINED COLUMNS
		i.	Enter Column Name
		ii.	Add New ->
		iii.	<- Remove
	g.	FILTERS & SORTING
		i.	FILTER BY
			1.	+ ADD FILTER
			2.	X CLEAR ALL
			3.	X REMOVE SELECTED
		ii.	SORT BY
			1.	+ ADD SORT BY
			2.	X CLEAR ALL
	h.	CELL COLORS 
		i.	+ ADD COLOR RULE
			1.	Row or Cell Color?
				a.	Cell Color 
				b.	Row Color
			2.	Select filed to trigger cell//row color chagne
			3.	Set filed value condition to trigger color change
	i.	SHARING
	j.	SAVE
	k.	CLOSE

4. Docs:
2.	Search By PID
3.	SIP Projects By Year

5. About:
	1.	Bacl To SIP PM Tool
	2.	SIP Link

6. Account
1.	Unit
2.	SIP Role
3.	Project Units
4.	PM Tool Admin
5.	Ok
*/


