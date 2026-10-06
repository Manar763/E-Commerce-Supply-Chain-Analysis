Use Final_Project


-----------------------------------                                       -------------------------------------------------
-----------------------------------   Business Analysis : 26 KPI Questions  -------------------------------------------------
-----------------------------------                                       -------------------------------------------------


---- Before the questions : what are the 3 tables ? ----

----- 1. Customers side    : Customers -> Zipcodes -> States            -----
----- 2. Products side     : Products  -> Categories -> Departments     -----
----- 3. Orders side    : Order_Items -> Orders -> Regions / Delivery_Statuses   -----



---- KPIS ----

----- Sales = Price x Quantity (before discount) -----
----- Order_Item_Total (Net Sales) = Sales - Discount -----
----- Order_Profit_Per_Order = the Profit of the ITEM row (it is different for items of the same order , so it is not the profit of the whole order) -----
----- Profit Margin % = Profit / Sales x 100 -----
----- AOV = Sales / number of orders -----


---- 1 : What are the overall financial KPIs (Sales, Net Sales, Discount, Profit, Margin)? ----

----- KPI : Sales = SUM(Sales) | Net Sales = SUM(Order_Item_Total) | Profit Margin % = Profit / Sales * 100 -----

Select
    ROUND(SUM(Sales), 0) #Sales,
    ROUND(SUM(Order_Item_Total), 0) #NetSales,
    ROUND(SUM(Order_Item_Discount), 0) #Discount,
    ROUND(SUM(Order_Item_Discount) * 100.0 / SUM(Sales), 2) #DiscountPct,
    ROUND(SUM(Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Sales), 2) #ProfitMargin,
    ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Order_Item_Total), 2) #NetProfitMargin
From Order_Items

----- Result : -----
----- Sales = 36784734 , NetSales = 33054402 , Discount = 3730378 , DiscountPct = 10.14 , Profit = 3966903 , ProfitMargin = 10.78 , NetProfitMargin = 12 -----


---- 2 : What are the volume KPIs (Orders, Active Customers, Items, Units, AOV, Items per Order, Sales per Customer)? ----

----- KPI : AOV (Average Order Value) = Sales / number of distinct orders | Items per Order = items / orders -----

Select
    COUNT(DISTINCT O.Order_Id) #Orders,
    COUNT(DISTINCT O.Customer_Id) #ActiveCustomers,
    COUNT(OI.Order_Item_Id) #OrderItems,
    SUM(OI.Order_Item_Quantity) #Units,
    ROUND(SUM(OI.Sales) / COUNT(DISTINCT O.Order_Id), 2) #AOV,
    ROUND(COUNT(OI.Order_Item_Id) * 1.0 / COUNT(DISTINCT O.Order_Id), 2) #ItemsPerOrder,
    ROUND(SUM(OI.Sales) / COUNT(DISTINCT O.Customer_Id), 2) #SalesPerCustomer
From Orders O
Join Order_Items OI
    On O.Order_Id = OI.Order_Id

----- Result : -----
----- Orders = 65752 , ActiveCustomers = 20652 , OrderItems = 180519 , Units = 384079 , AOV = 559.45 , ItemsPerOrder = 2.75 , SalesPerCustomer = 1781.17 -----

----- Insight : Each customer bought about 1781 on average and each order has about 2.75 items. -----
----- Insight : All 20652 customers have at least one order (we prove it in Question 14). -----


---- 3 : How do the KPIs change each year (fair comparison with Average Monthly Sales)? ----

----- KPI : Average Monthly Sales = Sales / number of months in that year (so 2018 with 1 month is comparable) -----

Select
    YEAR(O.order_date_DateOrders) #Year,
    COUNT(DISTINCT MONTH(O.order_date_DateOrders)) #Months,
    COUNT(DISTINCT O.Order_Id) #Orders,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Sales) / COUNT(DISTINCT MONTH(O.order_date_DateOrders)), 0) #AvgMonthlySales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin
From Orders O
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Group by YEAR(O.order_date_DateOrders)
Order by #Year

----- Result : -----
----- Year = 2015 , Months = 12 , Orders = 20904 , Sales = 12340831 , AvgMonthlySales = 1028403 , Profit = 1318857 , ProfitMargin = 10.69 -----
----- Year = 2016 , Months = 12 , Orders = 20859 , Sales = 12303817 , AvgMonthlySales = 1025318 , Profit = 1310119 , ProfitMargin = 10.65 -----
----- Year = 2017 , Months = 12 , Orders = 21866 , Sales = 11808436 , AvgMonthlySales = 984036 , Profit = 1304085 , ProfitMargin = 11.04 -----
----- Year = 2018 , Months = 1 , Orders = 2123 , Sales = 331650 , AvgMonthlySales = 331650 , Profit = 33842 , ProfitMargin = 10.2 -----

----- Insight : Sales : 2015 = 12.34M , 2016 = 12.30M , 2017 = 11.81M (about 4% lower than 2016). 2018 has only January. -----
----- Insight : Margin stayed almost the same (10.65% - 11.04%). Orders went UP in 2017 (21866) while Sales went DOWN , so AOV fell. -----
----- Insight : Watch out : never compare 2018 with the other years without looking at #Months. -----


---- 4 : What is the monthly Sales trend and the Month-over-Month growth (MoM %)? ----

----- KPI : MoM Growth % = (This month - Last month) / Last month * 100  (LAG gives us last month) -----

With MonthlySales As
(
    Select
        YEAR(O.order_date_DateOrders) YearNo,
        MONTH(O.order_date_DateOrders) MonthNo,
        SUM(OI.Sales) TotalSales,
        SUM(OI.Order_Profit_Per_Order) TotalProfit
    From Orders O
    Join Order_Items OI
        On O.Order_Id = OI.Order_Id
    Group by YEAR(O.order_date_DateOrders), MONTH(O.order_date_DateOrders)
)
Select
    YearNo #Year,
    MonthNo #Month,
    ROUND(TotalSales, 0) #Sales,
    ROUND(TotalProfit, 0) #Profit,
    ROUND((TotalSales - LAG(TotalSales) Over (Order by YearNo, MonthNo)) * 100.0
        / LAG(TotalSales) Over (Order by YearNo, MonthNo), 2) #MoM_Growth
From MonthlySales
Order by YearNo, MonthNo

----- Result : -----
----- (37 months. Highlights only) -----
----- 2015-02 = 927010 (lowest before Nov 2017) , 2017-09 = 1143775 (highest) -----
----- 2017-10 = 1073994 (-6.10%) , 2017-11 = 626914 (-41.63%) , 2017-12 = 503911 (-19.62%) , 2018-01 = 331650 (-34.18%) -----

---- Follow-up check for Question 4 : why did the Sales fall after Oct 2017 ? ----

Select
    YEAR(O.order_date_DateOrders) #Year,
    MONTH(O.order_date_DateOrders) #Month,
    COUNT(DISTINCT O.Order_Id) #Orders,
    ROUND(COUNT(OI.Order_Item_Id) * 1.0 / COUNT(DISTINCT O.Order_Id), 2) #ItemsPerOrder,
    COUNT(DISTINCT OI.Product_Card_Id) #ProductsSold
