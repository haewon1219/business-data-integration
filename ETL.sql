-- Table Creation
CREATE TABLE test (
    id INTEGER,
    date DATE,
    store_nbr INTEGER,
    family VARCHAR(50),
    onpromotion INTEGER
);

CREATE TABLE train (
    id INTEGER,
    date DATE,
    store_nbr INTEGER,
    family VARCHAR(50),
    sales FLOAT,
    onpromotion INTEGER
);

CREATE TABLE stores (
    store_nbr INTEGER,
    city VARCHAR(50),
    state VARCHAR(50),
    type VARCHAR(10),
    cluster INTEGER
);

CREATE TABLE transactions (
    date DATE,
    store_nbr INTEGER,
    transactions INTEGER
);

CREATE TABLE oil (
    date DATE,
    dcoilwtico FLOAT
);

CREATE TABLE holidays_events (
    date DATE,
    type VARCHAR(50),
    locale VARCHAR(50),
    locale_name VARCHAR(50),
    description VARCHAR(100),
    transferred BOOLEAN
);

-- Data Import (COPY)
COPY test FROM '/Users/haewon/Documents/test.csv' DELIMITER ',' CSV HEADER;
COPY train FROM '/Users/haewon/Documents/train.csv' DELIMITER ',' CSV HEADER;
COPY stores FROM '/Users/haewon/Documents/stores.csv' DELIMITER ',' CSV HEADER;
COPY transactions FROM '/Users/haewon/Documents/transactions.csv' DELIMITER ',' CSV HEADER;
COPY oil FROM '/Users/haewon/Documents/oil.csv' DELIMITER ',' CSV HEADER;
COPY holidays_events FROM '/Users/haewon/Documents/holidays_events.csv' DELIMITER ',' CSV HEADER;

--Creating a New Table (holiday_dates) and Populating with Data
CREATE TABLE holiday_dates AS -- Create a new table called holiday_dates
SELECT
    dates::date AS date,
    CASE 
        WHEN holidays_events.date IS NOT NULL THEN TRUE 
        WHEN EXTRACT(DOW FROM dates) IN (0, 6) THEN TRUE -- 0 is Sunday, 6 is Saturday
        ELSE FALSE
    END AS is_holiday,
    holidays_events.type,
    holidays_events.locale,
    holidays_events.locale_name,
    holidays_events.description,
    holidays_events.transferred
FROM
    generate_series('2013-01-01'::date, '2017-12-26'::date, '1 day') AS dates
LEFT JOIN
    holidays_events ON dates::date = holidays_events.date
ORDER BY
    dates
	
--Joining Tables for Analysis (Train Data)
SELECT t.*, s.*, h.is_holiday, h.type, h.locale, h.locale_name
FROM train AS t
JOIN stores AS s ON t.store_nbr = s.store_nbr
JOIN holiday_dates AS h ON t.date = h.date

--Joining Tables for Analysis (Test Data)
SELECT t.*, s.*, h.is_holiday, h.type, h.locale, h.locale_name
FROM test AS t
JOIN stores AS s ON t.store_nbr = s.store_nbr
JOIN holiday_dates AS h ON t.date = h.date
