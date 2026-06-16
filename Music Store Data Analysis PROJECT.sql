-- Create a new database to store all project data
CREATE DATABASE music_store;

-- Select the database to work with it
USE music_store;

-- Verify current database
SHOW DATABASES;
SHOW TABLES;

SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'MUSIC_STORE'; 

-- FIRST TABLE (ARTIST)
-- Create Artist table to store artist details
CREATE TABLE Artist (
    ArtistId INT PRIMARY KEY,     -- Unique ID for each artist
    Name VARCHAR(120)             -- Artist name
);

-- SECOND TABLE (ALBUM)
-- Create Album table to store album details
CREATE TABLE Album (
    AlbumId INT PRIMARY KEY,      -- Unique album ID
    Title VARCHAR(160),           -- Album name
    ArtistId INT,                 -- Reference to artist
    FOREIGN KEY (ArtistId) REFERENCES Artist(ArtistId)
);

-- Create Genre table to classify music
CREATE TABLE Genre (
    GenreId INT PRIMARY KEY,      -- Unique genre ID
    Name VARCHAR(120)             -- Genre name (Rock, Pop, etc.)
);

-- MEDIATYPE
-- Create MediaType table for file formats
CREATE TABLE MediaType (
    MediaTypeId INT PRIMARY KEY,  -- Unique media type ID
    Name VARCHAR(120)             -- Format like MP3, WAV
);

-- TRACK (IMPORTANT TABLE)

-- Create Track table to store song details
CREATE TABLE Track (
    TrackId INT PRIMARY KEY,         -- Unique track ID
    Name VARCHAR(200),               -- Song name
    AlbumId INT,                    -- Links to Album
    MediaTypeId INT,                -- Links to MediaType
    GenreId INT,                    -- Links to Genre
    Composer VARCHAR(220),          -- Composer name
    Milliseconds INT,               -- Duration
    Bytes INT,                      -- File size
    UnitPrice DECIMAL(10,2),        -- Price of track
    FOREIGN KEY (AlbumId) REFERENCES Album(AlbumId),
    FOREIGN KEY (MediaTypeId) REFERENCES MediaType(MediaTypeId),
    FOREIGN KEY (GenreId) REFERENCES Genre(GenreId)
);

-- EMPLOYEE TABLE
-- Create Employee table
CREATE TABLE Employee (
    EmployeeId INT PRIMARY KEY,
    LastName VARCHAR(20),
    FirstName VARCHAR(20),
    Title VARCHAR(30),
    ReportsTo INT,
    Email VARCHAR(60),
    FOREIGN KEY (ReportsTo) REFERENCES Employee(EmployeeId)
);

-- CUSTOMER TABLE
-- Create Customer table
CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY,
    FirstName VARCHAR(40),
    LastName VARCHAR(20),
    Country VARCHAR(40),
    Email VARCHAR(60),
    SupportRepId INT,
    FOREIGN KEY (SupportRepId) REFERENCES Employee(EmployeeId)
);

-- INVOICE TABLE
-- Create Invoice table to store transactions
CREATE TABLE Invoice (
    InvoiceId INT PRIMARY KEY,
    CustomerId INT,
    InvoiceDate DATETIME,
    BillingCity VARCHAR(40),
    Total DECIMAL(10,2),
    FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
);
 
 -- INVOICELINE TABLE
 -- Create InvoiceLine table for purchased items
CREATE TABLE InvoiceLine (
    InvoiceLineId INT PRIMARY KEY,
    InvoiceId INT,
    TrackId INT,
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    FOREIGN KEY (InvoiceId) REFERENCES Invoice(InvoiceId),
    FOREIGN KEY (TrackId) REFERENCES Track(TrackId)
);

-- PLAYLIST + PLAYLISTTRACK
-- Playlist table
CREATE TABLE Playlist (
    PlaylistId INT PRIMARY KEY,
    Name VARCHAR(120)
);

-- Create Playlist (PARENT FIRST)
CREATE TABLE Playlist (
    PlaylistId INT PRIMARY KEY,   -- Unique playlist ID
    Name VARCHAR(120)             -- Playlist name
);

-- Create PlaylistTrack (CHILD)
-- Create PlaylistTrack table (many-to-many relation)

CREATE TABLE PlaylistTrack (
    PlaylistId INT,
    TrackId INT,
    PRIMARY KEY (PlaylistId, TrackId),
    FOREIGN KEY (PlaylistId) REFERENCES Playlist(PlaylistId),
    FOREIGN KEY (TrackId) REFERENCES Track(TrackId)
);


