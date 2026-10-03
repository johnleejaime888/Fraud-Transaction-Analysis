/*In this process, I cleaned the raw data by identifying and fixing inconsistent data, including typos, extra spaces, improper formats, and negative values. 
I also removed duplicate records to maintain data accuracy and ensure unique row counts.*/

/* 
Data Validation
 - Duplicates Records
 - I identified blank and negative values in the amount column  and converted them to NULL to prevent invalid values from affecting the calculation of totals and other metrics.
 - I identified missing values in the location column and replaced them with "Unknown" to preserve the records without making assumptions about the correct values.
 */

/* SQL Function Used: 
CTE Function, Windows Function, Argregated Function, CASE Function, CONCAT, LOCATE, UPPER, LOWER
SUBSTRING, SUBSTRING_INDEX, SELECT, UPDATE, DELETE, WHERE, AS, GROUP BY */


use project2000;

CREATE TABLE staging
LIKE transactions_raw;

INSERT INTO staging
SELECT * FROM transactions_raw;


# Checking Duplicate

/*I identified duplicate records using a CTE and window function. Since UPDATE is not applicable within the CTE, I created a new staging table to remove the duplicate records.*/

WITH duplicateCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY transaction_id) AS row_num
	FROM staging
)
SELECT * FROM duplicateCTE WHERE row_num > 1;

CREATE TABLE staging1
LIKE staging;

ALTER TABLE staging1
ADD COLUMN row_num INT;

INSERT INTO staging1
SELECT *,
		ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY transaction_id) AS row_num
	FROM staging;

DELETE FROM staging1 WHERE row_num > 1;

# Standardize Data

/* In this step I update the date format using STR_DATE and COALESCE function, COALESCE function check the column if the  */

SELECT DISTINCT(transaction_date) FROM staging1;

SELECT transaction_id, transaction_date, 
	COALESCE(
		STR_TO_DATE(transaction_date, "%m-%d-%Y"),
        STR_TO_DATE(transaction_date, "%d-%b-%Y"),
        STR_TO_DATE(transaction_date, "%e-%m-%Y"),
        STR_TO_DATE(transaction_date, "%Y-%m-%d"),
		STR_TO_DATE(transaction_date, "%Y/%m/%d")
		
        ) AS correct_date_format
FROM staging1;

SET sql_mode = '';

UPDATE staging1 SET transaction_date = COALESCE(
		STR_TO_DATE(transaction_date, "%m-%d-%Y"),
        STR_TO_DATE(transaction_date, "%d-%b-%Y"),
        STR_TO_DATE(transaction_date, "%e-%m-%Y"),
        STR_TO_DATE(transaction_date, "%Y-%m-%d"),
		STR_TO_DATE(transaction_date, "%Y/%m/%d")
        );

UPDATE staging1 SET transaction_date = REPLACE(transaction_date,'/','-');

SELECT * FROM staging1 WHERE amount_php < 0;

UPDATE staging1 SET amount_php = NULL WHERE amount_php < 0;

SELECT customer_name,
	CASE
		WHEN LOCATE(" ", TRIM(customer_name)) > 0 THEN
			CONCAT(
				UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 1, 1)),
				LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 2)),
				' ',
				UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ' , -1), 1, 1)),
					LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', -1), 2))
			)
            
            ELSE
				CONCAT(
				UPPER(SUBSTRING(TRIM(customer_name), 1, 1)),
                LOWER(SUBSTRING(TRIM(customer_name), 2))
        )
    END AS clean_customer_name
FROM staging1;

UPDATE staging1 SET customer_name = 
	CASE
		WHEN LOCATE(" ", TRIM(customer_name)) > 0 THEN
			CONCAT(
				UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 1, 1)),
				LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 2)),
				' ',
				UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ' , -1), 1, 1)),
					LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', -1), 2))
			)
            
            ELSE
				CONCAT(
				UPPER(SUBSTRING(TRIM(customer_name), 1, 1)),
                LOWER(SUBSTRING(TRIM(customer_name), 2))
        )
    END;
    
    
    SELECT merchant_category, TRIM(merchant_category),
		CASE
			WHEN LOCATE(" ", TRIM(merchant_category)) > 0 THEN
				CONCAT(
					UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ', 1), 1, 1)),
					LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ', 1), 2)),
					' ',
					UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ' , -1), 1, 1)),
					LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ', -1), 2))
			)
            
            ELSE
				CONCAT(
					UPPER(SUBSTRING(TRIM(merchant_category), 1, 1)),
					LOWER(SUBSTRING(TRIM(merchant_category), 2))
                )
        END AS clean_category
    FROM staging1;

UPDATE staging1 SET merchant_category =
		CASE
			WHEN LOCATE(" ", TRIM(merchant_category)) > 0 THEN
				CONCAT(
					UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ', 1), 1, 1)),
					LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ', 1), 2)),
					' ',
					UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ' , -1), 1, 1)),
					LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(merchant_category),' ', -1), 2))
			)
            
            ELSE
				CONCAT(
					UPPER(SUBSTRING(TRIM(merchant_category), 1, 1)),
					LOWER(SUBSTRING(TRIM(merchant_category), 2))
                )
        END;
        
SELECT DISTINCT(merchant_name) FROM staging1;

SELECT DISTINCT(payment_method) FROM staging1;

SELECT DISTINCT(card_type) FROM staging1;

SELECT DISTINCT(location_city) FROM staging1;

UPDATE staging1 SET location_city =
	CASE
		WHEN location_city = 'Makati' THEN 'Makati City'
        WHEN location_city = 'Taguig' THEN 'Taguig City'
        WHEN location_city = 'Manila' THEN 'Manila City'
        WHEN location_city = 'Baguio' THEN 'Baguio City'
        WHEN location_city = 'Pasig' THEN 'Pasig City'
        WHEN location_city = 'N/A' THEN 'Unknown'
        WHEN location_city = '' THEN 'Unknown'
	ELSE location_city
    END;

SELECT DISTINCT(location_country) FROM staging1;

SELECT DISTINCT(device_type) FROM staging1;

SELECT DISTINCT(is_foreign_transaction) FROM staging1;

UPDATE staging1 SET is_foreign_transaction =
	CASE
		WHEN location_country = 'Philippines' THEN 0
	ELSE 1
    END;
    
SELECT account_age_days FROM staging1 WHERE account_age_days > 0;

SELECT * FROM staging1;