From Orders O
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Where O.order_date_DateOrders >= '2017-07-01'
Group by YEAR(O.order_date_DateOrders), MONTH(O.order_date_DateOrders)
Order by #Year, #Month

----- Result : -----
----- Year = 2017 , Month = 7 , Orders = 1776 , ItemsPerOrder = 2.99 , ProductsSold = 42 -----
----- Year = 2017 , Month = 8 , Orders = 1768 , ItemsPerOrder = 3 , ProductsSold = 42 -----
----- Year = 2017 , Month = 9 , Orders = 1723 , ItemsPerOrder = 3.01 , ProductsSold = 53 -----
----- Year = 2017 , Month = 10 , Orders = 2101 , ItemsPerOrder = 1.07 , ProductsSold = 20 -----
----- Year = 2017 , Month = 11 , Orders = 2055 , ItemsPerOrder = 1 , ProductsSold = 8 -----
----- Year = 2017 , Month = 12 , Orders = 2124 , ItemsPerOrder = 1 , ProductsSold = 14 -----
----- Year = 2018 , Month = 1 , Orders = 2123 , ItemsPerOrder = 1 , ProductsSold = 10 -----

----- Insight : From Jan 2015 to Oct 2017 monthly Sales is stable (about 0.93M - 1.14M). Best month = Sep 2017 (1143775). -----
----- Insight : Then it falls : Nov 2017 = 626914 (-41.63%) , Dec 2017 = 503911 (-19.62%) , Jan 2018 = 331650 (-34.18%). -----
----- Insight : Follow-up check below : the number of orders did NOT fall (about 2100 per month) , but from Oct 2017 each order has only 1 item (before it was about 3) and fewer products are sold. -----
----- Insight : So the drop is not a normal business drop. The way the data was recorded changed after Oct 2017. I cannot confirm the reason from the data , but I must write it in the Limitations. -----


---- 5 : How does each Department perform (Sales, Profit, Margin, Units, Average Discount)? ----

----- KPI : Profit Margin % = Profit / Sales * 100 for each department -----

Select
    D.Department_Name,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin,
    SUM(OI.Order_Item_Quantity) #Units,
    ROUND(AVG(OI.Order_Item_Discount_Rate) * 100, 2) #AvgDiscountPct
From Order_Items OI
Join Products P
    On OI.Product_Card_Id = P.Product_Card_Id
Join Categories CA
    On P.Category_Id = CA.Category_Id
Join Departments D
    On CA.Department_Id = D.Department_Id
Group by D.Department_Name
Order by #Sales DESC

----- Result : -----
----- Department_Name = Outdoors , Sales = 17365535 , Profit = 1866698 , ProfitMargin = 10.75 , Units = 106120 , AvgDiscountPct = 10.16 -----
----- Department_Name = Footwear , Sales = 8342424 , Profit = 874741 , ProfitMargin = 10.49 , Units = 101622 , AvgDiscountPct = 10.16 -----
----- Department_Name = Fitness , Sales = 4693023 , Profit = 518494 , ProfitMargin = 11.05 , Units = 75420 , AvgDiscountPct = 10.16 -----
----- Department_Name = Golf , Sales = 3997549 , Profit = 447666 , ProfitMargin = 11.2 , Units = 87466 , AvgDiscountPct = 10.19 -----
----- Department_Name = Technology , Sales = 1138397 , Profit = 122216 , ProfitMargin = 10.74 , Units = 2110 , AvgDiscountPct = 10.08 -----
----- Department_Name = Apparel , Sales = 852622 , Profit = 98029 , ProfitMargin = 11.5 , Units = 7527 , AvgDiscountPct = 10.18 -----
----- Department_Name = Discs Shop , Sales = 228888 , Profit = 24193 , ProfitMargin = 10.57 , Units = 2026 , AvgDiscountPct = 10.18 -----
----- Department_Name = Health and Beauty , Sales = 106080 , Profit = 9494 , ProfitMargin = 8.95 , Units = 362 , AvgDiscountPct = 10.14 -----
----- Department_Name = Pet Shop , Sales = 41525 , Profit = 3589 , ProfitMargin = 8.64 , Units = 492 , AvgDiscountPct = 10.16 -----
----- Department_Name = Book Shop , Sales = 12587 , Profit = 883 , ProfitMargin = 7.02 , Units = 405 , AvgDiscountPct = 10.23 -----
----- Department_Name = Fan Shop , Sales = 6105 , Profit = 901 , ProfitMargin = 14.75 , Units = 529 , AvgDiscountPct = 10.17 -----

----- Insight : Outdoors is the biggest department (17.37M , about 47% of Sales). Outdoors + Footwear + Fitness + Golf are most of the business. -----
----- Insight : Margin range = 7.02% (Book Shop) to 14.75% (Fan Shop). But Fan Shop Sales are only 6105 , so its margin does not matter much. -----
----- Insight : Average discount is about 10.1% - 10.2% in ALL departments , so discount does not explain the margin differences between departments. -----


---- 6 : Which 10 categories generate the highest Profit, and what is their Margin? ----

----- KPI : Profit and Margin by Category -----

Select TOP 10
    CA.Category_Name,
    D.Department_Name,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin
From Order_Items OI
Join Products P
    On OI.Product_Card_Id = P.Product_Card_Id
Join Categories CA
    On P.Category_Id = CA.Category_Id
Join Departments D
    On CA.Department_Id = D.Department_Id
Group by CA.Category_Name, D.Department_Name
Order by #Profit DESC

----- Result : -----
----- Category_Name = Gun Safes , Department_Name = Outdoors , Sales = 6929654 , Profit = 756221 , ProfitMargin = 10.91 -----
----- Category_Name = Strength Training Equipment , Department_Name = Fitness , Sales = 4431943 , Profit = 494637 , ProfitMargin = 11.16 -----
----- Category_Name = Bikes , Department_Name = Outdoors , Sales = 4118425 , Profit = 427456 , ProfitMargin = 10.38 -----
----- Category_Name = Running Shoes & Shorts , Department_Name = Footwear , Sales = 3694843 , Profit = 383011 , ProfitMargin = 10.37 -----
----- Category_Name = Golf Polos , Department_Name = Golf , Sales = 3147800 , Profit = 350421 , ProfitMargin = 11.13 -----
----- Category_Name = Kayaks , Department_Name = Outdoors , Sales = 3113845 , Profit = 325147 , ProfitMargin = 10.44 -----
----- Category_Name = Life Vests , Department_Name = Outdoors , Sales = 2888994 , Profit = 318451 , ProfitMargin = 11.02 -----
----- Category_Name = Football Cleats , Department_Name = Footwear , Sales = 2891758 , Profit = 311903 , ProfitMargin = 10.79 -----
----- Category_Name = Shoes & T-Shirts , Department_Name = Footwear , Sales = 1309522 , Profit = 129814 , ProfitMargin = 9.91 -----
----- Category_Name = Computers , Department_Name = Technology , Sales = 663000 , Profit = 69657 , ProfitMargin = 10.51 -----

