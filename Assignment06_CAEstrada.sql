--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CAEstrada')
	 Begin 
	  Alter Database [Assignment06DB_CAEetrada] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CAEstrada;
	 End
	Create Database Assignment06DB_CAEstrada;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CAEstrada;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

Go

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create or Alter View vcategories
With SchemaBinding AS
	Select CategoryID, categoryname
	FROM dbo.categories;

GO

Create or Alter View vProducts
With SchemaBinding AS 
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.products;

GO

Create or Alter View vEmployees 
With SchemaBinding AS
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.employees;

GO

Create or Alter View vinventories
With SchemaBinding AS
	Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	From dbo.inventories
;

GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Deny Select On Products to Public;
Deny Select On Employees to Public;
Deny Select on Inventories to Public;

GO

Grant Select on vcategories to Public;
Grant Select on vProducts to Public;
Grant Select on vemployees to public;
Grant select on vinventories to public

;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create or Alter View vProductsByCategories AS
Select Top 1000000
	c.categoryname,
	p.productname,
	p.UnitPrice
FROM vcategories as C
Inner Join vproducts as P
	on c.categoryID = p.categoryID
Order By 1,2,3
;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create or Alter view vInventoriesByProductsByDates AS
Select Top 1000000
	p.productname, i.inventorydate, i.[count]
FROM vProducts as P
INNER JOIN vinventories as I
	on p.productID = i.productID
Order BY 1,2,3
;

GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create or Alter VIEW vInventoriesByEmployeesByDates AS
Select Distinct Top 1000000
	i.inventorydate, 
	e.employeefirstname + ' ' + e.employeelastname as EmployeeName
From vinventories as I
INNER JOIN vemployees as E
	ON i.employeeID = e.employeeID
Order by 1,2
;

GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create or Alter View vInventoriesByProductsByCategories AS
Select Top 1000000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count]
From vinventories as I
INNER JOIN vemployees as E
	ON i.employeeID = e.employeeID
INNER JOIN vProducts as P
	On i.ProductID = p.ProductID
Inner Join vcategories as C
	On p.categoryID = c.categoryID
Order By 1,2,3,4
;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create or Alter View vInventoriesByProductsByEmployees AS
Select Top 1000000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count],
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
From vinventories as I
INNER JOIN vemployees as E
	ON i.employeeID = e.employeeID
INNER JOIN vProducts as P
	On i.ProductID = p.ProductID
Inner Join vcategories as C
	On p.categoryID = c.categoryID
;

GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create or Alter View vInventoriesForChaiAndChangByEmployees AS
	Select Top 1000000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count],
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName


From vInventories as I
INNER JOIN vemployees as E
	ON i.employeeID = e.employeeID
INNER JOIN vProducts as P
	On i.ProductID = p.ProductID
Inner Join vcategories as C
	On p.categoryID = c.categoryID
Where i.productID in (
	Select ProductID from vProducts where ProductName in ('Chai', 'chang'))
Order By 3,1,2,4
;

GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create or Alter View vEmployeesByManager AS
Select Top 1000000
	m.employeefirstname + ' ' + m.employeelastname as Manager,
	e.employeefirstname + ' ' + e.employeelastname as Employee

From vEmployees as E
INNER JOIN vEmployees as M
ON e.managerID = m.employeeID

Order By 1,2
;
GO
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create or Alter View vInventoriesByProductsByCategoriesByEmployees AS
Select Top 1000000
	c.categoryID,
	c.categoryname,
	p.productID,
	p.productname,
	p.unitprice,
	i.inventoryID,
	i.inventorydate,
	i.[count],
	e.employeeID,
	e.EmployeeFirstName + ' ' + e.EmployeeFirstName as EmployeeName,
	m.EmployeeFirstName + ' ' + m.EmployeeLastName as Managername

From vinventories as I
INNER JOIN vproducts as P
	On i.productID = p.productID
Inner Join vcategories as C
	On p.categoryID = c.categoryID
Inner Join vemployees as E
	On i.employeeID = e.employeeID
Left Join v.employees as M
	ON e.managerID = m.employeeID

Order by 2,4,6,10
;

/***************************************************************************************/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/