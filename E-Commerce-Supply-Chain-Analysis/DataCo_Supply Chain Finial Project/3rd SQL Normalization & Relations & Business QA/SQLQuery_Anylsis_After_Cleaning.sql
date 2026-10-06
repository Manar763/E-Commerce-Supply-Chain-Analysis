Use Final_Project


-----------------------------------   Project Map : understand the 3 tables   -------------------------------------------------

----- How the 3 tables are connected : -----
----- Order_Items_Clean.Customer_Id     -> Customers_Clean.Customer_Id -----
----- Order_Items_Clean.Product_Card_Id -> Products_Clean.Product_Card_Id -----
----- Order_Items_Clean is the fact table , Customers_Clean and Products_Clean are the Dim tables  -----

----- After 3NF  the 3 tables become 10 tables : -----
----- Customers side : States -> Zipcodes -> Customers -----
----- Products side  : Departments -> Categories -> Products -----
----- Orders side    : Regions , Delivery_Statuses -> Orders -> Order_Items -----

-----------------------------------                              -------------------------------------------------
-----------------------------------      Customers_Clean Table   -------------------------------------------------
-----------------------------------                              -------------------------------------------------


---- Check Customers_Clean ----

----- count columns -----

Select
    COUNT(*) #Columns
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Customers_Clean'

----- Customers_Clean Columns = 8 -----


----- count rows -----

Select
    COUNT(*) #Rows
From Customers_Clean

----- Customers_Clean Rows = 20652 -----


----- columns data type -----

Select
    COLUMN_NAME , DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Customers_Clean'

----- Data types : -----
----- Customer_Id = smallint -----
----- Customer_Segment = nvarchar -----
----- Customer_Country = nvarchar -----
----- Customer_City = nvarchar -----
----- Customer_Street = nvarchar -----
----- Customer_State = nvarchar -----
----- Customer_Zipcode = varchar -----
----- Customer_Full_Name = nvarchar -----


---- Check Nulls in Customers_Clean Table ----

/*
Select
    COUNT(*) NullCity
From Customers_Clean
Where Customer_City IS Null

----- Null City = 0 -----

Select
    COUNT(*) NullCountry
From Customers_Clean
Where Customer_Country IS Null

----- Null Country = 0 -----

Select
    COUNT(*) NullCustomerId
From Customers_Clean
Where Customer_Id IS Null

----- Null Customer Id = 0 -----

Select
    COUNT(*) NullSegment
From Customers_Clean
Where Customer_Segment IS Null

----- Null Segment = 0 -----

Select
    COUNT(*) NullState
From Customers_Clean
Where Customer_State IS Null

----- Null State = 0 -----

Select
    COUNT(*) NullStreet
From Customers_Clean
Where Customer_Street IS Null

----- Null Street = 0 -----

Select
    COUNT(*) NullZipcode
From Customers_Clean
Where Customer_Zipcode IS Null

----- Null Zipcode = 0 -----

Select
    COUNT(*) NullFullName
From Customers_Clean
Where Customer_Full_Name IS Null

----- Null Full Name = 0 -----
*/

----- I searched for a way to count the Nulls in the table at once -----
----- count the Nulls in all columns in one query -----

Select
    COUNT(*) - COUNT(Customer_City) NullCity,
    COUNT(*) - COUNT(Customer_Country) NullCountry,
    COUNT(*) - COUNT(Customer_Id) NullCustomerId,
    COUNT(*) - COUNT(Customer_Segment) NullSegment,
    COUNT(*) - COUNT(Customer_State) NullState,
    COUNT(*) - COUNT(Customer_Street) NullStreet,
    COUNT(*) - COUNT(Customer_Zipcode) NullZipcode,
    COUNT(*) - COUNT(Customer_Full_Name) NullFullName
From Customers_Clean

----- Null values in all columns = 0 -----


---- Check Customer_Id ----

