-----------------------Question 1------------------------------
CREATE DATABASE pageviews;

SHOW DATABASES;

USE pageviews;

CREATE TABLE pageviews_table1 (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

DESCRIBE pageviews_table1;
	
LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q1-local/pageviews-20210120-200000' INTO TABLE PAGEVIEWS_TABLE1;

SELECT * FROM pageviews_table1
	WHERE domain_code='en' AND page_title != 'Main_Page' AND page_title != 'Special:Search'
	ORDER BY count_views desc LIMIT 10;



SELECT * FROM pageviews_table1
	WHERE domain_code='en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' LIMIT 5;

------------------------------------------
DROP TABLE pageviews_table1;
DROP TABLE pageviews_table2;
SHOW TABLES;

------------------------------------------
CREATE TABLE pageviews_table2 (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

DESCRIBE pageviews_table2;

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q1-local/pageviews-20210120-210000' INTO TABLE PAGEVIEWS_TABLE2;


SELECT * FROM pageviews_table2
	WHERE domain_code='en' AND page_title != 'Main_Page' AND page_title != 'Special:Search'
	ORDER BY count_views desc LIMIT 10;

----------------------------------------

select page_title, sum(count_views) total_views
from
(
    select domain_code, page_title, count_views
    from pageviews_table1
    union all
    select domain_code, page_title, count_views
    from pageviews_table2 
) t
WHERE domain_code='en' AND page_title != 'Main_Page' AND page_title != 'Special:Search'
group by page_title
ORDER BY total_views desc LIMIT 10;



INSERT OVERWRITE DIRECTORY '/user/hive/output-pageviews-total'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'


-----------Question 2----------------------

CREATE DATABASE fraction_clickstream;
SHOW DATABASES;
USE fraction_clickstream;

CREATE TABLE clickstream_dec(
	prev STRING,
	curr STRING,
	ref_type STRING,
	n INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t';

SHOW TABLES;
DESCRIBE clickstream_dec;

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q2-local/half-dec-clickstream/part-r-00000' INTO TABLE CLICKSTREAM_DEC;

--------------------------
DROP TABLE clickstream_dec;
--------------------------

SELECT * FROM clickstream_dec
WHERE ref_type = 'link'
ORDER BY n desc LIMIT 10;

--------------*******************--------------

SELECT prev, SUM(n) total_clicks FROM clickstream_dec
WHERE ref_type = 'link'
GROUP BY prev
ORDER BY total_clicks desc LIMIT 10;

-----------------------------------------------------------------------------------------
CREATE TABLE pageviews_dec (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

DESCRIBE pageviews_dec;

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q2-local/dec15-pageviews/pageviews-20201215-200000' INTO TABLE pageviews_dec;

-------------***********-------------
SELECT * FROM pageviews_dec
	WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
	ORDER BY count_views desc LIMIT 10;

--------------**********----------------


WITH link_clicks AS (
	SELECT prev, SUM(n) total_clicks
	FROM clickstream_dec
	WHERE ref_type = 'link'
	GROUP BY prev
), page_views AS (
	SELECT page_title, (count_views * 24 * 31) monthly_views
	FROM pageviews_dec
	WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
)
SELECT page_title, monthly_views, total_clicks, (total_clicks / monthly_views) ratio
FROM link_clicks
JOIN page_views ON link_clicks.prev = page_views.page_title
ORDER BY ratio desc
LIMIT 5

----------------------------------------------------------




------------------Question 3-------------------------------




DESCRIBE clickstream_dec;

SELECT prev, SUM(n) total_clicks FROM clickstream_dec
WHERE prev = 'Hotel_California' AND ref_type = 'link' 
GROUP BY prev;

SELECT prev, curr as hc_curr, n as hc_clicksfrompage FROM clickstream_dec
WHERE prev = 'Hotel_California' AND ref_type = 'link'
ORDER BY hc_clicksfrompage desc;

SELECT prev, SUM(n) as hc_sumclicks FROM clickstream_dec 
WHERE prev = 'Hotel_California' AND ref_type = 'link'
GROUP BY prev;

--
SELECT prev, SUM(n) as df_sumclicks FROM clickstream_dec 
WHERE prev = 'Don_Felder' AND ref_type = 'link'
GROUP BY prev;

SELECT prev, SUM(n) as hc_sumclicks2 FROM clickstream_dec 
WHERE prev = 'Don_Felder' OR prev = 'Glenn_Frey' OR prev = 'Desperado_(Eagles_song)' OR prev = 'Coda_(music)' OR prev = 'Take_It_Easy' 
	AND ref_type = 'link'
GROUP BY prev;

---------------
DESCRIBE pageviews_dec;

SELECT page_title, count_views from pageviews_dec 
WHERE page_title = 'Hotel_California' AND domain_code= 'en';

SELECT page_title, (count_views * 24 * 31) as hc_dec_countviews from pageviews_dec 
WHERE page_title = 'Hotel_California' AND domain_code= 'en';

--
SELECT page_title, count_views from pageviews_dec 
WHERE page_title = 'Don_Felder' AND domain_code= 'en';

SELECT page_title, (count_views * 24 * 31) as df_dec_countviews from pageviews_dec 
WHERE page_title = 'Don_Felder'AND domain_code= 'en';

--

SELECT page_title, count_views from pageviews_dec 
WHERE page_title = 'Glenn_Frey' AND domain_code= 'en';

SELECT page_title, (count_views * 24 * 31) as df_dec_countviews from pageviews_dec 
WHERE page_title = 'Glenn_Frey' AND domain_code= 'en';

--

SELECT page_title, count_views from pageviews_dec 
WHERE page_title = 'Desperado_(Eagles_song)' AND domain_code= 'en';

SELECT page_title, (count_views * 24 * 31) as df_dec_countviews from pageviews_dec 
WHERE page_title = 'Desperado_(Eagles_song)' AND domain_code= 'en';


-------------hc first ratio set-----------------

WITH hc_link_clicks AS (
	SELECT prev, curr, n as hc_total_clicks FROM clickstream_dec
	WHERE prev = 'Hotel_California' AND ref_type = 'link'
), hc_page_views AS (
	SELECT page_title, (count_views * 24 * 31) as hc_dec_countviews from pageviews_dec 
	WHERE page_title = 'Hotel_California' AND domain_code= 'en'
)
SELECT page_title, curr, hc_total_clicks, hc_dec_countviews, (hc_total_clicks / hc_dec_countviews) hc_dec_ratio
FROM hc_link_clicks
JOIN hc_page_views ON hc_link_clicks.prev = hc_page_views.page_title
ORDER BY hc_dec_ratio desc
LIMIT 38;

-------------hc second ratio set-----------------

WITH df_link_clicks AS (
	SELECT prev, curr, n as df_total_clicks FROM clickstream_dec
	WHERE prev = 'Don_Felder' AND ref_type = 'link'
), df_page_views AS (
	SELECT page_title, (count_views * 24 * 31) as df_dec_countviews from pageviews_dec 
	WHERE page_title = 'Don_Felder' AND domain_code= 'en'
)
SELECT page_title, curr, df_total_clicks, df_dec_countviews, (df_total_clicks / df_dec_countviews) df_dec_ratio
FROM df_link_clicks
JOIN df_page_views ON df_link_clicks.prev = df_page_views.page_title
ORDER BY df_dec_ratio desc;

-------------hc third ratio set-----------------

WITH eag_link_clicks AS (
	SELECT prev, curr, n as eag_total_clicks FROM clickstream_dec
	WHERE prev = 'Eagles_(band)' AND ref_type = 'link'
), eag_page_views AS (
	SELECT page_title, (count_views * 24 * 31) as eag_dec_countviews from pageviews_dec 
	WHERE page_title = 'Eagles_(band)' AND domain_code= 'en'
)
SELECT page_title, curr, eag_total_clicks, eag_dec_countviews, (eag_total_clicks / eag_dec_countviews) eag_dec_ratio
FROM eag_link_clicks
JOIN eag_page_views ON eag_link_clicks.prev = eag_page_views.page_title
ORDER BY eag_dec_ratio desc;

-----------------------------------------------------------


--------------------------Question 4-----------------------
CREATE TABLE ukpageviews_dec (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q3-local/pageviews-20201215-120000' INTO TABLE ukpageviews_dec;

SELECT domain_code, page_title, count_views from ukpageviews_dec 
WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
ORDER BY count_views desc LIMIT 10; 

select SUM(count_views) uk_totalcountviews from ukpageviews_dec
WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
GROUP BY domain_code;

------


CREATE TABLE uspageviews_dec (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

SHOW TABLES;


LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q3-local/pageviews-20201215-180000' INTO TABLE uspageviews_dec;

SELECT domain_code, page_title, count_views from uspageviews_dec 
WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
ORDER BY count_views desc LIMIT 10; 

select SUM(count_views) us_totalcountviews from uspageviews_dec
WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
GROUP BY domain_code;

---

WITH us AS (
	SELECT domain_code, page_title, count_views from uspageviews_dec 
	WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
), uk AS (
	SELECT domain_code, page_title, count_views from ukpageviews_dec 
	WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
)
SELECT us.page_title, us.count_views as usviews, uk.count_views as ukviews, (us.count_views - uk.count_views) AS diff
FROM us
JOIN uk ON us.page_title = uk.page_title
ORDER BY diff desc LIMIT 10;



-----------------------------


	
	--------------------QUESTION 5-------------------------
CREATE DATABASE revision_history;
SHOW DATABASES;
SHOW TABLES;
USE revision_history;

CREATE TABLE rev_hist(
	wiki_db STRING,
	event_entity STRING,
	event_type STRING,
	event_timestamp STRING,
	event_comment STRING,
	event_user_id BIGINT,
	event_user_text_historical STRING,
	event_user_text STRING,
	event_user_blocks_historical array<string>,
	event_user_blocks array<string>	,
	event_user_groups_historical array<string>,
	event_user_groups array<string>,
	event_user_is_bot_by_historical	array<string>,
	event_user_is_bot_by array<string>,
	event_user_is_created_by_self boolean,
	event_user_is_created_by_system	boolean,
	event_user_is_created_by_peer boolean,
	event_user_is_anonymous boolean,
	event_user_registration_timestamp string,
	event_user_creation_timestamp string,
	event_user_first_edit_timestamp string,
	event_user_revision_count bigint,
	event_user_seconds_since_previous_revision bigint,
	page_id bigint,
	page_title_historical string,
	page_title string,
	page_namespace_historical int,
	page_namespace_is_content_historical boolean,
	page_namespace int,
	page_namespace_is_content boolean,
	page_is_redirect boolean,
	page_is_deleted boolean,
	page_creation_timestamp string,
	page_first_edit_timestamp string,
	page_revision_count bigint,
	page_seconds_since_previous_revision bigint,
	user_id bigint,
	user_text_historical string,
	user_text string,
	user_blocks_historical array<string>,
	user_blocks array<string>,
	user_groups_historical array<string>,
	user_groups array<string>,	
	user_is_bot_by_historical array<string>,
	user_is_bot_by array<string>,
	user_is_created_by_self	boolean,
	user_is_created_by_system boolean,
	user_is_created_by_peer boolean,
	user_is_anonymous boolean,
	user_registration_timestamp string,
	user_creation_timestamp string,
	user_first_edit_timestamp string,
	revision_id bigint,
	revision_parent_id bigint,
	revision_minor_edit boolean,
	revision_deleted_parts array<string>	,
	revision_deleted_parts_are_suppressed boolean,
	revision_text_bytes bigint,
	revision_text_bytes_diff bigint,
	revision_text_sha1 string,
	revision_content_model string,
	revision_content_format string,
	revision_is_deleted_by_page_deletion boolean,
	revision_deleted_by_page_deletion_timestamp string,
	revision_is_identity_reverted boolean,
	revision_first_identity_reverting_revision_id bigint,
	revision_seconds_to_identity_revert bigint,
	revision_is_identity_revert boolean,
	revision_is_from_before_page_creation boolean,
	revision_tags array<string>)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY '\t';

DROP TABLE rev_hist;
	
DESCRIBE rev_hist;

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q5-local/2020-12.enwiki.2020-12.tsv' INTO TABLE rev_hist;

SELECT * from rev_hist WHERE wiki_db='enwiki' LIMIT 5;
SELECT * from rev_hist WHERE wiki_db='enwiki' AND page_title='Wonder_Woman_1984' AND event_user_text_historical = 'ClueBot NG' AND event_comment LIKE 'Reverting possible vandalism%' AND event_timestamp LIKE '2020-%' LIMIT 10;
SELECT * from rev_hist WHERE wiki_db='enwiki' AND event_user_text_historical = 'ClueBot NG' AND event_comment LIKE 'Reverting possible vandalism%' AND event_timestamp LIKE '2020-%' LIMIT 50;


SELECT AVG(page_seconds_since_previous_revision) FROM rev_hist 
WHERE wiki_db='enwiki' 
	AND event_user_text_historical = 'ClueBot NG' 
	AND event_comment LIKE 'Reverting possible vandalism%' 
	AND event_timestamp BETWEEN '2020-12-15 11:42:00.0' AND '2020-12-15 12:42:00.0'
		LIMIT 10;
		

----------------------
SHOW TABLES;
CREATE TABLE pageviews_dec (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

DESCRIBE pageviews_dec;
DROP TABLE pageviews_dec;

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q2-local/dec15-pageviews/pageviews-20201215-200000' INTO TABLE pageviews_dec;


SELECT SUM(count_views) FROM uspageviews_dec
WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-';

SELECT (SUM(count_views) / 3600) as views_per_second FROM pageviews_dec
WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'

-------

----attempted to, but unable to join these tables------
WITH pgviews AS ( 
	SELECT (SUM(count_views) / 3600) as views_per_second FROM pageviews_dec
	WHERE domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-'
), revs AS (
	SELECT AVG(page_seconds_since_previous_revision) as AVG_seconds_since_prev_revision FROM rev_hist 
	WHERE wiki_db='enwiki' 
	AND event_user_text_historical = 'ClueBot NG' 
	AND event_comment LIKE 'Reverting possible vandalism%' 
	AND event_timestamp BETWEEN '2020-12-15 11:42:00.0' AND '2020-12-15 12:42:00.0'
)SELECT views_per_second, AVG_seconds_since_prev_revision, 
	(views_per_second * AVG_seconds_since_prev_revision) as views_vandalized_page FROM pgviews 
	FULL JOIN revs ON pgviews.page_title = revs.page_title
	LIMIT 10;
	


--------------------------QUESTION 6--------------------------------------
SHOW TABLES;

-----partitioning test----

CREATE EXTERNAL TABLE pageviews_ext (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' '
	LOCATION '/user/melissawhite/pgviews_ext';

DESCRIBE pageviews_ext;
DROP TABLE pageviews_ext;

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q2-local/dec15-pageviews/pageviews-20201215-200000' INTO TABLE pageviews_ext;

CREATE TABLE views_language (
	page_title STRING,
	count_views INT,
	total_response_size INT
	) PARTITIONED BY(domain_code STRING)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

DESCRIBE views_language;

DROP TABLE views_language;

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT INTO TABLE views_language PARTITION(domain_code)
SELECT domain_code, page_title, count_views, total_response_size FROM pageviews_ext;

-------
CREATE TABLE pageviews_lang (
	domain_code STRING,
	page_title STRING,
	count_views INT,
	total_response_size INT)
	ROW FORMAT DELIMITED
	FIELDS TERMINATED BY ' ';

DROP TABLE pageviews_lang;

LOAD DATA LOCAL INPATH '/home/melissawhite/project1/q1-local/pageviews-20210120-200000' INTO TABLE pageviews_lang;


SELECT page_title, count_views FROM pageviews_lang WHERE count_views > 20000 AND domain_code= 'en' AND page_title != 'Main_Page' AND page_title != 'Special:Search' AND page_title != '-' LIMIT 5;

SELECT page_title, count_views FROM pageviews_lang WHERE count_views > 1000 AND domain_code= 'es' AND page_title != 'Wikipedia:Portada' AND page_title != 'Especial:Buscar' AND page_title != '-' LIMIT 5;

SELECT page_title, count_views FROM pageviews_lang WHERE count_views > 2000 AND domain_code= 'fr' AND page_title != 'Wikipédia:Accueil_principal' AND page_title != 'Spécial:Recherche' AND page_title != '-' LIMIT 5;

SELECT page_title, count_views FROM pageviews_lang WHERE count_views > 2000 AND domain_code= 'de' AND page_title != 'Wikipedia:Hauptseite' AND page_title != 'Spezial:Suche' AND page_title != 'Special:MyPage/toolserverhelferleinconfig.js' AND page_title != '-' LIMIT 5;

