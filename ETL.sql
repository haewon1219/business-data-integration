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


-- Insert Holiday Events for Saturdays, Sundays, Christmas, and New Year
INSERT INTO holidays_events (date, type, locale, locale_name, description, transferred)
SELECT 
    generate_series::date AS date, -- Selecting the generated date
    'Holiday' AS type, -- Setting type as 'Holiday' for all entries
    t.locale,
    t.locale_name,
    CASE 
        WHEN EXTRACT(ISODOW FROM generate_series) = 6 THEN 'Saturday'
        WHEN EXTRACT(ISODOW FROM generate_series) = 7 THEN 'Sunday'
        WHEN EXTRACT(MONTH FROM generate_series) = 12 AND EXTRACT(DAY FROM generate_series) = 24 THEN 'Christmas Eve'
        WHEN EXTRACT(MONTH FROM generate_series) = 12 AND EXTRACT(DAY FROM generate_series) = 25 THEN 'Christmas Day'
        WHEN EXTRACT(MONTH FROM generate_series) = 1 AND EXTRACT(DAY FROM generate_series) = 1 THEN 'New Year'
    END AS description, -- Assigning appropriate descriptions
    false AS transferred -- Marking transferred as false for all entries
FROM 
    generate_series('2012-01-01'::date, '2017-12-31'::date, '1 day'::interval) AS generate_series -- Generating series of dates from 2012-01-01 to 2017-12-31 with interval of 1 day
CROSS JOIN 
    (SELECT DISTINCT locale, locale_name FROM holidays_events) AS t -- Cross joining with distinct locale and locale_name from holidays_events table
WHERE 
    EXTRACT(ISODOW FROM generate_series) IN (6, 7)
    OR (EXTRACT(MONTH FROM generate_series) = 12 AND EXTRACT(DAY FROM generate_series) = 24)
    OR (EXTRACT(MONTH FROM generate_series) = 12 AND EXTRACT(DAY FROM generate_series) = 25)
    OR (EXTRACT(MONTH FROM generate_series) = 1 AND EXTRACT(DAY FROM generate_series) = 1)
ORDER BY 
    date;


-- Joining Tables (train data)
SELECT t.ID, t.date, t.store_nbr, t.family, t.onpromotion,
       s.city, s.state, s.type, s.cluster,
       h.type AS holiday_type, h.locale, h.locale_name, h.description, h.transferred
FROM train AS t
LEFT JOIN stores AS s ON t.store_nbr = s.store_nbr
LEFT JOIN holidays_events AS h ON t.date = h.date AND s.city = h.locale_name;
