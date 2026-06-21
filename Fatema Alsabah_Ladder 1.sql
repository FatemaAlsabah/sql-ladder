-- # The Basics
-- 
-- ## Simple SELECTs
-- 1) Query all the data in the `pets` table.  
-- SELECT *
-- FROM pets
-- 2) Query only the first 5 rows of the `pets` table.
-- SELECT *
-- FROM pets
-- LIMIT 5
-- 3) Query only the names and ages of the pets in the `pets` table.
select name, age
from pets


-- 4) Query the pets in the `pets` table, sorted youngest to oldest.
select *
from pets
order by age 


-- 5) Query the pets in the `pets` table alphabetically.
select *
from pets
order by name


-- 6) Query all the male pets in the `pets` table.
select *
from pets
where lower(sex) = "m" 


-- 7) Query all the cats in the `pets` table.
select *
from pets
where lower(species) = "cat"


-- 8) Query all the pets in the `pets` table that are at least 5 years old.
select *
from pets
where age >= 5

-- 9) Query all the male dogs in the `pets` table. Do not include the sex or species column, since you already know them.
select name, age
from pets
where lower(sex) = "m" and lower(species) = "dog"


-- 10) Get all the names of the dogs in the `pets` table that are younger than 5 years old.
select name
from pets 
where lower(species) = "dog" and age < 5


-- 11) Query all the pets in the `pets` table that are either male dogs or female cats.
select *
from pets 
where (lower(species) = "dog" and lower(sex) = "m") or (lower(species) = "cat" and lower(sex) = "f")


-- 12) Query the five oldest pets in the `pets` table.
select *
from pets 
order by age desc
limit 5


-- 13) Get the names and ages of all the female cats in the `pets` table sorted by age, descending.
select name, age
from pets 
where lower(sex) = "f" and lower(species) = "cat"
order by age desc


-- 14) Get all pets from `pets` whose names start with P.
select *
from pets 
where lower(name) like "p%"


-- 15) Select all employees from `employees_null` where the salary is missing.
select *
from employees_null
where salary is null


-- 16) Select all employees from `employees_null` where the salary is below $35,000 or missing.
select *
from employees_null
where salary < 35000 or salary is null


-- 17) Select all employees from `employees_null` where the job title is missing. What do you see?
select *
from employees_null
where job is null -- UNKNOWN first name and UNKNOWN last name, null in job and startdate, salary is -1


-- 18) Who is the newest employee in `employees`? The most senior?
select *, max(startdate) as newest_startdate
from employees -- this is the newest employee
select *, min(startdate) as senior_startdate
from employees -- this is the most senior employee


-- 19) Select all employees from `employees` named Thomas.
select * 
from employees
where lower(firstname) = "thomas"


-- 20) Select all employees from `employees` named Thomas or Shannon.
select *
from employees
where lower(firstname) = "thomas" or lower(firstname) = "shannon"


-- 21) Select all employees from `employees` named Robert, Lisa, or any name that begins with a J. In addition, only show employees who are _not_ in sales. This will be a little bit of a longer query.
--     * _Hint:_ There will only be 6 rows in the result.
select * 
from employees
where (lower(firstname) = "robert" or lower(firstname) = "lisa" or lower(firstname) like "j%") and lower(job) != "sales"


-- 
-- ## Column Operations
-- 22) Query the top 5 rows of the `employees` table to get a glimpse of these new data.
select *
from employees
limit 5


-- 23) Query the `employees` table, but convert their salaries to Euros. 
--     * _Hint:_ 1 Euro = 1.1 USD.
--     * _Hint2:_ If you think the output is ugly, try out the `ROUND()` function.
select *, round(salary/1.1, 2)
from employees


-- 24) Repeat the previous problem, but rename the column `salary_eu`.
select *, round(salary/1.1, 2) as salary_eu
from employees

-- 25) Query the `employees` table, but combine the `firstname` and `lastname` columns to be "Firstname, Lastname" format. Call this column `fullname`. For example, the first row should contain `Thompson, Christine` as `fullname`. Also, display the rounded `salary_eu` instead of `salary`.
--     * _Hint:_ The string concatenation operator is `||`
select id, firstname ||', '|| lastname as fullname, job, round(salary/1.1, 2) as salary_eu, startdate
from employees


-- 26) Query the `employees` table, but replace `startdate` with `startyear` using the `SUBSTR()` function. Also include `fullname` and `salary_eu`.
select firstname ||', '|| lastname as fullname, substr(startdate, 1, 4) as startyear, round(salary/1.1, 2) as salary_eu
from employees


-- 27) Repeat the above problem, but instead of using `SUBSTR()`, use `STRFTIME()`.
select firstname ||', '|| lastname as fullname, strftime('%Y', startdate) as startyear, round(salary/1.1, 2) as salary_eu
from employees


-- 28) Query the `employees` table, replacing `firstname`/`lastname` with `fullname` and `startdate` with `startyear`. Print out the salary in USD again, except format it with a dollar sign, comma separators, and no decimal. For example, the first row should read `$123,696`. This column should still be named `salary`.
--     * _Hint:_ Check out SQLite's `printf` function.
--     * _Hint2:_ The format string you'll need is `$%,.2d`. You should read more about such formatting strings as they're useful in Python, too!
select firstname ||', '|| lastname as fullname, printf('$%,.2d', salary) as salary, strftime('%Y', startdate) as startyear
from employees


-- 
-- **Note:** For the next few problems, you'll probably want to use `CASE`/`WHEN` statements.
-- 
-- 29) Last year, only salespeople were eligible for bonuses. Create a column `bonus` that is "Yes" if you're eligible for a bonus, otherwise "No".
select *, CASE
when lower(job) = 'sales' then 'Yes'
else 'No'
end as bonus
from employees


-- 30) This year, only sales people with a salary of $100,000 or higher are eligible for bonuses. Create a `bonus` column like in the last problem for salespeople with salaries at least $100,000.
select *, CASE
when lower(job) = 'sales' and salary > 100000 then 'Yes'
else 'No'
end as bonus
from employees


-- 31) Next year, the bonus structure will be a little more complicated. You'll create a `target_comp` column which represents an employee's target total compensation after their bonus. Here is the company's bonus structure:
-- 
-- * Salespeople who make more than $100,000 will be eligible for a 10% bonus.
-- * Salespeople who make less than $100,000 will be eligible for a 5% bonus.
-- * Administrators will also be eligible for a 5% bonus.
-- * Anyone who does not meet any of the above descriptions is not eligible for a bonus.
-- 
-- Create this `target_comp` column, making sure to format _both_ the `salary` and `target_comp` columns nicely (ie, with dollar signs and comma separators).
select firstname, lastname, printf('$%,.2d', salary) as salary, startdate, printf('$%,.2d', CASE
when lower(job) = 'sales' and salary > 100000 then salary + salary *0.1
when lower(job) = 'sales' and salary < 100000 then salary + salary * 0.05
when lower(job) = 'administrator' then salary + salary * 0.05
else salary
end) as target_comp
from employees