----- Insight : Gun Safes (Outdoors) is the best category : Profit 756221 from Sales 6.93M. -----
----- Insight : Strength Training Equipment has a good margin (11.16%). Shoes & T-Shirts has the lowest margin in the top 10 (9.91%). -----


---- 7 : Which 10 products generate the highest Sales, and what share of total Sales does each one have? ----

----- KPI : Sales Share % = product Sales / total Sales * 100 (window function SUM(...) OVER ()) -----

Select TOP 10
    P.Product_Name,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Sales) * 100.0 / SUM(SUM(OI.Sales)) Over (), 2) #SalesShare,
    SUM(OI.Order_Item_Quantity) #Units
From Order_Items OI
Join Products P
    On OI.Product_Card_Id = P.Product_Card_Id
Group by P.Product_Card_Id, P.Product_Name
Order by #Sales DESC

----- Result : -----
----- Product_Name = Field & Stream Sportsman 16 Gun Fire Safe , Sales = 6929654 , SalesShare = 18.84 , Units = 17325 -----
----- Product_Name = Perfect Fitness Perfect Rip Deck , Sales = 4421143 , SalesShare = 12.02 , Units = 73698 -----
----- Product_Name = Diamondback Women's Serene Classic Comfort Bi , Sales = 4118425 , SalesShare = 11.2 , Units = 13729 -----
----- Product_Name = Nike Men's Free 5.0+ Running Shoe , Sales = 3667633 , SalesShare = 9.97 , Units = 36680 -----
----- Product_Name = Nike Men's Dri-FIT Victory Golf Polo , Sales = 3147800 , SalesShare = 8.56 , Units = 62956 -----
----- Product_Name = Pelican Sunstream 100 Kayak , Sales = 3099845 , SalesShare = 8.43 , Units = 15500 -----
----- Product_Name = Nike Men's CJ Elite 2 TD Football Cleat , Sales = 2891758 , SalesShare = 7.86 , Units = 22246 -----
----- Product_Name = O'Brien Men's Neoprene Life Vest , Sales = 2888994 , SalesShare = 7.85 , Units = 57803 -----
----- Product_Name = Under Armour Girls' Toddler Spine Surge Runni , Sales = 1269083 , SalesShare = 3.45 , Units = 31735 -----
----- Product_Name = Dell Laptop , Sales = 663000 , SalesShare = 1.8 , Units = 442 -----

----- Insight : Field & Stream Sportsman 16 Gun Fire Safe = 18.84% of all Sales with only 17325 units. -----
----- Insight : Perfect Rip Deck has the most units (73698) but only 12.02% of Sales (low price , high volume). -----
----- Insight : The top 10 products = about 90% of Sales (sum of the shares). Sales depend on very few products. -----


---- 8 : Which 10 products have the lowest Profit Margin? ----

----- KPI : Profit Margin % by product - lowest first -----

Select TOP 10
    P.Product_Name,
    CA.Category_Name,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin
From Order_Items OI
Join Products P
    On OI.Product_Card_Id = P.Product_Card_Id
Join Categories CA
    On P.Category_Id = CA.Category_Id
Group by P.Product_Card_Id, P.Product_Name, CA.Category_Name
Order by #ProfitMargin

----- Result : -----
----- Product_Name = Bushnell Pro X7 Jolt Slope Rangefinder , Category_Name = Fitness Trackers & GPS Watches , Sales = 6600 , Profit = -256 , ProfitMargin = -3.88 -----
----- Product_Name = SOLE E35 Elliptical , Category_Name = Cycling & Fitness Gear , Sales = 30000 , Profit = -965 , ProfitMargin = -3.22 -----
----- Product_Name = SOLE E25 Elliptical , Category_Name = Bikes & Ellipticals , Sales = 10000 , Profit = -170 , ProfitMargin = -1.7 -----
----- Product_Name = GoPro HERO3+ Black Edition Camera , Category_Name = Cycling & Fitness Gear , Sales = 12800 , Profit = 246 , ProfitMargin = 1.92 -----
----- Product_Name = Garmin Forerunner 910XT GPS Watch , Category_Name = Fitness Trackers & GPS Watches , Sales = 14000 , Profit = 391 , ProfitMargin = 2.79 -----
----- Product_Name = Diamondback Girls' Clarity 24 Hybrid Bike 201 , Category_Name = Bikes & Ellipticals , Sales = 8400 , Profit = 284 , ProfitMargin = 3.39 -----
----- Product_Name = Nike Men's Free TR 5.0 TB Training Shoe , Category_Name = Training Shoes , Sales = 20598 , Profit = 714 , ProfitMargin = 3.47 -----
----- Product_Name = Cleveland Golf Women's 588 RTX CB Satin Chrom , Category_Name = Women's Hybrids & Wedges , Sales = 8399 , Profit = 371 , ProfitMargin = 4.41 -----
----- Product_Name = Men's gala suit , Category_Name = Men's Clothing , Sales = 43857 , Profit = 2006 , ProfitMargin = 4.57 -----
----- Product_Name = GolfBuddy VT3 GPS Watch , Category_Name = Fitness Trackers & GPS Watches , Sales = 11799 , Profit = 569 , ProfitMargin = 4.82 -----

----- Insight : 3 products lose money overall : Bushnell Pro X7 Jolt Slope Rangefinder (-3.88%) , SOLE E35 Elliptical (-3.22%) , SOLE E25 Elliptical (-1.70%). -----
----- Insight : Their losses are small (-256 , -965 , -170) , so they are not the main loss problem. The main loss problem is item-level (see Question 26). -----


---- 9 : Does a bigger discount reduce the Profit Margin? (Discount bands) ----

----- KPI : Profit Margin % for each Discount band -----

Select
    CASE
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) = 0 THEN '0% (no discount)'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 5 THEN '1% - 5%'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 10 THEN '6% - 10%'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 15 THEN '11% - 15%'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 20 THEN '16% - 20%'
        ELSE '21% - 25%'
    END #DiscountBand,
    COUNT(*) #OrderItems,
    ROUND(SUM(Sales), 0) #Sales,
    ROUND(SUM(Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(Order_Profit_Per_Order) * 100.0 / SUM(Sales), 2) #ProfitMargin
From Order_Items
Group by
    CASE
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) = 0 THEN '0% (no discount)'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 5 THEN '1% - 5%'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 10 THEN '6% - 10%'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 15 THEN '11% - 15%'
        WHEN ROUND(Order_Item_Discount_Rate * 100, 0) <= 20 THEN '16% - 20%'
        ELSE '21% - 25%'
    END
Order by MIN(Order_Item_Discount_Rate)

----- Result : -----
----- DiscountBand = 0% (no discount) , OrderItems = 10028 , Sales = 2042369 , Profit = 267412 , ProfitMargin = 13.09 -----
----- DiscountBand = 1% - 5% , OrderItems = 50143 , Sales = 10215746 , Profit = 1171682 , ProfitMargin = 11.47 -----
----- DiscountBand = 6% - 10% , OrderItems = 40116 , Sales = 8173852 , Profit = 926512 , ProfitMargin = 11.34 -----
----- DiscountBand = 11% - 15% , OrderItems = 30087 , Sales = 6131787 , Profit = 625339 , ProfitMargin = 10.2 -----
----- DiscountBand = 16% - 20% , OrderItems = 40116 , Sales = 8176658 , Profit = 784061 , ProfitMargin = 9.59 -----
----- DiscountBand = 21% - 25% , OrderItems = 10029 , Sales = 2044322 , Profit = 191897 , ProfitMargin = 9.39 -----

