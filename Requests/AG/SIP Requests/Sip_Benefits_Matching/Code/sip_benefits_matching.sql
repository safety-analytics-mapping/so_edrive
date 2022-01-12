-- Bike Lane
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%New Facility%'
AND (full_treatment like '%Standard%' OR full_treatment like '%Curbside%' OR full_treatment like '%Buffered%')
AND full_treatment not like '%Removed%'


-- Bus Board Island
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Bus Board Island%'
AND full_treatment not like '%Removed%'


-- Bus Lane
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%SBS%'
AND full_treatment not like '%Removed%'


-- Channelization
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Channelization%'
AND full_treatment not like '%Removed%'


-- Curb Extension
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Neckdown%'
AND full_treatment not like '%Removed%'



-- Lane Stripe
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Parking Stripe%'
OR full_treatment like '%Non-Bike WPL%'
AND full_treatment not like '%Removed%'



-- Left Turn Bay
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Turn Bays%Left%'
AND full_treatment not like '%Removed%'



-- Left Turn Lane
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Left Turn Lane%'
AND full_treatment not like '%Removed%'



-- LBI
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%LBI%'
AND full_treatment not like '%Removed%'



-- LPI
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%LPI%'
AND full_treatment not like '%Removed%'



-- MEDIAN
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Median%'
AND full_treatment not like '%Tips%'
AND full_treatment not like '%Removed%'
AND full_treatment not like '%Bus Board Island%'
AND full_treatment not like '%Turn Bays%Left%'




-- MEDIAN TIP EXTENSIONS
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Median%'
AND full_treatment like '%Tips%'
AND full_treatment not like '%Removed%'




-- PEDESTRIAN SAFETY ISLANDS
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Ped Refuge Islands%'
AND full_treatment not like '%Removed%'




-- PEDESTRIAN SPACE
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Other Ped Space%'
AND full_treatment not like '%Removed%'




-- PROTECTED BIKING LANE
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%New Facility%Protected%'
AND full_treatment not like '%Removed%'




-- QWICK KURB
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Qwick%'
AND full_treatment not like '%Removed%'




-- RAISED CROSSWALK
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Raised Crosswalk%'  
AND full_treatment not like '%Removed%'





-- Remove One Travel Lane In Each Direction
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Lane%' 
AND full_treatment like '%Removed%'    




-- SIDEWALK EXPANSION
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Expansion%'
AND full_treatment not like '%Removed%'      




-- SPLIT PHASE
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Split Phase%'
AND full_treatment not like '%Removed%'




-- TUFF CURB
SELECT qid, full_treatment, full_treatment_int
FROM public.sip_flattened_tree
WHERE full_treatment like '%Tuff%' 
AND full_treatment not like '%Removed%'