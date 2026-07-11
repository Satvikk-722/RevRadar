-- RevRadar — Business Intelligence SQL Queries
-- Analyst: Satvik
-- Database: B2B SaaS CRM Data (2023)
-- Tool: MySQL
-- ================================================


-- ================================================
-- QUERY 1: Customer Distribution by Status
-- Business Question: How many customers in each 
-- status and what is their percentage share?
-- ================================================

SELECT 
    Status,
    COUNT(*) AS Total_Customers,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM revradar_clean)) * 100, 1) AS Percentage
FROM revradar_clean
GROUP BY Status
ORDER BY Total_Customers DESC;

-- Output : 
-- Status  Total_Customers  Percentage 
-- Active	    652            57.2
-- Churned	    249            21.8
-- Trial	    131	           11.5
-- Paused	    108	           9.5


-- ================================================
-- QUERY 2: Churn Rate by Quarter
-- Business Question: How did churn rate trend
-- across quarters in 2023?
-- ================================================

SELECT
    Quarter,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS Churn_Rate_Pct
FROM revradar_clean
GROUP BY Quarter
ORDER BY Quarter;

-- Output:
-- Quarter  Total_Customers  Churned_Customers  Churn_Rate_Pct
-- Q1           240               42                17.5
-- Q2           270               51                18.9
-- Q3           300               80                26.7
-- Q4           330               76                23.0


-- ================================================
-- QUERY 3: Active MRR by Segment
-- Business Question: How is active MRR distributed
-- across customer segments?
-- ================================================

SELECT
    Segment,
    COUNT(*) AS Active_Customers,
    SUM(MRR_INR) AS Total_MRR,
    ROUND(AVG(MRR_INR), 0) AS Avg_MRR_Per_Customer,
    ROUND(SUM(MRR_INR) / (SELECT SUM(MRR_INR) FROM revradar_clean WHERE Status = 'Active') * 100, 1) AS MRR_Pct_of_Total
FROM revradar_clean
WHERE Status = 'Active'
GROUP BY Segment
ORDER BY Total_MRR DESC;

-- Output:
-- Segment       Active_Customers  Total_MRR   Avg_MRR_Per_Customer  MRR_Pct_of_Total
-- Enterprise        230           9775584          42503                59.0
-- Mid-Market        212           4919303          23204                29.7
-- SMB               210           1885296           8978                11.4


-- ================================================
-- QUERY 4: Lost MRR by Churn Reason
-- Business Question: Which churn reasons are causing
-- the highest revenue loss?
-- ================================================

SELECT
    Churn_Reason,
    COUNT(*) AS Total_Churned,
    SUM(MRR_INR) AS Total_Lost_MRR,
    ROUND(AVG(MRR_INR), 0) AS Avg_MRR_Per_Customer,
    ROUND(SUM(MRR_INR) / (SELECT SUM(MRR_INR) FROM revradar_clean WHERE Status = 'Churned' AND Churn_Reason != 'Not Applicable') * 100, 1) AS Pct_of_Total_Lost_MRR
FROM revradar_clean
WHERE Status = 'Churned'
AND Churn_Reason != 'Not Applicable'
GROUP BY Churn_Reason
ORDER BY Total_Lost_MRR DESC;

-- Output:
-- Churn_Reason      Total_Churned  Total_Lost_MRR  Avg_MRR_Per_Customer  Pct_of_Total_Lost_MRR
-- Missing features      61           1637901            26851                  26.8
-- Competitor            43           1576906            36672                  25.8
-- Price                 61           1096440            17974                  17.9
-- Poor UX               34            688019            20236                  11.2
-- Budget cut            23            613050            26654                  10.0
-- No response           23            507692            22074                   8.3


-- ================================================
-- QUERY 5: Top 10 Highest MRR Active Customers
-- Business Question: Who are our most valuable
-- active customers we cannot afford to lose?
-- ================================================

SELECT
    Customer_ID,
    Segment,
    Plan,
    MRR_INR,
    CSAT,
    Usage_Pct,
    Region
FROM revradar_clean
WHERE Status = 'Active'
ORDER BY MRR_INR DESC
LIMIT 10;

-- Output:
-- Customer_ID  Segment       Plan        MRR_INR  CSAT  Usage_Pct  Region
-- 1069         Enterprise    Enterprise  79827     6.4     69       East
-- 878          Mid-Market    Enterprise  79625     8.7     67       North
-- 858          Mid-Market    Enterprise  79460     8.0     68       North
-- 740          SMB           Enterprise  79009     6.1     40       West
-- 458          Mid-Market    Enterprise  78831     8.9     43       West
-- 505          Enterprise    Enterprise  78778     8.3     69       West
-- 1113         Enterprise    Enterprise  78753     8.9     57       West
-- 917          Enterprise    Enterprise  78686     7.2     60       East
-- 184          Mid-Market    Enterprise  78505     7.9     40       West
-- 952          Mid-Market    Enterprise  78497     8.5     72       South


