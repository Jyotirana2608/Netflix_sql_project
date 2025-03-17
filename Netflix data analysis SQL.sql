-- Netflix project 

CREATE TABLE  netflix
(
show_id VARCHAR(10),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(208),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INTEGER,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);

select * from netflix;

select COUNT (*) as total_count from netflix;

select DISTINCT TYPE
	from netflix;

--15 business problems --

----1.  Count the number of movies vs TV Shows----

select type, COUNT (*) as total_content from netflix
GROUP BY type

--2. Find the most common rating for movies and Tv shows

Select type, rating 
	from
	(
	select type, rating, COUNT(*), 
	 RANK() OVER(PARTITION BY type ORDER BY COUNT (*) DESC) as ranking	
	 from netflix
     GROUP BY 1,2
	 ) as t1
     where ranking = 1 

--3. list all moviesreleased in a specific year ( eg 2020)

select * from netflix
where 
	type = 'Movie'
    AND
    release_year = 2020

--4. find the top 5 countries with the most content on netflix

select
UNNEST(STRING_TO_ARRAY(country, ',' ))as new_country,
COUNT (show_id) as total_content
from netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--5. Identify the longest movie?

select * from netflix
where
type= 'Movie'
AND
duration= (select MAX(duration) from netflix)

--6. Find content added in the last 5 years.

select
*
from netflix
where
TO_DATE(date_added, 'Month DD YYYY') >= CURRENT_DATE -INTERVAL '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
where director LIKE '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons.

select * from netflix 
where 
type = 'TV Show'
AND
SPLIT_PART(duration, ' ',1)::numeric > 5 

	or
	
SELECT * 
FROM netflix 
WHERE type = 'TV Show' 
AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

--9. Count the number of content items in each genre.

select 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
from netflix
GROUP BY 1

--10. Find each year and the average numbers of content release by India on netflix.  Return top 5 year with highest avg content release.

select
  EXTRACT(YEAR FROM TO_DATE(date_added, 'Month, DD, YEAR')) as year,
  COUNT(*) as yearly_content,
  ROUND(
  COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix where country = 'India')::numeric * 100 
  ,2)as avg_content_per_year
FROM netflix
Where country = 'India'
GROUP BY 1

--11. List all movies that are documentries.
	
select * from netflix
where
listed_in ILIKE '%documentaries%'  

-- ilike for capital letters

--12. Find all content without a director.

select * from netflix
where
director is NULL 

--13. Find how many movies actor 'salman khan' appeared in last 10 years!

select * from netflix
where
casts ILIKE '%Salman khan%'
AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
from netflix
where country ILIKE '%india'
Group by 1
order by 2 DESC
LIMIT 10

--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
select *,
	CASE
	WHEN 
	description ILIKE '%kill%' OR
	description ILIKE '%violence%' THEN 'Bad_Content'
	ELSE 'Good Content'
	END category
	from netflix
	)
select
category,
COUNT(*) as total_content
from new_table
GROUP BY 1


