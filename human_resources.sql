CREATE DATABASE HUMAN_RESOURCES;

USE HUMAN_RESOURCES;

ALTER TABLE HR
CHANGE ï»¿id emp_id VARCHAR(20) NULL;

SELECT * FROM HR;

SET sql_safe_updates=0;

UPDATE HR 
SET birthdate = CASE
   WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
   WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
   ELSE NULL 
END;

ALTER TABLE HR 
MODIFY COLUMN birthdate DATE;

UPDATE HR  
SET hire_date = CASE    
    WHEN hire_date LIKE '%/%' THEN STR_TO_DATE(hire_date, '%m/%d/%Y')    
    WHEN hire_date LIKE '%-%' THEN STR_TO_DATE(hire_date, '%m-%d-%Y')    
    ELSE NULL  
END;
ALTER TABLE HR
MODIFY COLUMN hire_date DATE;

SELECT * FROM HR;

DESC HR;
SELECT hire_date FROM HR;

UPDATE HR
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate <> '';

SELECT termdate FROM HR;

ALTER TABLE HR
MODIFY COLUMN termdate DATE;

SELECT termdate FROM HR WHERE termdate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
UPDATE HR 
SET termdate = NULL 
WHERE termdate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

/*
NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' utilise une expression régulière pour vérifier si la date est correcte :

^[0-9]{4} → Vérifie que l'année a 4 chiffres (ex. 2025).

-[0-9]{2} → Vérifie que le mois a 2 chiffres (ex. 05).

-[0-9]{2}$ → Vérifie que le jour a 2 chiffres (ex. 12).

✅ Pourquoi ? Avant de modifier la colonne, il faut s’assurer que toutes les valeurs sont bien des dates valides.
*/

DESC HR;

ALTER TABLE HR
ADD COLUMN Age INT;
SELECT * FROM HR;
ALTER TABLE HR
CHANGE COLUMN Age age INT;

UPDATE HR
SET AGE = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
SELECT birthdate, age FROM HR;

SELECT 
   MIN(age) AS youngest,
   MAX(age) AS oldest
FROM HR;
SELECT COUNT(*) FROM HR
WHERE age < 18; -- Peut etre on pourrait eliminer les valeurs en dessous de 18ans pour faire nos analyses

-- QUESTIONS 
-- 1. What is the gender breakdown of employees in the company ?
SELECT gender, COUNT(*) AS count FROM HR
WHERE age >=18 AND termdate IS NULL 
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company ?
SELECT race, COUNT(*) AS count FROM HR
WHERE age>=18 AND termdate IS NULL
GROUP BY race
ORDER BY count(*) DESC;

-- 3. What is the age distribution of employees in the company ? 
SELECT 
   MIN(age) AS youngest,
   MAX(age) AS oldest
 FROM HR
 WHERE age>=18 AND termdate IS NULL;
 
 SELECT 
   CASE
     WHEN age>=18 AND age<=24 THEN '18-24'
     WHEN age>=25 AND age<=34 THEN '25-34'
     WHEN age>=35 AND age<=44 THEN '35-44'
     WHEN age>=45 AND age<=54 THEN '45-54'
     WHEN age>=55 AND age<=64 THEN '55-64'
     ELSE '65+'
	END AS age_group,
    COUNT(*) AS count
    FROM HR
    WHERE age>=18 AND termdate IS NULL
    GROUP BY age_group
    ORDER BY age_group;

SELECT 
   CASE
     WHEN age>=18 AND age<=24 THEN '18-24'
     WHEN age>=25 AND age<=34 THEN '25-34'
     WHEN age>=35 AND age<=44 THEN '35-44'
     WHEN age>=45 AND age<=54 THEN '45-54'
     WHEN age>=55 AND age<=64 THEN '55-64'
     ELSE '65+'
	END AS age_group, gender, COUNT(*) AS count
    FROM HR
    WHERE age>=18 AND termdate IS NULL
    GROUP BY age_group, gender
    ORDER BY age_group, gender;
-- 4. How many employees work at headquarters versus remote location
SELECT location, COUNT(*) AS count 
FROM HR
WHERE age>=18 AND termdate IS NULL
GROUP BY location;

-- 5. What is the average lenght of employment who have been terminated ?
SELECT 
   ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_length_employment
FROM HR
WHERE termdate<=CURDATE() AND age>=18 AND termdate IS NOT NULL;

-- 6. How does the gender distrubtion vary across departments and job titles
SELECT department, gender, COUNT(*) AS count
FROM HR
WHERE age>=18 AND termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of jobtitle across the company ?
SELECT jobtitle, COUNT(*) AS count
FROM HR
WHERE age>=18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate ? / Quel est le département qui connaît le taux de rotation le plus élevé ?
SELECT department,
  total_count,
  terminated_count,
  terminated_count/total_count AS termination_rate
FROM (
  SELECT department,
  COUNT(*) AS total_count,
  SUM(CASE WHEN termdate IS NOT NULL AND termdate<=CURDATE() THEN 1 ELSE 0 END) AS terminated_count
  FROM HR
  WHERE age>=18
  GROUP BY department
  ) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?/ 
-- Quelle est la répartition des employés entre les différents sites, par ville et par État ?
SELECT location_state, COUNT(*) AS count
FROM HR
WHERE age>=18 AND termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates ?
-- Comment le nombre de salariés de l'entreprise a-t-il évolué dans le temps en fonction des dates d'embauche et de fin de contrat ?
SELECT 
   year,
   hires,
   terminations,
   hires - terminations AS net_change,
   ROUND((hires - terminations)/hires * 100, 2) AS net_change_percent
FROM(
   SELECT
     YEAR(hire_date) AS year,
     COUNT(*) AS hires,
     SUM(CASE WHEN termdate IS NOT NULL AND termdate<=CURDATE() THEN 1 ELSE 0 END) AS terminations
     FROM HR
     WHERE age>=18
     GROUP BY YEAR(hire_date)
     ) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department ? / Quelle est la répartition de la durée du mandat dans chaque département ?
SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365),0) AS avg_tenure
FROM HR
WHERE age>=18 AND termdate IS NOT NULL AND termdate<=CURDATE()
GROUP BY department;





