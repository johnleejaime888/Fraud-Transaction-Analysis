SELECT * FROM staging1;

#1. What is the overall fraud rate, and how does it trend over the data period? Any spikes worth flagging?
	
    SELECT month(transaction_date) AS month_number, monthname(transaction_date) AS month_name,
		SUM(CASE WHEN is_fraud = '1' THEN 1 ELSE 0 END) AS total_fraud,
        COUNT(*) AS total,
        ROUND(SUM(CASE WHEN is_fraud = '1' THEN 1 ELSE 0 END) / COUNT(*), 2) AS avg_fraud
    FROM staging1 GROUP BY month(transaction_date), monthname(transaction_date) ORDER BY month(transaction_date);
    
#Based on the data, 197 out of 5,000 transactions were identified as fraudulent, with an average fraud rate of 4% and 2 to 4% per month."

#2. Which **merchant categories** carry the highest fraud rate (not just highest fraud count — rate matters more for risk prioritization)?
	
    SELECT merchant_category,
		SUM(CASE WHEN is_fraud = '1' THEN 1 ELSE 0 END) AS total_fraud,
        COUNT(*) AS total,
        ROUND(SUM(CASE WHEN is_fraud = '1' THEN 1 ELSE 0 END) / COUNT(*), 2) AS avg_fraud
    FROM staging1 GROUP BY merchant_category ORDER BY avg_fraud DESC;
    
# Gaming and Money Transfer recorded the highest fraud rates at around 6%, with 25 fraudulent transactions each, while Jewelry had the lowest fraud rate at approximately 2%, with only 6 fraudulent transactions.

#3. Are **foreign transactions** meaningfully riskier than domestic ones? By how much?
	
    SELECT is_foreign_transaction,
		SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS total_fraud,
        COUNT(*) AS total,
        ROUND(SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS avg_fraud_rate
    FROM staging1 GROUP BY is_foreign_transaction;
    
# Foreign transactions recorded a significantly higher fraud rate at approximately 26%, with 134 fraudulent transactions, compared with domestic transactions at 1%, with 63 fraudulent transactions.

#4. Does **transaction velocity** (number of transactions in the last 24h) correlate with fraud? Is there a velocity threshold where risk jumps?

SELECT is_fraud,
	SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) total_fraud,
    SUM(COALESCE(transaction_velocity_24h, 0)) total_transaction_velocity,
    COUNT(*) AS total,
    ROUND(SUM(COALESCE(transaction_velocity_24h, 0)) / COUNT(*), 0) AS average_transaction_velocity_24h
FROM staging1 GROUP BY is_fraud;

# Higher transaction velocity appears to be associated with increased fraud risk, with fraudulent transactions averaging approximately 9 transactions compared with 2 transactions for normal transactions.


# 5. Which **payment method / card type** combinations show elevated fraud?

SELECT card_type, payment_method,
	SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END) AS total_fraud
FROM staging1 GROUP BY card_type, payment_method ORDER BY total_fraud DESC;

# Based on the analysis, all card type and payment method combinations showed elevated levels of fraudulent transactions.

#6. Does **account age** matter — are newer accounts riskier?
	
SELECT is_fraud, 
SUM(COALESCE(account_age_days, 0)) AS total_account_age_day, 
COUNT(*) AS total, 
SUM(COALESCE(account_age_days, 0)) / COUNT(*) AS avg_account_age FROM staging1  GROUP BY is_fraud;

#Based on the analysis, account age does not appear to be a significant factor in fraud, as fraudulent calls were observed across both new and older accounts.
