
Use Final_Project


--- Check Total Rows ---

Select
    COUNT(*) #Rows
From Order_Items_EXP

----- Rows = 180519 -----

Select
    COLUMN_NAME , DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Order_Items_EXP'


 ----- Order_Items has 31 columns -----
 -----   Benefit_per_order , Sales_per_customer , Order_Customer_Id , Order_Item_Cardprod_Id , Order_Zipcode -----
 ----- So I brought back the sections of these 5 columns below (each one has a note) -----
----- order_date_DateOrders & shipping_date_DateOrders are nvarchar -----
----- They need to be changed to Date type -----
----- Money columns (Sales , Order_Item_Total , Order_Profit_Per_Order ...) are float -----


--- Check Type Column ---

Select
    COUNT(Type) NullType
From Order_Items_EXP
Where [Type] IS Null

----- Null Type = 0 -----

Select 
      DISTINCT [Type]
From Order_Items_EXP

----- Type Values = CASH , DEBIT , PAYMENT , TRANSFER -----


--- Check Days_for_shipping_real Column ---

Select
    COUNT(*) NullDaysReal
From Order_Items_EXP
Where Days_for_shipping_real IS Null

----- Null Days Real = 0 -----

Select
    MIN(Days_for_shipping_real) MinDays,
    MAX(Days_for_shipping_real) MaxDays,
    AVG(Days_for_shipping_real * 1.0) AvgDays
From Order_Items_EXP

----- Min = 0 , Max = 6 , Avg = 3.49 -----


--- Check Days_for_shipment_scheduled Column ---

Select
    COUNT(*) NullDaysScheduled
From Order_Items_EXP
Where Days_for_shipment_scheduled IS Null

----- Null Days Scheduled = 0 -----

Select 
     DISTINCT Days_for_shipment_scheduled
From Order_Items_EXP
Order by Days_for_shipment_scheduled

----- Scheduled Days Values = 0 , 1 , 2 , 4 -----


--- Check Benefit_per_order Column ---

Select
    COUNT(*) NullBenefit
From Order_Items_EXP
Where Benefit_per_order IS Null

----- Null Benefit = 0 -----

Select
    ROUND(MIN(Benefit_per_order), 2) MinVal,
    ROUND(MAX(Benefit_per_order), 2) MaxVal,
    ROUND(AVG(Benefit_per_order), 2) AvgVal,
    COUNT(CASE WHEN Benefit_per_order < 0 THEN 1 END) #Negative
From Order_Items_EXP

----- Min = -4274.98 , Max = 911.8 , Avg = 21.97 , Negative = 33784 -----

---- Is Benefit_per_order = Order_Profit_Per_Order? ----

Select
    COUNT(*) #DifferentRows
From Order_Items_EXP
Where (Benefit_per_order - Order_Profit_Per_Order) > 0

----- Different Rows = 0 -----

--- Check Sales_per_customer Column ---

Select
    COUNT(*) NullSalesPerCustomer
From Order_Items_EXP
Where Sales_per_customer IS Null

----- Null Sales Per Customer = 0 -----

Select
    ROUND(MIN(Sales_per_customer), 2) MinVal,
    ROUND(MAX(Sales_per_customer), 2) MaxVal,
    ROUND(AVG(Sales_per_customer), 2) AvgVal,
    COUNT(CASE WHEN Sales_per_customer <= 0 THEN 1 END) #ZeroOrNegative
From Order_Items_EXP

----- Min = 7.49 , Max = 1939.99 , Avg = 183.11 , Zero or Negative = 0 -----

---- Is Sales_per_customer = Order_Item_Total? ----

Select
    COUNT(*) #DifferentRows
From Order_Items_EXP
Where ABS(Sales_per_customer - Order_Item_Total) > 0.001

----- Different Rows = 0 -----

--- Check Delivery_Status Column ---

Select
    COUNT(*) NullDeliveryStatus
From Order_Items_EXP
Where Delivery_Status IS Null

----- Null Delivery Status = 0 -----

Select 
     DISTINCT Delivery_Status
From Order_Items_EXP