Select
    COUNT(*) #Rows,
    COUNT(DISTINCT Customer_Id) #Customers
From Customers_Clean

----- Rows = 20652 -- Distinct Customer_Id = 20652 -----
----- Customer_Id is not repeated , so it can be the Primary Key -----


---- Normalization (3NF) for Customers_Clean Table ----

----- Customers_Clean columns : Customer_Id , Customer_Full_Name , Customer_Segment , Customer_Street -----
----- Customer_Zipcode , Customer_City , Customer_State , Customer_Country -----

---- Check Dependencies for Customers ----

----- If there is no result , the dependency is true -----

----- Question 1 : if I know the Zipcode , do I know the City ? -----

Select
    Customer_Zipcode,
    COUNT(DISTINCT Customer_City) #Cities
From Customers_Clean
Group by Customer_Zipcode
Having COUNT(DISTINCT Customer_City) > 1

----- Customer_Zipcode -> Customer_City : 0 -----


----- Question 2 : if I know the Zipcode , do I know the State ? -----

Select
    Customer_Zipcode,
    COUNT(DISTINCT Customer_State) #States
From Customers_Clean
Group by Customer_Zipcode
Having COUNT(DISTINCT Customer_State) > 1

----- Customer_Zipcode -> Customer_State : 0 -----


----- Question 3 : if I know the State , do I know the Country ? -----

Select
    Customer_State,
    COUNT(DISTINCT Customer_Country) #Countries
From Customers_Clean
Group by Customer_State
Having COUNT(DISTINCT Customer_Country) > 1

----- Customer_State -> Customer_Country : 0 -----


----- What I found : -----
----- Each Zipcode has only one City -----
----- Each Zipcode has only one State -----
----- Each State has only one Country -----

----- So I will split Customers_Clean into 3 tables : -----
----- States (Customer_State , Customer_Country) -----
----- Zipcodes (Customer_Zipcode , Customer_City , Customer_State) -----
----- Customers (Customer_Id , Customer_Full_Name , Customer_Segment , Customer_Street , Customer_Zipcode) -----


---- Create Table States ----

Create Table States
(
    Customer_State nvarchar(10) Primary Key,
    Customer_Country nvarchar(100)
)

Insert Into States
Select DISTINCT
    Customer_State,
    Customer_Country
From Customers_Clean

Select
    COUNT(*) #Rows
From States

----- States Rows = 44 -----


---- Create Table Zipcodes ----

Create Table Zipcodes
(
    Customer_Zipcode varchar(10) Primary Key,
    Customer_City nvarchar(100),
    Customer_State nvarchar(10) Foreign Key References States(Customer_State)
)

Insert Into Zipcodes
Select DISTINCT
    Customer_Zipcode,
    Customer_City,
    Customer_State
From Customers_Clean

Select
    COUNT(*) #Rows
From Zipcodes

----- Zipcodes Rows = 995 -----


---- Create Table Customers ----

Create Table Customers
(
    Customer_Id smallint Primary Key,
    Customer_Full_Name nvarchar(100),
    Customer_Segment nvarchar(50),
    Customer_Street nvarchar(100),
    Customer_Zipcode varchar(10) Foreign Key References Zipcodes(Customer_Zipcode)
)

Insert Into Customers
Select
    Customer_Id,
    Customer_Full_Name,
    Customer_Segment,
    Customer_Street,
    Customer_Zipcode
From Customers_Clean

Select
    COUNT(*) #Rows
From Customers

----- Customers Rows = 20652 -----


---- Check Customers Relations ----

----- join the 3 tables and count the rows -----

Select
    COUNT(*) #Rows
From Customers C
Join Zipcodes Z
    On C.Customer_Zipcode = Z.Customer_Zipcode
Join States S
    On Z.Customer_State = S.Customer_State

----- Rows after joining the 3 tables = 20652 -----



-----------------------------------                              -------------------------------------------------
-----------------------------------      Products_Clean Table    -------------------------------------------------
-----------------------------------                              -------------------------------------------------


