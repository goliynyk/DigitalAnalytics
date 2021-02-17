-- New
-- DIGITAL ANALYTICS: WEBSITE PERFORMANCE ANALYSIS (sql review: multi step queries, temp tbls, subqueries)

-- BASED ON: MAVEN ADVANCED SQL: MY SQL COURSE ON UDEMY - great course, highly recommend
-- https://www.udemy.com/course/advanced-sql-mysql-for-analytics-business-intelligence/

-- SECTION 5, LESSONS 32 - 49
-- --Website Performance Analysis 7 assignments  (what’s happening on website:entry page for each session, most viewed url, bounce rates) – (Website Mgr) 
-- -- -- a.	Overall point: Understand where customers are landing on the website and how they make there way
-- -- -- --  through the conversion funnel on the path to placing an order
-- -- -- b.	Top Website Content 2 (most viewed url, determine landing page per session)
-- -- -- c.	Landing Page Performance , A/B Testing, trends 3 (bounce rates, bounce rate comparison, trends)
-- -- -- d.	Analyzing and Testing Conversion Funnels 2 (deep dive on how far user navigated through website


-- OVERVIEW OF EACH LESSON
-- Understand where customers are landing on the website and how they make there way through the conversion funnel on the path to placing an order
-- Sect 5 lesson 34, 35 Top pages viewed		1st of 7: 
-- Sect 5 lesson 36, 37 Entry page determine	2nd of 7: Top entry pages per session			2012 06 09*
-- Sect 5 lesson 39, 40 Bounce rates entry		3rd of 7: Calc bounce rates from entry page		2012 06 12*
-- Sect 5 lesson 41, 42 Bounce Rates a/b		4th of 7: Landing page A/B tests				2012 07 28*
-- Sect 5 lesson 43, 44 Bounce Rates trends		5th of 7: Landing page trends					2012 08 31+ COMBINE steps 1,2,3
-- Sect 5 lesson 46, 47 Conversion Funnels 1	6th of 7: Building Conversion funnels			2012 09	05
-- Sect 5 lesson 48, 49 Conversion Funnels 2	7th of 7: Analysing Conversion funnels			2012 11 10


-- check session and url views over time in pbi
SELECT
	YEAR(created_at) AS year_time,
    QUARTER(created_at) AS quarter_time,
	COUNT(DISTINCT website_pageview_id) AS pv_count
FROM website_pageviews
GROUP BY year_time, quarter_time
ORDER BY year_time, quarter_time;


-- Sect 5 Concept: Website performance description: multi step queries


-- -- most viewed page
SELECT
	pageview_url,
    COUNT(website_pageview_id) AS pvs
    
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY 1
ORDER BY pvs DESC
;

-- -- findincg first page view id
-- DROP TEMPORARY TABLE first_pageviews;
-- CREATE TEMPORARY TABLE first_pageviews
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id
;

-- -- match first page view id to a) pull in url and session, then b) count sessions hitting that landing page
SELECT
	website_pageviews.pageview_url AS landing_page, -- aka "entry page"
    COUNT(DISTINCT first_pageviews.website_session_id) AS landing_page_count
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews.min_pv_id
GROUP BY landing_page
ORDER BY landing_page_count DESC
;
-- NOTE: everyone landing on home page at this point, so make sure it is a great page


-- Sect 5 assignment 34,35 1st of 7: Top website pages viewed Morgan: website manager on 6/9/2012:  most viewed webs pages

SELECT
	pageview_URL,
    COUNT(DISTINCT website_pageview_id) pvs
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY pvs DESC
;
-- Answer  look at home, products, mr fuzzy
-- -- next steps - are these list represenetative of top entry page, look at performance of each page

-- Sect 5 assignment 36,37 2nd of 7: Top entry pages; Morgan: website manager on 6/12/2012:  top entry pages pages

-- step 1: isolate entry pages per session
-- DROP TEMPORARY TABLE entry_pages;
-- CREATE TEMPORARY TABLE entry_pages
SELECT
	website_session_id,
    MIN(website_pageview_id) entry_page_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id
;


-- step 2: now that page view isolated, count number of pageview hits to that or those entry pages
SELECT
	pageview_url,
	COUNT(DISTINCT website_pageview_id) AS entry_count -- this should limit to just entry related pageviews b/c of join
		
FROM entry_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = entry_pages.entry_page_id
GROUP BY pageview_url
ORDER BY entry_count DESC
;
-- ANSWER all landing on homepage, is it best initial experience for customers
-- -- next steps: what metric to measure performance; is that as good as we want

-- SECT 5 ASSIGNMENT 38
-- CONCEPT: Bounce rates (session level concept): 
-- -- performance of key landing pages and then test to improve results
-- -- what was landing page, how many sessions, how many bounced and what is the bounce rate

-- Step 1: what is the landing page: identify landing page id: website_pageviews > first_page_views_demo
-- Step 2: what is the landing page: identify landing page url: first_page_views_demo LEFT JOIN page_view_url > 
-- -- file has session id, landing page url,
-- Step 3: count total page views for each session but flag only bounced session id's by limiting to 1
-- Step 4: summarize total and bounced sessions

