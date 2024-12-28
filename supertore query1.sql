use supertore;
alter table  `sales 2`
rename to Superstore;

update superstore
set Order_Date = str_to_date(Order_Date,'%m/%d/%Y') ;
ALTER TABLE superstore
MODIFY COLUMN Order_Date  DATE ;

update superstore
set Ship_Date = str_to_date(Ship_Date,'%m/%d/%Y') ;
ALTER TABLE superstore
MODIFY COLUMN Ship_Date   DATE ;



#1. Total sales, profit, and profit margin by product category and region
SELECT Region, Category, 
           SUM(Sales) AS Total_Sales, 
           SUM(Profit) AS Total_Profit, 
           SUM(Profit)/SUM(Sales) AS Profit_Margin
    FROM Superstore
    GROUP BY Region, Category;
    
    #2. Top 5 most profitable products and the customers who purchased them
    SELECT Product_Name, Customer_Name,  SUM(Profit) AS Total_Profit
    FROM Superstore
    group by Product_Name, Customer_Name,
    ORDER BY Total_Profit DESC
    LIMIT 5;


#3. Month-over-month percentage change in total sales for each region
SELECT Region, DATE_FORMAT(Order_Date, '%Y-%m') AS Month, 
           SUM(Sales) AS Total_Sales,
           (SUM(Sales) - LAG(SUM(Sales)) OVER (PARTITION BY Region ORDER BY DATE_FORMAT(Order_Date, '%Y-%m'))) / 
           LAG(SUM(Sales)) OVER (PARTITION BY Region
 ORDER BY DATE_FORMAT(Order_Date, '%Y-%m')) * 100 AS MoM_Change
    FROM Superstore
    GROUP BY Region, DATE_FORMAT(Order_Date, '%Y-%m');
    
    
#4. Region with the highest profit
SELECT Region, SUM(Profit) AS Total_Profit
    FROM Superstore
    GROUP BY Region
    ORDER BY Total_Profit DESC
    LIMIT 1;
    
#5. Top 3 customers contributing to the highest sales in each segment
SELECT Segment, Customer_Name, SUM(Sales) AS Total_Sales
    FROM Superstore
    GROUP BY Segment, Customer_Name
    ORDER BY Segment, Total_Sales DESC
    LIMIT 3;
    
#6. Average delivery time by shipping mode
SELECT Ship_Mode, AVG(DATEDIFF(Ship_Date, Order_Date)) AS Avg_Delivery_Time
    FROM Superstore
    GROUP BY Ship_Mode;
    
    
#7. Top 5 cities with the highest order volume and their average sales and profit
SELECT City, COUNT(Order_ID) AS Order_Volume, AVG(Sales) AS Avg_Sales, AVG(Profit) AS Avg_Profit
    FROM Superstore
    GROUP BY City
    ORDER BY Order_Volume DESC
    LIMIT 5;
    
    
#8. Orders with discounts exceeding 20% and a positive profit margin
SELECT *
    FROM Superstore
    WHERE Discount > 0.2 AND Profit > 0;
    
    
#9. Percentage of total sales for each shipping mode in each region
SELECT Region, Ship_Mode, 
           SUM(Sales) AS Sales_By_Mode, 
           (SUM(Sales) / SUM(SUM(Sales)) OVER (PARTITION BY Region)) * 100 AS Percent_Of_Total
    FROM Superstore
    GROUP BY Region, Ship_Mode;
    
    
#10. Number of orders shipped late
SELECT COUNT(*) AS Late_Orders
    FROM Superstore
    WHERE Ship_Date > DATE_ADD(Order_Date, INTERVAL Expected_Delivery_Days DAY);
    
    
#11. Products purchased by the highest number of unique customers in each region
SELECT Region, Product_Name, COUNT(DISTINCT Customer_ID) AS Unique_Customers
    FROM Superstore
    GROUP BY Region, Product_Name
    ORDER BY Region, Unique_Customers DESC;
    
    
#12. Customers who made repeat purchases of the same product and their total sales and profit contribution
SELECT Customer_Name, Product_Name, SUM(Sales) AS Total_Sales, SUM(Profit) AS Total_Profit
    FROM Superstore
    GROUP BY Customer_Name, Product_Name
    HAVING COUNT(*) > 1;
    
    
#13. Top 10 customers by total purchase value
SELECT Customer_Name, SUM(Sales) AS Total_Purchase_Value
    FROM Superstore
    GROUP BY Customer_Name
    ORDER BY Total_Purchase_Value DESC
    LIMIT 10;
    
    
#14. Total sales and profit for each product and products with consistent negative profit margins
SELECT Product_Name, 
           SUM(Sales) AS Total_Sales, 
           SUM(Profit) AS Total_Profit,
           AVG(Profit) AS Avg_Profit
    FROM Superstore
    GROUP BY Product_Name
    HAVING Avg_Profit < 0;
    
    
#15. Top-selling product in each month of each year
SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month, Product_Name, SUM(Sales) AS Total_Sales
    FROM Superstore
    GROUP BY Month, Product_Name
    ORDER BY Month, Total_Sales DESC;
    
    
#16. Impact of discounts on sales and profit by ranges
SELECT CASE 
               WHEN Discount BETWEEN 0 AND 0.1 THEN '0-10%'
               WHEN Discount BETWEEN 0.1 AND 0.2 THEN '10-20%'
               ELSE '>20%'
           END AS Discount_Range,
           AVG(Sales) AS Avg_Sales, 
           AVG(Profit) AS Avg_Profit
    FROM Superstore
    GROUP BY Discount_Range;
    
    
#17. Orders where discounts caused negative profit margins and total loss
SELECT *, (Sales - Profit) AS Total_Loss
    FROM Superstore
    WHERE Discount > 0 AND Profit < 0;
    
    
#18. Revenue from repeat vs new customers
SELECT Customer_Name, 
           SUM(Sales) AS Revenue,
           CASE 
               WHEN COUNT(*) > 1 THEN 'Repeat'
               ELSE 'New'
           END AS Customer_Type
    FROM Superstore
    GROUP BY Customer_Name;
    
    
#19. Seasonal trends in monthly sales and comparison across years
SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month, 
           YEAR(Order_Date) AS Year, 
           AVG(Sales) AS Avg_Monthly_Sales
    FROM Superstore
    GROUP BY Month, Year;
    
    
#20. Lifetime value (LTV) of each customer
SELECT Customer_Name, 
           SUM(Sales) AS Lifetime_Sales, 
           SUM(Profit) AS Lifetime_Profit
    FROM Superstore
    GROUP BY Customer_Name;

