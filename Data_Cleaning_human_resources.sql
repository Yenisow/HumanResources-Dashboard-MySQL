CREATE DATABASE HUMAN_RESOURCES;

USE HUMAN_RESOURCES;

ALTER TABLE HR
CHANGE ï»¿id emp_id VARCHAR(20) NULL;

SELECT * FROM HR;

UPDATE HUMAN_RE  
SET hire_date = CASE    
    WHEN hire_date LIKE '%/%' THEN STR_TO_DATE(hire_date, '%m/%d/%Y')    
    WHEN hire_date LIKE '%-%' THEN STR_TO_DATE(hire_date, '%m-%d-%Y')    
    ELSE NULL  
END;