----- Insight : Margin goes down when the discount goes up : 13.09% with no discount , 9.39% with 21% - 25% discount (about 3.7 points lower). -----
----- Insight : Think : is the extra discount creating enough extra sales to pay for the lower margin ? The data alone cannot answer this. -----


---- 10 : How does each Customer Segment perform (Customers, Orders, Sales, Profit, Margin, AOV)? ----

----- KPI : Customers , Orders , Sales , Profit , Margin , AOV for each Segment -----

Select
    C.Customer_Segment,
    COUNT(DISTINCT C.Customer_Id) #Customers,
    COUNT(DISTINCT O.Order_Id) #Orders,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin,
    ROUND(SUM(OI.Sales) / COUNT(DISTINCT O.Order_Id), 2) #AOV
From Customers C
Join Orders O
    On C.Customer_Id = O.Customer_Id
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Group by C.Customer_Segment
Order by #Sales DESC

----- Result : -----
----- Customer_Segment = Consumer , Customers = 10695 , Orders = 34119 , Sales = 19095790 , Profit = 2073488 , ProfitMargin = 10.86 , AOV = 559.68 -----
----- Customer_Segment = Corporate , Customers = 6239 , Orders = 19856 , Sales = 11168407 , Profit = 1202575 , ProfitMargin = 10.77 , AOV = 562.47 -----
----- Customer_Segment = Home Office , Customers = 3718 , Orders = 11777 , Sales = 6520538 , Profit = 690840 , ProfitMargin = 10.59 , AOV = 553.67 -----

----- Insight : Consumer = 19.10M Sales (about 52% of Sales) , Corporate = 11.17M , Home Office = 6.52M. -----
----- Insight : AOV (553 - 562) and margin (10.59% - 10.86%) are almost the same in all segments. So Consumer is bigger only because it has more customers. -----


---- 11 : How do customers in each Country perform (Customers, Sales, Profit, Sales per Customer)? ----

----- KPI : Sales per Customer = Sales / distinct customers -----

Select
    S.Customer_Country,
    COUNT(DISTINCT C.Customer_Id) #Customers,
    COUNT(DISTINCT O.Order_Id) #Orders,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Sales) / COUNT(DISTINCT C.Customer_Id), 2) #SalesPerCustomer
From Customers C
Join Zipcodes Z
    On C.Customer_Zipcode = Z.Customer_Zipcode
Join States S
    On Z.Customer_State = S.Customer_State
Join Orders O
    On C.Customer_Id = O.Customer_Id
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Group by S.Customer_Country
Order by #Sales DESC

----- Result : -----
----- Customer_Country = EE. UU. , Customers = 12719 , Orders = 40440 , Sales = 22634493 , Profit = 2453526 , SalesPerCustomer = 1779.58 -----
----- Customer_Country = Puerto Rico , Customers = 7933 , Orders = 25312 , Sales = 14150242 , Profit = 1513377 , SalesPerCustomer = 1783.72 -----

----- Insight : EE. UU. has 12719 customers and 22.63M Sales. Puerto Rico has 7933 customers and 14.15M Sales. -----
----- Insight : Sales per customer is almost equal (1779.58 vs 1783.72). -----
----- Insight : Watch out : this is the CUSTOMER address. The Order_Country (where the order is sent) has 164 countries. They are two different things. -----


---- 12 : Which 10 customer States generate the highest Sales? ----

----- KPI : Sales and Profit for each customer State -----

Select TOP 10
    S.Customer_State,
    S.Customer_Country,
    COUNT(DISTINCT C.Customer_Id) #Customers,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit
From Customers C
Join Zipcodes Z
    On C.Customer_Zipcode = Z.Customer_Zipcode
Join States S
    On Z.Customer_State = S.Customer_State
Join Orders O
    On C.Customer_Id = O.Customer_Id
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Group by S.Customer_State, S.Customer_Country
Order by #Sales DESC

----- Result : -----
----- Customer_State = PR , Customer_Country = Puerto Rico , Customers = 7933 , Sales = 14150242 , Profit = 1513377 -----
----- Customer_State = CA , Customer_Country = EE. UU. , Customers = 3321 , Sales = 5929684 , Profit = 640959 -----
----- Customer_State = NY , Customer_Country = EE. UU. , Customers = 1278 , Sales = 2301325 , Profit = 239430 -----
----- Customer_State = TX , Customer_Country = EE. UU. , Customers = 1088 , Sales = 1869746 , Profit = 199453 -----
----- Customer_State = IL , Customer_Country = EE. UU. , Customers = 855 , Sales = 1561645 , Profit = 180049 -----
----- Customer_State = FL , Customer_Country = EE. UU. , Customers = 583 , Sales = 1110758 , Profit = 136257 -----
----- Customer_State = OH , Customer_Country = EE. UU. , Customers = 465 , Sales = 833181 , Profit = 84622 -----
----- Customer_State = MI , Customer_Country = EE. UU. , Customers = 427 , Sales = 782401 , Profit = 81340 -----
----- Customer_State = PA , Customer_Country = EE. UU. , Customers = 426 , Sales = 772199 , Profit = 78245 -----
----- Customer_State = NJ , Customer_Country = EE. UU. , Customers = 381 , Sales = 654153 , Profit = 67470 -----

----- Insight : Puerto Rico (PR) is first with 14.15M , because PR is stored as a State. Then CA (5.93M) , NY (2.30M) , TX (1.87M) , IL (1.56M). -----
----- Insight : California alone is about 5.93M with 3321 customers. -----


---- 13 : Who are the top 10 customers by Net Spend (Customer Lifetime Value)? ----

----- KPI : Customer Lifetime Value (CLV) = total Net Spent of the customer (SUM of Order_Item_Total) -----

Select TOP 10
    C.Customer_Id,
    C.Customer_Full_Name,
    C.Customer_Segment,
    COUNT(DISTINCT O.Order_Id) #Orders,
    ROUND(SUM(OI.Order_Item_Total), 2) #NetSpent,
    ROUND(SUM(OI.Order_Profit_Per_Order), 2) #Profit
From Customers C
Join Orders O
    On C.Customer_Id = O.Customer_Id
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Group by C.Customer_Id, C.Customer_Full_Name, C.Customer_Segment
Order by #NetSpent DESC

