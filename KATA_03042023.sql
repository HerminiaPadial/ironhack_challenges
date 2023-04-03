select 
count(name) as products,
country
from products
where country IN ('United States of America','Canada')
group by country
order by products desc