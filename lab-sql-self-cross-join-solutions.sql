use sakila;

-- EXERCISE: Get all pairs of actors that worked together.

select b.first_name actor1_name, b.last_name actor1_surname, 
d.first_name actor2_name, d.last_name actor2_surname
from film_actor a
join actor b on a.actor_id = b.actor_id
join film_actor c on a.film_id = c.film_id and a.actor_id < c.actor_id -- to remove duplicates 
join actor d on c.actor_id = d.actor_id;


-- EXERCISE: Get all pairs of customers that have rented the same film more than 3 times.

/* NOTE FOR THE T.A.: It took me a while to be sure this was the correct solution without 
getting lost in the reviewing process, so excuse me if the querry looks a tad overexplained. */

select -- MAIN QUERRY. I need info from customer1 & customer2 in each pair and info from the film.
c1.first_name customer1_name, c1.last_name customer1_surname, -- Customer1 info (from 1st subquery).
c2.first_name customer2_name, c2.last_name customer2_surname, -- Customer2 info (from 2nd subquery).
c1.title film, (c1.n_rents + c2.n_rents) as pair_total_rents -- Times each pair has rent each film.
from -- Select abovementioned info from a table created via 2 joined subquerries, 1 per customer.
( -- 1ST SUBQUERRY: retrieves information about customer1.
select a.customer_id, a.first_name, a.last_name, d.film_id, d.title, 
count(b.rental_id) as n_rents -- Count the times that customer1 has rent each film.
from customer a 
join rental b on a.customer_id = b.customer_id
join inventory c on b.inventory_id = c.inventory_id
join film d on c.film_id = d.film_id
group by customer_id, film_id -- Aggregate info by customer and film to then make the count.
) -- End of 1st subquerry.
as c1 -- Table containing the info about customer1 of the pair.
join -- Join customer1 table c1 with customer2 table c2 to create a table containing each pair.
( -- 2ND SUBQUERRY: retrieves information about customer2. Similar to the previous subquerry.
select a.customer_id, a.first_name, a.last_name, d.film_id, d.title, 
count(b.rental_id) as n_rents -- Count the times that customer2 has rent each film.
from customer a 
join rental b on a.customer_id = b.customer_id
join inventory c on b.inventory_id = c.inventory_id
join film d on c.film_id = d.film_id
group by customer_id, film_id -- Aggregate info by customer and film to then make the count.
) -- End of 2nd subquerry.
as c2 -- Table containing the info about customer2 of the pair.
on c1.film_id = c2.film_id -- Indicate where tables c1 and c2 must join to create each couple
and c1.customer_id < c2.customer_id -- (<) Avoid getting duplicate pairs (eg, TIM/BOB and BOB/TIM).
where (c1.n_rents + c2.n_rents) > 3 -- Filter the films watched less than 4 times by each pair.
order by pair_total_rents desc -- Let's put the most watched films first, for pleasure.
; -- End of main querry.


-- EXERCISE: Get all possible pairs of actors and films.

select first_name, last_name, title 
from (select actor_id, first_name, last_name from actor) actors
cross join (select film_id, title from film) films
order by last_name;