----- Result : -----
----- Customer_Id = 791 , Customer_Full_Name = Mary Smith , Customer_Segment = Corporate , Orders = 13 , NetSpent = 9436.61 , Profit = -866.38 -----
----- Customer_Id = 8766 , Customer_Full_Name = Mary Duncan , Customer_Segment = Corporate , Orders = 11 , NetSpent = 8400.98 , Profit = 1495.16 -----
----- Customer_Id = 9371 , Customer_Full_Name = Mary Patterson , Customer_Segment = Consumer , Orders = 11 , NetSpent = 8222.67 , Profit = 1346.58 -----
----- Customer_Id = 2641 , Customer_Full_Name = Betty Spears , Customer_Segment = Consumer , Orders = 11 , NetSpent = 8221.64 , Profit = 2441.97 -----
----- Customer_Id = 4249 , Customer_Full_Name = Mary Butler , Customer_Segment = Consumer , Orders = 13 , NetSpent = 8198.15 , Profit = 439.71 -----
----- Customer_Id = 1657 , Customer_Full_Name = Betty Phillips , Customer_Segment = Consumer , Orders = 11 , NetSpent = 8165.23 , Profit = 2196.92 -----
----- Customer_Id = 3710 , Customer_Full_Name = Ashley Smith , Customer_Segment = Consumer , Orders = 14 , NetSpent = 8112.13 , Profit = 1055.13 -----
----- Customer_Id = 5654 , Customer_Full_Name = Jerry Smith , Customer_Segment = Home Office , Orders = 15 , NetSpent = 7918.75 , Profit = 1045.36 -----
----- Customer_Id = 5715 , Customer_Full_Name = Kelly Smith , Customer_Segment = Corporate , Orders = 12 , NetSpent = 7881.1 , Profit = -177.45 -----
----- Customer_Id = 1288 , Customer_Full_Name = Evelyn Thompson , Customer_Segment = Home Office , Orders = 12 , NetSpent = 7869.02 , Profit = 403.11 -----

----- Insight : The biggest spender is Mary Smith (Id 791) with 9436.61 , but her total Profit is NEGATIVE (-866.38). Kelly Smith (Id 5715) is also negative. -----
----- Insight : Spending a lot is not the same as being profitable. Many customers share the same name , so we always group by Customer_Id. -----


---- 14 : What is the Repeat Customer Rate (customers with more than one order)? ----

----- KPI : Repeat Rate % = customers with more than 1 order / all customers * 100 -----

With CustomerOrders As
(
    Select
        C.Customer_Id,
        COUNT(DISTINCT O.Order_Id) OrdersCount
    From Customers C
    Left Join Orders O
        On C.Customer_Id = O.Customer_Id
    Group by C.Customer_Id
)
Select
    COUNT(*) #Customers,
    COUNT(CASE WHEN OrdersCount = 0 THEN 1 END) #CustomersWithoutOrders,
    COUNT(CASE WHEN OrdersCount > 1 THEN 1 END) #RepeatCustomers,
    ROUND(COUNT(CASE WHEN OrdersCount > 1 THEN 1 END) * 100.0 / COUNT(*), 2) #RepeatRate,
    ROUND(AVG(OrdersCount * 1.0), 2) #AvgOrdersPerCustomer
From CustomerOrders

----- Result : -----
----- Customers = 20652 , CustomersWithoutOrders = 0 , RepeatCustomers = 11768 , RepeatRate = 56.98 , AvgOrdersPerCustomer = 3.18 -----

----- Insight : 56.98% of customers ordered more than once. The average is 3.18 orders per customer. No customer is without orders. -----


---- 15 : How many customers are loss-making (total Profit < 0) in each Segment? ----

----- KPI : Loss Customers % = customers whose total Profit < 0 / all customers * 100 -----

With CustomerProfit As
(
    Select
        C.Customer_Id,
        C.Customer_Segment,
        SUM(OI.Order_Profit_Per_Order) TotalProfit
    From Customers C
    Join Orders O
        On C.Customer_Id = O.Customer_Id
    Join Order_Items OI
        On O.Order_Id = OI.Order_Id
    Group by C.Customer_Id, C.Customer_Segment
)
Select
    Customer_Segment,
    COUNT(*) #Customers,
    COUNT(CASE WHEN TotalProfit < 0 THEN 1 END) #LossCustomers,
    ROUND(COUNT(CASE WHEN TotalProfit < 0 THEN 1 END) * 100.0 / COUNT(*), 2) #LossCustomersPct,
    ROUND(SUM(CASE WHEN TotalProfit < 0 THEN TotalProfit ELSE 0 END), 0) #TotalLossOfThem
From CustomerProfit
Group by Customer_Segment
Order by #LossCustomersPct DESC

----- Result : -----
----- Customer_Segment = Home Office , Customers = 3718 , LossCustomers = 751 , LossCustomersPct = 20.2 , TotalLossOfThem = -199747 -----
----- Customer_Segment = Consumer , Customers = 10695 , LossCustomers = 2101 , LossCustomersPct = 19.64 , TotalLossOfThem = -553335 -----
----- Customer_Segment = Corporate , Customers = 6239 , LossCustomers = 1217 , LossCustomersPct = 19.51 , TotalLossOfThem = -327218 -----

----- Insight : About 19.5% - 20.2% of the customers in every segment are loss-making. Home Office has the highest share (20.20%). -----
----- Insight : The total loss of these customers is about 1.08 million (553335 + 327218 + 199747). -----


---- 16 : What is the share of each Order Status in Orders and in Sales? ----

----- KPI : Orders Share % and Sales Share % for each Order Status -----

With OrderTotals As
(
    Select
        O.Order_Id,
        O.Order_Status,
        SUM(OI.Sales) OrderSales
    From Orders O
    Join Order_Items OI
        On O.Order_Id = OI.Order_Id
    Group by O.Order_Id, O.Order_Status
)
Select
    Order_Status,
    COUNT(*) #Orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) Over (), 2) #OrdersShare,
    ROUND(SUM(OrderSales), 0) #Sales,
    ROUND(SUM(OrderSales) * 100.0 / SUM(SUM(OrderSales)) Over (), 2) #SalesShare
From OrderTotals
Group by Order_Status
Order by #Orders DESC

----- Result : -----
----- Order_Status = COMPLETE , Orders = 21716 , OrdersShare = 33.03 , Sales = 12095315 , SalesShare = 32.88 -----
----- Order_Status = PENDING_PAYMENT , Orders = 14382 , OrdersShare = 21.87 , Sales = 8106697 , SalesShare = 22.04 -----
----- Order_Status = PROCESSING , Orders = 7901 , OrdersShare = 12.02 , Sales = 4504064 , SalesShare = 12.24 -----
----- Order_Status = PENDING , Orders = 7321 , OrdersShare = 11.13 , Sales = 4120533 , SalesShare = 11.2 -----
----- Order_Status = CLOSED , Orders = 7249 , OrdersShare = 11.02 , Sales = 4022624 , SalesShare = 10.94 -----
----- Order_Status = ON_HOLD , Orders = 3624 , OrdersShare = 5.51 , Sales = 1981543 , SalesShare = 5.39 -----
----- Order_Status = SUSPECTED_FRAUD , Orders = 1488 , OrdersShare = 2.26 , Sales = 825935 , SalesShare = 2.25 -----
----- Order_Status = CANCELED , Orders = 1367 , OrdersShare = 2.08 , Sales = 744370 , SalesShare = 2.02 -----
----- Order_Status = PAYMENT_REVIEW , Orders = 704 , OrdersShare = 1.07 , Sales = 383654 , SalesShare = 1.04 -----

