
-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
-- No of tables used in the query 
-- %wins of each bidder 
-- 1
select * from ipl_bidder_details; -- fetch the data from the table bidder_id and bidder_name(bidder_id)
-- 2.
select * from ipl_bidding_details; -- bid_status 
-- 3.
select * from ipl_bidder_points; -- no_of_bids`

select bidder_id,bidder_name,bid_status,no_of_bids,SUM(CASE WHEN bid_status LIKE 'won' THEN 1 ELSE 0 END) total_no_of_wins,
ROUND((SUM(CASE WHEN bid_status LIKE 'won' THEN 1 ELSE 0 END) / no_of_bids) * 100, 2) win_percentage
from ipl_bidder_details join ipl_bidding_details using(bidder_id) 
join ipl_bidder_points using(bidder_id)
GROUP BY bidder_id , bidder_name , no_of_bids
ORDER BY win_percentage DESC;


-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.
select * from ipl_stadium; # fetch the stadium_name and city of the stadium 
select * from ipl_match_schedule; # fetch stadium id and match id 
select * from ipl_match;
SELECT 
    stadium_id, stadium_name, city,COUNT(city) AS No_of_matches 
    -- no of matches are completed according to the status of table ipl_match_schedule
FROM
    ipl_match_schedule ims LEFT JOIN ipl_match im 
    ON ims.MATCH_ID = im.MATCH_ID
	JOIN ipl_stadium USING (stadium_id)
WHERE
    status = 'completed'
GROUP BY stadium_id , stadium_name , city
ORDER BY stadium_id , stadium_name;

-- or 
SELECT count(im.Match_id) No_of_match,s.stadium_name,s.city
FROM ipl_match_schedule im JOIN ipl_stadium s
using (stadium_id)
group by s.STADIUM_NAME,s.city;

-- 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
select STADIUM_ID,STADIUM_NAME from ipl_stadium; 
select TOSS_WINNER,MATCH_WINNER from ipl_match where TOSS_WINNER=MATCH_WINNER ;
select bid_team,bid_status from ipl_bidding_details;

SELECT stadium_id,stadium_name, SUM(CASE WHEN toss_winner = match_winner THEN 1 ELSE 0 END) common_winner, COUNT(stadium_id) total_matches,
 (SUM(CASE WHEN toss_winner = match_winner THEN 1 ELSE 0 END) / COUNT(stadium_id)) * 100 win_percentage
FROM ipl_match JOIN ipl_match_schedule USING (match_id) JOIN ipl_stadium USING (stadium_id)
WHERE status = 'completed'
GROUP BY stadium_id , stadium_name
ORDER BY stadium_id;

-- 4.	Show the total bids along with the bid team and team name.
SELECT * FROM ipl_bidder_details;
SELECT * FROM ipl_bidding_details; -- bid team, bid_status
SELECT * FROM ipl_TEAM;
select ibd.bid_team ,ifnull(it.team_name,"total"),count(ibd.bid_team)
total_bids_per_team from ipl_bidding_details ibd
left join ipl_team it on ibd.bid_team=it.team_id
group by it.team_name with rollup;-- USE FOR SUM OF TOTAL BID of all TEAMs

-- or 
SELECT COUNT(BID_TEAM) NO_OF_BID ,IBD.BID_TEAM,IT.TEAM_NAME
FROM IPL_BIDDING_DETAILS IBD
JOIN IPL_TEAM IT
ON IBD.BID_TEAM = IT.TEAM_ID
GROUP BY IBD.BID_TEAM,IT.TEAM_NAME;

-- 5.	Show the team id who won the match as per the win details.
select * from IPL_TEAM; -- team_id and team_name
select * from IPL_MATCH; -- team_id1,team_id2 AND match_winner
SELECT IT.TEAM_ID, IT.TEAM_NAME, IM.TEAM_ID1, IM.TEAM_ID2,IM.MATCH_WINNER,IM.WIN_DETAILS
FROM IPL_TEAM IT
JOIN IPL_MATCH IM
ON SUBSTR(IT.REMARKS,1,3) = SUBSTR(IM.WIN_DETAILS,6,3);

-- 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.
SELECT  ITS.TEAM_ID,SUM(MATCHES_PLAYED) TOTAL_MATCHES,SUM(MATCHES_WON) NO_OF_MATCH_WON,SUM(MATCHES_LOST) NO_OF_MATCH_LOST,IT.TEAM_NAME
FROM ipl_team IT
JOIN ipl_team_standings ITS
USING(TEAM_ID)
GROUP BY IT.TEAM_NAME,ITS.TEAM_ID;
-- 7.	Display the bowlers for the Mumbai Indians team.
SELECT *
FROM ipl_team_players;
SELECT DISTINCT(TEAM_ID), PLAYER_ROLE
FROM ipl_team_players
WHERE PLAYER_ROLE="BOWLER" ;
SELECT IP.PLAYER_ID,IP.PLAYER_NAME,ITP.PLAYER_ROLE,IT.TEAM_NAME
FROM ipl_player IP
JOIN ipl_team_players ITP
USING(PLAYER_ID)
JOIN ipl_team IT
USING(TEAM_ID)
WHERE IT.TEAM_NAME="Mumbai Indians" AND ITP.PLAYER_ROLE="Bowler";

-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 
-- all-rounders in descending order.
SELECT TEAM_NAME,ITP.PLAYER_ROLE,COUNT(ITP.PLAYER_ROLE) NO_OF_ALL_ROUNDERS
FROM ipl_team IT 
JOIN ipl_team_players ITP
USING(TEAM_ID)
WHERE ITP.PLAYER_ROLE= "All-Rounder"
GROUP BY IT.TEAM_NAME,ITP.PLAYER_ROLE
HAVING COUNT(ITP.PLAYER_ROLE) > 4;
-- 9. Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
SELECT * FROM ipl_bidder_details;
select * from ipl_bidding_details;
SELECT * FROM ipl_match_schedule;
SELECT * FROM ipl_bidder_points;
SELECT * FROM ipl_stadium;
Select * from ipl_match;
select * from ipl_team;
create view winner as
(select *, if(match_winner = 1, team_id1,team_id2) m_winner from ipl_match);

select  BIDDER_ID,bid_status, year(bid_date), sum(total_points)
from ipl_bidder_points join ipl_bidding_details using (bidder_id)
where bid_team = (select team_id from ipl_team where REMARKS = 'CSK') and
SCHEDULE_ID in (select SCHEDULE_ID from ipl_match_schedule 
					where STADIUM_ID = (select STADIUM_ID from ipl_stadium where STADIUM_NAME = "M. Chinnaswamy Stadium")
                    and MATCH_ID in (select MATCH_ID from winner where m_winner = (select team_id from ipl_team where REMARKS = 'CSK')))
group by BID_STATUS,year(BID_DATE),BIDDER_ID
order by sum(TOTAL_POINTS) desc;

-- 10.	Extract the Bowlers or All Rounders those are in the 5 highest number of wickets.
with temp as(
select TEAM_NAME, PLAYER_NAME, PLAYER_ROLE, cast(substring(performance_dtls,position('Wkt-' in performance_dtls)+4,2) as decimal) Wickets 
from ipl_team_players a join ipl_player b using (player_id)
join ipl_team using (team_id)
where PLAYER_ROLE in ('Bowler','All-Rounder')
)
select * from
(select *, dense_rank()over(order by Wickets desc) rnk from temp) t
where rnk <= 5;

-- 11.show the percentage of toss wins of each bidder and display the results in descending order based on the percentage



SELECT  BIDDER_ID,TOSS_WINNER,COUNT(TOSS_WINNER) NO_OF_TOSS_WIN,ROUND(COUNT(TOSS_WINNER)/(COUNT(bidder_id) over() )* 100,2) PERCENTAGE
FROM ipl_match IM
JOIN ipl_match_schedule
USING(MATCH_ID)
JOIN ipl_bidding_details
USING(SCHEDULE_ID)
GROUP BY BIDDER_ID,TOSS_Winner
ORDER BY percentage DESC
;

-- 12.find the IPL season which has min duration and max duration.
-- tables 
select * from ipl_tournament; -- TOURNMT_ID,TOURNMT_NAME,to_Date,from_date
select TOURNMT_ID,TOURNMT_NAME,datediff(to_Date,from_date) date_diff from ipl_tournament 
order by date_diff desc
limit 1;
select TOURNMT_ID,TOURNMT_NAME,datediff(to_Date,from_date) date_diff from ipl_tournament 
order by date_diff asc
limit 1;

with temp  as (
select TOURNMT_ID,TOURNMT_NAME,datediff(to_Date,from_date) date_diff,
 rank() over (order by  datediff(TO_DATE,from_date)) rank_min,
 rank() over (order by  datediff(TO_DATE,from_date) desc ) rank_max
 from ipl_tournament
 ) -- this temp table fetch the tournment_id, Tournment_name and duration in days after fetching the data 
 select TOURNMT_ID,TOURNMT_NAME,date_diff Duration_days
 from temp
 where rank_min=1
 or rank_max=1;
-- First create a temp table and in this table first we select the tournmt_id,TOURNMT_NAME,date_difference by using the from date to to date it will return the 
-- no of days and alias it by date_diff next we used the rank function on date difference and assign min or max rank according to the no of days 
-- now call the temp table in another main query and it will return three rows 
-- rank() rank for each row within a partition of a result set.

-- 13.Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order
select * from ipl_bidder_details;-- fetch bidder_id,bidder_name
select * from ipl_bidder_points; -- total points
select * from ipl_bidding_details; -- bid_date extract month and year 

select ibd.Bidder_ID,ibd.Bidder_Name, year(bid_date) as Year,month(bid_date) as Month, ibp.Total_points
from ipl_bidder_details ibd join ipl_bidder_points ibp using(bidder_id) join
ipl_bidding_details ibds using(bidder_id)
where year(bid_date)= 2017
group by BIDDER_ID,year,month,TOTAL_POINTS
order by TOTAL_POINTS desc,month asc;

-- In this query we used ipl_bidder_details, ipl_bidder_points, ipl_bidding_details table and fetch the data 
-- Bidder_ID,Bidder_Name,  Year,month,Total_points, (bidder_id) is common to all tables we have to fetch only 2017 year data and group it 
-- by using group by clause columns are BIDDER_ID,year,month,TOTAL_POINTS, and order it by using oreder by clause and columns are total points and months  
-- Aryabhatta Parachure get the highest point(35) and Gagan Panda get lowest point (0)

-- 14.	Write a query for the above question using sub queries by having the same constraints as the above question.
select * from ipl_bidding_details; -- fetch month,year,
select * from ipl_bidder_details;
select * from ipl_bidder_points;
-- select bidder_id, bid_date, year(bid_date) yr, month(bid_date) mt from ipl_bidding_details
-- where year(bid_date) = 2017
-- group by bidder_id, year(bid_date),month(BID_DATE);
-- bidder_id, year= 2014,extract month from bid_date
with temp as
(select bidder_id, year(bid_date) year, month(bid_date) month from ipl_bidding_details
where year(bid_date) = 2017
group by bidder_id, year(bid_date),month(BID_DATE)
) -- this subquery return the bidder_id,bidder_name,year,month,total_points in descending order 
select bidder_id, 
(select bidder_name from  ipl_bidder_details ibds where ibds.BIDDER_id = temp.BIDDER_ID) bidder_name,
year, month,
(select total_points from ipl_bidder_points a where a.BIDDER_ID = temp.BIDDER_ID) total_points
from temp
order by total_points desc, month asc;

-- In this query first we have created a temp table 
-- by using subquery return the bidder_id,bidder_name,year,month,total_points in descending order it will show the all bidder id of year 2017,
-- but show the name from both tables where the bidder_id are same in both temp table and ipl_bidder_details table and 
-- fetch the total_points from ipl_bidder_points where the bidder_id matched with the temp table 
-- now place it in desc(total_points) or ascending order(asc) We get the 55 rows (121(ID)	Aryabhatta Parachure(Name)	2017(year)	4(month)	35(total points)) got the highest point and (109	Gagan Panda	2017	5	0)
-- got the lowest points 
-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
select * from ipl_bidding_details;-- bidder_id,bid_date
select * from ipl_bidder_details; -- bidder_name
select * from ipl_BIDDER_POINTS; -- total points
with temp  as (
select * from (
select BIDDER_ID,TOTAL_POINTS,
 rank() over (order by  TOTAL_POINTS) rank_min,
 rank() over (order by  TOTAL_POINTS desc ) rank_max
 from ipl_BIDDER_POINTS ) t
 where rank_max <=3 or rank_min <=3)
 
 
 SELECT distinct BIDDER_ID,TOTAL_POINTS,year(BID_DATE) Year,BIDDER_NAME,
 if(rank_max <=3, Bidder_name,null) Highest_Bidder,
 if(rank_min <=3 ,bidder_name, null) Lowest_bidder
 FROM TEMP JOIN ipl_bidding_details using(bidder_id)
 JOIN ipl_bidder_details using(bidder_id)
 WHERE year(bid_date)=2018 ;
 -- In this query we used ipl_bidding_details, ipl_bidder_details, ipl_BIDDER_POINTS tables, now we have to find out top 3 and bottom 3 ranks  
 -- by using the rank() over() function which are used in temp table so it will assign to the different columns highest_bidder and lowest_bidder
 -- of the year 2018 
 -- finally we get the result max total point and min total points of different bidder_id with their name in the year 2018 so that we get only 6 rows from the data tables 

-- 16.	Create two tables called Student_details and Student_details_backup.

create table Student_details (
Student_id int not null primary key, 
Student_name varchar(20) not null, 
mail_id varchar(20), 
mobile_no bigint
)
;
insert into student_details values(1,'Sanvika','sanvi@gmail.com',893264876);
insert into student_details values(2,'anvi','anvi@gmail.com',83264876);
select * from student_details;
create table Student_details_backup as select * from Student_details;
select * from student_details_backup;
create trigger insert_trig
after insert on Student_details
for each row
insert into Student_details_backup (Student_id,student_name,mail_id,mobile_no) 
values (new.Student_id,new.student_name,new.mail_id,new.mobile_no);


-- This is a student table which have 4 attributes with differnt data type and size now we created a trigger name as insert_trig
-- and use after insert for each row, so the trigger run when any event occur and it will perform insert,delete,update operations and replce the old values by new values 
-- so it will run automatically 
-- Now what happen in result when i am inserting the data into Student_details it automatically updated into the table like a new record in the student_details_backup 
-- and check it by using select * from table_name command it show two records in the table 