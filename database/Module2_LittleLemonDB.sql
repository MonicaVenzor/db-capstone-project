-- ===============================
-- Module 1: Database verification
-- ===============================

SHOW DATABASES;

USE littlelemondb;
SHOW TABLES;

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


-- ===============================
-- Module 2: BOOKINGS, TRANSACTIONS
-- ===============================

SHOW DATABASES;

USE littlelemondb;
SHOW TABLES;

-- Mock data inserted for Module 2 testing purposes
TRUNCATE TABLE Bookings;

INSERT INTO Bookings (BookingID, BookingDate, BookingTime, TableNumber, CustomerID, StaffID) VALUES
(1, '2022-10-10', '18:00:00', 5, 1, 1),
(2, '2022-11-12', '19:00:00', 3, 3, 1),
(3, '2022-10-11', '18:30:00', 2, 2, 2),
(4, '2022-10-13', '20:00:00', 2, 1, 2);

SELECT * FROM Bookings;

-- Procedure: CheckBooking
DROP PROCEDURE IF EXISTS CheckBooking;

DELIMITER //

CREATE PROCEDURE CheckBooking(
    IN booking_date DATE,
    IN table_number INT
)
BEGIN
    DECLARE table_status VARCHAR(50);

    SELECT 
        IF(COUNT(*) > 0, 'Table is already booked', 'Table is available')
    INTO table_status
    FROM Bookings
    WHERE BookingDate = booking_date
      AND TableNumber = table_number;

    SELECT table_status AS BookingStatus;
END //

DELIMITER ;

-- Test CheckBooking
CALL CheckBooking('2022-10-10', 5);

-- Procedure: ManageBooking
DROP PROCEDURE IF EXISTS ManageBooking;

DELIMITER //

CREATE PROCEDURE ManageBooking(
    IN booking_date DATE,
    IN table_number INT
)
BEGIN
    DECLARE booking_count INT;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO booking_count
    FROM Bookings
    WHERE BookingDate = booking_date
      AND TableNumber = table_number;

    IF booking_count > 0 THEN
        ROLLBACK;
        SELECT 'Booking declined: table already booked' AS Status;
    ELSE
        INSERT INTO Bookings (BookingDate, BookingTime, TableNumber, CustomerID, StaffID)
        VALUES (booking_date, '21:00:00', table_number, 1, 1);

        COMMIT;
        SELECT 'Booking confirmed' AS Status;
    END IF;
END //

DELIMITER ;


-- Test ManageBooking
CALL ManageBooking('2022-10-10', 5);

-- Procedure: AddBooking
DROP PROCEDURE IF EXISTS AddBooking;

DELIMITER //

CREATE PROCEDURE AddBooking(
    IN booking_id INT,
    IN customer_id INT,
    IN booking_date DATE,
    IN table_number INT
)
BEGIN
    INSERT INTO Bookings (BookingID, BookingDate, BookingTime, TableNumber, CustomerID, StaffID)
    VALUES (booking_id, booking_date, '20:00:00', table_number, customer_id, 1);

    SELECT 'New booking added' AS Status;
END //

DELIMITER ;

-- Test AddBooking
CALL AddBooking(10, 2, '2022-12-01', 4);


-- Procedure: UpdateBooking
DROP PROCEDURE IF EXISTS UpdateBooking;

DELIMITER //

CREATE PROCEDURE UpdateBooking(
    IN booking_id INT,
    IN new_booking_date DATE
)
BEGIN
    UPDATE Bookings
    SET BookingDate = new_booking_date
    WHERE BookingID = booking_id;

    SELECT 'Booking updated' AS Status;
END //

DELIMITER ;

-- Test UpdateBooking
CALL UpdateBooking(10, '2022-12-05');

-- Procedure: CancelBooking
DROP PROCEDURE IF EXISTS CancelBooking;

DELIMITER //

CREATE PROCEDURE CancelBooking(
    IN booking_id INT
)
BEGIN
    DELETE FROM Bookings
    WHERE BookingID = booking_id;

    SELECT 'Booking cancelled' AS Status;
END //

DELIMITER ;

-- Test CancelBooking
CALL CancelBooking(10);