---- Check Products_Clean ----

Select
    COUNT(*) #Columns
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Products_Clean'

----- Products_Clean Columns = 7 -----

Select
    COUNT(*) #Rows
From Products_Clean

----- Products_Clean Rows = 118 -----

Select
    COLUMN_NAME , DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Products_Clean'

----- Data types : -----
----- Category_Id = tinyint -----
----- Category_Name = nvarchar -----
----- Department_Id = tinyint -----
----- Department_Name = nvarchar -----
----- Product_Card_Id = smallint -----
----- Product_Name = nvarchar -----
----- Product_Price = float -----


---- Check Nulls in Products_Clean Table ----

Select
    COUNT(*) - COUNT(Category_Id) NullCategoryId,
    COUNT(*) - COUNT(Category_Name) NullCategoryName,
    COUNT(*) - COUNT(Department_Id) NullDepartmentId,
    COUNT(*) - COUNT(Department_Name) NullDepartmentName,
    COUNT(*) - COUNT(Product_Card_Id) NullProductCardId,
    COUNT(*) - COUNT(Product_Name) NullProductName,
    COUNT(*) - COUNT(Product_Price) NullPrice
From Products_Clean

----- Null values in all columns = 0 -----


---- Check Product_Card_Id ----

Select
    COUNT(*) #Rows,
    COUNT(DISTINCT Product_Card_Id) #Products
From Products_Clean

----- Rows = 118 -- Distinct Product_Card_Id = 118 -----
----- Product_Card_Id is not repeated , so it can be the Primary Key -----


---- Normalization (3NF) for Products_Clean Table ----

----- Products_Clean columns : Product_Card_Id , Product_Name , Product_Price -----
----- Category_Id , Category_Name , Department_Id , Department_Name -----

---- Check Dependencies for Products ----

----- If there is no result , the dependency is true -----

----- Question 1 : if I know the Department_Id , do I know the Department_Name ? -----

Select
    Department_Id,
    COUNT(DISTINCT Department_Name) #Names
From Products_Clean
Group by Department_Id
Having COUNT(DISTINCT Department_Name) > 1

----- Department_Id -> Department_Name : 0 -----


----- Question 2 : if I know the Category_Id , do I know the Category_Name ? -----

Select
    Category_Id,
    COUNT(DISTINCT Category_Name) #Names
From Products_Clean
Group by Category_Id
Having COUNT(DISTINCT Category_Name) > 1

----- Category_Id -> Category_Name : 0 -----


----- Question 3 : if I know the Category_Id , do I know the Department_Id ? -----

Select
    Category_Id,
    COUNT(DISTINCT Department_Id) #Departments
From Products_Clean
Group by Category_Id
Having COUNT(DISTINCT Department_Id) > 1

----- Category_Id -> Department_Id : 0 -----


----- Question 4 : if I know the Product_Card_Id , do I know the Category_Id ? -----

Select
    Product_Card_Id,
    COUNT(DISTINCT Category_Id) #Categories
From Products_Clean
Group by Product_Card_Id
Having COUNT(DISTINCT Category_Id) > 1

----- Product_Card_Id -> Category_Id : 0 -----


----- What I found : -----
----- Each Department_Id has only one Department_Name -----
----- Each Category_Id has only one Category_Name and one Department -----
----- Each Product has only one Category -----

----- So I will split Products_Clean into 3 tables : -----
----- Departments (Department_Id , Department_Name) -----
----- Categories (Category_Id , Category_Name , Department_Id) -----
----- Products (Product_Card_Id , Product_Name , Product_Price , Category_Id) -----


---- Create Table Departments ----

Create Table Departments
(
    Department_Id tinyint Primary Key,
    Department_Name nvarchar(100)
)

Insert Into Departments
Select DISTINCT
    Department_Id,
    Department_Name
From Products_Clean