-- build table with folowing fields, then group and count
-- -- website session id
-- -- landing page url
-- -- column with website session id of bounced
-- then group and count
-- -- group by landing page url, count websession ids for two columns, add a 4th calc column for bounce rate


-- step 1
-- DROP TEMPORARY TABLE first_pv_demo;
-- CREATE TEMPORARY TABLE first_pv_demo
SELECT
	website_session_id,
    MIN(website_pageview_id) AS Min_Pageview_Id
FROM website_pageviews
WHERE created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY website_session_id;

SELECT *
FROM first_pv_demo;

-- step 2 - pull in landing page url for each website session
-- CREATE TEMPORARY TABLE sessions_w_landing_page
SELECT
	first_pv_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page

FROM first_pv_demo
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_pageview_id = first_pv_demo.Min_Pageview_Id
;
-- 14,826 sessions with landing page identified

-- bring in and count all pageviews for that session, then just limit to bounced sessions

-- CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
	sessions_w_landing_page.website_session_id,
    sessions_w_landing_page.landing_page,
    COUNT(DISTINCT website_pageviews.pageview_url) AS count_of_pages_viewed
FROM sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_landing_page.website_session_id
GROUP BY
	sessions_w_landing_page.website_session_id,
    sessions_w_landing_page.landing_page
HAVING count_of_pages_viewed = 1;
-- subset of 7,036 website sessions with bound ids versus 14,826 total sessions


-- step 3 now add those bounced session back into table as a new column
SELECT
	sessions_w_landing_page.landing_page,
    COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS sessions_total,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) AS sessions_bounced,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) / 
			COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_landing_page
	LEFT JOIN bounced_sessions_only
		ON sessions_w_landing_page.website_session_id = bounced_sessions_only.website_session_id
GROUP BY
	sessions_w_landing_page.landing_page;

-- SECT 5 ASSIGNMENT 39, 40 Bounce Rates 3rd of 7: calc bounce rates Morgan: website manager on 6/14/2012:  bounce rate for home page
-- build table with folowing fields, then group and count
-- -- website session id
-- -- landing page url
-- -- column with website session id of bounced
-- then group and count
-- -- group by landing page url, count websession ids for two columns, add a 4th calc column for bounce rate

-- step 1: isolate entry pages per session
-- CREATE TEMPORARY TABLE tbl_UrlEntryID
SELECT
	website_session_id,
    MIN(website_pageview_id) entry_page_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id
;

-- step 2: add url to final table, purpose of join is to drop in url to fianl table
-- CREATE TEMPORARY TABLE tbl_Final
SELECT
	tbl_UrlEntryID.website_session_id,
    website_pageviews.pageview_url
FROM tbl_UrlEntryID
	LEFT JOIN website_pageviews
		ON tbl_UrlEntryID.entry_page_id = website_pageviews.website_pageview_id;

-- step 3: create temp table of sessions ids with total views, isolate bounced sessions
-- --  and use join to limit (note purpose of join appears to be to limit table size so could have used date)
-- CREATE TEMPORARY TABLE tbl_SessionIdsBounced
SELECT
	tbl_Final.website_session_id,
    COUNT(website_pageviews.website_pageview_id) AS sessions_total
FROM tbl_Final
	LEFT JOIN website_pageviews
		ON tbl_Final.website_session_id = website_pageviews.website_session_id
GROUP BY tbl_Final.website_session_id
HAVING sessions_total = 1
ORDER BY sessions_total DESC; -- 6,536 rows

-- step 4: to Final table add column of session ids that bounced, purpose of join is to add to final table
SELECT
	tbl_Final.pageview_url,
    COUNT(tbl_Final.website_session_id) AS sessions_tot,
    COUNT(tbl_SessionIdsBounced.website_session_id) AS sessions_bounced,
    COUNT(tbl_SessionIdsBounced.website_session_id) / COUNT(tbl_Final.website_session_id) AS bounce_rate
FROM tbl_Final
	LEFT JOIN tbl_SessionIdsBounced
		ON tbl_Final.website_session_id = tbl_SessionIdsBounced.website_session_id
GROUP BY tbl_Final.pageview_url
;
-- ANSWER of home page bounce rate is close to 60%; next steps is to set up a new custom landing page then A/B testing

-- SECT 5 ASSIGNMENT 41, 42 Bounce Rates a/b		4th of 7: Landing page A/B tests
-- -- Morgan: website manager on 7/28/2012: it is 6 weeks later, new land page built, A/B test comparison

-- STEP 0: find when / lander launched
-- STEP 1: find first pageview id for each sessions (limit to relevant time period)
-- STEP 2: identify landing page for each session
-- STEP 3: count pageviews for each session
-- STEP 4: summarize total sessions and bounced session, by a/b test

-- STEP 0: find when / lander launched
SELECT
	MIN(created_at),
    MIN(website_pageview_id)
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL
;
-- ANSWER url id is 23504 on  6/19/2012