----- Delivery Status Values = Advance shipping , Late delivery , Shipping canceled , Shipping on time  -----


--- Check Late_delivery_risk Column ---

Select
    COUNT(*) NullLateRisk
From Order_Items_EXP
Where Late_delivery_risk IS Null

----- Null Late Risk = 0 -----

Select 
     DISTINCT Late_delivery_risk
From Order_Items_EXP

----- Late Risk Values = 0 , 1 -----


--- Check Customer_Id Column ---

Select
    COUNT(*) NullCustomerId
From Order_Items_EXP
Where Customer_Id IS Null

----- Null Customer Id = 0 -----

Select
    COUNT(DISTINCT Customer_Id) #Customers
From Order_Items_EXP

----- Total Customers = 20652  -----


--- Check Market Column ---

Select
    COUNT(*) NullMarket
From Order_Items_EXP
Where Market IS Null

----- Null Market = 0 -----

Select
      DISTINCT Market
From Order_Items_EXP

----- Market Values = Africa , Europe , LATAM , Pacific Asia , USCA -----


--- Check Order_City Column ---

Select
    COUNT(Order_City) NullOrderCity
From Order_Items_EXP
Where Order_City IS Null

----- Null Order City = 0 -----

Select
    COUNT(DISTINCT Order_City) #OrderCities
From Order_Items_EXP

----- Distinct Order Cities = 3596 -----


--- Check Order_Country Column ---

Select
    COUNT(*) NullOrderCountry
From Order_Items_EXP
Where Order_Country IS Null

----- Null Order Country = 0 -----

Select
    COUNT(DISTINCT Order_Country) #OrderCountries
From Order_Items_EXP

----- Distinct Order Countries = 164 -----



--- Check Order_Customer_Id Column ---


Select
    COUNT(*) NullOrderCustomerId
From Order_Items_EXP
Where Order_Customer_Id IS Null

----- Null Order Customer Id = 0 -----

Select
    COUNT(DISTINCT Order_Customer_Id) #OrderCustomers
From Order_Items_EXP

----- Distinct Order Customer Ids = 20652 -----

---- Is Order_Customer_Id =  Customer_Id? ----

Select
    COUNT(*) #DifferentRows
From Order_Items_EXP
Where Order_Customer_Id <> Customer_Id

----- Different Rows = 0 -----


--- Check order_date_DateOrders Column ---

 Select Top 50 order_date_DateOrders 
   From Order_Items_EXP

Select
    COUNT(*) NullOrderDate
From Order_Items_EXP
Where order_date_DateOrders IS Null

----- Null Order Date = 0 -----


--- Check Order_Id Column ---

Select
    COUNT(*) NullOrderId
From Order_Items_EXP
Where Order_Id IS Null

----- Null Order Id = 0 -----

Select
    COUNT(DISTINCT Order_Id) #Orders
From Order_Items_EXP

----- Distinct Orders = 65752 -----

----- Checked that each Order ID has only one Customer  ----

Select
    Order_Id,
    COUNT(DISTINCT Customer_Id) #Customers
From Order_Items_EXP
Group by Order_Id
Having COUNT(DISTINCT Customer_Id) > 1

----- Order_Id with more than one Customer = 0 -----


--- Check Order_Item_Cardprod_Id Column ---

Select
    COUNT(*) NullCardprodId
From Order_Items_EXP
Where Order_Item_Cardprod_Id IS Null

----- Null Cardprod Id = 0 -----

Select
    COUNT(DISTINCT Order_Item_Cardprod_Id) #CardprodIds
From Order_Items_EXP

----- Distinct Order_Item_Cardprod_Id = 118 -----

---- Is Order_Item_Cardprod_Id =  Product_Card_Id? ----

Select
    COUNT(*) #DifferentRows
From Order_Items_EXP
Where Order_Item_Cardprod_Id <> Product_Card_Id

----- Different Rows = 0 -----


--- Check Order_Item_Discount Column ---

Select
    COUNT(*) NullDiscount
From Order_Items_EXP
Where Order_Item_Discount IS Null

