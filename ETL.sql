CREATE TABLE test (
    id INTEGER PRIMARY KEY,
    date DATE,
    store_nbr INTEGER,
    family VARCHAR(50),
    onpromotion INTEGER
);

CREATE TABLE train (
    id INTEGER PRIMARY KEY,
    date DATE,
    store_nbr INTEGER,
    family VARCHAR(50),
    sales FLOAT,
    onpromotion INTEGER
);

CREATE TABLE stores (
    store_nbr INTEGER PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50),
    type VARCHAR(10),
    cluster INTEGER
);

CREATE TABLE transactions (
    date DATE PRIMARY KEY,
    store_nbr INTEGER,
    transactions INTEGER
);

CREATE TABLE oil (
    date DATE PRIMARY KEY,
    dcoilwtico FLOAT
);

CREATE TABLE holidays_events (
    date DATE PRIMARY KEY,
    type VARCHAR(50),
    locale VARCHAR(50),
    locale_name VARCHAR(50),
    description VARCHAR(100),
    transferred BOOLEAN
);

COPY test FROM '/path/to/test.csv' DELIMITER ',' CSV HEADER;
COPY train FROM '/path/to/train.csv' DELIMITER ',' CSV HEADER;
COPY stores FROM '/path/to/stores.csv' DELIMITER ',' CSV HEADER;
COPY transactions FROM '/path/to/transactions.csv' DELIMITER ',' CSV HEADER;
COPY oil FROM '/path/to/oil.csv' DELIMITER ',' CSV HEADER;
COPY holidays_events FROM '/path/to/holidays_events.csv' DELIMITER ',' CSV HEADER;

SELECT t.id, t.date, t.store_nbr, t.family, t.sales, t.onpromotion, s.city, s.state, s.type, s.cluster, o.dcoilwtico, h.type AS holiday_type, h.locale, h.locale_name
FROM train t
JOIN stores s ON t.store_nbr = s.store_nbr
LEFT JOIN oil o ON t.date = o.date
LEFT JOIN holidays_events h ON t.date = h.date
ORDER BY t.id, t.date, t.store_nbr
