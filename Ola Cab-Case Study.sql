create database cab_db;
use cab_db;

select * from data;
select * from localities;

set sql_safe_updates = 0;

alter table data
add column newpickup_date date;

update data
set newpickup_date = str_to_date (pickup_date, "%d-%m-%Y");

alter table data
add column newConfirmed_at_date date;

select left(Confirmed_at, locate(" ", Confirmed_at, 1)-1)
from data;

update data
set newConfirmed_at_date = str_to_date (left(Confirmed_at, locate(" ", Confirmed_at, 1)-1), "%d-%m-%Y");

alter table data
add column newConfirmed_at_time time;

select right(Confirmed_at, 5)
from data;

update data
set newConfirmed_at_time = right(Confirmed_at, 5);

#1 Find hour of 'pickup' and 'confirmed_at' time, and make a column of weekday as "Sun,Mon, etc"next to pickup_datetime	
select hour(pickup_time) 'hour of pickup', newConfirmed_at_time 'confirmed_at time', pickup_datetime, weekday(newpickup_date) 'weekday'
from data;

#2. Make a table with count of bookings with booking_type = p2p catgorized by booking mode as 'phone', 'online','app',etc	
select Booking_mode, Booking_type, count(*) as 'count of bookings'
from data
where Booking_type = "p2p"
group by Booking_mode;

#3. Find top 5 drop zones in terms of average revenue
select zone_id, avg(d.Fare) as avg_rvn
from localities l inner join data d on l.Area = d.DropArea
group by l.zone_id
order by avg_rvn desc
limit 5;

#4.    Find all unique driver numbers grouped by top 5 pickzones
create view top5pickzone as
select distinct l.zone_id as top_zone, sum(d.fare) as SumRevenue
from data d
inner join localities l
on d.pickuparea = l.area
group by l.zone_id
order by SumRevenue desc
limit 5;

select distinct l.zone_id, d.Driver_number
from data d
inner join localities l
on d.pickuparea = l.area
where d.Driver_number is not null and
l.zone_id in (select top_zone from top5pickzone)
order by 1,2;
	
#5. Make a list of top 10 driver by driver numbers in terms of fare collected where service_status is done, done-issue
select Driver_number, Fare, Service_status
from data
where Service_status = "done" or Service_status = "done-issue" 
order by Fare desc
limit 10;