----- Insight : Only 33.03% of orders are COMPLETE and 11.02% are CLOSED. PENDING_PAYMENT is 21.87%. -----
----- Insight : Orders share and Sales share are almost equal for every status , so the status does not depend on order size. -----
----- Insight : CANCELED = 2.08% and SUSPECTED_FRAUD = 2.26% of orders. -----


---- 17 : How much Sales is at risk because of CANCELED and SUSPECTED_FRAUD orders? ----

----- KPI : At Risk % = Sales of CANCELED + SUSPECTED_FRAUD orders / total Sales * 100 -----

Select
    ROUND(SUM(OI.Sales), 0) #TotalSales,
    ROUND(SUM(CASE WHEN O.Order_Status IN ('CANCELED', 'SUSPECTED_FRAUD') THEN OI.Sales ELSE 0 END), 0) #AtRiskSales,
    ROUND(SUM(CASE WHEN O.Order_Status IN ('CANCELED', 'SUSPECTED_FRAUD') THEN OI.Sales ELSE 0 END) * 100.0
        / SUM(OI.Sales), 2) #AtRiskPct,
    ROUND(SUM(CASE WHEN O.Order_Status NOT IN ('CANCELED', 'SUSPECTED_FRAUD') THEN OI.Sales ELSE 0 END), 0) #SalesWithoutCancelFraud,
    ROUND(SUM(CASE WHEN O.Order_Status IN ('CANCELED', 'SUSPECTED_FRAUD') THEN OI.Order_Profit_Per_Order ELSE 0 END), 0) #ProfitOnAtRiskOrders
From Orders O
Join Order_Items OI
    On O.Order_Id = OI.Order_Id

----- Result : -----
----- TotalSales = 36784734 , AtRiskSales = 1570305 , AtRiskPct = 4.27 , SalesWithoutCancelFraud = 35214429 , ProfitOnAtRiskOrders = 160482 -----

----- Insight : 1570305 of Sales (4.27%) is in CANCELED or SUSPECTED_FRAUD orders. -----
----- Insight : Watch out : these orders still show a Profit of 160482 in the data. So the total profit (3966903) may be overstated. The business should confirm this. -----


---- 18 : How does each Payment Type perform (Orders, Sales, Margin, AOV, Fraud Rate)? ----

----- KPI : Fraud Rate % = SUSPECTED_FRAUD orders / all orders of that payment type * 100 -----

Select
    O.[Type] #PaymentType,
    COUNT(DISTINCT O.Order_Id) #Orders,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin,
    ROUND(SUM(OI.Sales) / COUNT(DISTINCT O.Order_Id), 2) #AOV,
    ROUND(COUNT(DISTINCT CASE WHEN O.Order_Status = 'SUSPECTED_FRAUD' THEN O.Order_Id END) * 100.0
        / COUNT(DISTINCT O.Order_Id), 2) #FraudRate
From Orders O
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Group by O.[Type]
Order by #Sales DESC

----- Result : -----
----- PaymentType = DEBIT , Orders = 25340 , Sales = 14076857 , ProfitMargin = 10.87 , AOV = 555.52 , FraudRate = 0 -----
----- PaymentType = TRANSFER , Orders = 18077 , Sales = 10194902 , ProfitMargin = 10.7 , AOV = 563.97 , FraudRate = 8.23 -----
----- PaymentType = PAYMENT , Orders = 15086 , Sales = 8490351 , ProfitMargin = 10.45 , AOV = 562.8 , FraudRate = 0 -----
----- PaymentType = CASH , Orders = 7249 , Sales = 4022624 , ProfitMargin = 11.39 , AOV = 554.92 , FraudRate = 0 -----

----- Insight : SUSPECTED_FRAUD exists only in TRANSFER : 8.23% of the TRANSFER orders. DEBIT , PAYMENT and CASH have 0% fraud. -----
----- Insight : DEBIT has the highest Sales (14.08M). CASH has the best margin (11.39%). PAYMENT has the lowest (10.45%). -----


---- 19 : What is the share of each Delivery Status and how many days does it take? ----

----- KPI : Orders Share % for each Delivery Status + average real vs scheduled days -----

Select
    DS.Delivery_Status,
    DS.Late_delivery_risk,
    COUNT(*) #Orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) Over (), 2) #OrdersShare,
    ROUND(AVG(O.Days_for_shipping_real * 1.0), 2) #AvgRealDays,
    ROUND(AVG(O.Days_for_shipment_scheduled * 1.0), 2) #AvgScheduledDays
From Orders O
Join Delivery_Statuses DS
    On O.Delivery_Status = DS.Delivery_Status
Group by DS.Delivery_Status, DS.Late_delivery_risk
Order by #Orders DESC

----- Result : -----
----- Delivery_Status = Late delivery , Late_delivery_risk = 1 , Orders = 36048 , OrdersShare = 54.82 , AvgRealDays = 4.09 , AvgScheduledDays = 2.47 -----
----- Delivery_Status = Advance shipping , Late_delivery_risk = 0 , Orders = 15127 , OrdersShare = 23.01 , AvgRealDays = 2.5 , AvgScheduledDays = 4 -----
----- Delivery_Status = Shipping on time , Late_delivery_risk = 0 , Orders = 11722 , OrdersShare = 17.83 , AvgRealDays = 2.98 , AvgScheduledDays = 2.98 -----
----- Delivery_Status = Shipping canceled , Late_delivery_risk = 0 , Orders = 2855 , OrdersShare = 4.34 , AvgRealDays = 3.49 , AvgScheduledDays = 2.9 -----

----- Insight : Late delivery = 54.82% of orders (36048). Real days = 4.09 but scheduled days = 2.47. -----
----- Insight : Shipping canceled (2855 orders) is exactly CANCELED (1367) + SUSPECTED_FRAUD (1488) orders. -----


---- 20 : How does each Shipping Mode perform (Late Rate, Average Real Days, Average Delay)? ----

----- KPI : Late Rate % = orders with Late_delivery_risk = 1 / all orders * 100 | Delay = real days - scheduled days -----

Select
    O.Shipping_Mode,
    COUNT(*) #Orders,
    ROUND(SUM(CAST(DS.Late_delivery_risk AS int)) * 100.0 / COUNT(*), 2) #LateRate,
    ROUND(AVG(O.Days_for_shipment_scheduled * 1.0), 2) #AvgScheduledDays,
    ROUND(AVG(O.Days_for_shipping_real * 1.0), 2) #AvgRealDays,
    ROUND(AVG((O.Days_for_shipping_real - O.Days_for_shipment_scheduled) * 1.0), 2) #AvgDelayDays
From Orders O
Join Delivery_Statuses DS
    On O.Delivery_Status = DS.Delivery_Status
Group by O.Shipping_Mode
Order by #LateRate DESC