-- ================================================
-- QUERY 6: At-Risk Active Customers
-- Business Question: Which active customers show
-- early churn signals — low CSAT and low usage?
-- ================================================

SELECT
    Customer_ID,
    Segment,
    Plan,
    MRR_INR,
    CSAT,
    Usage_Pct,
    Region
FROM revradar_clean
WHERE Status = 'Active'
AND CSAT < 7
AND Usage_Pct < 45
ORDER BY MRR_INR DESC;

-- Output (At-Risk Customers List):
-- Customer_ID  Segment       Plan        MRR_INR  CSAT  Usage_Pct  Region
-- 740          SMB           Enterprise  79009     6.1     40       West
-- 335          Mid-Market    Enterprise  72349     6.8     39       North
-- 450          Enterprise    Enterprise  69756     6.3     39       East
-- 513          Enterprise    Enterprise  68394     6.9     41       North
-- 936          Mid-Market    Enterprise  56498     6.3     38       West
-- 895          Enterprise    Enterprise  51734     6.2     38       East
-- 299          SMB           Enterprise  49547     6.9     44       West
-- 101          Enterprise    Enterprise  47148     6.9     40       North
-- 749          Enterprise    Enterprise  45622     6.5     36       North
-- 744          Enterprise    Enterprise  40395     6.5     40       North
-- 399          Mid-Market    Enterprise  36511     6.9     38       East
-- 343          Enterprise    Enterprise  33987     6.9     44       West
-- 483          Enterprise    Enterprise  30083     6.9     42       South
-- 244          Enterprise    Enterprise  37895     6.4     36       West
-- 280          Mid-Market    Growth      18463     6.5     38       West
-- 88           Mid-Market    Growth      17731     6.6     44       East
-- 179          Mid-Market    Growth      17071     6.9     35       West
-- 253          Mid-Market    Growth      16888     6.5     41       West
-- 635          Mid-Market    Growth      16888     6.2     42       North
-- 487          Mid-Market    Growth      16096     6.9     40       North
-- 221          Enterprise    Growth      16126     6.6     40       West
-- 1122         Enterprise    Growth      15366     6.3     41       North
-- 763          SMB           Starter     15075     6.5     42       North
-- 861          Mid-Market    Growth      14328     6.6     44       East
-- 493          Mid-Market    Growth      13985     6.7     39       West
-- 623          Mid-Market    Growth      13628     6.5     44       South
-- 883          SMB           Growth      11571     6.7     42       West
-- 551          Mid-Market    Growth      11578     6.5     42       West
-- 274          Mid-Market    Growth      11362     6.9     40       East
-- 118          Mid-Market    Growth      11764     6.3     40       South
-- 1124         Mid-Market    Growth      11317     6.9     39       North
-- 455          Mid-Market    Growth      10405     6.9     37       West
-- 533          Mid-Market    Growth      10677     6.4     38       West
-- 772          Mid-Market    Growth       8899     6.3     36       South
-- 604          SMB           Growth       8883     6.6     35       East
-- 201          Enterprise    Growth      16386     6.9     41       West
-- 695          SMB           Starter      4700     6.9     40       North
-- 237          SMB           Starter      4510     6.9     42       West
-- 632          SMB           Starter      4247     6.5     38       North
-- 412          Enterprise    Starter      3938     6.8     43       South
-- 7            SMB           Starter      3812     6.7     43       East
-- 764          SMB           Starter      3269     6.5     42       East
-- 698          SMB           Starter      3196     6.1     38       North
-- 929          SMB           Starter      3123     6.3     36       East
-- 939          SMB           Starter      2959     6.9     42       East
-- 1078         SMB           Starter      3356     6.9     39       North
-- 149          SMB           Starter      3580     6.8     43       North
-- 401          SMB           Starter      3513     6.9     38       West
-- 495          SMB           Starter      2585     6.4     36       East
-- 561          Mid-Market    Starter      2816     6.3     39       South
-- 608          Mid-Market    Starter      2320     6.3     35       South
-- 218          Mid-Market    Starter      2021     6.4     37       North
-- 1046         SMB           Starter      2039     6.2     41       North

-- Total MRR at risk
SELECT
    COUNT(*) AS At_Risk_Customers,
    SUM(MRR_INR) AS Total_MRR_At_Risk
FROM revradar_clean
WHERE Status = 'Active'
AND CSAT < 7
AND Usage_Pct < 45;

-- Output (At-Risk Summary):
-- At_Risk_Customers  Total_MRR_At_Risk
--        53               1079399


