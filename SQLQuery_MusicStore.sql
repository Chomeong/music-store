--question set - easy
--who's the senior most employee based on job title?
select top 1 * from employee order by levels desc

--which countries have the most invoices?
select 
    billing_country, 
    count(*) as count_of_invoices 
from invoice 
group by billing_country 
order by count_of_invoices desc

--what are top 3 values of total invoices?
select top 3 total from invoice order by total desc

--which city has the best customers? we would like to throw a promotional music festival in the city 
--	who made the most money. write a query that returns one city that has the highest sum of invoice totals.
--	return both the city name and sum of all invoice tools
select 
    billing_city, 
    sum(total) as invoice_total 
from invoice 
group by billing_city
order by invoice_total desc

--who is the best customer? the customer who has spent the most money will be declared the best customer. 
--	write a query that returns the person who has spent the most money
select top 1
    customer.customer_id, 
    customer.first_name, 
    customer.last_name, 
    sum(invoice.total) as total 
from customer 
left join invoice 
on customer.customer_id = invoice.customer_id 
group by customer.customer_id, customer.first_name, customer.last_name;

--question set - moderate
--write query to return the email, first name, last name, & genre of all rock music listeners. 
--return your list ordered alphabetically by email starting w/ A
select distinct 
    customer.email, 
    customer.first_name, 
    customer.last_name, 
    genre.[name] as genre
from customer 
inner join invoice on customer.customer_id = invoice.invoice_id 
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track on invoice_line.track_id = track.track_id
inner join genre on track.genre_id = genre.genre_id
where genre.[name] like 'Rock%'
order by customer.email asc

--let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the artist name & total track count of the top 10 rock bands
select top 10 artist.[name], count(track.track_id) as number_of_songs 
from artist 
inner join album2 on album2.artist_id = artist.artist_id 
inner join track on album2.album_id = track.album_id
inner join genre on track.genre_id = genre.genre_id
where genre.[name] like 'Rock%'
group by artist.[name]
order by number_of_songs desc

--return all the track names that have a song length longer than the average song length. 
--Return the name & miliseconds for each track. 
--order by the song length with the longest songs listed first
select [name], milliseconds 
from track 
where milliseconds > (select avg(milliseconds) from track) 
order by milliseconds desc

--question set - advanced
--Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
with earned_most as (
    select 
        artist.artist_id, 
        artist.[name], 
        sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
    from invoice_line
    inner join track on invoice_line.track_id = track.track_id
    inner join album2 on track.album_id = album2.album_id
    inner join artist on album2.artist_id = artist.artist_id
    group by artist.artist_id, artist.[name]
)

select
    customer.customer_id,
    customer.first_name, 
    customer.last_name, 
    earned_most.[name] as artist_name, 
    sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from customer
inner join invoice on customer.customer_id = invoice.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track on invoice_line.track_id = track.track_id
inner join album2 on track.album_id = album2.album_id
inner join earned_most on album2.artist_id = earned_most.artist_id
group by customer.customer_id, customer.first_name, customer.last_name, earned_most.[name]
order by customer.customer_id, earned_most.[name]

--We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres.
with popular as(
    select 
        customer.country,
        genre.[name],
        count(invoice_line.quantity) as amount_of_purchase,
        row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) as RowNum
    from invoice_line
    inner join invoice on invoice_line.invoice_id = invoice.invoice_id
    inner join customer on invoice.customer_id = customer.customer_id
    inner join track on invoice_line.track_id = track.track_id
    inner join genre on track.genre_id = genre.genre_id
    group by customer.country, genre.[name]

)

select * from popular where RowNum <= 1

--Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount
with top_amount as(
    select 
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        invoice.billing_country,
        sum(invoice.total) as amount_spent,
        row_number() over (partition by invoice.billing_country order by sum(invoice.total) desc) as RowNum
    from customer
    inner join invoice on invoice.customer_id = customer.customer_id
    group by customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
)

select * from top_amount where RowNum <= 1