-- Many-to-many relation
CREATE TABLE PlaylistTrack (
    PlaylistId INT,
    TrackId INT,
    PRIMARY KEY (PlaylistId, TrackId),
    FOREIGN KEY (PlaylistId) REFERENCES Playlist(PlaylistId),
    FOREIGN KEY (TrackId) REFERENCES Track(TrackId)
);

 -- DATA IMPORTING STEPS --
 
-- “LOAD DATA LOCAL INFILE specifies file path.
-- INTO TABLE defines destination.
-- FIELDS TERMINATED BY separates columns.
-- ENCLOSED BY handles text values.
-- LINES TERMINATED BY separates rows.
-- IGNORE 1 ROWS skips header.” 



-- COUNT NUMBER OF TABLES
SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'music_store';

-- Display all artist data
SELECT * FROM Artist;

-- Display all album data
SELECT * FROM Album;

-- Display all genre data
SELECT * FROM Genre;

-- Display media types
SELECT * FROM MediaType;

-- Display track data
SELECT * FROM Track;

-- Display employee data
SELECT * FROM Employee;

-- Display customer data
SELECT * FROM Customer;

-- Display invoice data
SELECT * FROM Invoice;

-- Display invoice line data
SELECT * FROM InvoiceLine;

-- Display playlist data
SELECT * FROM Playlist;

-- Display playlist-track mapping
SELECT * FROM PlaylistTrack;

-- TASKS --

-- Now performing business analysis queries:

-- 1. Who is the senior most employee based on job title? 
SELECT FirstName, LastName, Title
FROM Employee
ORDER BY Title DESC
LIMIT 1;

-- 2. Which countries have the most Invoices?
SELECT c.Country, COUNT(*) AS total_invoices
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
GROUP BY c.Country
ORDER BY total_invoices DESC;

-- 3. What are the top 3 values of total invoice?
SELECT Total
FROM Invoice
ORDER BY Total DESC
LIMIT 3;

-- 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
SELECT BillingCity, SUM(Total) AS revenue
FROM Invoice
GROUP BY BillingCity
ORDER BY revenue DESC
LIMIT 1;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
SELECT c.FirstName, c.LastName, SUM(i.Total) AS total_spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY total_spent DESC
LIMIT 1;

-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
SELECT DISTINCT 
    c.Email, 
    c.FirstName, 
    c.LastName, 
    g.Name AS Genre
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE LOWER(TRIM(g.Name)) LIKE '%rock%'
ORDER BY c.Email;

-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands 
SELECT ar.Name, COUNT(t.TrackId) AS track_count
FROM Artist ar
JOIN Album al ON ar.ArtistId = al.ArtistId
JOIN Track t ON al.AlbumId = t.AlbumId
JOIN Genre g ON t.GenreId = g.GenreId
WHERE g.Name LIKE '%Rock%'
GROUP BY ar.ArtistId, ar.Name
ORDER BY track_count DESC
LIMIT 10;


-- 8. Return all the track names that have a song length longer than the average song length.- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first
SELECT Name, Milliseconds
FROM Track
WHERE Milliseconds > (
    SELECT AVG(Milliseconds) FROM Track
)
ORDER BY Milliseconds DESC;


-- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 
SELECT 
    c.FirstName,
    c.LastName,
    ar.Name AS ArtistName,
    SUM(il.UnitPrice * il.Quantity) AS total_spent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY c.CustomerId, ar.Name
ORDER BY total_spent DESC;


-- 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres
SELECT country, genre, purchases
FROM (
    SELECT 
        c.Country AS country,
        g.Name AS genre,
        COUNT(*) AS purchases,
        RANK() OVER (
            PARTITION BY c.Country 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY c.Country, g.Name
) ranked
WHERE rnk = 1;

-- 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
SELECT country, customer_name, total_spent
FROM (
    SELECT 
        c.Country AS country,
        CONCAT(c.FirstName, ' ', c.LastName) AS customer_name,
        SUM(i.Total) AS total_spent,
        RANK() OVER (
            PARTITION BY c.Country
            ORDER BY SUM(i.Total) DESC
        ) AS rnk
    FROM Customer c
    JOIN Invoice i ON c.CustomerId = i.CustomerId
    GROUP BY c.Country, c.CustomerId
) ranked
WHERE rnk = 1;