-- STEP 1: find first pageview id for each sessions (limit to relevant time period and utm sourch and utm campaign
-- -- table join is only for limit in where clause
-- DROP TEMPORARY TABLE first_test_pageviews;
-- CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
	AND website_sessions.created_at < '2012-07-28'
    AND website_pageviews.website_pageview_id > '23504'
GROUP BY website_pageviews.website_session_id;
-- Answer = 4,753 rows

-- STEP 2: identify landing page for each session
-- -- table join back to pageview table is to pull in landing page
-- CREATE TEMPORARY TABLE nonbrand_test_session_w_landing_page
SELECT
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
	first_test_pageviews
		LEFT JOIN  website_pageviews
			ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE pageview_url IN ('/home', '/lander-1');	
-- Answer = 4,753 rows again

-- STEP 3: count pageviews for each session
-- CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
	a.website_session_id,
    a.landing_page,
    COUNT(b.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_session_w_landing_page a
	LEFT JOIN website_pageviews b
		ON a.website_session_id = b.website_session_id
GROUP BY a.website_session_id, a.landing_page
HAVING COUNT(b.website_pageview_id) = 1;
-- Answer = 2,550 rows

-- STEP 4: summarize total sessions and bounced session, by a/b test
-- STEP 4a
SELECT
	a.landing_page,
    a.website_session_id,
	b.website_session_id AS bounced_website_session_id
FROM nonbrand_test_session_w_landing_page a
	LEFT JOIN nonbrand_test_bounced_sessions b
		ON a.website_session_id = b.website_session_id
ORDER BY a.website_session_id;

-- STEP 4b final output - count
SELECT
	a.landing_page,
    COUNT(DISTINCT a.website_session_id) AS sessions,
	COUNT(DISTINCT b.website_session_id) AS bounced_session,
    COUNT(DISTINCT b.website_session_id) /  COUNT(DISTINCT a.website_session_id) AS bounce_rate
FROM nonbrand_test_session_w_landing_page a
	LEFT JOIN nonbrand_test_bounced_sessions b
		ON a.website_session_id = b.website_session_id
GROUP BY a.landing_page;
-- ANSWER: new landing page is performing better so all traffic will be directed there moving forward

-- SECT 5 ASSIGNMENT 43, 44 Bounce Rates trends		5th of 7: Landing page trends					2012 08 31+
-- -- Morgan: website manager: confirm all re-routed overall traffic going to new landing page and confirm that bounce rates are favorable

-- STEP 1: find first pageview id for each sessions (limit to relevant time period)
-- STEP 2: identify landing page for each session
-- STEP 3: count pageviews for each session
-- STEP 4: summarize total sessions and bounced session, to lander

-- NEW combine STEPS 1, 2, and 3!!! cleaner coding
-- STEP 1: find first pageview id for each sessions (limit to relevant time period)
-- STEP 2: identify landing page for each session  (skipped this and pull in later)
-- STEP 3: count pageviews for each session

-- DROP TEMPORARY TABLE sessions_w_min_pv_and_view_count;
-- CREATE TEMPORARY TABLE sessions_w_min_pv_and_view_count
SELECT
	website_sessions.website_session_id,
    MIN(website_pageview_id) AS first_pageview_id,
    COUNT(website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
	website_sessions.created_at > '2012-06-01' AND website_sessions.created_at < '2012-08-31'
	AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY website_sessions.website_session_id;
-- Answer = 11,623 rows

-- STEPS new
-- DROP TEMPORARY TABLE sessions_w_counts_lander_and_created_at;
-- CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT
	sessions_w_min_pv_and_view_count.website_session_id,
    sessions_w_min_pv_and_view_count.first_pageview_id,
    sessions_w_min_pv_and_view_count.count_pageviews,
    pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_and_view_count
		LEFT JOIN website_pageviews
			ON sessions_w_min_pv_and_view_count.first_pageview_id = website_pageviews.website_pageview_id; -- added this on 2021 01 23
	
-- STEPS summarize
-- template
SELECT
	session_created_at 						-- AS year_week,
    session_created_at						-- AS week_start_date,
    website_session_id						-- AS total_sessions,
    count_pageviews, website_session_id 	-- AS bounced_sessions,
    count_pageviews, website_session_id 	-- AS bounce_rate
    landing_page, website_session_id		-- AS home_sessions,
    landing_page, website_session_id 		-- AS lander_sessions

FROM sessions_w_counts_lander_and_created_at;

-- fill in fields
SELECT
	YEARWEEK(session_created_at)																						AS year_week,
    MIN(DATE(session_created_at))																						AS week_start_date,
    COUNT(DISTINCT website_session_id)																					AS total_sessions,
    COUNT(CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) 											AS bounced_sessions,
    COUNT(CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0 / COUNT(DISTINCT website_session_id)	AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) 								AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) 							AS lander_sessions

FROM sessions_w_counts_lander_and_created_at

GROUP BY year_week;

-- ANSWER: In June, bounce rate around 60%; in Aug, bounce rate is 53% as all traffic is re-routed to new lander page