----- Null Discount = 0 -----

Select
     DISTINCT Order_Item_Discount 
From Order_Items_EXP

Select
    ROUND(MIN(Order_Item_Discount), 2) MinVal,
    ROUND(MAX(Order_Item_Discount), 2) MaxVal,
    ROUND(AVG(Order_Item_Discount), 2) AvgVal,
    COUNT(CASE WHEN Order_Item_Discount < 0 THEN 1 END) #Negative
From Order_Items_EXP

----- Min = 0 , Max = 500 , Avg = 20.66 , Negative = 0 -----


--- Check Order_Item_Discount_Rate Column ---

Select
    COUNT(*) NullDiscountRate
From Order_Items_EXP
Where Order_Item_Discount_Rate IS Null

Select
     DISTINCT Order_Item_Discount_Rate
From Order_Items_EXP

----- Null Discount Rate = 0 -----

Select
    ROUND(MIN(Order_Item_Discount_Rate), 4) MinVal,
    ROUND(MAX(Order_Item_Discount_Rate), 4) MaxVal,
    ROUND(AVG(Order_Item_Discount_Rate), 4) AvgVal
From Order_Items_EXP

----- Min = 0 , Max = 0.25 , Avg = 0.1017 -----
----- All values are between 0 and 1 -----


--- Check Order_Item_Id Column ---

Select
    COUNT(*) NullOrderItemId
From Order_Items_EXP
Where Order_Item_Id IS Null

----- Null Order Item Id = 0 -----

Select
    COUNT(DISTINCT Order_Item_Id) #OrderItems
From Order_Items_EXP

----- Distinct Order Item Ids = 180519 -----
----- It is equal to the total rows , so Order_Item_Id is a Primary Key -----


--- Check Order_Item_Product_Price Column ---

Select
    COUNT(*) NullItemPrice
From Order_Items_EXP
Where Order_Item_Product_Price IS Null


----- Null Item Price = 0 -----

Select
    ROUND(MIN(Order_Item_Product_Price), 2) MinVal,
    ROUND(MAX(Order_Item_Product_Price), 2) MaxVal,
    ROUND(AVG(Order_Item_Product_Price), 2) AvgVal,
    COUNT(CASE WHEN Order_Item_Product_Price <= 0 THEN 1 END) #ZeroOrNegative
From Order_Items_EXP

----- Min = 9.99 , Max = 1999.99 , Avg = 141.23 , Zero or Negative = 0 -----


--- Check Order_Item_Profit_Ratio Column ---

Select
    COUNT(*) NullProfitRatio
From Order_Items_EXP
Where Order_Item_Profit_Ratio IS Null

----- Null Profit Ratio = 0 -----

Select
    ROUND(MIN(Order_Item_Profit_Ratio), 4) MinVal,
    ROUND(MAX(Order_Item_Profit_Ratio), 4) MaxVal,
    ROUND(AVG(Order_Item_Profit_Ratio), 4) AvgVal,
    COUNT(CASE WHEN Order_Item_Profit_Ratio < 0 THEN 1 END) #Negative
From Order_Items_EXP

----- Min = -2.75 , Max = 0.5 , Avg = 0.1206 , Negative = 33784 -----


--- Check Order_Item_Quantity Column ---

Select
    COUNT(*) NullQuantity
From Order_Items_EXP
Where Order_Item_Quantity IS Null

----- Null Quantity = 0 -----

Select 
     DISTINCT Order_Item_Quantity
From Order_Items_EXP
Order by Order_Item_Quantity

----- Quantity Values = 1 , 2 , 3 , 4 , 5 -----


--- Check Sales Column ---

Select
    COUNT(*) NullSales
From Order_Items_EXP
Where Sales IS Null

----- Null Sales = 0 -----

Select
    ROUND(MIN(Sales), 2) MinVal,
    ROUND(MAX(Sales), 2) MaxVal,
    ROUND(AVG(Sales), 2) AvgVal,
    COUNT(CASE WHEN Sales <= 0 THEN 1 END) #ZeroOrNegative
From Order_Items_EXP

