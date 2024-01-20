create database music_db
use music_db

select*from[dbo].[customer]
select*from [dbo].[album_csv]
select*from [dbo].[album2_csv]
select*from [dbo].[artist_csv]
select*from [dbo].[employee_csv]
select*from [dbo].[genre_csv]
select*from [dbo].[invoiceline_csv]
select*from [dbo].[media_type_csv]
select*from [dbo].[playlist_csv]
select*from [dbo].[playlist_track_csv]
select*from [dbo].[track_csv]
select*from [dbo].[invoice_csv]

---ques set 1---

--Q1 who is senior most employee based on job title?
select top 1 *from employee_csv
order by levels desc

--Q2 which countries have the most invoices..
select count(*) as c, billing_country 
from invoice_csv
group by billing_country
order by c desc


---Q3 what are top3 values of total invoices
select top 3 total from invoice_csv
order by total desc

--Q4 which city has best customers? we would like to throw a promotional music festival in city we made most money. write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoices totals.
select top 1 billing_city, sum(total) as invoice_total
from invoice_csv 
group by billing_city
order by invoice_total desc

---Q5 who's the best customer? the customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
select c.customer_id, sum(total)as invoice_total, 
	c.first_name, c.last_name 
		from customer c join invoice_csv i
			on c.customer_id= i.customer_id
				group by c.customer_id, c.first_name, c.last_name 
					order by invoice_total desc


----------QUESTIONS SET-2----------

-----Q1 Write query to return email, first name, last name, & genre of all rock music listeners. Return your list ordered alphabetically by email starting with A
Select email, first_name, last_name from customer c join invoice_csv i
on c.customer_id= i.customer_id
join invoiceline_csv ic on ic.invoice_line_id= i.invoice_id
  WHERE track_id IN(
			SELECT track_id FROM track_csv t
				JOIN genre_csv g 
					on t.genre_id= g.genre_id
						WHERE g.name LIKE 'Rock')
group by email,first_name, last_name
ORDER BY email;

-----Q2 Let's invite the artists who have written the most rock music in our data set. Write a query that returns the artist name and total track count of the top 10 rock bands----
select top 10 count(art.artist_id) as no_of_songs, art.artist_id, art.name from track_csv t 
join album_csv a ON t.album_id= a.album_id
JOIN  artist_csv art ON art.artist_id= a.artist_id
JOIN  genre_csv g ON g.genre_id= t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY art.artist_id, art.name
ORDER BY no_of_songs desc


----Q3 Return all track names that have a song length longer than average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT name, milliseconds
FROM track_csv
WHERE milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track_csv)
order by milliseconds desc

----QUESTION SET 3 ADVANCE----


---Q1 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.
WITH best_selling_artist AS (
	SELECT  artist_csv.artist_id AS artist_id, artist_csv.name  AS artist_name,
	SUM(invoiceline_csv.unit_price*invoiceline_csv.quantity) AS total_sales
	FROM invoiceline_csv
	JOIN track_csv ON track_csv.track_id = invoiceline_csv.track_id
	JOIN album_csv ON album_csv.album_id = track_csv.album_id
	JOIN artist_csv ON artist_csv.artist_id= album_csv.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice_csv i
JOIN customer c ON c.customer_id= i.customer_id
JOIN invoiceline_csv il ON il.invoice_id= i.invoice_id
JOIN track_csv t ON t.track_id= il.track_id
JOIN album_csv alb ON  alb.album_id= t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id= alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

---Q2 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that retiurns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
WITH popular_genre AS
(
	SELECT COUNT(invoiceline_csv.quantity) AS purchases, customer.country, genre_csv.name, genre_csv.genre_id, ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT( invoiceline_csv.quantity) DESC) AS Rowno
	FROM invoiceline_csv
	JOIN invoice_csv ON invoice_csv.invoice_id= invoiceline_csv.invoice_id
	JOIN customer ON customer.customer_id= invoice_csv.customer_id
	JOIN track_csv ON track_csv.track_id= invoiceline_csv.track_id
	JOIN genre_csv ON genre_csv.genre_id= track_csv.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC)
SELECT* FROM popular_genre WHERE RowNo <=1

---Q3 Write a query that determines the customer that has spent most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.----

WITH Customer_with_ountry AS(
		SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
		ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
		FROM invoice_csv JOIN customer ON customer.customer_id= invoice_csv.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC, 5 DESC)
SELECT*From Customer_with_ountry WHERE RowNo <=1
















































































