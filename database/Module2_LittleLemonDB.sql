-- ===============================
-- Module 2: Virtual Tables, Joins,
-- Subqueries, Procedures, Prepared Statements
-- ===============================

SHOW DATABASES;

USE littlelemondb;
SHOW TABLES;

-- View
DROP VIEW IF EXISTS OrdersView;
CREATE VIEW OrdersView AS
SELECT 
    o.OrderID,
    oi.Quantity,
    o.TotalCost AS Cost
FROM Orders o
JOIN OrderItems oi
    ON o.OrderID = oi.OrderID
WHERE oi.Quantity > 2;

SELECT * FROM OrdersView;

-- Mock data inserted for Module 2 testing purposes

INSERT INTO CustomerDetails (CustomerID, FirstName, LastName, Phone, Email) VALUES
(1, 'Vanessa', 'McCarthy', '5551234567', 'vanessa@email.com'),
(2, 'Marcos', 'Romero', '5559876543', 'marcos@email.com'),
(3, 'Ana', 'Lopez', '5554567890', 'ana@email.com');

INSERT INTO StaffInformation (StaffID, FirstName, LastName, Role, Salary) VALUES
(1, 'John', 'Smith', 'Manager', 5000.00),
(2, 'Laura', 'Brown', 'Waiter', 2500.00);

SHOW COLUMNS FROM MenuItems;

INSERT INTO MenuItems (MenuItemID, ItemName, Category, Cuisine, Price) VALUES
(1, 'Greek Salad', 'Starter', 'Greek', 50.00),
(2, 'Moussaka', 'Course', 'Greek', 150.00),
(3, 'Kabasa', 'Course', 'Turkish', 100.00),
(4, 'Chocolate Cake', 'Dessert', 'International', 60.00),
(5, 'Lemonade', 'Drink', 'International', 40.00);

INSERT INTO Orders (OrderID, OrderDate, CustomerID, TotalCost) VALUES
(1, '2022-10-10', 1, 250.00),
(2, '2022-11-12', 2, 200.00),
(3, '2022-10-11', 3, 90.00);

INSERT INTO OrderItems (OrderItemID, OrderID, MenuItemID, Quantity, ItemPrice) VALUES
(1, 1, 2, 3, 150.00),
(2, 1, 1, 1, 50.00),
(3, 2, 3, 2, 100.00),
(4, 3, 5, 1, 40.00);

INSERT INTO Bookings (BookingID, BookingDate, BookingTime, TableNumber, CustomerID, StaffID) VALUES
(1, '2022-10-10', '18:00:00', 5, 1, 2),
(2, '2022-11-12', '19:00:00', 3, 3, 2),
(3, '2022-10-11', '18:30:00', 2, 2, 1),
(4, '2022-10-13', '20:00:00', 2, 1, 1);

SELECT * FROM OrdersView;

-- Join query
SELECT c.CustomerID, CONCAT(c.FirstName,' ',c.LastName), o.TotalCost
FROM CustomerDetails c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.TotalCost > 150;

-- Subquery

SELECT ItemName
FROM MenuItems
WHERE MenuItemID = ANY (
    SELECT MenuItemID
    FROM OrderItems
    WHERE Quantity > 2
);

-- Procedure: GetMaxQuantity
DROP PROCEDURE IF EXISTS GetMaxQuantity;

DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity
    FROM OrderItems;
END //

DELIMITER ;

CALL GetMaxQuantity();

-- Prepared Statement
DEALLOCATE PREPARE GetOrderDetail;
PREPARE GetOrderDetail FROM
'SELECT 
     o.OrderID,
     oi.Quantity,
     o.TotalCost AS Cost
 FROM Orders o
 JOIN OrderItems oi
     ON o.OrderID = oi.OrderID
 WHERE o.CustomerID = ?';

SET @id = 1;

EXECUTE GetOrderDetail USING @id;

-- Procedure: CancelOrder
DROP PROCEDURE IF EXISTS CancelOrder;

DELIMITER //

CREATE PROCEDURE CancelOrder(IN order_id INT)
BEGIN
    -- Primero eliminar los items del pedido
    DELETE FROM OrderItems
    WHERE OrderID = order_id;

    -- Luego eliminar el pedido
    DELETE FROM Orders
    WHERE OrderID = order_id;
END //

DELIMITER ;

SELECT * FROM Orders WHERE OrderID = 3;
