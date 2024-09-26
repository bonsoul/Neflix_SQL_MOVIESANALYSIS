SELECT *
FROM netflix_titles


-- 1. Count the number of Movies vs TV Shows

SELECT type,COUNT(*) AS Number_TVShows_or_Movie
FROM netflix_titles
GROUP BY type

-- 2. Find the most common rating for movies and TV shows


WITH RatingCounts AS (
    SELECT type, rating, COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT type, rating, rating_count, 
           RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT type, rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List all movies released in a specific year 
SELECT *
FROM netflix_titles
WHERE release_year = 2021

-- 4. Find the top 5 countries with the most content on Netflix

SELECT TOP 5
      value AS country,
	  COUNT(*) AS Total_Content
FROM netflix_titles
CROSS APPLY string_split(country, ',')
WHERE value IS NOT NULL
GROUP BY value
ORDER BY Total_Content DESC;

-- 5. Identify the longest movie
SELECT *
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, CHARINDEX(' ',duration) - 1) AS INT) DESC;

-- 6. Find content added in the last 5 years

SELECT *
FROM netflix_titles
WHERE TRY_CONVERT(DATE,date_added, 101) >= DATEADD(YEAR, -5, GETDATE());

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix_titles
CROSS APPLY string_split(director, ',')
WHERE director = 'Rajiv Chilaka'

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix_titles
WHERE 
     TYPE = 'TV Show'
	 AND
	 CAST(LEFT(duration,CHARINDEX(' ',duration) -1) AS INT) > 5 
	 ORDER BY CAST(LEFT(duration,CHARINDEX(' ',duration) -1) AS INT)  DESC;

 -- 9. Count the number of content items in each genre

SELECT value AS gerne, COUNT(*) AS Total_Content
FROM netflix_titles
CROSS APPLY string_split(listed_in, ',')
GROUP BY value

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT TOP 5
     country,
	 release_year,
	 COUNT(show_id) as Total_Release,
	 CAST(COUNT(show_id) as decimal (10,2)) as Avg_Release
FROM netflix_titles
WHERE country = 'India'
GROUP BY country,release_year
ORDER BY Avg_Release DESC

-- 11. List all movies that are documentaries
SELECT*
FROM netflix_titles
WHERE listed_in = 'Documentaries'

-- 12. Find all content without a director
SELECT*
FROM netflix_titles
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT*
FROM netflix_titles
WHERE 
     cast LIKE '%Salman Khan%'
	 AND
	 release_year > YEAR(GETDATE()) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TOP 10
        cast,
		COUNT(*) AS Total_Count
FROM netflix_titles
CROSS APPLY string_split(cast, ',') as Split_Casts
WHERE country = 'India'
GROUP BY cast
ORDER BY Total_Count Desc

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT
     Category,
	 TYPE,
	 COUNT(*) AS content_count
FROM (
     SELECT*,
	 CASE
	    WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS category
FROM netflix_titles
) as Categorized_content
GROUP BY category, TYPE
ORDER BY TYPE DESC;

-- END -- 