Select
    COUNT(*) #Rows
From Departments

----- Departments Rows = 11 -----


---- Create Table Categories ----

Create Table Categories
(
    Category_Id tinyint Primary Key,
    Category_Name nvarchar(100),
    Department_Id tinyint Foreign Key References Departments(Department_Id)
)

Insert Into Categories
Select DISTINCT
    Category_Id,
    Category_Name,
    Department_Id
From Products_Clean

Select
    COUNT(*) #Rows
From Categories

----- Categories Rows = 51 


---- Create Table Products ----

Create Table Products
(
    Product_Card_Id smallint Primary Key,
    Product_Name nvarchar(100),
    Product_Price Float,
    Category_Id tinyint Foreign Key References Categories(Category_Id)
)

Insert Into Products
Select
    Product_Card_Id,
    Product_Name,
    Product_Price,
    Category_Id
From Products_Clean

Select
    COUNT(*) #Rows
From Products

----- Products Rows = 118 -----


---- Check Products Relations ----

Select
    COUNT(*) #Rows
From Products P
Join Categories C
    On P.Category_Id = C.Category_Id
Join Departments D
    On C.Department_Id = D.Department_Id

----- Rows after joining the 3 tables = 118 -----



-----------------------------------                                 ----------------------------------------------
-----------------------------------   Order_Items_Clean Table       ----------------------------------------------
-----------------------------------                                 ----------------------------------------------




---- Check Order_Items_Clean ----

----- count columns -----

Select
    COUNT(*) #Columns
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Order_Items_Clean'

----- Order_Items_Clean Columns = 26 -----


----- count rows -----

Select
    COUNT(*) #Rows
From Order_Items_Clean

----- Order_Items_Clean Rows = 180519 -----


----- columns data type -----

Select
    COLUMN_NAME , DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Order_Items_Clean'

----- Data types : -----
----- Type = nvarchar -----
----- Days_for_shipping_real = tinyint -----
----- Days_for_shipment_scheduled = tinyint  -----
----- Delivery_Status = nvarchar -----
----- Late_delivery_risk = bit  -----
----- Customer_Id =  smallint -----
----- Market = nvarchar  -----
----- Order_City = nvarchar  -----
----- Order_Country =  nvarchar -----
----- order_date_DateOrders = datetime2  -----
----- Order_Id = int  -----
----- Order_Item_Discount = float  -----
----- Order_Item_Discount_Rate = float  -----
----- Order_Item_Id = int  -----
----- Order_Item_Product_Price = float  -----
----- Order_Item_Profit_Ratio = float -----
----- Order_Item_Quantity = tinyint  -----
----- Sales = float -----
----- Order_Item_Total = float -----
----- Order_Profit_Per_Order =  float -----
----- Order_Region = nvarchar -----
----- Order_State = nvarchar  -----
----- Order_Status = nvarchar -----
----- Product_Card_Id =  smallint -----
----- shipping_date_DateOrders =  datetime2 -----
----- Shipping_Mode =  nvarchar -----


---- Check Nulls in Order_Items_Clean Table ----

----- count the Nulls in all columns in one query -----

