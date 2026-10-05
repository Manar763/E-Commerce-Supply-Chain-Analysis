--- Step 1: Create Database 

Create Database Final_Project
 
Use Final_Project

--- Step 2: Import Data ---
--- I imported 3 CSV files with Import Flat File ---
--- Tables: Customers_EXP , Products_EXP , Order_Items_EXP ---
 
Select TOP 10 *
From Customers_EXP
 
Select TOP 10 *
From Products_EXP
 
 
Select TOP 10 *
From Order_Items_EXP
 
 
--- Step 3: Check Total Rows ---
 
---- Check Total Rows ----
 
Select
    COUNT(*) #Rows
From Customers_EXP
 
----- Customers_EXP Rows = 180519 -----
 
Select
    COUNT(*) #Rows
From Products_EXP
 
----- Products Rows = 180519 -----
 
Select
    COUNT(*) #Rows
From Order_Items_EXP
 
----- Order_Items Rows = 180519 -----
----- Customers_EXP and Products_EXP have the same rows as Order_Items ----- 
 
--- Step 4: Check Columns & Data Types ---
 
Select
    COLUMN_NAME , DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Customers_EXP'
 
----- Customers_EXP has 13 columns -----
----- Customer_Id is smallint , Customer_Zipcode , Latitude & Longitude are varchar -----
----- The other 9 columns are nvarchar -----


 
-----// Check Customers_EXP Table //-----
 
 
 
--- Check Customer_Id Column ---
 
Select
    COUNT(*) NullCustomerID
From Customers_EXP
Where Customer_Id IS Null
 
----- Null Customer ID = 0 -----
 
Select
    COUNT(DISTINCT Customer_Id) #Customers
From Customers_EXP
 
----- Distinct Customers = 20652 -----
----- Customer_Id is repeated (20652 Customers in 180519 rows) -----
 
Select TOP 10
    Customer_Id,
    COUNT(*) #Rows
From Customers_EXP
Group by Customer_Id
Order by COUNT(*) DESC
 
----- Max times one Customer is repeated = 47 (Customer_Id 5654) -----
 
 
--- Check Customer_Fname Column ---
 
Select
    COUNT(*) NullFname
From Customers_EXP
Where Customer_Fname IS Null
 
----- Null First Name = 0 -----
 
 
--- Check Customer_Lname Column ---
 
Select
    COUNT(*) NullLname
From Customers_EXP
Where Customer_Lname IS Null
 
----- Null Last Name = 8 -----
 
Select
    *
From Customers_EXP
Where Customer_Lname IS Null
 
----- The 8 rows are for different customers -----
----- First name and Customer_Id are not Null in these rows -----
----- So in Python I will keep it -----
 
 
--- Check Customer_Segment Column ---
 
Select
    COUNT(*) NullSegment
From Customers_EXP
Where Customer_Segment IS Null
 
----- Null Segment = 0 -----
 
Select DISTINCT
    Customer_Segment
From Customers_EXP
 
----- Segment Names = Corporate , Home Office , Consumer (3 values) -----
 
 
--- Check Customer_Country Column ---
 
Select
    COUNT(*) NullCountry
From Customers_EXP
Where Customer_Country IS Null
 
----- Null Country = 0 -----
 
Select DISTINCT
    Customer_Country
From Customers_EXP
Order by Customer_Country
 
----- Country Names = Puerto Rico , EE. UU. (2 values) -----



--- Check Customer_City Column ---
 
Select
    COUNT(*) NullCity
From Customers_EXP
Where Customer_City IS Null
 
----- Null City = 0   -----
 
Select
    COUNT(DISTINCT Customer_City) #Cities
From Customers_EXP
 
----- Distinct Cities = 563   -----
 

--- Check Customer_Street Column ---
 
Select
    COUNT(*) NullStreet
From Customers_EXP
Where Customer_Street IS Null
 
----- Null Street = 0 -----
 
Select
    COUNT(DISTINCT Customer_Street) #Streets
From Customers_EXP
 
----- Distinct Streets = 6930 -----
  

   
--- Check Customer_State Column ---
 
Select
    COUNT(*) NullState
From Customers_EXP
Where Customer_State IS Null
 
----- Null State = 0 -----

 
Select DISTINCT
    Customer_State
From Customers_EXP
 
----- State has 46 values : 44 state codes (AL , AR , AZ , CA ...) and 2 numbers (91732 , 95758) -----
 
---- Check Numbers in Customer State ----
 
Select
    *
From Customers_EXP
Where Customer_State IN ('91732', '95758')
 
----- These 3 rows have a different data shape -----
----- They are the same 3 rows that have Null Zipcode -----
----- (Customer_Id 14577 and 17171 have 95758 , Customer_Id 14046 has 91732) -----
----- In these rows : City has the state (CA) , State has the zipcode , Street has the city (Elk Grove , El Monte) -----
----- I will fix them in Python cleaning -----
 

 
 
--- Check Customer_Zipcode Column ---
 
Select
    COUNT(*) NullZipcode
From Customers_EXP
Where Customer_Zipcode IS Null
 
----- Null Zipcode = 3 -----
 
Select
    *
From Customers_EXP
Where Customer_Zipcode IS Null
 
----- These are the same 3 rows with a number in Customer_State -----


--- Check Latitude Column ---
 
Select
    COUNT(*) NullLatitude
From Customers_EXP
Where Latitude IS Null
 
----- Null Latitude = 194 -----
 
Select
    *
From Customers_EXP
Where Latitude IS Null
 
 
 
--- Check Longitude Column ---
 
Select
    COUNT(*) NullLongitude
From Customers_EXP
Where Longitude IS Null
 
----- Null Longitude = 290  -----

Select
    Longitude , Latitude 
From Customers_EXP
Where  Longitude IS Null OR Latitude IS Null

----- I will delete this column in Python -----


 
--- Check Customer_Email Column ---
 
Select TOP 10
    Customer_Email
From Customers_EXP
 
----- All values are XXXXXXXXX  -----
----- I will delete this column in Python  -----
 
--- Check Customer_Password Column ---
 
Select TOP 10
    Customer_Password
From Customers_EXP
 
----- All values are XXXXXXXXX  -----
----- I will delete this column in Python -----
 

 
 
-----// Summary & Notes for Python Cleaning //-----
 
----- 1. Customers_EXP has 180519 rows but only 20652 Customers (repeated rows) -----
----- 2. Delete Customer_Email & Customer_Password & Latitude & Longitude -----
----- 3. Fix 3 rows : Customer_State has a number and Customer_Zipcode is Null -----
----- 4. Customer_Lname has 8 Null values (different customers) : decide in Python -----
