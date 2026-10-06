
Use Final_Project


--- Check Total Rows ---

Select
    COUNT(*) #Rows
From Products_EXP

----- Rows = 180519 -----


--- Check Columns & Data Types ---

Select
    COLUMN_NAME , DATA_TYPE
From INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'Products_EXP'


----- Products has 11 columns -----
----- Product_Card_Id is smallint , Product_Price is float -----
----- Category_Id , Department_Id , Product_Category_Id & Product_Status are tinyint -----
----- The other 5 columns are nvarchar  -----


--- Check Category_Id Column ---

Select
    COUNT(*) NullCategoryId
From Products_EXP
Where Category_Id IS Null

----- Null Category Id = 0 -----

Select DISTINCT
    Category_Id
From Products_EXP
Order by Category_Id

Select
    COUNT(DISTINCT Category_Id) #CategoryIds
From Products_EXP

----- Distinct Category Ids = 51 -----
----- Your old note said 50. The new Products file has 51 (Category_Id 13 is new) -----
----- Category Ids = 2 , 3 , 4 , 5 , 6 , 7 , 9 , 10 , 11 , 12 , 13 , 16 , 17 , 18 , 24 , 26 , 29 , 30 , 31 , 32 -----
----- 33 , 34 , 35 , 36 , 37 , 38 , 40 , 41 , 43 , 44 , 45 , 46 , 48 , 59 , 60 , 61 , 62 , 63 , 64 , 65 -----
----- 66 , 67 , 68 , 69 , 70 , 71 , 72 , 73 , 74 , 75 , 76 -----


--- Check Category_Name Column ---

Select
    COUNT(*) NullCategoryName
From Products_EXP
Where Category_Name IS Null

----- Null Category Name = 0 -----

Select
    COUNT(DISTINCT Category_Name) #CategoryNames
From Products_EXP


Select
  DISTINCT Category_Name
From Products_EXP

----- Distinct Category Names = 51 -----

--- Check Department_Id Column ---

Select
    COUNT(*) NullDepartmentId
From Products_EXP
Where Department_Id IS Null

----- Null Department Id = 0 -----

Select
    DISTINCT Department_Id
From Products_EXP

----- Distinct Department Ids = 11 -----
----- Department Ids = 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 -----


--- Check Department_Name Column ---

Select
    COUNT(*) NullDepartmentName
From Products_EXP
Where Department_Name IS Null

----- Null Department Name = 0 -----

Select
    DISTINCT Department_Name
From Products_EXP

----- Distinct Department Names = 11 -----
----- Department Names = Apparel , Book Shop , Discs Shop , Fan Shop , Fitness , Footwear -----
----- Golf , Health and Beauty , Outdoors , Pet Shop , Technology -----


--- Check Product_Card_Id Column ---

Select
    COUNT(*) NullProductCardId
From Products_EXP
Where Product_Card_Id IS Null

----- Null Product Card Id = 0 -----

Select
    COUNT(DISTINCT Product_Card_Id) #Products
From Products_EXP

Select
     DISTINCT Product_Card_Id
From Products_EXP
Order by Product_Card_Id 

----- Distinct Products = 118 -----


--- Check Product_Category_Id Column ---

Select
    COUNT(*) NullProductCategoryId
From Products_EXP
Where Product_Category_Id IS Null

----- Null Product Category Id = 0 -----

Select
    COUNT(DISTINCT Product_Category_Id) #ProductCategoryIds
From Products_EXP


Select
   DISTINCT Product_Category_Id
From Products_EXP

----- Distinct Product Category Ids = 51 -----
----- Same 51 values as Category_Id -----


--- Check Product_Description Column ---

Select TOP 10
    Product_Description
From Products_EXP

----- All values are Null -----
----- I will delete this column in Python -----


--- Check Product_Image Column ---

Select TOP 10
    Product_Image
From Products_EXP

----- This column has image links -----
----- I will delete this column in Python -----


--- Check Product_Name Column ---

Select
    COUNT(*) NullProductName
From Products_EXP
Where Product_Name IS Null

----- Null Product Name = 0 -----

Select
    COUNT(DISTINCT Product_Name) #ProductNames
From Products_EXP

----- Distinct Product Names = 118 -----


--- Check Product_Price Column ---

Select
    COUNT(*) NullPrice
From Products_EXP
Where Product_Price IS Null

----- Null Price = 0 -----

Select
    ROUND(MIN(Product_Price), 2) MinPrice,
    ROUND(MAX(Product_Price), 2) MaxPrice,
    ROUND(AVG(Product_Price), 2) AvgPrice,
    COUNT(CASE WHEN Product_Price <= 0 THEN 1 END) #ZeroOrNegative
From Products_EXP

----- Min Price = 9.99 , Max Price = 1999.99 , Avg Price = 141.23 , Zero or Negative = 0 -----


--- Check Product_Status Column ---

Select DISTINCT
    Product_Status
From Products_EXP

----- All values are 0 -----
----- I will delete this column in Python -----


---- Is Category_Id = Product_Category_Id? ----

Select
    COUNT(*) #DifferentRows
From Products_EXP
Where Category_Id <> Product_Category_Id

----- Rows where Category_Id <> Product_Category_Id = 0 -----
----- The 2 columns have the same values -----


---- Does each Category_Id have one Category_Name? ----

Select
    Category_Id,
    COUNT(DISTINCT Category_Name) #Names
From Products_EXP
Group by Category_Id
Having COUNT(DISTINCT Category_Name) > 1

----- Category Ids with more than one name = 0  -----


---- Does each Department_Id have one Department_Name? ----

Select
    Department_Id,
    COUNT(DISTINCT Department_Name) #Names
From Products_EXP
Group by Department_Id
Having COUNT(DISTINCT Department_Name) > 1

----- Department Ids with more than one name = 0  -----


---- Does each Product have one Category_Id? ----

Select
    Product_Card_Id,
    COUNT(DISTINCT Category_Id) #CategoryIds
From Products_EXP
Group by Product_Card_Id
Having COUNT(DISTINCT Category_Id) > 1

----- Product_Card_Id  with more than one Category_Id = 0 -----


--- Does each Product have one price? ---

Select
    Product_Card_Id,
    COUNT(DISTINCT Product_Price) #Prices
From Products_EXP
Group by Product_Card_Id
Having COUNT(DISTINCT Product_Price) > 1

----- Product_Card_Id  with more than one Product_Price = 0 -----



-----// Summary & Notes for Python Cleaning //-----

----- 1. Products_EXP has 180519 rows but only 118 Products (repeated rows) -----
----- 2. Delete Product_Description (all Null) , Product_Image (links) , Product_Status (all 0) -----
----- 3. Product_Category_Id is the same as Category_Id : keep one of them -----
----- 4. Each Category_Id has one name and each Department_Id has one name -----