Select
    COUNT(*) - COUNT(Type) NullType,
    COUNT(*) - COUNT(Days_for_shipping_real) NullDaysReal,
    COUNT(*) - COUNT(Days_for_shipment_scheduled) NullDaysScheduled,
    COUNT(*) - COUNT(Delivery_Status) NullDeliveryStatus,
    COUNT(*) - COUNT(Late_delivery_risk) NullLateRisk,
    COUNT(*) - COUNT(Customer_Id) NullCustomerId,
    COUNT(*) - COUNT(Market) NullMarket,
    COUNT(*) - COUNT(Order_City) NullOrderCity,
    COUNT(*) - COUNT(Order_Country) NullOrderCountry,
    COUNT(*) - COUNT(order_date_DateOrders) NullOrderDate,
    COUNT(*) - COUNT(Order_Id) NullOrderId,
    COUNT(*) - COUNT(Order_Item_Discount) NullDiscount,
    COUNT(*) - COUNT(Order_Item_Discount_Rate) NullDiscountRate,
    COUNT(*) - COUNT(Order_Item_Id) NullOrderItemId,
    COUNT(*) - COUNT(Order_Item_Product_Price) NullItemPrice,
    COUNT(*) - COUNT(Order_Item_Profit_Ratio) NullProfitRatio,
    COUNT(*) - COUNT(Order_Item_Quantity) NullQuantity,
    COUNT(*) - COUNT(Sales) NullSales,
    COUNT(*) - COUNT(Order_Item_Total) NullItemTotal,
    COUNT(*) - COUNT(Order_Profit_Per_Order) NullProfitPerOrder,
    COUNT(*) - COUNT(Order_Region) NullRegion,
    COUNT(*) - COUNT(Order_State) NullOrderState,
    COUNT(*) - COUNT(Order_Status) NullOrderStatus,
    COUNT(*) - COUNT(Product_Card_Id) NullProductCardId,
    COUNT(*) - COUNT(shipping_date_DateOrders) NullShippingDate,
    COUNT(*) - COUNT(Shipping_Mode) NullShippingMode
From Order_Items_Clean

----- Null values in all columns = 0 -----


---- Check Order_Item_Id ----

----- check Order_Item_Id column is not repeated -----

Select
    COUNT(*) #Rows,
    COUNT(DISTINCT Order_Item_Id) #OrderItems
From Order_Items_Clean

----- Rows = 180519 -- Distinct Order_Item_Id = 180519 -----
----- Order_Item_Id is not repeated , so it can be the Primary Key -----


---- Check Orders ----

----- count the orders -----

Select
    COUNT(DISTINCT Order_Id) #Orders
From Order_Items_Clean

----- Distinct Order_Id = 65752 -----
----- One order can have many items , so Order_Id is repeated in Order_Items_Clean -----


---- Check Customers Without a Match ----

----- find order items whose customer is not in Customers -----

Select
    COUNT(*) #Rows
From Order_Items_Clean O
Left Join Customers C
    On O.Customer_Id = C.Customer_Id
Where C.Customer_Id IS Null

----- Order items without a customer = 0 -----


---- Check Products Without a Match ----

----- find order items whose product is not in Products -----

Select
    COUNT(*) #Rows
From Order_Items_Clean O
Left Join Products P
    On O.Product_Card_Id = P.Product_Card_Id
Where P.Product_Card_Id IS Null

----- Order items without a product = 0 -----


---- Normalization (3NF) for Order_Items_Clean Table ----

----- Order_Items_Clean has 26 columns -----
----- Order columns : Order_Id , Customer_Id , Order_Region , Market , Delivery_Status , Late_delivery_risk -----
----- order_date_DateOrders , shipping_date_DateOrders , Type , Shipping_Mode , Order_Status -----
----- Order_City , Order_State , Order_Country , Days_for_shipping_real , Days_for_shipment_scheduled -----
----- Item columns : Order_Item_Id , Product_Card_Id , Order_Item_Quantity , Order_Item_Product_Price -----
----- Order_Item_Discount , Order_Item_Discount_Rate , Order_Item_Profit_Ratio -----
----- Sales , Order_Item_Total , Order_Profit_Per_Order -----


---- Check Dependencies for Order_Items ----

----- If there is no result , the dependency is true -----

----- Question 1 : if I know the Order_Region , do I know the Market ? -----

Select
    Order_Region,
    COUNT(DISTINCT Market) #Markets
From Order_Items_Clean
Group by Order_Region
Having COUNT(DISTINCT Market) > 1

----- Order_Region -> Market : 0 -----


----- Question 2 : if I know the Delivery_Status , do I know the Late_delivery_risk ? -----

Select
    Delivery_Status,
    COUNT(DISTINCT Late_delivery_risk) #Risks
