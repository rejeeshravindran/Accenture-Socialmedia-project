--exploring and cleaning the dataset 


--looking into the content table  
select * from sql_pro.dbo.content
order by 1 

--we don't require URL column and user column in the table and we can delete for the same


alter table sql_pro.dbo.content
drop column URL;


alter table sql_pro.dbo.content
drop column [User ID]


--looking into category column and replacing characters no longer required


select category from sql_pro.dbo.content
where category like '%"%'

select replace(Category ,'"','') as Content_type
from sql_pro.dbo.content 

alter table sql_pro.dbo.content
add Category_type nvarchar(150)

update sql_pro.dbo.content
set Category_type = replace(Category ,'"','')

select distinct Category_type from sql_pro.dbo.content
order by 1 

--deleting the category column which no longer required

alter table sql_pro.dbo.contents
drop column category

select * from sql_pro.dbo.content
order by 1 


--looking into the reaction table
--deleting the rows in type column where is null / and deleting the userid column which we don't require


select  * from sql_pro.dbo.Reactions
where type is null

delete from sql_pro.dbo.Reactions 
where type is null 

alter table sql_pro.dbo.Reactions
drop column [user id]

alter table sql_pro.dbo.Reactiontypes
drop column F1

alter table sql_pro.dbo.content
drop column F1

alter table sql_pro.dbo.reactions
drop column F1


alter table sql_pro.dbo.Content
drop column category


--------------
--converting the datetime into date format for our use 

select Datetime , convert(date,Datetime) as Date  from sql_pro.dbo.Reactions

alter table sql_pro.dbo.Reactions
add date date 

update sql_pro.dbo.Reactions
set date = convert(date,Datetime) 

alter table sql_pro.dbo.Reactions
drop column Datetime 



select * from sql_pro.dbo.Reactions 


--cleaning has been completed and we are moving into analysis
-------------------------------------


--joining the content table  reaction table & reactiontype table and creating a cte table out of it so that
--we can find the total counts of the distinct categories and the top 5 categories 


WITH CTE_table AS 

(SELECT  a.[Content ID] as con_id , b.[Content ID] as react_id , c.Type ,  R_Type , date , Category_type ,Score

FROM sql_pro.dbo.content  a
join sql_pro.dbo.reactions  b ON a.[content id]= b.[content id] join sql_pro.dbo.ReactionTypes  c ON b.R_Type = c.Type


) select  category_type, count (category_type) as category_count       from CTE_table
group by category_type
order by 2 desc


--for finding total score corresponding to the category 

WITH CTE_table AS 

(SELECT  a.[Content ID] as con_id , b.[Content ID] as react_id , c.Type ,  R_Type , date , Category_type ,Score

FROM sql_pro.dbo.content  a
join sql_pro.dbo.reactions  b ON a.[content id]= b.[content id] join sql_pro.dbo.ReactionTypes  c ON b.R_Type = c.Type


) select  category_type , sum (score ) as category_score from CTE_table
group by  category_type
order by 2 desc 



-------------------------------------------
--adding the category score into the  content table 

ALTER TABLE sql_pro.dbo.content
ADD category_score INT;


WITH CTE_table AS (
    SELECT a.[Content ID] AS con_id,
           b.[Content ID] AS react_id,
           c.Type,
           R_Type,
           Category_type,
           Score
    FROM sql_pro.dbo.content a
    JOIN sql_pro.dbo.reactions b ON a.[content id] = b.[content id]
    JOIN sql_pro.dbo.ReactionTypes c ON b.R_Type = c.Type
)
UPDATE sql_pro.dbo.content
SET category_score = subquery.category_score
FROM (
    SELECT category_type,
           SUM(score) AS category_score
    FROM CTE_table
    GROUP BY category_type
) AS subquery
WHERE sql_pro.dbo.content.category_type = subquery.category_type;


---------------------------------------------------------------------
-- adding category count into the content column

alter table sql_pro.dbo.content
add category_count INT



WITH CTE_table AS 
(SELECT  a.[Content ID] as con_id , b.[Content ID] as react_id , c.Type ,  R_Type , date , Category_type ,Score

FROM sql_pro.dbo.content  a
join sql_pro.dbo.reactions  b ON a.[content id]= b.[content id] join sql_pro.dbo.ReactionTypes  c ON b.R_Type = c.Type

) 
update sql_pro.dbo.content
set category_count = subquery2.category_count
from (
select  category_type, count(category_type) as category_count   from CTE_table
group by category_type
) as subquery2
 where sql_pro.dbo.content.category_type=subquery2.category_type

-------------------------------------------------------
--creating a view 
--The analysis is completed successfully by finding the top performing contents for the company
--both the score and count of the categories are found 


create view Top_Performing   as

(
select distinct Category_type , category_score , category_count from sql_pro.dbo.content 

)