----- Min = 9.99 , Max = 1999.99 , Avg = 203.77 , Zero or Negative = 0 -----


--- Check Order_Item_Total Column ---

Select
    COUNT(*) NullItemTotal
From Order_Items_EXP
Where Order_Item_Total IS Null

----- Null Item Total = 0 -----

Select
    ROUND(MIN(Order_Item_Total), 2) MinVal,
    ROUND(MAX(Order_Item_Total), 2) MaxVal,
    ROUND(AVG(Order_Item_Total), 2) AvgVal,
    COUNT(CASE WHEN Order_Item_Total <= 0 THEN 1 END) #ZeroOrNegative
From Order_Items_EXP

----- Min = 7.49 , Max = 1939.99 , Avg = 183.11 , Zero or Negative = 0 -----


--- Check Order_Profit_Per_Order Column ---

Select
    COUNT(*) NullProfitPerOrder
From Order_Items_EXP
Where Order_Profit_Per_Order IS Null

----- Null Profit Per Order = 0 -----

Select
    ROUND(MIN(Order_Profit_Per_Order), 2) MinVal,
    ROUND(MAX(Order_Profit_Per_Order), 2) MaxVal,
    ROUND(AVG(Order_Profit_Per_Order), 2) AvgVal,
    COUNT(CASE WHEN Order_Profit_Per_Order < 0 THEN 1 END) #Negative
From Order_Items_EXP

----- Min = -4274.98 , Max = 911.8 , Avg = 21.97 , Negative = 33784 -----


--- Check Order_Region Column ---

Select
    COUNT(*) NullRegion
From Order_Items_EXP
Where Order_Region IS Null

----- Null Region = 0 -----

Select 
     DISTINCT Order_Region
From Order_Items_EXP
Order by Order_Region

----- Region has 23 values : Canada , Caribbean , Central Africa , Central America , Central Asia -----
----- East Africa , East of USA , Eastern Asia , Eastern Europe , North Africa , Northern Europe -----
----- Oceania , South America , South Asia , South of USA , Southeast Asia , Southern Africa -----
----- Southern Europe , US Center , West Africa , West Asia , West of USA , Western Europe -----


--- Check Order_State Column ---

Select
    COUNT(*) NullOrderState
From Order_Items_EXP
Where Order_State IS Null

----- Null Order State = 0 -----

Select
    COUNT(DISTINCT Order_State) #OrderStates
From Order_Items_EXP

----- Distinct Order States = 1088 -----

--- Check Order_Status Column ---

Select
    COUNT(*) NullOrderStatus
From Order_Items_EXP
Where Order_Status IS Null

----- Null Order Status = 0 -----

Select
     DISTINCT Order_Status
From Order_Items_EXP

----- Order Status has 9 values : CANCELED , CLOSED , COMPLETE , ON_HOLD , PAYMENT_REVIEW -----
----- PENDING , PENDING_PAYMENT , PROCESSING , SUSPECTED_FRAUD -----


--- Check Order_Zipcode Column ---

Select
    COUNT(*) NullZipcode
From Order_Items_EXP
Where Order_Zipcode IS Null

----- Null Zipcode = 155679 -----

Select
    COUNT(DISTINCT Order_Zipcode) #Zipcodes
From Order_Items_EXP

----- Distinct Zipcodes = 609  -----
----- Most of the column is empty. I will delete it in Python -----


--- Check Product_Card_Id Column ---

Select
    COUNT(*) NullProductCardId
From Order_Items_EXP
Where Product_Card_Id IS Null

----- Null Product Card Id = 0 -----

Select
     COUNT(DISTINCT Product_Card_Id) #ProductCardId
From Order_Items_EXP

----- Distinct Product_Card_Id = 118 (same as the Products_EXP table) -----


--- Check shipping_date_DateOrders Column ---

Select
    Top 50 shipping_date_DateOrders
From Order_Items_EXP

Select
    COUNT(*) NullShippingDate
From Order_Items_EXP
Where shipping_date_DateOrders IS Null

----- Null Shipping Date = 0  -----