----- Result : -----
----- Shipping_Mode = First Class , Orders = 10079 , LateRate = 95.27 , AvgScheduledDays = 1 , AvgRealDays = 2 , AvgDelayDays = 1 -----
----- Shipping_Mode = Second Class , Orders = 12778 , LateRate = 76.72 , AvgScheduledDays = 2 , AvgRealDays = 4 , AvgDelayDays = 2 -----
----- Shipping_Mode = Same Day , Orders = 3571 , LateRate = 46.15 , AvgScheduledDays = 0 , AvgRealDays = 0.48 , AvgDelayDays = 0.48 -----
----- Shipping_Mode = Standard Class , Orders = 39324 , LateRate = 38.13 , AvgScheduledDays = 4 , AvgRealDays = 4 , AvgDelayDays = 0 -----

----- Insight : First Class : 95.27% late (promised 1 day , real 2 days). Second Class : 76.72% late (promised 2 days , real 4 days). -----
----- Insight : Standard Class : 38.13% late with 4 days promised and 4 days real. Same Day : 46.15% late. -----
----- Insight : So the delay problem is the PROMISE (scheduled days) of First Class and Second Class , not the speed of Standard Class. -----


---- 21 : What is the Late Delivery Rate in each Market? ----

----- KPI : Late Rate % by Market -----

Select
    R.Market,
    COUNT(*) #Orders,
    ROUND(SUM(CAST(DS.Late_delivery_risk AS int)) * 100.0 / COUNT(*), 2) #LateRate,
    ROUND(AVG((O.Days_for_shipping_real - O.Days_for_shipment_scheduled) * 1.0), 2) #AvgDelayDays
From Orders O
Join Regions R
    On O.Order_Region = R.Order_Region
Join Delivery_Statuses DS
    On O.Delivery_Status = DS.Delivery_Status
Group by R.Market
Order by #LateRate DESC

----- Result : -----
----- Market = Pacific Asia , Orders = 17577 , LateRate = 55.3 , AvgDelayDays = 0.58 -----
----- Market = Europe , Orders = 18561 , LateRate = 54.95 , AvgDelayDays = 0.57 -----
----- Market = USCA , Orders = 8579 , LateRate = 54.83 , AvgDelayDays = 0.57 -----
----- Market = LATAM , Orders = 17181 , LateRate = 54.36 , AvgDelayDays = 0.56 -----
----- Market = Africa , Orders = 3854 , LateRate = 54.13 , AvgDelayDays = 0.55 -----

----- Insight : Late Rate is almost the same in all markets (54.13% - 55.30%). So the delay is not a market problem. -----


---- 22 : Which 5 Regions have the highest Late Delivery Rate? ----

----- KPI : Late Rate % by Region (top 5) -----

Select TOP 5
    R.Order_Region,
    R.Market,
    COUNT(*) #Orders,
    ROUND(SUM(CAST(DS.Late_delivery_risk AS int)) * 100.0 / COUNT(*), 2) #LateRate
From Orders O
Join Regions R
    On O.Order_Region = R.Order_Region
Join Delivery_Statuses DS
    On O.Delivery_Status = DS.Delivery_Status
Group by R.Order_Region, R.Market
Order by #LateRate DESC

----- Result : -----
----- Order_Region = Central Africa , Market = Africa , Orders = 556 , LateRate = 57.55 -----
----- Order_Region = East Africa , Market = Africa , Orders = 613 , LateRate = 56.77 -----
----- Order_Region = South of USA , Market = USCA , Orders = 1345 , LateRate = 55.99 -----
----- Order_Region = West Asia , Market = Pacific Asia , Orders = 2022 , LateRate = 55.98 -----
----- Order_Region = Eastern Europe , Market = Europe , Orders = 1292 , LateRate = 55.96 -----

----- Insight : Central Africa is the highest (57.55%) but the difference with the 5th region is small (about 1.6 points). No region is a big problem by itself. -----


---- 23 : Does Delivery Status affect Profit Margin and the number of loss-making items? ----

----- KPI : Profit Margin % and Loss Items % for each Delivery Status -----

Select
    O.Delivery_Status,
    COUNT(*) #OrderItems,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin,
    ROUND(COUNT(CASE WHEN OI.Order_Profit_Per_Order < 0 THEN 1 END) * 100.0 / COUNT(*), 2) #LossItemsPct
From Orders O
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Group by O.Delivery_Status
Order by #Sales DESC

----- Result : -----
----- Delivery_Status = Late delivery , OrderItems = 98977 , Sales = 20126395 , Profit = 2140052 , ProfitMargin = 10.63 , LossItemsPct = 18.74 -----
----- Delivery_Status = Advance shipping , OrderItems = 41592 , Sales = 8518008 , Profit = 935225 , ProfitMargin = 10.98 , LossItemsPct = 18.69 -----
----- Delivery_Status = Shipping on time , OrderItems = 32196 , Sales = 6570026 , Profit = 731144 , ProfitMargin = 11.13 , LossItemsPct = 18.54 -----
----- Delivery_Status = Shipping canceled , OrderItems = 7754 , Sales = 1570305 , Profit = 160482 , ProfitMargin = 10.22 , LossItemsPct = 19.2 -----

----- Insight : Margin is 10.63% for late orders and 11.13% for on-time orders. The difference is only 0.5 point. -----
----- Insight : Loss Items % is about the same in every status (18.5% - 19.2%). Late delivery does not hurt profit in this data. -----


---- 24 : How does each Market perform (Orders, Customers, Sales, Profit, Margin, AOV, Sales Share)? ----

----- KPI : Orders , Customers , Sales , Share , Profit , Margin , AOV for each Market -----

Select
    R.Market,
    COUNT(DISTINCT O.Order_Id) #Orders,
    COUNT(DISTINCT O.Customer_Id) #Customers,
    ROUND(SUM(OI.Sales), 0) #Sales,
    ROUND(SUM(OI.Sales) * 100.0 / SUM(SUM(OI.Sales)) Over (), 2) #SalesShare,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #Profit,
    ROUND(SUM(OI.Order_Profit_Per_Order) * 100.0 / SUM(OI.Sales), 2) #ProfitMargin,
    ROUND(SUM(OI.Sales) / COUNT(DISTINCT O.Order_Id), 2) #AOV
From Orders O
Join Order_Items OI
    On O.Order_Id = OI.Order_Id
Join Regions R
    On O.Order_Region = R.Order_Region
Group by R.Market
Order by #Sales DESC

----- Result : -----
----- Market = Europe , Orders = 18561 , Customers = 11657 , Sales = 10872397 , SalesShare = 29.56 , Profit = 1169443 , ProfitMargin = 10.76 , AOV = 585.77 -----
----- Market = LATAM , Orders = 17181 , Customers = 9325 , Sales = 10277613 , SalesShare = 27.94 , Profit = 1123322 , ProfitMargin = 10.93 , AOV = 598.2 -----
----- Market = Pacific Asia , Orders = 17577 , Customers = 13267 , Sales = 8273744 , SalesShare = 22.49 , Profit = 857753 , ProfitMargin = 10.37 , AOV = 470.71 -----
----- Market = USCA , Orders = 8579 , Customers = 6256 , Sales = 5066529 , SalesShare = 13.77 , Profit = 564314 , ProfitMargin = 11.14 , AOV = 590.57 -----
----- Market = Africa , Orders = 3854 , Customers = 3311 , Sales = 2294453 , SalesShare = 6.24 , Profit = 252071 , ProfitMargin = 10.99 , AOV = 595.34 -----