-- ================================================
-- QUERY 7: Churn Rate by Plan
-- Business Question: Which plan has the highest
-- churn problem — by volume and revenue impact?
-- ================================================

SELECT
    Plan,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS Churn_Rate_Pct,
    SUM(CASE WHEN Status = 'Churned' THEN MRR_INR ELSE 0 END) AS Total_Lost_MRR
FROM revradar_clean
GROUP BY Plan
ORDER BY Churn_Rate_Pct DESC;

-- Output:
-- Plan        Total_Customers  Churned_Customers  Churn_Rate_Pct  Total_Lost_MRR
-- Growth           405               94               23.2          1302478
-- Enterprise       391               84               21.5          4582930
-- Starter          344               71               20.6           250269


-- ================================================
-- QUERY 8: Average CSAT and Usage by Status
-- Business Question: How do CSAT and feature usage
-- differ across customer status groups?
-- ================================================

SELECT
    Status,
    ROUND(AVG(CSAT), 2) AS Avg_CSAT,
    ROUND(AVG(Usage_Pct), 2) AS Avg_Usage_Pct,
    COUNT(*) AS Total_Customers
FROM revradar_clean
GROUP BY Status
ORDER BY Total_Customers DESC;

-- Output:
-- Status   Avg_CSAT  Avg_Usage_Pct  Total_Customers
-- Active     7.54        55.15           652
-- Churned    4.68        20.57           249
-- Trial      6.57        34.36           131
-- Paused     6.56        35.46           108


-- ================================================
-- QUERY 9: Revenue Concentration Risk
-- Business Question: How dependent are we on
-- Enterprise segment — what is the concentration risk?
-- ================================================

SELECT
    Segment,
    COUNT(*) AS Active_Customers,
    SUM(MRR_INR) AS Total_Active_MRR,
    ROUND(AVG(MRR_INR), 0) AS Avg_MRR_Per_Customer,
    ROUND(SUM(MRR_INR) / (SELECT SUM(MRR_INR) FROM revradar_clean WHERE Status = 'Active') * 100, 2) AS MRR_Pct_of_Total
FROM revradar_clean
WHERE Status = 'Active'
GROUP BY Segment
ORDER BY Total_Active_MRR DESC;

-- Output:
-- Segment       Active_Customers  Total_Active_MRR  Avg_MRR_Per_Customer  MRR_Pct_of_Total
-- Enterprise        230              9775584              42503                58.96
-- Mid-Market        212              4919303              23204                29.67
-- SMB               210              1885296               8978                11.37

-- Insight:
-- Enterprise contributes 59% of MRR from only 35% of customers.
-- Losing 3 Enterprise accounts = losing ~14 SMB accounts in revenue.
-- High concentration risk — retention strategy must prioritize Enterprise.

-- ================================================
-- QUERY 10: High Support Tickets and Low CSAT
-- Business Question: Which customers are creating
-- the most operational burden and are dissatisfied?
-- ================================================

SELECT
    Customer_ID,
    Segment,
    Plan,
    Status,
    Support_Tickets,
    CSAT,
    MRR_INR,
    Region
FROM revradar_clean
WHERE Support_Tickets >= 5
AND CSAT < 7
AND Status = 'Active'
ORDER BY MRR_INR;

