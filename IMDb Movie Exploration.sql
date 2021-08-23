--Creating IMDb dataset tables for import

CREATE TABLE name_basics(
	nconst VARCHAR(250),
	primaryName VARCHAR,
	birthYear INT,
	deathYear INT,
	primaryProfession VARCHAR,
	knownForTitles VARCHAR
);

CREATE TABLE title_akas(
	titleId VARCHAR(250),
	ordering INT,
	title VARCHAR,
	region VARCHAR(25),
	language VARCHAR(25),
	types VARCHAR(250),
	attributes VARCHAR(250),
	isOriginalTitle SMALLINT
);

CREATE TABLE title_basics(
	tconst VARCHAR(250),
	titleType VARCHAR(150),
	primaryTitle VARCHAR,
	originalTitle VARCHAR,
	isAdult SMALLINT,
	startYear INT,
	endYear INT,
	runtimeMinutes SMALLINT,
	genres VARCHAR(250)
);

CREATE TABLE title_crew(
	tconst VARCHAR(250),
	directors VARCHAR,
	writers VARCHAR
);

CREATE TABLE title_episode(
	tconst VARCHAR(250),
	parentTconst VARCHAR(250),
	seasonNumber SMALLINT,
	episodeNumber SMALLINT
);

CREATE TABLE title_principals(
	tconst VARCHAR(250),
	ordering INT,
	nconst VARCHAR(250),
	category VARCHAR(250),
	job VARCHAR(250),
	characters VARCHAR
);

CREATE TABLE title_ratings(
	tconst VARCHAR(250),
	averageRating NUMERIC(5,2),
	numVotes INT
);

--Searching for romance movies released in the 21st century with a rating of at least 8.0

SELECT tb.primarytitle, tb.startyear, tb.genres, tr.averagerating
FROM title_basics tb
INNER JOIN title_ratings tr
ON tb.tconst = tr.tconst
WHERE tb.genres ILIKE '%romance%'
AND tb.titletype = 'movie'
AND tb.startyear > 2000
AND tr.averagerating > 8.0
ORDER BY startyear, averagerating DESC;

--Steven Spielberg's top 10 highest rated movies

SELECT nconst, primaryname
FROM name_basics
WHERE primaryname = 'Steven Spielberg';

----nconst for Steven Spielberg = nm0000229

SELECT tb.primarytitle, tb.startyear, tb.genres, tr.averagerating
FROM title_basics tb
JOIN title_crew tc
ON tb.tconst = tc.tconst
JOIN title_ratings tr
ON tb.tconst = tr.tconst
WHERE tc.directors = 'nm0000229'
AND tb.titletype = 'movie'
ORDER BY tr.averagerating DESC
LIMIT 10;

--Finding the shortest and longest duration movies and their directors

SELECT tb.titletype, tb.primarytitle, tb.startyear, tb.runtimeminutes, tc.directors
FROM title_basics tb
JOIN title_crew tc
ON tb.tconst = tc.tconst
WHERE tb.runtimeminutes =
	(
	SELECT MIN(runtimeminutes)
	FROM title_basics
	WHERE titletype = 'movie'
	)
GROUP BY tb.titletype, tb.primarytitle, tb.startyear, tb.runtimeminutes, tc.directors
HAVING tb.titletype = 'movie';

SELECT tb.titletype, tb.primarytitle, tb.startyear, tb.runtimeminutes, tc.directors
FROM title_basics tb
JOIN title_crew tc
ON tb.tconst = tc.tconst
WHERE tb.runtimeminutes =
	(
	SELECT MAX(runtimeminutes)
	FROM title_basics
	WHERE titletype = 'movie'
	)
GROUP BY tb.titletype, tb.primarytitle, tb.startyear, tb.runtimeminutes, tc.directors
HAVING tb.titletype = 'movie';

--Finding the longest running TV series

SELECT tb.titletype, tb.primarytitle, tb.startyear, te.seasonnumber
FROM title_basics tb
JOIN title_episode te
ON tb.tconst = te.parenttconst
WHERE te.seasonnumber =
	(
	SELECT MAX(te.seasonnumber)
	FROM title_basics tb
	JOIN title_episode te
	ON tb.tconst = te.parenttconst
	GROUP BY tb.titletype
	HAVING tb.titletype ILIKE '%tvseries%'
	);
	
--Ranking Christoper Nolan's movies.

SELECT nconst, primaryname
FROM name_basics
WHERE primaryname LIKE 'Chris%Nolan%';

----nconst for Christopher Nolan = 'nm0634240'

SELECT tb.primarytitle, tb.startyear, tr.averagerating,
RANK() OVER(ORDER BY tr.averagerating DESC) movierank,
CASE (RANK() OVER(ORDER BY tr.averagerating DESC))
	WHEN 1 THEN 'Highest'
	ELSE 'no rank'
	END rank_description
FROM title_basics tb
JOIN title_crew tc
ON tb.tconst = tc.tconst
JOIN title_ratings tr
ON tb.tconst = tr.tconst
WHERE tc.directors = 'nm0634240';

--Rating of TV Show 'The Office'

SELECT tb.primarytitle, tr.averagerating
FROM title_basics tb
JOIN title_ratings tr
ON tb.tconst = tr.tconst
WHERE primarytitle = 'The Office'
AND titletype ILIKE 'tvseries'
AND startyear = 2005;

--The lowest rated movie with at least 10000 votes released in 2020.

SELECT tb.primarytitle, MIN(tr.averagerating)
FROM title_basics tb
JOIN title_ratings tr
ON tb.tconst = tr.tconst
WHERE tb.startyear = 2020
AND tb.titletype = 'movie'
AND tr.numvotes >= 10000
GROUP BY tb.primarytitle
ORDER BY MIN(tr.averagerating)
LIMIT 1;
