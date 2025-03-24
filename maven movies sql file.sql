

use mavenmovies;

select* from rental;
select * from inventory;
select * from customer;

-- You need to provide customer firstname, lastname and email id to the marketing team --
select first_name, last_name, email from customer;


-- How many movies are with rental rate of $0.99? --
select count(film_id) from film
where rental_rate = 0.99;

-- We want to see rental rate and how many movies are in each rental category --
select rental_rate,
 count(*) from film group by (rental_rate);
 
 
-- Which rating has the most films? --
select rating , count(*)as category from film group by rating order by category desc;



-- Which rating is most prevalant in each store? --
select inv.store_id,F.rating,count(inventory_id)as no_of_copies
 from inventory as inv left join film as F 
on inv.film_id= F.film_id 
group by inv.store_id,F.rating 
order by no_of_copies desc;


-- List of films by Film Name, Category, Language --
select f.film_id,f.title,c.name as categoryname, lang.name as lan from film as f left join film_category as fc 
on f.film_id= fc.film_id left join category as c  on fc.category_id= c.category_id
left join language as lang on f.language_id=lang.language_id;


-- How many times each movie has been rented out?
select  F.title ,COUNT(R.RENTAL_ID) AS POPULARITY from rental as R LEFT JOIN inventory AS INV 
ON R.inventory_id=INV.inventory_id left JOIN FILM AS F 
ON INV.film_id= F.film_id
GROUP BY F.TITLE
ORDER BY  POPULARITY DESC ;

#
-- REVENUE PER FILM (TOP 10 GROSSERS)
SELECT* FROM PAYMENT;

select  F.title ,SUM(P.amount) AS REVENUE from rental as R LEFT JOIN inventory AS INV 
ON R.inventory_id=INV.inventory_id left JOIN FILM AS F 
ON INV.film_id= F.film_id LEFT JOIN payment AS P  ON R.rental_id=P.rental_id
group bY F.TITLE 
ORDER BY REVENUE DESC
LIMIT 10 ;



-- Most Spending Customer so that we can send him/her rewards or debate points


SELECT 
P.CUSTOMER_ID , sum(AMOUNT) AS SPENDING,C.FIRST_NAME 
FROM  payment AS P LEFT JOIN 
customer AS C ON 
P.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY P.CUSTOMER_ID
ORDER BY SPENDING DESC
LIMIT 1; 



-- Which Store has historically brought the most revenue?

select* FROM  STORE;
select* FROM PAYMENT;

 SELECT S.store_id,SUM(AMOUNT) AS REVENUE_PER_STORE FROM payment AS P LEFT JOIN 
 staff AS S ON P.STAFF_ID = S.staff_id
 GROUP BY store_id
 ORDER BY REVENUE_PER_STORE;
 
 
-- How many rentals we have for each month

 select COUNT(RENTAL_ID) FROM rental;
select monthname(RENTAL_DATE) AS MONTH_NAME, 
extract(YEAR FROM RENTAL_DATE) AS YEARR,COUNT(RENTAL_ID) AS RENTALS FROM rental
group by extract(YEAR FROM RENTAL_DATE), monthname(RENTAL_DATE) ; 


-- Reward users who have rented at least 30 times (with details of customers)
SELECT * FROM RENTAL ;
SELECT * FROM CUSTOMER;
SELECT Customer_id , count(*) as number_of_rentals 
from rental group by customer_id
having number_of_rentals > 30;


 
select r.customer_id, count(*) as number_of_rental ,c.first_name,c.last_name,
c.email from rental as r left join customer as c
on r.customer_id=c.customer_id 
group by r.customer_id 
having number_of_rental > 30; 

select * from customer 
where customer_id in (SELECT x.customer_id from (SELECT Customer_id , count(*) as number_of_rentals 
from rental
 group by customer_id
having number_of_rentals > 30) AS x);



-- Could you pull all payments from our first 100 customers (based on customer ID)

SELECT * FROM CUSTOMER;
SELECT customer_id, rental_id,payment_date FROM payment
WHERE customer_id < 101;

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?
SELECT * FROM film WHERE special_features LIKE "%BEHIND THE SCENES%";


-- unique movie ratings and number of movies
SELECT RATING, COUNT(FILM_ID) FROM FILM
GROUP BY RATING;


-- Could you please pull a count of titles sliced by rental duration?
select* FROM rental;
select* FROM FILM;
select RENTAL_DURATION,COUNT(FILM_ID ) AS FILMNO FROM FILM
GROUP BY RENTAL_DURATION;


-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION
SELECT RATING , RENTAL_DURATION, COUNT(FILM_ID ) FROM FILM
GROUP BY RATING,rental_DURATION ;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?


SELECT REPLACEMENT_COST,
	COUNT(FILM_ID) AS NUMBER_OF_FILMS,
    MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
    MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
    AVG(RENTAL_RATE) AS AVERAGE_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;

-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

SELECT CUSTOMER_ID,COUNT(*) AS TOTAL_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;

-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;

-- CATEGORIZE MOVIES AS PER LENGTH

SELECT TITLE,LENGTH,
	CASE
		WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
	END AS LENGTH_BUCKET
FROM FILM;

SELECT *
FROM CATEGORY;


-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;



-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”

SELECT CUSTOMER_ID,FIRST_NAME,LAST_NAME,
	CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'store 1 active'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'store 1 inactive'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'store 2 active'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'store 2 inactive'
        ELSE 'ERROR'
	END AS STORE_AND_STATUS
FROM CUSTOMER;


-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

SELECT DISTINCT INVENTORY.INVENTORY_ID,
				INVENTORY.STORE_ID,
                FILM.TITLE,
                FILM.DESCRIPTION 
FROM FILM INNER JOIN INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID;

-- Actor first_name, last_name and number of movies

SELECT * FROM FILM_ACTOR;
SELECT * FROM ACTOR;

SELECT 
	ACTOR.ACTOR_ID,
    ACTOR.FIRST_NAME,
    ACTOR.LAST_NAME,
    COUNT(FILM_ACTOR.FILM_ID) AS NUMBER_OF_FILMS
FROM ACTOR
	LEFT JOIN FILM_ACTOR
		ON ACTOR.ACTOR_ID= FILM_ACTOR.ACTOR_ID
GROUP BY
	ACTOR.ACTOR_ID;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

SELECT FILM.TITLE,
	COUNT(FILM_ACTOR.ACTOR_ID) AS NUMBER_OF_ACTORS
FROM FILM 
	LEFT JOIN FILM_ACTOR
		ON FILM.FILM_ID = FILM_ACTOR.FILM_ID
GROUP BY 
	FILM.TITLE;
    
-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
    
SELECT ACTOR.FIRST_NAME,
		ACTOR.LAST_NAME,
        FILM.TITLE
FROM ACTOR INNER JOIN FILM_ACTOR
	ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
			INNER JOIN FILM
	ON FILM_ACTOR.FILM_ID = FILM.FILM_ID
ORDER BY
ACTOR.LAST_NAME,
ACTOR.FIRST_NAME;


-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”


select distinct film.title ,film.description from film
inner join inventory on film.film_id = inventory.film_id
and inventory.store_id=2;

-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? 

SELECT * FROM STAFF;
SELECT * FROM ADVISOR;

 (select first_name,last_name, 'advisors'as designation from advisor
 union  
select first_name, last_name ,'staff' as designation
from staff);
 

