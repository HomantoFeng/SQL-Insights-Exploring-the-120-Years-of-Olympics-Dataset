-- 1. How many olympics games have been held?

SELECT count(distinct Games) as Olym_games_num
FROM schema_120_Olympics.athlete_events_convert

-- 2. List down all Olympics games held so far.

SELECT Games,City as All_games
FROM schema_120_Olympics.athlete_events_convert
GROUP BY Games,City
ORDER BY Games,City

-- 3. Mention the total no. of nations who participated in each olympics game?
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert JOIN schema_120_Olympics.noc_regions 
USING (NOC)
)

SELECT Games,count(distinct region) as no_nations
FROM add_country_info
GROUP BY Games
ORDER BY Games


-- 4. Which year saw the highest and lowest no of countries participating in olympics?
-- answer, 1896 summer is the lowest no of countries and 2016 summer is the high

SELECT Games,count(distinct NOC) as no_nations
FROM schema_120_Olympics.athlete_events_convert
GROUP BY Games
ORDER BY no_nations desc
LIMIT 1

-- 5. Which nation has participated in all of the olympic games?
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert JOIN schema_120_Olympics.noc_regions 
USING (NOC)
)

SELECT region,count(distinct Games) as no_of_games
FROM add_country_info
GROUP BY region
-- ORDER BY no_of_games DESC
HAVING no_of_games= (SELECT count(distinct Games) FROM schema_120_Olympics.athlete_events_convert)


-- 6. Identify the sport which was played in all summer olympics.

WITH sport_summer_games as (SELECT Sport,Games
FROM schema_120_Olympics.athlete_events_convert
WHERE Season = 'Summer'
GROUP BY Sport,Games),
no_summer_games as (SELECT count(distinct Games) as no_games
FROM schema_120_Olympics.athlete_events_convert
WHERE Season = 'Summer')

SELECT Sport,count(*) as no_games_sport
FROM sport_summer_games
GROUP BY Sport
HAVING no_games_sport=(select no_games from no_summer_games)

-- 7. Which Sports were just played only once in the olympics?
SELECT Sport,count(distinct Games) as no_games_sport,min(Games)
FROM schema_120_Olympics.athlete_events_convert
GROUP BY Sport
HAVING no_games_sport=1

-- 8. Fetch the total no of sports played in each olympic games.
SELECT Games,count(distinct Sport) as no_sport_per_games
FROM schema_120_Olympics.athlete_events_convert
GROUP BY Games
ORDER BY no_sport_per_games DESC


-- 9. Fetch details of the oldest athletes to win a gold medal.
SELECT *
FROM schema_120_Olympics.athlete_events_convert
WHERE Medal='Gold' and age=
(SELECT max(Age)
FROM schema_120_Olympics.athlete_events_convert
WHERE Medal='Gold')

-- 10. Find the Ratio of male and female athletes participated in all olympic games.
SELECT sum(case when Sex='M' THEN 1 ELSE 0 END)/sum(case when Sex='F' THEN 1 ELSE 0 END) as sex_ratio
FROM schema_120_Olympics.athlete_events_convert

-- 11. Fetch the top 5 athletes who have won the most gold medals.
WITH gold_tb AS (SELECT Name,sum(IF(Medal='Gold',1,0)) as gold_num
FROM schema_120_Olympics.athlete_events_convert
GROUP BY Name ORDER BY gold_num DESC),
	rank_tb AS ( SELECT Name,gold_num,dense_rank() over(order by gold_num desc) as gold_rank
FROM gold_tb)

SELECT *
FROM rank_tb
where gold_rank<=5

-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert JOIN schema_120_Olympics.noc_regions 
USING (NOC)
),

medal_tb AS (SELECT Name,region,sum(IF(Medal='Gold' or Medal='Silver' or Medal='Bronze',1,0)) as medal_num
FROM add_country_info
GROUP BY Name, region ORDER BY medal_num DESC),
	
rank_tb AS (SELECT Name,region, medal_num,dense_rank() over(order by medal_num desc) as medal_rank
FROM medal_tb)

SELECT *
FROM rank_tb
where medal_rank<=5


-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
),
medal_tb AS (SELECT region,sum(IF(ISNULL(Medal),0,1)) as medal_num
FROM add_country_info
GROUP BY region ORDER BY medal_num DESC),
rank_tb AS (SELECT region, medal_num,dense_rank() over(order by medal_num desc) as medal_rank
FROM medal_tb)

SELECT *
FROM rank_tb
where medal_rank<=5

-- 14. List down total gold, silver and broze medals won by each country.
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
)

SELECT region,sum(IF(Medal='Gold',1,0)) as Gold_num,sum(IF(Medal='Silver',1,0)) as Silver_num,sum(IF(Medal='Bronze',1,0)) as Bronze_num
FROM add_country_info
GROUP BY region
Order by Gold_num DESC,Silver_num DESC,Bronze_num DESC