--- Check Shipping_Mode Column ---

Select
    COUNT(*) NullShippingMode
From Order_Items_EXP
Where Shipping_Mode IS Null

----- Null Shipping Mode = 0 -----

Select 
     DISTINCT Shipping_Mode
From Order_Items_EXP

----- Shipping Mode Values = First Class , Same Day , Second Class , Standard Class (4 values) -----



--- Sales = Product Price x Quantity ? ---

Select
    COUNT(*) #DifferentRows
From Order_Items_EXP
Where (Sales - Order_Item_Product_Price * Order_Item_Quantity) > 0.02

----- Different Rows = 0 -----


--- Order_Item_Total = Sales - Discount ? ---

Select
    COUNT(*) #DifferentRows
From Order_Items_EXP
Where ABS(Order_Item_Total - (Sales - Order_Item_Discount)) > 0.02

----- Different Rows = 0 -----

--- Late_delivery_risk and Delivery_Status ---

Select
    Delivery_Status,
    Late_delivery_risk,
    COUNT(*) #Rows
From Order_Items_EXP
Group by Delivery_Status , Late_delivery_risk
Order by Delivery_Status

--- Shipping_Mode and Days_for_shipment_scheduled ---

Select
    Shipping_Mode,
    Days_for_shipment_scheduled,
    COUNT(*) #Rows
From Order_Items_EXP
Group by Shipping_Mode , Days_for_shipment_scheduled
Order by Shipping_Mode

----- Same Day = 0 , First Class = 1 , Second Class = 2 , Standard Class = 4 -----



--- Does each Order_Id have one date and one status? ---

Select
    Order_Id,
    COUNT(DISTINCT order_date_DateOrders) #Dates,
    COUNT(DISTINCT Order_Status) #Statuses
From Order_Items_EXP
Group by Order_Id
Having COUNT(DISTINCT order_date_DateOrders) > 1 OR COUNT(DISTINCT Order_Status) > 1

----- Order_Id with more than one date or status = 0  -----

--- Losses bigger than what the customer paid ---

Select
    COUNT(*) #BigLossRows
From Order_Items_EXP
Where Order_Profit_Per_Order < - Order_Item_Total

-----  6301 -----

----  Does every Customer_Id in Order_Items exist in Customers_EXP? ----

Select
    COUNT(*) #CustomersNotFound
From Order_Items_EXP O
LEFT JOIN Customers_EXP C
    ON C.Customer_Id = O.Customer_Id
Where C.Customer_Id IS NULL

----- Customers not found = 0 -----


---- Does every Product_Card_Id in Order_Items exist in Products_EXP? ----

Select
    COUNT(*) #ProductsNotFound
From Order_Items_EXP O
LEFT JOIN Products_EXP P
    ON P.Product_Card_Id = O.Product_Card_Id
Where P.Product_Card_Id IS NULL

----- Products not found = 0 -----


----  Is the price in Order_Items the same as the price in Products_EXP? ----

Select
    COUNT(*) #DifferentPrice
From Order_Items_EXP O
Join Products_EXP P
    On O.Product_Card_Id = P.Product_Card_Id
Where (O.Order_Item_Product_Price - P.Product_Price) > 0.01

----- Different Price = 0 -----



-----// Summary & Notes for Python Cleaning //-----

----- 1. Order_Item_Id is the Primary Key (180519 Order Items) -----
----- 2. Orders = 65752 , Customers = 20652 , Products = 118 -----
----- 3. Change order_date_DateOrders & shipping_date_DateOrders to Date type  -----
----- 4. Order_Zipcode : 155679 Null delete it in Python -----
----- 5. 4 repeated columns : delete them in Python (each one was checked , 0 different rows) : -----
-----    Benefit_per_order = Order_Profit_Per_Order , Sales_per_customer = Order_Item_Total -----
-----    Order_Customer_Id = Customer_Id , Order_Item_Cardprod_Id = Product_Card_Id -----
----- 6. All the checks between tables are OK : Customer_Id , Product_Card_Id and the price match Customers_EXP and Products_EXP -----