From Order_Items_Clean
Group by Delivery_Status
Having COUNT(DISTINCT Late_delivery_risk) > 1

----- Delivery_Status -> Late_delivery_risk : 0 -----


----- Question 3 : if I know the Order_Id , do I know the Order_Status ? -----

Select
    Order_Id,
    COUNT(DISTINCT Order_Status) #Statuses
From Order_Items_Clean
Group by Order_Id
Having COUNT(DISTINCT Order_Status) > 1

----- Order_Id -> Order_Status : 0 -----


----- Question 4 : if I know the Order_Id , do I know the order date ? -----

Select
    Order_Id,
    COUNT(DISTINCT order_date_DateOrders) #Dates
From Order_Items_Clean
Group by Order_Id
Having COUNT(DISTINCT order_date_DateOrders) > 1

----- Order_Id -> order_date_DateOrders : 0 -----


----- What I found : -----
----- Each Order_Region has only one Market -----
----- Each Delivery_Status has only one Late_delivery_risk -----
----- Each Order has only one Status and one Date -----

----- So I will split Order_Items_Clean into 4 tables : -----
----- Regions (Order_Region , Market) -----
----- Delivery_Statuses (Delivery_Status , Late_delivery_risk) -----
----- Orders (Order_Id , Customer_Id , Order_Region , Delivery_Status , dates , Type , Shipping_Mode ...) -----
----- Order_Items (Order_Item_Id , Order_Id , Product_Card_Id , Quantity , Price , Discount , Sales ...) -----


---- Create Table Regions ----

----- create a table for the regions and markets -----

Create Table Regions
(
    Order_Region nvarchar(100) Primary Key,
    Market nvarchar(50)
)

Insert Into Regions
Select DISTINCT
    Order_Region,
    Market
From Order_Items_Clean

Select
    COUNT(*) #Rows
From Regions

----- Regions Rows = 23 -----


---- Create Table Delivery_Statuses ----

----- create a table for the delivery status and late risk -----

Create Table Delivery_Statuses
(
    Delivery_Status nvarchar(50) Primary Key,
    Late_delivery_risk bit
)

Insert Into Delivery_Statuses
Select DISTINCT
    Delivery_Status,
    Late_delivery_risk
From Order_Items_Clean

Select
    COUNT(*) #Rows
From Delivery_Statuses

----- Delivery_Statuses Rows = 4 -----


---- Create Table Orders ----

Create Table Orders
(
    Order_Id int Primary Key,
    Customer_Id smallint Foreign Key References Customers(Customer_Id),
    Order_Region nvarchar(100) Foreign Key References Regions(Order_Region),
    Delivery_Status nvarchar(50) Foreign Key References Delivery_Statuses(Delivery_Status),
    order_date_DateOrders datetime2,
    shipping_date_DateOrders datetime2,
    [Type] nvarchar(50),
    Shipping_Mode nvarchar(50),
    Order_Status nvarchar(50),
    Order_City nvarchar(100),
    Order_State nvarchar(100),
    Order_Country nvarchar(100),
    Days_for_shipping_real tinyint,
    Days_for_shipment_scheduled tinyint
)

Insert Into Orders
Select DISTINCT
    Order_Id,
    Customer_Id,
    Order_Region,
    Delivery_Status,
    order_date_DateOrders,
    shipping_date_DateOrders,
    [Type],
    Shipping_Mode,
    Order_Status,
    Order_City,
    Order_State,
    Order_Country,
    Days_for_shipping_real,
    Days_for_shipment_scheduled
From Order_Items_Clean

Select
    COUNT(*) #Rows
From Orders

----- Orders Rows = 65752 -----


---- Create Table Order_Items ----

