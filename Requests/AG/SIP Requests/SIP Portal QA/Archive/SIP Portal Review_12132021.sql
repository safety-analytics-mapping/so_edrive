/*SIP Portal Review

* = Functions Properly
*! = Error

Header to test:

https://qagisapps.nycdot.nyc/SIPPortal
1.	Home button *     
2.	Search Projects button *
3.	Help button *
4.	Mail button  
5.	Account *

http://dotdevgisiis02/SIPPortal
1. Home Page to test:

Map
1.	Map + *
2.	Map – * 
3.	Map Layers 
	a.	All Projects 
		i.	Completed SIP Projects *
		ii.	Ongoing/Planned SIP Projects *
		iii.	Other Projects *
	b.	VZ Priority Geographies *
		i.	VZ Corridors *  
		ii.	VZ Intersections *
		iii.	VZ Zones *
	c.	Bike Lanes *
	d.	Bike Priority Districts *
	e.	Senior Areas *
	f.	City Council Districts *
	g.	Community Districts *
	h.	Zip Codes *
	i.	Police Precints *
	j.	Boroughs  *
	k.	Clion *
	l.	Est Motor Vehicle AADT *
		i.	Very Low (<3k) *
		ii.	Low (3-5k) *
		iii.	Mid-Low (5-7k) *
		iv.	Mid-High (7-9k) *
		v.	High (9-25k) *
		vi.	Very High (>25k) *
	m.	RRM *
		i.	RRM weekly *
		ii.	RRM Seasonal *
	n.	Special Events 
	o.	Cyclomedia * Extra white space in project pop up window. Text not fitted to size of gmaps picture.
		i.	Date Selection *
		ii.	Maximize *
		iii.	Minimize *
		iv.	Project Location Selection *
		v.	Open Location in Google Maps *
4.	Map Scroll *
5.	Map Pan *
6.	Map I * Does nothing


My Projects 
1.	Project Name *
2.	Start Date * 
3.	End Date  *
4.	Unit  *
5.	Funding Source *
6.	MTP  *
	a.	MTP *
	b.	MTP / Bikes *
7.	VZ Status *
8.	Status *
9.	Approved SIP *
10.	Date Approved *
11.	Project Manager *
12.	Assigned To *
13.	Select Geometry *
	a.	Segment * 
	b.	Node *
14.	Filter by Street Name 
	a.	– Geometries * Does not work, does not solely deselect filtered name
	b.	+ Geometries *
15.	Save  *
16. Delete*
    
-- Delete Background----------------------------------
SELECT * 
FROM sip_treatments
WHERE tid = 57914;

SELECT * 
FROM sip_projects
WHERE pid = 10048;
------------------------------------------------------


New Project

--Project Backend-------------------------------------
SELECT * 
FROM sip_projects sp
JOIN sip_lookup sl
ON sp.unit::varchar = sl.lookupid::varchar
JOIN sip_lookup sl2
ON sp.capital::varchar = sl2.lookupid::varchar
JOIN sip_lookup sl3
ON sp.status::varchar = sl3.lookupid::varchar
JOIN sip_lookup sl4
ON sp.vz_status::varchar = sl4.lookupid::varchar
ORDER BY date_updated DESC
----------------------------------------------

1.	Project Name *
2.	Start Date *
3.	End Date * 
4.	Unit *
5.	Funding Source *
6.	MTP *
    a.	MTP *
	b.	MTP / Bikes *
7.	VZ Status *
8.	Status *
9.	Approved SIP *
10.	Date Approved *
	a. Should only be approved <= Startdate *! 
11.	Project Manager *
12.	Assigned To *
13.	Select Geometry *
	a.	Segment *
	b.	Node *
14.	Filter by street name *
	a.	– Geometries * Does not work, does not solely deselect filtered name
	b.	+ Geometries *
15.	Save *
16.	Delete *
17.	Treatments  *
	a.	Project Name *
	b.	Treatment Bullet  *
		i.	Treatment Created By:  *
		ii.	Project Assigned To: *
		iii.	Improvement Name *
		iv.	Start Date *
		v.	End Date *
		vi.	Treament Type *
			1.	Bikes *
			2.	Bus Treatments *
			3.	Channelization *
			4.	Median Changes *
			5.	Moving Lane Changes *
			6.	Pedestrian Treatments *
			7.	Streetscape Elements *
			8.	Traffic Controls *
			9.	Turn Restrictions *
			10.	Vehicle Parking *
		vii.	Number of Lanes *
		viii.	Select Geometry *
			1.	Segment  *
			2.	Node *
		ix.	Filter by Street Name 
			1.	– Geometries * Does not work, does not solely deselect filtered name
			2.	+ Geometries *
		x.	Save *
		xi.	Delete *
		xii.	Back to all Treatments *
	c.	New Treatment Button *  
		i.	Improvement name  *
		ii.	Start Date * 
		iii.	End Date *
		iv.	Treatment Type  *
			1.	Bikes *
			2.	Bus Treatments * 
			3.	Channelization *
			4.	Median Changes * 
			5.	Moving Lane Changes *  
			6.	Pedestrian Treatments *
			7.	Streetscape Elements *
			8.	Traffic Controls *
			9.	Turn Restrictions *
			10.	Vehicle Parking*
		v.	Select Geometry *
			1.	Segment *
			2.	Node *
		vi.	Filter by Street Name * 
		vii.	– Geometries * Does not work, does not solely deselect filtered name
		viii.	+ Geometries *
		ix.	Save *
		x.	Back to all Treatments *
		
-- Treatments Backend ----------------------------	
SELECT st.*, sq.question, sq2.question
FROM public.sip_treatments st
JOIN sip_questions sq
ON st.treatmenttype::varchar = sq.qid::varchar
JOIN  sip_questions sq2
ON st.breadcrumbid::varchar = sq2.qid::varchar
WHERE tid = 57901 or pid_fk = 10044;


SELECT id, tid_fk, qid_fk, q_value, sq.question
FROM public.sip_treatments_attr sta
JOIN sip_questions sq
ON sta.qid_fk::varchar = sq.qid::varchar
WHERE tid_fk = 57901;

--Segment Treatments Geo
SELECT *
FROM sip_treatments_geo stg
JOIN clion c 
ON stg.segmentid::int = c.segmentid::int
WHERE tid_fk = 57901;

--Node Treatments Geo
SELECT *
FROM sip_treatments_geo stg
JOIN clion_node c 
ON stg.nodeid::int = c.nodeid::int
WHERE tid_fk = 57905;
--------------------------------------------------

Treatment Notes: 
- Every Completed SIP has to have at least one treatment
- The treatment has to be closed out
- The treatment needs to have geometry
- When saving a completed SIP with a treatment, 
the breadcrumbid of the treatment should be the bottom of a 
treatment tree

Errors:
- Should be able to add a new treatment after the SIP is completed

18.	Delegate *
	a.	User ID *
	b.	First Name *
	c.	Last Name *
	d.	Email *
	e.  Unit *
	
--Delegate Backend------------------------------------
SELECT * 
FROM sip_projects sp
WHERE assignedto = 'soge'
------------------------------------------------------

19.	Summary *
	a.	Description *
	b.	Insert Background and Location Information: *
		i.	+ *
	c.	Crash History  !* - KSI Does not add up on summary. Pulls in data from safety data viewer incorrectly.
						  - Does not pull in latest data

--Crash History Backend-------------------------------
SELECT segmentid FROM sip_projects_geo
WHERE pid_fk = 10044
------------------------------------------------------
	
	d.	Please select images layout:  *
		i.	1 Image *
		ii.	2 Images  *
	e.	Image 1 *
		i.	Import Image 1 *   
	f.	Save *
	g.	Improvements Repopulate *
		i.	+ *
		ii.	Trash  *

--Improvements Backend-------------------------------------
SELECT * 
FROM sip_treatments
WHERE tid = 57901;

SELECT * 
FROM sip_treatments_attr
WHERE tid_fk = 57901;
-----------------------------------------------------------

	h.	Benefits Repopulate *
		i.	+ *
		ii.	Trash *

--Benefits Backend-----------------------------------------
SELECT * 
FROM sip_benefits
WHERE qid_fk = 281
-----------------------------------------------------------

	i.	Please select images layout: *
		i.	1 Image *
		ii.	2 Images *
		iii.	3 Image *
		iv.	4 Images *
	j.	Image 1 *
		i.	Import Image 1  *
	k.	Save *
	l.	Scope *
		i.	Concrete Work *
		ii.	Concrete Work-Ramps only *
		iii.	Flexible Bollards *
		iv.	Street Furniture with Partner *
		v.	Landscaping-Maintenance Partner *
		vi.	Landscaping-Parks *
		vii.	Markings *
		viii.	Martello/Bell Bollard *
		ix.	Roadway Resurfacing *
		x.	Rubber Isalnd/Bus Boarder *
		xi.	Signal Installation/Reconfiguration *
		xii.	Signal Timing Plans *
		xiii.	Signs Curb Regulations *
		xiv.	Signs-Traffic Control *
		xv.	Colored or Textured Roadways *
	m.	Images: Existing Conditions *
		i.	Import Image *
	n.	Proposed Configuration *
		i.	Import image 2 *
	o.	Photo Archive *
	p.	Save *
	q.	Before Images *
		i.	Import Before Image  *
	r.	After Image * 
		i.	Import After Image * 
	s.	Save *
	t.	3 Pager /  4 Pager  *
	u.	Generate PDF *
	v.	Leave Summary 
		i.	Warning *
			1.	Quit *
			2.	Save *

Issue: 
- Warning for maximum page limit does not go away once your 
within limit.

20.	MTP 
	- Prior to switching MTP status, in backend MTP shows us as null. After switching MTP status and switching back to select, MTP shows up as 0. *!
	- Spacing between 'Other:' and user entered text does not get produced. *!
	a.	ADA Accessibility *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	Other *
	b.	Bus Bulbs *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	There are no bus stops at this location *
			2.	Location does not meet technical criteria for a Bus Bulb *
			3.	A Bus Bulb is not constructible *
			4.	During the public review process, DOT heard concerns from community members and/or elected officials about Bus Bulbs and decided not to pursue them at this location at this time *
			5.	Due to resource constraints, a Bus Bulb will not be installed at this time* 
			6.	Other *
	c.	Bus Lanes *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	There are no buses at this location *
			2.	Reduction in vehicular travel lanes necessary to create a Bus Lane would  result in vehicle congestion and operational concerns *
			3.	During the public review process, DOT heard concerns from community  members and/or elected officials about Bus Lanes and decided not to pursue them at this location at this time *
			4.	Due to resource constraints, a Bus Lane will not be installed at this time*
			5.	Other *
	d.	Daylighting *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	Other treatments were installed to slow turns and/or enhance visibility* 
			2.	During the public review process, DOT heard concerns from community members and/or elected officials about Daylighting and decided not to pursue Daylighting at this location at this time *
			3.	Daylighting is not feasible/needed at this location based on professional engineering judgement *
			4.	Other *
	e.	Dedicated Vehicle Loading and Unloading Zones *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	Adjacent land uses do not require Dedicated Vehicle Loading and Unloading Zone(s) *
			2.	Dedicated Vehicle Loading and Unloading Zone(s) is not feasible/needed at this location at this time based on professional engineering judgment*
			3.	During the public review process, DOT heard concerns from community members and/or elected officials about Dedicated Vehicle Loading and Unloading Zone(s) and decided not to pursue these loading/unloading zones at this location at this time *
			4.	Other *
	f.	Narrow Vehicle Lanes (10ft or Less) *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	This location is a bus route, 11' travel lanes are standard *
			2.	This location has two-way traffic with lanes directly adjacent to traffic moving in the opposite direction, 11' travel lanes are standard *
			3.	During the public review process, DOT heard concerns from community members and/or elected officials about Narrow Vehicle Lanes and decided not to pursue them at this location at this time *
			4.	Narrow Vehicle Lanes are not feasible/needed at this location at this time based on professional engineering judgment *
			5.	This location is a truck route, 11' travel lanes are standard *
			6.	Other *
	g.	Pedestrian Safety Islands *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	A Pedestrian Safety Island is not feasible/needed at this location at this time based on professional engineering judgment *
			2.	A Pedestrian Safety Island at this location would create geometric challenges and operational concerns *
			3.	Other pedestrian safety feature(s) exist at this location *
			4.	During the public review process, DOT heard concerns from community members and/or elected officials about Pedestrian Safety Islands and decided not to pursue them at this location at this time *
			5.	Due to resource constraints, a Pedestrian Safety Island will not be installed at this time *
			6.	Other *
	h.	Protected Bicycle Lane * 
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	Reduction in vehicular travel lanes necessary to create a Protected Bicycle Lane would result in vehicle congestion and operational concerns *
			2.	A Protected Bicycle Lane is not feasible/needed at this location at this time based on professional engineering judgment *
			3.	Addition of a Protected Bicycle Lane would not connect to the larger network and/or would be a stand alone lane with no connections at either end *
			4.	During the public review process, DOT heard concerns from community members and/or elected officials about Protected Bicycle Lanes and decided not to pursue them at this location at this time *
			5.	Due to resource constraints, a Protected Bicycle Lane will not be installed at this time *
			6.	Other *
	i.	Signal-Protected Pedestrian Crossings * 
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	Existing vehicular turning volumes do not allow for a conflict-free pedestrian crossing at this location *
			2.	No signal infrastructure exists at this location *
			3.	During the public review process, DOT heard concerns from community members and/or elected officials about a Signal Protected Pedestrian Crossing and decided not to pursue it at this location at this time *
			4.	Due to resource constraints, a Signal Protected Pedestrian Crossing will not be installed at this time *
			5.	Other *
	j.	Signal Retiming * 
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	Signal retiming at this location is not feasible/needed at this time based on professional engineering judgment *
			2.	No signal infrastructure exists at this location *
			3.	During the public review process, DOT heard concerns from community members and/or elected officials about Signal Retiming s and decided not to pursue it at this location at this time *
			4.	Due to resource constraints, Signal Timing will not be altered at this time *
			5.	Other *
	k.	Wide Sidewalks (8ft or Greater) *
		i.	Included in Project *
		ii.	Preexisiting feature *
		iii.	Not included in project *
			1.	Sidewalk Widening at this location is not feasible/needed at this time based on professional engineering judgment *
			2.	During the public review process, DOT heard concerns from community members and/or elected officials about Sidewalk Widening and decided not to pursue it at this location at this time *
			3.	Due to resource constraints, Sidewalk Widening will not occur at this time *
			4.	Other *
			
--MTP Backend-------------------------------------	
SELECT * 
FROM sip_project_mtp_checklist
WHERE project_id = 10044;

SELECT * 
FROM sip_project_mtp_sub_checklist
WHERE proj_id = 10044;

select *
from sip_project_mtp_sub_checklist spm
join sip_mtp_sub_checklist_lookup l
on spm.sub_question_seq_id = l.subqid
where proj_id = 10044;
---------------------------------------------------

21.	SIP PM Tool  



http://dotdevgisiis02/SIPPortal#/project-search

2. Search Page to test:

Project Search

1.	Project Name *
2.	Status *
	a.	Pre-SIP *
	b.	SIP *
	c.	Capital 
	d.	Completed SIP *
	e.	SIP / Completed SIP *
	f.	On Hold *
	g.	Non-SIP Program *
3.	Sip Year *
4.	Unit *
	a.	Bikes and Greenways *
	b.	BC’s Office *
	c.	Freight *
	d.	Ped Unit *
	e.	Public Space *
	f.	RIS *
	g.	School Safety *
	h.	Special Projects *
	i.	Traffic Engineering and Planning *
	j.	Transit Development *

--UNIT Backend-------------------------------------	
SELECT sl.description, count(pid)
FROM sip_projects sp
JOIN sip_lookup sl
ON sp.unit::varchar = sl.lookupid::varchar
GROUP BY sl.description
ORDER BY sl.description
---------------------------------------------------	

5.	Funding Source *
	a.	FHWA *
	b.	FTA *
	c.	None *

--Funding Source Backend---------------------------
SELECT sl.description, count(pid)
FROM sip_projects sp
JOIN sip_lookup sl
ON sp.capital::varchar = sl.lookupid::varchar
GROUP BY sl.description
ORDER BY sl.description
---------------------------------------------------

6.	MTP *
	a.	MTP *
	b.	MTP Bikes *
	
--MTP Backend---------------------------
SELECT sl.description, count(pid)
FROM sip_projects sp
JOIN sip_lookup sl
ON sp.mtp::varchar = sl.lookupid::varchar
GROUP BY sl.description
ORDER BY sl.description
---------------------------------------------------

Notes:
- None option should be available for MTP project 
search

7.	Vision Zero *
	a.	None *
	b.	Priority Area *
	c.	Priory Area + Corridor *
	d.	Priority Corridor *
	e.	Priority Intersection *
	f.	Priority Intersection + Area *
	g.	Priority Intersection + Corridor *
	h.	Priority Intersection + Corridor + Area *
	i.	VZ Project *
8.	Project Manager  *
	a.	User ID *
	b.	First Name *
	c.	Last Name *
	d.	Email *
9.	Assigned To *
	a.	User ID *
	b.	First Name *
	c.	Last Name *
	d.	Email *

Search That Newly Added Project Exists

1.	Project Name *
2.	Status *
3.	Sip Year *
4.	Unit *
5.	Funding Source *
6.	MTP *
7.	Vision Zero *
8.	Project Manager  *
9.	Assigned To *

	
Geography Search

1.	Borough *
	a.	Staten Island *
	b.	Manhattan *
	c.	Bronx *
	d.	Brooklyn *
	e.	Queens *
	
--Borough Backend---------------------------
WITH data AS(
SELECT lboro + rboro boro,pid 
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
)

SELECT   CASE WHEN boro = 2 THEN 'MANHATTAN' 
			WHEN boro = 4 THEN 'BRONX' 
			WHEN boro = 6 or boro = 7 THEN 'BROOKLYN' 
			WHEN boro = 7 or boro = 8 THEN 'QUEENS' 
			WHEN boro = 10 THEN 'STATEN ISLAND' END,
			count (DISTINCT pid)
FROM data
GROUP BY 1
--------------------------------------------

SELECT count(DISTINCT pid) 
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
WHERE lboro = 4 or rboro=4

SELECT DISTINCT pid, rboro, lboro
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
WHERE (lboro = 4 or rboro=4) and pid = 673

2.	City Council District *
3.	Community District *
4.	Police Precinct *
5.	Senior Area *
	a.	 True/False *
6.	Vision Zero Geography *
	a.	VZ Zone *
	b.	VZ Corridor *
	c.	VZ Intersection *
	d.	Any VZP *
	e.	Not VZP *
7.	Zip Code *

Treatment Type Search

1.	Treatment type *
	a.	Bikes *
	b.	Bus Treatments *
	c.	Channelization *
	d.	Median Changes *
	e.	Moving Lane Changes *
	f.	Pedestrian Treatments *
	g.	Streetscape Elements *
	h.	Traffic Controls *
	i.	Turn Restrictions *
	j.	Vehicle Parking *

Search That Only Treatments in Newly
Added Projects Come Up For Search

1.	Treatment type *
	a.	Bikes *
	b.	Bus Treatments *
	c.	Channelization *
	d.	Median Changes *
	e.	Moving Lane Changes *
	f.	Pedestrian Treatments *
	g.	Streetscape Elements *
	h.	Traffic Controls *
	i.	Turn Restrictions *
	j.	Vehicle Parking *
	
	
Search Projects Button

1.	Download SHP *
2.	Print Map *
3.	Project Name *
4.	SIP Year *
5.	Start Date *
6.	End Date *
7.	Unit *
8.	Funding Source *
9.	MTP * 
10.	Status *
11.	VZ Status  *
12.	PM *
13.	Map + *
14.	Map – *
15.	Map Layers *
	a.	All Projects *
		i.	Completed SIP Projects *
		ii.	Ongoing/Planned SIP Projects *
		iii.	Other Projects *
	b.	VZ Priority Geographies *
		i.	VZ Corridors *
		ii.	VZ Intersections *
		iii.	VZ Zones *
	c.	Bike Lanes *
	d.	Bike Priority Districts *
	e.	Senior Areas *
	f.	City Council Districts *
	g.	Community Districts *
	h.	Zip Codes *
	i.	Police Precints *
	j.	Boroughs *
	k.	Clion *
	l.	Est Motor Vehicle AADT *
	m.	RRM *
		i.	RRM weekly *
		ii.	RRM Seasonal *
16.	Map Scroll *
17.	Map Pan *
18.	Map Select *
	a.	Project Link Select *
	b.	Open Location in Google Maps *
19.	Map I * Does nothing
20. Export To Excel
21. Magnifying Glass
	a. Attributes *
	b. Comparator *
	c. Input *
	d. Reset *
	e. Find !* Does not work. 
21. Page Number
22. Items per Page


http://dotdevgisiis02/SIPPortal//Images/SIPPortalGuide.pdf

3. Help: *
1.	SIP Portal User Guide & Treatment Descriptions *

4. Mail: *
1.	To *
2.	CC *
3.	Message *
4.	Send Question *
 
5. Account *
1.	Username display *

6. Footer *
1.	* SIP in footer is not all caps.