-- 15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
)
SELECT Games,region,sum(IF(Medal='Gold',1,0)) as Gold_num,sum(IF(Medal='Silver',1,0)) as Silver_num,sum(IF(Medal='Bronze',1,0)) as Bronze_num
FROM add_country_info
GROUP BY Games,region
Order by Games,region

-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
),

medal_rank_byregion as (SELECT *,dense_rank() OVER(PARTITION BY Games ORDER BY Gold_num DESC) as gold_rank,dense_rank() OVER(PARTITION BY Games ORDER BY Silver_num DESC) as silver_rank,dense_rank() OVER(PARTITION BY Games ORDER BY Bronze_num DESC) as bronze_rank
FROM (
SELECT Games,region,sum(IF(Medal='Gold',1,0)) as Gold_num,sum(IF(Medal='Silver',1,0)) as Silver_num,sum(IF(Medal='Bronze',1,0)) as Bronze_num
FROM add_country_info
GROUP BY Games,region
Order by Games,region ) tmp)

SELECT * 
FROM (
(SELECT Games,concat(region,'-',Gold_num) as top_Gold_country
FROM medal_rank_byregion
where gold_rank=1) as gold
JOIN 
(SELECT Games,concat(region,'-',Silver_num) as top_Silver_country
FROM medal_rank_byregion
where silver_rank=1) as silver
USING (Games)
JOIN
(SELECT Games,concat(region,'-',Bronze_num) as top_Bronze_country
FROM medal_rank_byregion
where bronze_rank=1) as bronze
USING (Games) 
)
ORDER BY Games

-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
),


medal_rank_byregion as (SELECT *,dense_rank() OVER(PARTITION BY Games ORDER BY Gold_num DESC) as gold_rank,dense_rank() OVER(PARTITION BY Games ORDER BY Silver_num DESC) as silver_rank,
dense_rank() OVER(PARTITION BY Games ORDER BY Bronze_num DESC) as bronze_rank,dense_rank() OVER(PARTITION BY Games ORDER BY Medal_num DESC) as Medal_rank
FROM (
SELECT Games,region,sum(IF(Medal='Gold',1,0)) as Gold_num,sum(IF(Medal='Silver',1,0)) as Silver_num,sum(IF(Medal='Bronze',1,0)) as Bronze_num,sum(IF(ISNULL(Medal),0,1)) as Medal_num
FROM add_country_info
GROUP BY Games,region
Order by Games,region ) tmp)

SELECT * 
FROM (
(SELECT Games,concat(region,'-',Gold_num) as top_Gold_country
FROM medal_rank_byregion
where gold_rank=1) as gold
JOIN 
(SELECT Games,concat(region,'-',Silver_num) as top_Silver_country
FROM medal_rank_byregion
where silver_rank=1) as silver
USING (Games)
JOIN
(SELECT Games,concat(region,'-',Bronze_num) as top_Bronze_country
FROM medal_rank_byregion
where bronze_rank=1) as bronze
USING (Games) 

JOIN
(SELECT Games,concat(region,'-',Medal_num) as top_Medal_country
FROM medal_rank_byregion
where medal_rank=1) as medal
USING (Games) 
)
ORDER BY Games

-- 18. Which countries have never won gold medal but have won silver/bronze medals?
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
)

SELECT region,sum(IF(Medal='Gold',1,0)) as Gold_num,sum(IF(Medal='Silver',1,0)) as Silver_num,sum(IF(Medal='Bronze',1,0)) as Bronze_num
FROM add_country_info
GROUP BY region
HAVING Gold_num=0 and (Silver_num>0 or Bronze_num>0)
Order by Gold_num DESC,Silver_num DESC,Bronze_num DESC

-- 19. In which Sport/event, India has won highest medals.
-- (actually, in my script, you can replace contry name with any countries you are intested to query)
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
),
medal_num_by_noc as 
(
SELECT Sport,region,sum(IF(ISNULL(Medal),0,1)) as medal_num
FROM add_country_info
GROUP BY Sport,region
),
medal_num_by_noc_withrank as
(SELECT *,dense_rank() OVER(PARTITION BY region ORDER BY medal_num DESC ) as medal_rank
FROM medal_num_by_noc 
)
SELECT Sport,region,medal_num 
FROM 
medal_num_by_noc_withrank
WHERE region='India' and medal_rank=1


-- 20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games.
-- (actually, in my script, you can replace contry name with any countries you are intested to query)
WITH add_country_info as 
(
SELECT *
FROM schema_120_Olympics.athlete_events_convert2 JOIN schema_120_Olympics.noc_regions 
USING (NOC)
)
SELECT region, Games,count(*) as medals_Hockey
FROM add_country_info
WHERE region='India' and Sport='Hockey' and ISNULL(Medal)<>True
GROUP BY Games
ORDER BY Games