Create Table Order_Items
(
    Order_Item_Id int Primary Key,
    Order_Id int Foreign Key References Orders(Order_Id),
    Product_Card_Id smallint Foreign Key References Products(Product_Card_Id),
    Order_Item_Quantity tinyint,
    Order_Item_Product_Price decimal(10,2),
    Order_Item_Discount decimal(10,2),
    Order_Item_Discount_Rate float,
    Order_Item_Profit_Ratio float,
    Sales float,
    Order_Item_Total decimal(10,2),
    Order_Profit_Per_Order decimal(10,2)
)

Insert Into Order_Items
Select
    Order_Item_Id,
    Order_Id,
    Product_Card_Id,
    Order_Item_Quantity,
    Order_Item_Product_Price,
    Order_Item_Discount,
    Order_Item_Discount_Rate,
    Order_Item_Profit_Ratio,
    Sales,
    Order_Item_Total,
    Order_Profit_Per_Order
From Order_Items_Clean

Select
    COUNT(*) #Rows
From Order_Items

----- Order_Items Rows = 180519 -----

---- Check All Relations ----

----- join all the tables and count the rows -----

Select
    COUNT(*) #Rows
From Order_Items OI
Join Orders O
    On OI.Order_Id = O.Order_Id
Join Customers C
    On O.Customer_Id = C.Customer_Id
Join Zipcodes Z
    On C.Customer_Zipcode = Z.Customer_Zipcode
Join States S
    On Z.Customer_State = S.Customer_State
Join Products P
    On OI.Product_Card_Id = P.Product_Card_Id
Join Categories CA
    On P.Category_Id = CA.Category_Id
Join Departments D
    On CA.Department_Id = D.Department_Id
Join Regions R
    On O.Order_Region = R.Order_Region
Join Delivery_Statuses DS
    On O.Delivery_Status = DS.Delivery_Status

----- Rows after joining all tables = 180519 -----




-----------------------------------                                  -------------------------------------------------
-----------------------------------             Extra Checks         -------------------------------------------------
-----------------------------------                                  -------------------------------------------------


---- Check Total Sales ----


Select
    ROUND(SUM(Sales), 2) #Sales
From Order_Items

----- Sales in Order_Items =36784735.01 -----

Select
    ROUND(SUM(Sales), 2) #Sales
From Order_Items_Clean

----- Sales in Order_Items_Clean = 36784735.01  -----


---- Check Sales = Price x Quantity ----

Select
    COUNT(*) #DifferentRows
From Order_Items
Where (Sales - Order_Item_Product_Price * Order_Item_Quantity) > 0.02

----- Different rows = 0 -----


---- Check Order_Item_Total = Sales - Discount ----

Select
    COUNT(*) #DifferentRows
From Order_Items
Where (Order_Item_Total - (Sales - Order_Item_Discount)) > 0.02

----- Different rows = 0 -----


---- Check Days_for_shipping_real = days between order date and shipping date ----

Select
    COUNT(Order_Id) #Orders
From Orders
Where Days_for_shipping_real <> DATEDIFF(DAY, order_date_DateOrders, shipping_date_DateOrders)

----- Different rows = 0 -----


---- Check what is Shipping canceled ? ----

Select
    Order_Status,
    Delivery_Status,
    COUNT(Order_Id) #Orders
From Orders
Where Delivery_Status = 'Shipping canceled'
Group by Order_Status, Delivery_Status

----- CANCELED = 1367 , SUSPECTED_FRAUD = 1488 -----


---- Check orders shipped in more days than scheduled , and their Delivery_Status ----

Select
    Delivery_Status,
    COUNT(*) #Orders
From Orders
Where Days_for_shipping_real > Days_for_shipment_scheduled
Group by Delivery_Status

----- Late delivery = 36048 , Shipping canceled = 1650 (total 37698) -----

---- Check discount rate must be between 0 and 1 ----

Select
    MIN(Order_Item_Discount_Rate) #MinRate,
    MAX(Order_Item_Discount_Rate) #MaxRate
From Order_Items

----- Min = 0 , Max = 0.25 -----