-- Output (52 customers — ordered by MRR ascending):
-- Customer_ID  Segment       Plan        Status  Tickets  CSAT  MRR_INR  Region
-- 991          SMB           Starter     Active    6       6.6    2137    East
-- 476          SMB           Starter     Active    5       6.3    2290    East
-- 608          Mid-Market    Starter     Active    5       6.3    2320    South
-- 951          SMB           Starter     Active    5       6.4    2712    South
-- 977          SMB           Starter     Active    5       6.1    3102    South
-- 929          SMB           Starter     Active    6       6.3    3123    East
-- 402          SMB           Starter     Active    6       6.8    3209    East
-- 401          SMB           Starter     Active    5       6.9    3513    West
-- 892          SMB           Starter     Active    5       6.3    3545    West
-- 149          SMB           Starter     Active    6       6.8    3580    North
-- 39           SMB           Starter     Active    5       6.2    3711    East
-- 822          Mid-Market    Starter     Active    5       6.9    3934    East
-- 412          Enterprise    Starter     Active    5       6.8    3938    South
-- 697          SMB           Starter     Active    6       6.3    3943    West
-- 632          SMB           Starter     Active    5       6.5    4247    North
-- 292          SMB           Starter     Active    5       6.9    4438    East
-- 60           SMB           Growth      Active    5       6.1    8044    West
-- 1121         Mid-Market    Growth      Active    5       6.6    8662    East
-- 516          SMB           Growth      Active    6       6.9    9174    West
-- 61           Mid-Market    Growth      Active    5       6.4    9295    North
-- 462          SMB           Growth      Active    6       6.9   10036    East
-- 682          SMB           Growth      Active    5       6.5   11213    West
-- 551          Mid-Market    Growth      Active    5       6.5   11578    West
-- 1036         Enterprise    Growth      Active    5       6.2   13298    East
-- 296          Enterprise    Growth      Active    5       6.2   13476    West
-- 623          Mid-Market    Growth      Active    6       6.5   13628    South
-- 386          Enterprise    Enterprise  Active    5       6.4   15075    West
-- 1122         Enterprise    Growth      Active    5       6.3   15366    North
-- 225          Mid-Market    Growth      Active    5       6.9   16695    South
-- 263          Mid-Market    Growth      Active    6       6.9   17001    North
-- 911          Mid-Market    Growth      Active    5       6.9   17459    East
-- 88           Mid-Market    Growth      Active    6       6.6   17731    East
-- 59           SMB           Growth      Active    5       6.9   19068    South
-- 202          Mid-Market    Growth      Active    5       6.4   19128    South
-- 752          Mid-Market    Growth      Active    6       6.4   19483    South
-- 979          Mid-Market    Growth      Active    5       6.9   19613    North
-- 503          Enterprise    Enterprise  Active    6       6.9   34031    South
-- 213          Enterprise    Enterprise  Active    5       6.3   43047    West
-- 749          Enterprise    Enterprise  Active    5       6.5   45622    North
-- 35           Enterprise    Enterprise  Active    5       6.6   49162    South
-- 261          Enterprise    Enterprise  Active    5       6.3   49271    North
-- 299          SMB           Enterprise  Active    6       6.9   49547    West
-- 765          Enterprise    Enterprise  Active    5       6.9   51004    East
-- 777          Enterprise    Enterprise  Active    6       6.2   51169    West
-- 936          Mid-Market    Enterprise  Active    5       6.3   56498    West
-- 206          SMB           Enterprise  Active    5       6.9   60275    West
-- 1004         Enterprise    Enterprise  Active    6       6.9   64307    West
-- 837          Enterprise    Enterprise  Active    6       6.7   66789    West
-- 62           Enterprise    Enterprise  Active    5       6.6   68287    North
-- 513          Enterprise    Enterprise  Active    6       6.9   68394    North
-- 137          Enterprise    Enterprise  Active    5       6.1   69358    West
-- 582          Enterprise    Enterprise  Active    5       6.9   72555    North



-- ================================================
-- QUERY 11: Onboarding Type vs Churn Rate
-- Business Question: Does onboarding type impact
-- customer retention?
-- ================================================

SELECT
    Onboarding_Type,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND((SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Churn_Rate_Pct,
    ROUND(AVG(CSAT), 1) AS Avg_CSAT,
    ROUND(AVG(Usage_Pct), 2) AS Avg_Usage_Pct
FROM revradar_clean
WHERE Onboarding_Type != 'Unknown'
GROUP BY Onboarding_Type
ORDER BY Churn_Rate_Pct DESC;

-- Output:
-- Onboarding_Type  Total_Customers  Churned_Customers  Churn_Rate_Pct  Avg_CSAT  Avg_Usage_Pct
-- Assisted              205               50               24.39          6.6        41.25
-- Enterprise CSM        339               73               21.53          6.7        44.14
-- Self-serve            558              118               21.15          6.7        43.52


-- ================================================
-- QUERY 12: Industry-wise Churn and Revenue Analysis
-- Business Question: Which industries have the
-- highest churn rate and revenue at risk?
-- ================================================

SELECT
    Industry,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND((SUM(CASE WHEN Status = 'Churned' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 1) AS Churn_Rate_Pct,
    SUM(CASE WHEN Status = 'Active' THEN MRR_INR ELSE 0 END) AS Active_MRR,
    SUM(CASE WHEN Status = 'Churned' THEN MRR_INR ELSE 0 END) AS Lost_MRR,
    ROUND(AVG(CSAT), 2) AS Avg_CSAT
FROM revradar_clean
GROUP BY Industry
ORDER BY Churn_Rate_Pct DESC;

-- Output:
-- Industry      Total_Customers  Churned_Customers  Churn_Rate_Pct  Active_MRR  Lost_MRR  Avg_CSAT
-- Ecommerce          137               34               24.8          1828120     942544     6.58
-- SaaS               149               37               24.8          1986185     931615     6.61
-- Fintech            130               31               23.8          1675216    1052675     6.64
-- Manufacturing      152               33               21.7          1829964    1000015     6.74
-- EdTech             139               29               20.9          2159359     517779     6.79
-- Healthcare         136               28               20.6          2074129     622143     6.71
-- Logistics          142               29               20.4          2155181     467691     6.75
-- Media              155               28               18.1          2872029     601215     6.85