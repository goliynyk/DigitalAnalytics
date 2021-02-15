-- DIGITAL ANALYTICS: TRAFFIC SOURCE ANALYSIS (sql reiew Count and Case statements)

-- BASED ON: MAVEN ADVANCED SQL: MY SQL COURSE ON UDEMY - great course, highly recommend
-- https://www.udemy.com/course/advanced-sql-mysql-for-analytics-business-intelligence/

-- SECTION 5, LESSONS 32 - 49
-- Traffic Source Analysis (part 1) 5 assignments -Email, Social, Search, Direct (Mktg Director type questions)
-- -- a.	Overall point: Where is most traffic coming from, how source performs in terms of volumes and conversion rates 
-- -- -- -- and adjusting bids to optimize marketing budgets (answer – gmail, non br)
-- -- b.	Is converstion rate to orders high enough (A: no, only 2.88%, so bid down gmail, nonbr, confirm traffic falls)
-- -- c.	Check conversion rate mobile (0.96%)  versus desktop (3.73%) bid up desktop
-- -- d.	Confirm volume of sessions increase



-- Conversion rate approach
SELECT
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_cr
FROM website_sessions
		LEFT JOIN orders 
			ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;


-- Sect 4 assignment 21, 22: From CEO 1st of 5: Live one month, where is all the traffic coming from
SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) AS session
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY
	utm_source,
    utm_campaign,
    http_referer
ORDER BY 4 DESC;
-- Answer: All traffic coming from Google Nonbranded


-- Sect 4 assignment 23, 24 2nd of 5: From Mkt Mgr: what is CR for Google Nonbranded
SELECT
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) as orders,
    COUNT(order_id) / COUNT(website_sessions.website_session_id) AS cvr
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';
-- Answer 2.88%; should be closer to 4%, otherwise spending too much
    
-- Concept 25
-- -- COUNT and CASE

SELECT
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS single_items_orders,
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS two_items_orders

FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

  
    
-- Sect 4 assignment 26, 27 3rd of 5: Mkt Mgr: Over past month, we lowered bid on google nonbrand starting on 4/15/12.


-- Need to confirm that trended traffic sessions overall wasn't hurt
-- note: GROUP BY vs SELECT: WEEK(create_at)
SELECT
	-- WEEK(created_at),
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions

FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	WEEK(created_at)
ORDER BY 1 ASC
;
-- ANSWER: traffic was negatively impacted, volume down, now need to make up volume in other campaigns that have better CR rate


-- Sect 4 assignment 28, 29 4th of 5: Mkt Mgr: To increase volume, bid higher on Desktop, mobile device experience is poor.
-- -- First let's analyze at current conversion rate by device

SELECT
	device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
	COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_cv
FROM website_sessions
		LEFT JOIN orders
			ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY device_type
ORDER BY 1 DESC
;
-- ANSWER: poor Mobile conversion rate, will bid higher on Desktop
-- -- will boost Sales they will rank higher in auction


-- Sect 4 assignment 30,31 5th of 5: Mkt Mgr: To increase volume, bid higher on Desktop, mobile device experience is poor.
-- -- show weekly trends for Desktop and Mobile to see if bid change on 5/19 impact volumes (which would then translate to better CR overall

SELECT
	-- WEEK(created_at)
    MIN(DATE(created_at)) AS start_of_week,
    -- COUNT(DISTINCT website_session_id) AS sessions_total,
    COUNT(CASE WHEN device_type = 'mobile' THEN 'mobile' ELSE NULL END) AS sessions_mobile,
    COUNT(CASE WHEN device_type = 'desktop' THEN 'desktop' ELSE NULL END) AS sessions_desktop
    -- AS weekly_start_dates
FROM website_sessions
WHERE created_at < '2012-06-09'
	AND created_at > '2012-04-15'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at)
ORDER BY WEEK(created_at)
;
-- ANSWER: desktop traffic did increase a result of bidding up on Desktop which had better CR

-- PGO make up - not exercise associated with this
-- what is CR for Google Nonbranded after remixing desktop and mobile after 5/20
SELECT
	website_sessions.created_at,
    MIN(DATE(website_sessions.created_at)) AS start_of_week,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) as orders,
    COUNT(order_id) / COUNT(website_sessions.website_session_id) AS cvr
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-06-09'
	    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(website_sessions.created_at);
-- Answer 2.88%; should be closer to 4%, otherwise spending too much