----- Insight : Europe = 29.56% of Sales (10.87M) , then LATAM (27.94%). Pacific Asia has the most customers (13267) but the lowest AOV (470.71) and the lowest margin (10.37%). -----
----- Insight : USCA has the best margin (11.14%). -----
----- Insight : Watch out : do NOT add the customers of the markets. A customer can order in more than one market (the sum is 43816 but we have only 20652 customers). -----


---- 25 : Which Region is the best (highest Sales) inside each Market? ----

----- KPI : Market Share % = region Sales / Sales of its market * 100 (RANK + PARTITION BY) -----

With RegionSales As
(
    Select
        R.Market,
        R.Order_Region,
        SUM(OI.Sales) TotalSales,
        SUM(OI.Order_Profit_Per_Order) TotalProfit
    From Orders O
    Join Order_Items OI
        On O.Order_Id = OI.Order_Id
    Join Regions R
        On O.Order_Region = R.Order_Region
    Group by R.Market, R.Order_Region
),
RankedRegions As
(
    Select
        Market,
        Order_Region,
        TotalSales,
        TotalProfit,
        RANK() Over (Partition by Market Order by TotalSales DESC) SalesRank,
        TotalSales * 100.0 / SUM(TotalSales) Over (Partition by Market) MarketShare
    From RegionSales
)
Select
    Market,
    Order_Region #TopRegion,
    ROUND(TotalSales, 0) #Sales,
    ROUND(TotalProfit, 0) #Profit,
    ROUND(MarketShare, 2) #ShareOfMarketSales
From RankedRegions
Where SalesRank = 1
Order by #Sales DESC

----- Result : -----
----- Market = Europe , TopRegion = Western Europe , Sales = 5894381 , Profit = 625446 , ShareOfMarketSales = 54.21 -----
----- Market = LATAM , TopRegion = Central America , Sales = 5665712 , Profit = 616342 , ShareOfMarketSales = 55.13 -----
----- Market = Pacific Asia , TopRegion = Oceania , Sales = 2016654 , Profit = 201478 , ShareOfMarketSales = 24.37 -----
----- Market = USCA , TopRegion = West of USA , Sales = 1571416 , Profit = 164941 , ShareOfMarketSales = 31.02 -----
----- Market = Africa , TopRegion = West Africa , Sales = 727951 , Profit = 80030 , ShareOfMarketSales = 31.73 -----

----- Insight : Western Europe = 54.21% of Europe. Central America = 55.13% of LATAM. Oceania = 24.37% of Pacific Asia. West of USA = 31.02% of USCA. West Africa = 31.73% of Africa. -----
----- Insight : Europe and LATAM depend on one region for more than half of their Sales. -----


---- 26 : How big is the loss problem in each Department (loss items, loss amount, loss as % of Sales)? ----

----- KPI : Loss Items % = items with Profit < 0 / all items | Loss % of Sales = total loss / Sales -----

Select
    D.Department_Name,
    COUNT(*) #OrderItems,
    COUNT(CASE WHEN OI.Order_Profit_Per_Order < 0 THEN 1 END) #LossItems,
    ROUND(COUNT(CASE WHEN OI.Order_Profit_Per_Order < 0 THEN 1 END) * 100.0 / COUNT(*), 2) #LossItemsPct,
    ROUND(SUM(CASE WHEN OI.Order_Profit_Per_Order < 0 THEN OI.Order_Profit_Per_Order ELSE 0 END), 0) #TotalLoss,
    ROUND(SUM(CASE WHEN OI.Order_Profit_Per_Order < 0 THEN OI.Order_Profit_Per_Order ELSE 0 END) * 100.0
        / SUM(OI.Sales), 2) #LossPctOfSales,
    ROUND(SUM(OI.Order_Profit_Per_Order), 0) #NetProfit
From Order_Items OI
Join Products P
    On OI.Product_Card_Id = P.Product_Card_Id
Join Categories CA
    On P.Category_Id = CA.Category_Id
Join Departments D
    On CA.Department_Id = D.Department_Id
Group by D.Department_Name
Order by #LossItemsPct DESC

----- Result : -----
----- Department_Name = Health and Beauty , OrderItems = 362 , LossItems = 85 , LossItemsPct = 23.48 , TotalLoss = -11939 , LossPctOfSales = -11.25 , NetProfit = 9494 -----
----- Department_Name = Pet Shop , OrderItems = 492 , LossItems = 104 , LossItemsPct = 21.14 , TotalLoss = -4982 , LossPctOfSales = -12 , NetProfit = 3589 -----
----- Department_Name = Discs Shop , OrderItems = 2026 , LossItems = 399 , LossItemsPct = 19.69 , TotalLoss = -23459 , LossPctOfSales = -10.25 , NetProfit = 24193 -----
----- Department_Name = Book Shop , OrderItems = 405 , LossItems = 78 , LossItemsPct = 19.26 , TotalLoss = -1721 , LossPctOfSales = -13.67 , NetProfit = 883 -----
----- Department_Name = Footwear , OrderItems = 48921 , LossItems = 9231 , LossItemsPct = 18.87 , TotalLoss = -903207 , LossPctOfSales = -10.83 , NetProfit = 874741 -----
----- Department_Name = Apparel , OrderItems = 4016 , LossItems = 755 , LossItemsPct = 18.8 , TotalLoss = -84766 , LossPctOfSales = -9.94 , NetProfit = 98029 -----
----- Department_Name = Outdoors , OrderItems = 66816 , LossItems = 12507 , LossItemsPct = 18.72 , TotalLoss = -1834943 , LossPctOfSales = -10.57 , NetProfit = 1866698 -----
----- Department_Name = Fitness , OrderItems = 25533 , LossItems = 4753 , LossItemsPct = 18.62 , TotalLoss = -484999 , LossPctOfSales = -10.33 , NetProfit = 518494 -----
----- Department_Name = Golf , OrderItems = 29570 , LossItems = 5453 , LossItemsPct = 18.44 , TotalLoss = -409950 , LossPctOfSales = -10.26 , NetProfit = 447666 -----
----- Department_Name = Technology , OrderItems = 1849 , LossItems = 337 , LossItemsPct = 18.23 , TotalLoss = -123075 , LossPctOfSales = -10.81 , NetProfit = 122216 -----
----- Department_Name = Fan Shop , OrderItems = 529 , LossItems = 82 , LossItemsPct = 15.5 , TotalLoss = -507 , LossPctOfSales = -8.31 , NetProfit = 901 -----

----- Insight : About 18.71% of all items lose money (33784 of 180519). The rate is 18% - 19% in the big departments. -----
----- Insight : Outdoors has the biggest total loss (-1834943) but it is also the biggest department. Health and Beauty has the highest rate (23.48%) with only 362 items. -----
----- Insight : Every department still has a positive Net Profit. The loss is spread over the whole business , so it is a price / discount policy issue , not one department. -----

