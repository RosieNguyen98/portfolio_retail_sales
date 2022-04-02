-- CHOOSE DATA FOR ANALYSE
CREATE VIEW sales_history AS
SELECT s.CustomerKey, s.SalesOrderNumber, p.ProductName,
       ps.ProductSubcategoryName, ps.ProductCategory,  s.SalesOrderLineNumber,
       s.OrderQuantity, s.UnitPrice, s.TotalProductCost, s.TaxAmount,
       s.SalesAmount, s.OrderDate, st.SalesTerritoryRegion,
       st.SalesTerritoryCountry, st.SalesTerritoryGroup, c.FirstPurchaseYear,
       if(FirstPurchaseYear < YEAR(OrderDate), 'Existing Customer', 'New Customer') AS Status
FROM f_sales s
JOIN d_sales_territory st
     USING (SalesTerritoryKey)
JOIN d_product p
     USING (ProductKey)  
JOIN d_product_subcategory ps
     ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN d_customer c
     USING (CustomerKey)
WHERE YEAR(OrderDate) BETWEEN 2011 AND 2014
ORDER BY YEAR(OrderDate), st.SalesTerritoryGroup, st.SalesTerritoryCountry;


-- Revenue by Territory
SELECT YEAR(OrderDate) AS Year, SalesTerritoryGroup, SalesTerritoryCountry, SalesTerritoryRegion,
       sum(SalesAmount) AS Revenue
FROM sales_history
GROUP BY YEAR(OrderDate), SalesTerritoryGroup, SalesTerritoryCountry, SalesTerritoryRegion
ORDER BY YEAR(OrderDate), SalesTerritoryGroup;

-- Revenue by Product
SELECT  YEAR(OrderDate) AS Year, ProductCategory, ProductSubcategoryName, ProductName,
		sum(SalesAmount) AS Revenue
FROM sales_history
GROUP BY YEAR(OrderDate), ProductCategory, ProductSubcategoryName, ProductName
ORDER BY YEAR(OrderDate), ProductCategory, ProductSubcategoryName, ProductName;

-- Revenue from New vs Existing customer
SELECT YEAR(Orderdate), status, sum(SalesAmount) as Revenue
FROM sales_history
GROUP BY YEAR(Orderdate), status
ORDER BY YEAR(Orderdate), status;


-- Average profit margin
SELECT YEAR(Orderdate) AS Year,
       sum(SalesAmount) AS TotalRevenue,
       sum(TotalProductCost) AS TotalCost,
       round((sum(SalesAmount) - sum(TotalProductCost))/ sum(SalesAmount), 2) AS ProfitMargin
FROM sales_history
GROUP BY YEAR(Orderdate)
ORDER BY YEAR(Orderdate);


-- Average Transaction Size
WITH AverageTransactionSize AS (
SELECT OrderDate,
       Year(Orderdate) AS Year, Month(Orderdate) AS Month,
       sum(SalesAmount) AS TotalOrderValue,
       count(distinct SalesOrderNumber) AS TotalOrder
FROM sales_history
GROUP BY SalesOrderNumber
ORDER BY Orderdate)

SELECT *, round(TotalOrderValue/TotalOrder, 0) AS AverageTransactionSize
FROM AverageTransactionSize;


