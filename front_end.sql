DROP TABLE IF EXISTS fact_economic_data CASCADE;
DROP TABLE IF EXISTS fact_exchange_rates CASCADE;
DROP TABLE IF EXISTS fact_country_income CASCADE;
DROP TABLE IF EXISTS dim_countries CASCADE;
DROP TABLE IF EXISTS dim_indicators CASCADE;
DROP TABLE IF EXISTS dim_time CASCADE;
DROP TABLE IF EXISTS dim_sources CASCADE;
DROP TABLE IF EXISTS dim_units CASCADE;
DROP TABLE IF EXISTS dim_regions CASCADE;
DROP TABLE IF EXISTS dim_income_groups CASCADE;

CREATE TABLE dim_income_groups (income_group_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,label VARCHAR(50) NOT NULL);

CREATE TABLE dim_regions (region_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,region_name VARCHAR(50) NOT NULL);

CREATE TABLE dim_units (unit_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,unit_name VARCHAR(50) NOT NULL);

CREATE TABLE dim_sources (source_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,source_name VARCHAR(100) NOT NULL,url TEXT);

CREATE TABLE dim_time (year_id INTEGER PRIMARY KEY,decade VARCHAR(10),is_crisis_year BOOLEAN);

CREATE TABLE dim_countries (country_id VARCHAR(3) PRIMARY KEY,country_name VARCHAR(100) NOT NULL,region_id INTEGER REFERENCES dim_regions(region_id));

CREATE TABLE fact_country_income (country_id VARCHAR(3) REFERENCES dim_countries(country_id),year_id INT REFERENCES dim_time(year_id),income_group_id INT REFERENCES dim_income_groups(income_group_id),PRIMARY KEY (country_id, year_id));

CREATE TABLE dim_indicators (indicator_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,indicator_name VARCHAR(100) NOT NULL,unit_id INTEGER REFERENCES dim_units(unit_id),definition TEXT);

CREATE TABLE fact_economic_data (fact_id INTEGER GENERATED ALWAYS AS IDENTITY,country_id VARCHAR(3) NOT NULL REFERENCES dim_countries(country_id),indicator_id INTEGER NOT NULL REFERENCES dim_indicators(indicator_id),year_id INTEGER NOT NULL REFERENCES dim_time(year_id),source_id INTEGER NOT NULL REFERENCES dim_sources(source_id),value NUMERIC(20, 2) NOT NULL, PRIMARY KEY (fact_id,year_id)) PARTITION BY RANGE(year_id);
CREATE TABLE fact_economic_data_2000_2004 PARTITION OF fact_economic_data FOR VALUES FROM (2000) TO (2005);
CREATE TABLE fact_economic_data_2005_2009 PARTITION OF fact_economic_data FOR VALUES FROM (2005) TO (2010);
CREATE TABLE fact_economic_data_2010_2014 PARTITION OF fact_economic_data FOR VALUES FROM (2010) TO (2015);
CREATE TABLE fact_economic_data_2015_2019 PARTITION OF fact_economic_data FOR VALUES FROM (2015) TO (2020);
CREATE TABLE fact_economic_data_2020_2024 PARTITION OF fact_economic_data FOR VALUES FROM (2020) TO (2025);
ALTER TABLE fact_economic_data 
ADD CONSTRAINT unique_economic_entry 
UNIQUE (country_id, indicator_id, source_id, year_id);

CREATE TABLE fact_exchange_rates (rate_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,country_id VARCHAR(3) NOT NULL REFERENCES dim_countries(country_id),year_id INTEGER NOT NULL REFERENCES dim_time(year_id),source_id INTEGER NOT NULL REFERENCES dim_sources(source_id),local_currency_code VARCHAR(3) NOT NULL,usd_exchange_rate NUMERIC(15, 4) NOT NULL);
ALTER TABLE fact_exchange_rates 
ADD CONSTRAINT unique_exchange_rate_entry 
UNIQUE (country_id, year_id, source_id);

INSERT INTO dim_units (unit_name) VALUES ('current US$'),('% of total'),('annual %'),('count'),('LCU per US$');

INSERT INTO dim_indicators (indicator_name, unit_id, definition) VALUES ('GDP (current US$)',1, 'Gross domestic product is the total income earned through the production of goods and services in an economic territory during an accounting period'),
('GDP growth (annual %)',3, 'Gross domestic product is the total income earned through the production of goods and services in an economic territory during an accounting period'),
('Population, total (count)',4,'Total population is based on the de facto definition of population, which counts all residents regardless of legal status or citizenship. The values shown are midyear estimates'),
('Inflation, consumer prices (annual %)',3,'Inflation as measured by the consumer price index reflects the annual percentage change in the cost to the average consumer of acquiring a basket of goods and services that may be fixed or changed at specified intervals, such as yearly'),
('Foreign direct investment, net inflows (% of GDP)',2,'Foreign direct investment are the net inflows of investment to acquire a lasting management interest (10 percent or more of voting stock) in an enterprise operating in an economy other than that of the investor'),
('Unemployment, total (% of total labor force) (modeled ILO estimate)',2,'Unemployment refers to the share of the labor force that is without work but available for and seeking employment'),
('Exports of goods and services (% of GDP)',2,'Exports of goods includes changes in the economic ownership of goods from residents of the compiling economy to non-residents, irrespective of physical movement of goods across national borders'),
('Gross fixed capital formation (% of GDP)',2,'Gross fixed capital formation includes acquisitions less disposals of fixed assets during the accounting period, including certain specified expenditures on services that add to the value of non-produced assets'),
('Official exchange rate (LCU per US$, period average)',5,'Official exchange rate refers to the exchange rate determined by national authorities or to the rate determined in the legally sanctioned exchange market');

INSERT INTO dim_time (year_id, decade,is_crisis_year) VALUES (2000, '2000s', FALSE),
(2001, '2000s', FALSE),
(2002, '2000s', FALSE),
(2003, '2000s', FALSE),
(2004, '2000s', FALSE),
(2005, '2000s', FALSE),
(2006, '2000s', FALSE),
(2007, '2000s', FALSE),
(2008, '2000s', TRUE),
(2009, '2000s', TRUE),
(2010, '2010s', FALSE),
(2011, '2010s', FALSE),
(2012, '2010s', FALSE),
(2013, '2010s', FALSE),
(2014, '2010s', FALSE),
(2015, '2010s', FALSE),
(2016, '2010s', FALSE),
(2017, '2010s', FALSE),
(2018, '2010s', FALSE),
(2019, '2010s', FALSE),
(2020, '2020s', TRUE),
(2021, '2020s', TRUE),
(2022, '2020s', FALSE),
(2023, '2020s', FALSE),
(2024, '2020s', FALSE);

INSERT INTO dim_regions (region_name) VALUES ('Mainland'),('Insular');

INSERT INTO dim_income_groups (label) VALUES ('Low Income'),
('Lower-middle Income'),
('Upper-middle Income'),
('High Income');

INSERT INTO dim_countries (country_id,country_name,region_id) VALUES('BRN','Brunei Darussalam',2),
('KHM','Cambodia',1),
('IDN','Indonesia',2),
('LAO','Laos',1),
('MYS','Malaysia',1),
('MMR','Myanmar',1),
('PHL','Philippines',2),
('SGP','Singapore',2),
('THA','Thailand',1),
('VNM','Vietnam',1);

INSERT INTO dim_sources (source_name,url) VALUES ('World Bank Open Data','https://databank.worldbank.org/source/world-development-indicators');

INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2004, 1, 8619178774.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2005, 1, 10547202621.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2006, 1, 12644616419.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2007, 1, 13432029484.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2008, 1, 15926456515.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2009, 1, 11912904510.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2010, 1, 13707121038.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2011, 1, 18524791063.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2012, 1, 19048443341.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2013, 1, 18094148099.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2014, 1, 17097797386.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2015, 1, 12930296870.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2016, 1, 11400266045.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2017, 1, 12128168045.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2018, 1, 13566908391.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2019, 1, 13469235365.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2020, 1, 12005799654.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2021, 1, 14006496617.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2022, 1, 16681536467.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2023, 1, 15095084656.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 1, 2024, 1, 15340808592.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2004, 1, 0.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2005, 1, 0.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2006, 1, 4.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2007, 1, -3.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2008, 1, -3.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2009, 1, -1.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2010, 1, 2.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2011, 1, 3.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2012, 1, 0.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2013, 1, -2.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2014, 1, -2.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2015, 1, -0.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2016, 1, -2.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2017, 1, 1.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2018, 1, 0.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2019, 1, 3.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2020, 1, 1.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2021, 1, -1.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2022, 1, -1.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2023, 1, 1.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 2, 2024, 1, 4.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2004, 1, 352911.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2005, 1, 358916.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2006, 1, 364663.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2007, 1, 370873.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2008, 1, 377793.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2009, 1, 384952.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2010, 1, 392332.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2011, 1, 399389.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2012, 1, 405557.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2013, 1, 411202.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2014, 1, 416750.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2015, 1, 422212.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2016, 1, 427564.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2017, 1, 432772.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2018, 1, 437810.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2019, 1, 442680.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2020, 1, 447404.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2021, 1, 451721.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2022, 1, 455370.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2023, 1, 458949.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 3, 2024, 1, 462721.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2004, 1, 0.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2005, 1, 1.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2006, 1, 0.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2007, 1, 0.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2008, 1, 2.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2009, 1, 1.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2010, 1, 0.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2011, 1, 0.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2012, 1, 0.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2013, 1, 0.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2014, 1, -0.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2015, 1, -0.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2016, 1, -0.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2017, 1, -1.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2018, 1, 1.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2019, 1, -0.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2020, 1, 1.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2021, 1, 1.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2022, 1, 3.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2023, 1, 0.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 4, 2024, 1, -0.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2004, 1, 1.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2005, 1, 1.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2006, 1, 0.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2007, 1, 1.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2008, 1, 1.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2009, 1, 2.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2010, 1, 3.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2011, 1, 3.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2012, 1, 4.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2013, 1, 4.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2014, 1, 3.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2015, 1, 1.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2016, 1, -1.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2017, 1, 3.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2018, 1, 3.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2019, 1, 2.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2020, 1, 4.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2021, 1, 1.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2022, 1, -1.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2023, 1, -0.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 5, 2024, 1, 0.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2004, 1, 5.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2005, 1, 5.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2006, 1, 6.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2007, 1, 6.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2008, 1, 6.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2009, 1, 6.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2010, 1, 6.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2011, 1, 6.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2012, 1, 6.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2013, 1, 6.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2014, 1, 6.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2015, 1, 7.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2016, 1, 8.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2017, 1, 9.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2018, 1, 8.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2019, 1, 6.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2020, 1, 7.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2021, 1, 4.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2022, 1, 5.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2023, 1, 5.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 6, 2024, 1, 5.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2004, 1, 57.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2005, 1, 58.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2006, 1, 60.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2007, 1, 56.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2008, 1, 65.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2009, 1, 59.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2010, 1, 67.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2011, 1, 69.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2012, 1, 70.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2013, 1, 68.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2014, 1, 68.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2015, 1, 52.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2016, 1, 49.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2017, 1, 49.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2018, 1, 51.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2019, 1, 57.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2020, 1, 57.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2021, 1, 80.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2022, 1, 86.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2023, 1, 76.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 7, 2024, 1, 74.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2004, 1, 27.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2005, 1, 23.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2006, 1, 21.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2007, 1, 24.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2008, 1, 23.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2009, 1, 30.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2010, 1, 27.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2011, 1, 30.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2012, 1, 35.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2013, 1, 42.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2014, 1, 34.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2015, 1, 37.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2016, 1, 37.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2017, 1, 35.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2018, 1, 41.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2019, 1, 50.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2020, 1, 52.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2021, 1, 66.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2022, 1, 60.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2023, 1, 60.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 8, 2024, 1, 58.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2004, 1, 19.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2005, 1, 16.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2006, 1, 15.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2007, 1, 19.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2008, 1, 20.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2009, 1, 26.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2010, 1, 23.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2011, 1, 25.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2012, 1, 32.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2013, 1, 39.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2014, 1, 27.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2015, 1, 35.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2016, 1, 34.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2017, 1, 34.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2018, 1, 40.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2019, 1, 38.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2020, 1, 40.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2021, 1, 31.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2022, 1, 25.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2023, 1, 29.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('BRN', 9, 2024, 1, 27.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2004, 1, 5883297160.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2005, 1, 7066296463.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2006, 1, 8350531017.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2007, 1, 10127916460.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2008, 1, 12174303999.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2009, 1, 12502901170.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2010, 1, 13808673288.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2011, 1, 16032622024.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2012, 1, 17826536700.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2013, 1, 19807135253.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2014, 1, 22041463968.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2015, 1, 24174170369.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2016, 1, 26556545153.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2017, 1, 29355665910.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2018, 1, 33145892169.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2019, 1, 36685356408.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2020, 1, 34818073901.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2021, 1, 36790163687.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2022, 1, 39994532960.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2023, 1, 42335646896.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 1, 2024, 1, 46352647037.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2004, 1, 9.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2005, 1, 13.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2006, 1, 10.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2007, 1, 10.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2008, 1, 7.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2009, 1, 4.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2010, 1, 5.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2011, 1, 7.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2012, 1, 7.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2013, 1, 7.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2014, 1, 8.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2015, 1, 7.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2016, 1, 7.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2017, 1, 8.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2018, 1, 8.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2019, 1, 7.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2020, 1, -3.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2021, 1, 3.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2022, 1, 5.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2023, 1, 5.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 2, 2024, 1, 5.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2004, 1, 13244731.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2005, 1, 13439202.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2006, 1, 13639028.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2007, 1, 13841770.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2008, 1, 14053479.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2009, 1, 14276810.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2010, 1, 14500726.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2011, 1, 14722584.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2012, 1, 14945085.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2013, 1, 15170208.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2014, 1, 15396772.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2015, 1, 15623251.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2016, 1, 15852803.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2017, 1, 16073372.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2018, 1, 16274522.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2019, 1, 16481304.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2020, 1, 16725474.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2021, 1, 16974305.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2022, 1, 17201724.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2023, 1, 17423880.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 3, 2024, 1, 17638801.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2004, 1, 4.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2005, 1, 6.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2006, 1, 5.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2007, 1, 8.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2008, 1, 24.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2009, 1, -1.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2010, 1, 4.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2011, 1, 5.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2012, 1, 2.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2013, 1, 2.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2014, 1, 3.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2015, 1, 1.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2016, 1, 3.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2017, 1, 2.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2018, 1, 2.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2019, 1, 1.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2020, 1, 2.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2021, 1, 2.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2022, 1, 5.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2023, 1, 2.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 4, 2024, 1, 0.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2004, 1, 2.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2005, 1, 5.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2006, 1, 5.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2007, 1, 8.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2008, 1, 6.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2009, 1, 7.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2010, 1, 10.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2011, 1, 9.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2012, 1, 11.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2013, 1, 10.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2014, 1, 8.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2015, 1, 7.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2016, 1, 9.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2017, 1, 9.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2018, 1, 9.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2019, 1, 9.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2020, 1, 10.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2021, 1, 9.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2022, 1, 8.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2023, 1, 9.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 5, 2024, 1, 9.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2004, 1, 1.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2005, 1, 1.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2006, 1, 1.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2007, 1, 1.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2008, 1, 0.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2009, 1, 0.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2010, 1, 0.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2011, 1, 0.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2012, 1, 0.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2013, 1, 0.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2014, 1, 0.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2015, 1, 0.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2016, 1, 0.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2017, 1, 0.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2018, 1, 0.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2019, 1, 0.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2020, 1, 0.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2021, 1, 0.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2022, 1, 0.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2023, 1, 0.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 6, 2024, 1, 0.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2004, 1, 60.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2005, 1, 61.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2006, 1, 64.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2007, 1, 61.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2008, 1, 61.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2009, 1, 46.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2010, 1, 50.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2011, 1, 49.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2012, 1, 53.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2013, 1, 56.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2014, 1, 56.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2015, 1, 55.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2016, 1, 56.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2017, 1, 56.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2018, 1, 55.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2019, 1, 55.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2020, 1, 59.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2021, 1, 72.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2022, 1, 72.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2023, 1, 66.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 7, 2024, 1, 71.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2004, 1, 70.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2005, 1, 72.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2006, 1, 75.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2007, 1, 72.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2008, 1, 68.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2009, 1, 56.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2010, 1, 59.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2011, 1, 59.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2012, 1, 63.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2013, 1, 68.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2014, 1, 67.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2015, 1, 66.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2016, 1, 66.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2017, 1, 64.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2018, 1, 62.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2019, 1, 60.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2020, 1, 62.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2021, 1, 73.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2022, 1, 73.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2023, 1, 67.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 8, 2024, 1, 72.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2004, 1, 21.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2005, 1, 22.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2006, 1, 23.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2007, 1, 24.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2008, 1, 21.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2009, 1, 25.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2010, 1, 21.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2011, 1, 21.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2012, 1, 23.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2013, 1, 25.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2014, 1, 29.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2015, 1, 29.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2016, 1, 29.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2017, 1, 29.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2018, 1, 29.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2019, 1, 30.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2020, 1, 30.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2021, 1, 29.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2022, 1, 33.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2023, 1, 32.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('KHM', 9, 2024, 1, 31.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2004, 1, 257000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2005, 1, 286000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2006, 1, 365000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2007, 1, 432000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2008, 1, 510000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2009, 1, 540000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2010, 1, 755000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2011, 1, 893000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2012, 1, 918000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2013, 1, 913000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2014, 1, 891000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2015, 1, 861000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2016, 1, 932000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2017, 1, 1020000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2018, 1, 1040000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2019, 1, 1120000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2020, 1, 1060000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2021, 1, 1190000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2022, 1, 1320000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2023, 1, 1370000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 1, 2024, 1, 1400000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2004, 1, 5.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2005, 1, 5.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2006, 1, 5.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2007, 1, 6.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2008, 1, 6.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2009, 1, 4.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2010, 1, 6.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2011, 1, 6.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2012, 1, 6.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2013, 1, 5.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2014, 1, 5.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2015, 1, 4.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2016, 1, 5.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2017, 1, 5.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2018, 1, 5.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2019, 1, 5.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2020, 1, -2.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2021, 1, 3.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2022, 1, 5.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2023, 1, 5.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 2, 2024, 1, 5.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2004, 1, 227926649.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2005, 1, 230871650.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2006, 1, 233951652.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2007, 1, 237062337.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2008, 1, 240157903.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2009, 1, 243220028.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2010, 1, 246305322.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2011, 1, 249470032.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2012, 1, 252698525.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2013, 1, 255852467.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2014, 1, 258877399.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2015, 1, 261799249.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2016, 1, 264627418.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2017, 1, 267346658.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2018, 1, 269951846.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2019, 1, 272489381.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2020, 1, 274814866.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2021, 1, 276758053.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2022, 1, 278830529.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2023, 1, 281190067.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 3, 2024, 1, 283487931.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2004, 1, 6.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2005, 1, 10.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2006, 1, 13.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2007, 1, 6.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2008, 1, 10.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2009, 1, 4.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2010, 1, 5.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2011, 1, 5.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2012, 1, 4.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2013, 1, 6.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2014, 1, 6.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2015, 1, 6.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2016, 1, 3.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2017, 1, 3.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2018, 1, 3.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2019, 1, 3.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2020, 1, 1.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2021, 1, 1.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2022, 1, 4.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2023, 1, 3.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 4, 2024, 1, 2.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2004, 1, 0.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2005, 1, 2.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2006, 1, 1.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2007, 1, 1.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2008, 1, 1.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2009, 1, 0.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2010, 1, 2.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2011, 1, 2.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2012, 1, 2.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2013, 1, 2.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2014, 1, 2.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2015, 1, 2.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2016, 1, 0.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2017, 1, 2.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2018, 1, 1.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2019, 1, 2.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2020, 1, 1.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2021, 1, 1.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2022, 1, 1.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2023, 1, 1.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 5, 2024, 1, 1.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2004, 1, 7.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2005, 1, 7.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2006, 1, 7.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2007, 1, 8.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2008, 1, 7.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2009, 1, 6.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2010, 1, 5.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2011, 1, 5.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2012, 1, 4.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2013, 1, 4.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2014, 1, 4.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2015, 1, 4.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2016, 1, 4.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2017, 1, 3.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2018, 1, 4.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2019, 1, 3.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2020, 1, 4.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2021, 1, 3.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2022, 1, 3.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2023, 1, 3.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 6, 2024, 1, 3.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2004, 1, 32.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2005, 1, 34.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2006, 1, 31.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2007, 1, 29.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2008, 1, 29.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2009, 1, 24.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2010, 1, 24.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2011, 1, 26.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2012, 1, 24.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2013, 1, 23.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2014, 1, 23.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2015, 1, 21.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2016, 1, 19.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2017, 1, 20.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2018, 1, 21.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2019, 1, 18.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2020, 1, 17.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2021, 1, 21.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2022, 1, 24.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2023, 1, 21.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 7, 2024, 1, 22.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2004, 1, 27.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2005, 1, 29.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2006, 1, 25.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2007, 1, 25.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2008, 1, 28.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2009, 1, 21.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2010, 1, 22.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2011, 1, 23.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2012, 1, 24.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2013, 1, 24.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2014, 1, 24.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2015, 1, 20.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2016, 1, 18.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2017, 1, 19.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2018, 1, 22.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2019, 1, 19.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2020, 1, 15.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2021, 1, 18.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2022, 1, 20.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2023, 1, 19.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 8, 2024, 1, 20.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2004, 1, 22.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2005, 1, 23.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2006, 1, 24.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2007, 1, 24.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2008, 1, 27.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2009, 1, 31.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2010, 1, 31.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2011, 1, 31.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2012, 1, 32.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2013, 1, 31.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2014, 1, 32.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2015, 1, 32.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2016, 1, 32.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2017, 1, 32.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2018, 1, 32.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2019, 1, 32.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2020, 1, 31.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2021, 1, 30.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2022, 1, 29.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2023, 1, 29.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('IDN', 9, 2024, 1, 29.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2004, 1, 2366398120.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2005, 1, 2735558735.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2006, 1, 3455030061.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2007, 1, 4223152739.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2008, 1, 5446433157.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2009, 1, 5836137330.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2010, 1, 7131771015.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2011, 1, 8750104617.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2012, 1, 10192846339.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2013, 1, 11983252627.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2014, 1, 13279245886.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2015, 1, 14426380126.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2016, 1, 15912501723.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2017, 1, 17071155481.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2018, 1, 18141641090.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2019, 1, 18740561513.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2020, 1, 18981805250.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2021, 1, 18827148531.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2022, 1, 15468785204.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2023, 1, 15843155731.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 1, 2024, 1, 16502933121.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2004, 1, 6.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2005, 1, 7.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2006, 1, 8.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2007, 1, 7.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2008, 1, 7.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2009, 1, 7.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2010, 1, 8.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2011, 1, 8.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2012, 1, 8.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2013, 1, 8.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2014, 1, 7.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2015, 1, 7.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2016, 1, 7.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2017, 1, 6.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2018, 1, 6.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2019, 1, 5.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2020, 1, 0.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2021, 1, 2.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2022, 1, 2.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2023, 1, 3.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 2, 2024, 1, 4.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2004, 1, 5781626.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2005, 1, 5869523.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2006, 1, 5963200.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2007, 1, 6056236.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2008, 1, 6148969.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2009, 1, 6241642.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2010, 1, 6334194.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2011, 1, 6426590.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2012, 1, 6518978.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2013, 1, 6611385.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2014, 1, 6703172.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2015, 1, 6801645.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2016, 1, 6908802.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2017, 1, 7018147.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2018, 1, 7128045.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2019, 1, 7237636.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2020, 1, 7346533.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2021, 1, 7453194.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2022, 1, 7559007.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2023, 1, 7664993.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 3, 2024, 1, 7769819.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2004, 1, 10.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2005, 1, 7.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2006, 1, 6.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2007, 1, 4.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2008, 1, 7.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2009, 1, 0.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2010, 1, 5.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2011, 1, 7.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2012, 1, 4.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2013, 1, 6.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2014, 1, 4.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2015, 1, 1.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2016, 1, 1.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2017, 1, 0.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2018, 1, 2.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2019, 1, 3.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2020, 1, 5.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2021, 1, 3.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2022, 1, 22.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2023, 1, 31.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 4, 2024, 1, 23.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2004, 1, 0.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2005, 1, 1.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2006, 1, 5.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2007, 1, 7.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2008, 1, 4.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2009, 1, 5.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2010, 1, 3.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2011, 1, 3.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2012, 1, 6.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2013, 1, 5.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2014, 1, 6.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2015, 1, 7.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2016, 1, 5.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2017, 1, 9.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2018, 1, 7.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2019, 1, 4.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2020, 1, 5.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2021, 1, 5.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2022, 1, 4.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2023, 1, 11.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 5, 2024, 1, 5.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2004, 1, 1.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2005, 1, 1.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2006, 1, 1.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2007, 1, 1.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2008, 1, 0.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2009, 1, 0.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2010, 1, 0.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2011, 1, 0.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2012, 1, 1.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2013, 1, 1.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2014, 1, 1.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2015, 1, 2.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2016, 1, 2.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2017, 1, 3.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2018, 1, 2.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2019, 1, 2.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2020, 1, 2.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2021, 1, 2.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2022, 1, 1.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2023, 1, 1.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 6, 2024, 1, 1.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2004, 1, 24.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2005, 1, 28.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2006, 1, 38.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2007, 1, 33.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2008, 1, 33.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2009, 1, 30.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2010, 1, 35.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2011, 1, 40.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2012, 1, 37.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2013, 1, 38.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2014, 1, 40.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2015, 1, 33.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2016, 1, 33.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2017, 1, 33.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2018, 1, 30.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2019, 1, 35.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2020, 1, 40.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2021, 1, 37.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2022, 1, 38.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2023, 1, 40.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 7, 2024, 1, 33.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2004, 1, 41.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2005, 1, 42.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2006, 1, 43.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2007, 1, 45.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2008, 1, 48.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2009, 1, 46.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2010, 1, 49.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2011, 1, 51.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2012, 1, 60.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2013, 1, 60.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2014, 1, 58.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2015, 1, 51.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2016, 1, 41.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2017, 1, 43.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2018, 1, 45.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2019, 1, 45.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2020, 1, 42.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2021, 1, 47.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2022, 1, 52.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2023, 1, 55.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 8, 2024, 1, 58.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2004, 1, 31.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2005, 1, 34.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2006, 1, 30.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2007, 1, 32.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2008, 1, 31.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2009, 1, 33.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2010, 1, 27.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2011, 1, 28.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2012, 1, 32.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2013, 1, 30.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2014, 1, 29.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2015, 1, 31.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2016, 1, 29.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2017, 1, 8244843189.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2018, 1, 31.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2019, 1, 30.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2020, 1, 28.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2021, 1, 25.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2022, 1, 23.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2023, 1, 22.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('LAO', 9, 2024, 1, 21.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2004, 1, 125000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2005, 1, 144000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2006, 1, 163000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2007, 1, 194000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2008, 1, 231000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2009, 1, 202000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2010, 1, 255000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2011, 1, 298000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2012, 1, 314000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2013, 1, 323000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2014, 1, 338000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2015, 1, 301000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2016, 1, 301000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2017, 1, 319000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2018, 1, 359000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2019, 1, 365000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2020, 1, 337000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2021, 1, 374000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2022, 1, 408000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2023, 1, 400000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 1, 2024, 1, 422000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2004, 1, 6.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2005, 1, 5.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2006, 1, 5.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2007, 1, 6.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2008, 1, 4.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2009, 1, -1.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2010, 1, 7.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2011, 1, 5.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2012, 1, 5.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2013, 1, 4.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2014, 1, 6.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2015, 1, 5.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2016, 1, 4.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2017, 1, 5.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2018, 1, 4.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2019, 1, 4.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2020, 1, -5.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2021, 1, 3.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2022, 1, 9.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2023, 1, 3.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 2, 2024, 1, 5.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2004, 1, 25256772.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2005, 1, 25836071.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2006, 1, 26417909.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2007, 1, 26998389.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2008, 1, 27570059.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2009, 1, 28124778.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2010, 1, 28655776.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2011, 1, 29162039.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2012, 1, 29662831.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2013, 1, 30174265.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2014, 1, 30696137.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2015, 1, 31232798.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2016, 1, 31789685.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2017, 1, 32355644.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2018, 1, 32910967.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2019, 1, 33440596.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2020, 1, 33889558.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2021, 1, 34282399.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2022, 1, 34695493.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2023, 1, 35126298.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 3, 2024, 1, 35557673.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2004, 1, 1.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2005, 1, 2.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2006, 1, 3.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2007, 1, 2.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2008, 1, 5.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2009, 1, 0.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2010, 1, 1.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2011, 1, 3.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2012, 1, 1.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2013, 1, 2.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2014, 1, 3.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2015, 1, 2.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2016, 1, 2.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2017, 1, 3.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2018, 1, 0.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2019, 1, 0.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2020, 1, -1.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2021, 1, 2.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2022, 1, 3.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2023, 1, 2.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 4, 2024, 1, 1.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2004, 1, 3.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2005, 1, 2.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2006, 1, 4.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2007, 1, 4.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2008, 1, 3.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2009, 1, 0.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2010, 1, 4.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2011, 1, 5.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2012, 1, 2.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2013, 1, 3.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2014, 1, 3.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2015, 1, 3.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2016, 1, 4.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2017, 1, 2.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2018, 1, 2.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2019, 1, 2.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2020, 1, 1.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2021, 1, 5.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2022, 1, 3.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2023, 1, 1.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 5, 2024, 1, 3.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2004, 1, 3.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2005, 1, 3.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2006, 1, 3.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2007, 1, 3.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2008, 1, 3.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2009, 1, 3.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2010, 1, 3.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2011, 1, 3.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2012, 1, 3.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2013, 1, 3.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2014, 1, 2.88);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2015, 1, 3.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2016, 1, 3.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2017, 1, 3.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2018, 1, 3.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2019, 1, 3.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2020, 1, 4.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2021, 1, 4.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2022, 1, 3.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2023, 1, 3.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 6, 2024, 1, 3.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2004, 1, 115.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2005, 1, 112.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2006, 1, 112.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2007, 1, 106.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2008, 1, 99.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2009, 1, 91.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2010, 1, 86.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2011, 1, 85.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2012, 1, 79.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2013, 1, 75.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2014, 1, 73.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2015, 1, 69.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2016, 1, 66.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2017, 1, 70.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2018, 1, 68.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2019, 1, 65.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2020, 1, 61.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2021, 1, 70.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2022, 1, 76.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2023, 1, 68.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 7, 2024, 1, 71.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2004, 1, 95.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2005, 1, 90.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2006, 1, 90.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2007, 1, 86.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2008, 1, 77.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2009, 1, 71.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2010, 1, 71.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2011, 1, 69.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2012, 1, 68.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2013, 1, 67.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2014, 1, 64.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2015, 1, 61.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2016, 1, 60.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2017, 1, 63.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2018, 1, 61.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2019, 1, 57.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2020, 1, 55.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2021, 1, 63.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2022, 1, 69.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2023, 1, 63.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 8, 2024, 1, 66.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2004, 1, 20.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2005, 1, 22.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2006, 1, 21.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2007, 1, 22.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2008, 1, 20.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2009, 1, 21.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2010, 1, 22.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2011, 1, 22.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2012, 1, 25.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2013, 1, 26.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2014, 1, 25.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2015, 1, 25.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2016, 1, 25.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2017, 1, 25.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2018, 1, 24.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2019, 1, 22.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2020, 1, 20.91);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2021, 1, 19.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2022, 1, 18.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2023, 1, 19.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MYS', 9, 2024, 1, 20.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2004, 1, 10567354056.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2005, 1, 11986972419.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2006, 1, 14502553710.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2007, 1, 20182477481.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2008, 1, 31862554102.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2009, 1, 36906181381.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2010, 1, 49540813342.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2011, 1, 59977326086.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2012, 1, 59937796648.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2013, 1, 60269732855.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2014, 1, 65531374210.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2015, 1, 59607290408.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2016, 1, 63298361984.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2017, 1, 66053040475.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2018, 1, 67860515993.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2019, 1, 75065106243.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2020, 1, 79006113670.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2021, 1, 66345291149.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2022, 1, 62253049903.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2023, 1, 66757619000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 1, 2024, 1, 74068349524.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2004, 1, 13.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2005, 1, 13.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2006, 1, 13.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2007, 1, 11.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2008, 1, 10.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2009, 1, 10.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2010, 1, 9.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2011, 1, 5.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2012, 1, 7.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2013, 1, 8.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2014, 1, 8.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2015, 1, 6.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2016, 1, 5.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2017, 1, 6.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2018, 1, 6.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2019, 1, 6.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2020, 1, -9.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2021, 1, -12.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2022, 1, 4.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2023, 1, 0.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 2, 2024, 1, -0.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2004, 1, 47068772.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2005, 1, 47438365.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2006, 1, 47785135.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2007, 1, 48125043.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2008, 1, 48390793.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2009, 1, 48660459.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2010, 1, 49024382.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2011, 1, 49419820.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2012, 1, 49837446.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2013, 1, 50262658.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2014, 1, 50681634.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2015, 1, 51089056.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2016, 1, 51495696.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2017, 1, 51894938.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2018, 1, 52272247.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2019, 1, 52640713.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2020, 1, 53016522.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2021, 1, 53387102.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2022, 1, 53756787.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2023, 1, 54133798.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 3, 2024, 1, 54500091.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2004, 1, 4.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2005, 1, 9.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2006, 1, 20.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2007, 1, 35.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2008, 1, 26.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2009, 1, 1.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2010, 1, 7.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2011, 1, 5.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2012, 1, 1.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2013, 1, 5.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2014, 1, 4.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2015, 1, 9.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2016, 1, 6.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2017, 1, 4.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2018, 1, 6.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2019, 1, 8.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2020, 1, 5.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2021, 1, 3.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2022, 1, 19.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2023, 1, 28.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 4, 2024, 1, 22.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2004, 1, 2.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2005, 1, 1.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2006, 1, 1.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2007, 1, 3.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2008, 1, 2.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2009, 1, 2.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2010, 1, 1.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2011, 1, 4.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2012, 1, 2.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2013, 1, 3.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2014, 1, 3.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2015, 1, 6.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2016, 1, 5.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2017, 1, 7.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2018, 1, 2.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2019, 1, 2.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2020, 1, 2.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2021, 1, 3.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2022, 1, 1.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2023, 1, 2.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 5, 2024, 1, 1.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2004, 1, 0.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2005, 1, 0.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2006, 1, 0.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2007, 1, 0.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2008, 1, 0.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2009, 1, 0.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2010, 1, 0.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2011, 1, 0.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2012, 1, 0.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2013, 1, 0.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2014, 1, 0.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2015, 1, 0.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2016, 1, 1.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2017, 1, 1.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2018, 1, 0.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2019, 1, 0.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2020, 1, 1.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2021, 1, 4.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2022, 1, 3.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2023, 1, 2.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 6, 2024, 1, 2.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2004, 1, 0.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2005, 1, 0.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2006, 1, 0.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2007, 1, 0.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2008, 1, 0.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2009, 1, 0.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2010, 1, 0.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2011, 1, 0.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2012, 1, 13.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2013, 1, 15.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2014, 1, 17.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2015, 1, 19.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2016, 1, 18.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2017, 1, 17.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2018, 1, 19.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2019, 1, 21.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2020, 1, 24.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2021, 1, 26.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2022, 1, 28.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2023, 1, 27.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 7, 2024, 1, 25.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2004, 1, 0.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2005, 1, 0.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2006, 1, 0.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2007, 1, 0.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2008, 1, 0.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2009, 1, 0.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2010, 1, 0.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2011, 1, 0.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2012, 1, 15.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2013, 1, 18.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2014, 1, 22.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2015, 1, 25.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2016, 1, 24.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2017, 1, 23.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2018, 1, 22.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2019, 1, 22.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2020, 1, 21.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2021, 1, 23.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2022, 1, 25.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2023, 1, 26.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 8, 2024, 1, 28.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2004, 1, 11.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2005, 1, 12.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2006, 1, 12.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2007, 1, 13.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2008, 1, 14.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2009, 1, 15.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2010, 1, 18.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2011, 1, 23.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2012, 1, 28.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2013, 1, 31.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2014, 1, 33.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2015, 1, 35.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2016, 1, 34.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2017, 1, 32.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2018, 1, 34.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2019, 1, 33.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2020, 1, 32.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2021, 1, 28.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2022, 1, 31.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2023, 1, 29.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('MMR', 9, 2024, 1, 27.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2004, 1, 95001999685.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2005, 1, 107000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2006, 1, 128000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2007, 1, 156000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2008, 1, 182000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2009, 1, 176000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2010, 1, 208000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2011, 1, 234000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2012, 1, 262000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2013, 1, 284000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2014, 1, 297000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2015, 1, 306000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2016, 1, 319000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2017, 1, 328000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2018, 1, 347000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2019, 1, 377000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2020, 1, 362000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2021, 1, 394000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2022, 1, 404000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2023, 1, 437000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 1, 2024, 1, 462000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2004, 1, 6.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2005, 1, 4.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2006, 1, 5.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2007, 1, 6.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2008, 1, 4.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2009, 1, 1.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2010, 1, 7.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2011, 1, 3.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2012, 1, 6.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2013, 1, 6.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2014, 1, 6.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2015, 1, 6.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2016, 1, 7.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2017, 1, 6.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2018, 1, 6.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2019, 1, 6.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2020, 1, -9.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2021, 1, 5.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2022, 1, 7.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2023, 1, 5.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 2, 2024, 1, 5.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2004, 1, 86394504.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2005, 1, 88015962.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2006, 1, 89508986.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2007, 1, 91075184.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2008, 1, 92699095.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2009, 1, 94384250.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2010, 1, 96337125.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2011, 1, 98248614.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2012, 1, 100175512.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2013, 1, 102076336.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2014, 1, 103767130.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2015, 1, 105312992.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2016, 1, 106735719.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2017, 1, 108119693.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2018, 1, 109465287.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2019, 1, 110804683.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2020, 1, 112081264.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2021, 1, 113100950.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2022, 1, 113964338.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2023, 1, 114891199.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 3, 2024, 1, 115843670.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2004, 1, 4.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2005, 1, 6.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2006, 1, 5.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2007, 1, 2.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2008, 1, 8.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2009, 1, 4.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2010, 1, 3.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2011, 1, 4.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2012, 1, 3.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2013, 1, 2.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2014, 1, 3.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2015, 1, 0.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2016, 1, 1.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2017, 1, 2.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2018, 1, 5.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2019, 1, 2.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2020, 1, 2.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2021, 1, 3.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2022, 1, 5.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2023, 1, 5.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 4, 2024, 1, 3.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2004, 1, 0.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2005, 1, 1.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2006, 1, 2.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2007, 1, 1.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2008, 1, 0.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2009, 1, 1.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2010, 1, 0.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2011, 1, 0.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2012, 1, 1.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2013, 1, 1.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2014, 1, 1.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2015, 1, 1.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2016, 1, 2.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2017, 1, 3.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2018, 1, 2.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2019, 1, 2.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2020, 1, 1.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2021, 1, 3.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2022, 1, 2.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2023, 1, 2.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 5, 2024, 1, 2.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2004, 1, 3.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2005, 1, 3.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2006, 1, 4.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2007, 1, 3.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2008, 1, 3.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2009, 1, 3.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2010, 1, 3.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2011, 1, 3.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2012, 1, 3.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2013, 1, 3.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2014, 1, 3.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2015, 1, 3.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2016, 1, 2.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2017, 1, 2.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2018, 1, 2.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2019, 1, 2.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2020, 1, 2.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2021, 1, 3.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2022, 1, 2.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2023, 1, 2.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 6, 2024, 1, 2.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2004, 1, 41.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2005, 1, 41.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2006, 1, 41.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2007, 1, 38.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2008, 1, 33.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2009, 1, 30.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2010, 1, 32.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2011, 1, 29.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2012, 1, 27.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2013, 1, 26.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2014, 1, 27.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2015, 1, 27.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2016, 1, 26.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2017, 1, 29.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2018, 1, 30.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2019, 1, 28.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2020, 1, 25.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2021, 1, 25.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2022, 1, 28.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2023, 1, 26.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 7, 2024, 1, 25.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2004, 1, 45.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2005, 1, 42.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2006, 1, 39.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2007, 1, 35.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2008, 1, 34.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2009, 1, 30.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2010, 1, 33.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2011, 1, 31.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2012, 1, 30.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2013, 1, 29.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2014, 1, 30.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2015, 1, 31.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2016, 1, 35.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2017, 1, 38.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2018, 1, 41.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2019, 1, 40.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2020, 1, 32.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2021, 1, 37.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2022, 1, 44.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2023, 1, 40.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 8, 2024, 1, 40.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2004, 1, 18.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2005, 1, 18.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2006, 1, 18.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2007, 1, 18.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2008, 1, 19.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2009, 1, 18.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2010, 1, 20.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2011, 1, 18.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2012, 1, 19.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2013, 1, 20.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2014, 1, 20.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2015, 1, 22.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2016, 1, 25.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2017, 1, 25.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2018, 1, 27.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2019, 1, 27.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2020, 1, 21.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2021, 1, 22.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2022, 1, 23.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2023, 1, 23.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('PHL', 9, 2024, 1, 23.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2004, 1, 115000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2005, 1, 128000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2006, 1, 149000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2007, 1, 181000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2008, 1, 194000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2009, 1, 194000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2010, 1, 240000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2011, 1, 279000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2012, 1, 295000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2013, 1, 308000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2014, 1, 315000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2015, 1, 308000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2016, 1, 320000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2017, 1, 344000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2018, 1, 377000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2019, 1, 376000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2020, 1, 349000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2021, 1, 437000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2022, 1, 509000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2023, 1, 505000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 1, 2024, 1, 547000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2004, 1, 9.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2005, 1, 7.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2006, 1, 9.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2007, 1, 9.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2008, 1, 1.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2009, 1, 0.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2010, 1, 14.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2011, 1, 6.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2012, 1, 4.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2013, 1, 4.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2014, 1, 3.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2015, 1, 2.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2016, 1, 3.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2017, 1, 4.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2018, 1, 3.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2019, 1, 1.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2020, 1, -3.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2021, 1, 9.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2022, 1, 4.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2023, 1, 1.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 2, 2024, 1, 4.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2004, 1, 4166664.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2005, 1, 4265762.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2006, 1, 4401365.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2007, 1, 4588599.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2008, 1, 4839396.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2009, 1, 4987573.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2010, 1, 5076732.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2011, 1, 5183688.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2012, 1, 5312437.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2013, 1, 5399162.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2014, 1, 5469724.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2015, 1, 5535002.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2016, 1, 5607283.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2017, 1, 5612253.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2018, 1, 5638676.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2019, 1, 5703569.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2020, 1, 5685807.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2021, 1, 5453566.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2022, 1, 5637022.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2023, 1, 5917648.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 3, 2024, 1, 6036860.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2004, 1, 1.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2005, 1, 0.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2006, 1, 0.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2007, 1, 2.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2008, 1, 6.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2009, 1, 0.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2010, 1, 2.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2011, 1, 5.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2012, 1, 4.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2013, 1, 2.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2014, 1, 1.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2015, 1, -0.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2016, 1, -0.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2017, 1, 0.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2018, 1, 0.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2019, 1, 0.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2020, 1, -0.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2021, 1, 2.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2022, 1, 6.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2023, 1, 4.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 4, 2024, 1, 2.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2004, 1, 21.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2005, 1, 15.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2006, 1, 26.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2007, 1, 26.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2008, 1, 7.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2009, 1, 12.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2010, 1, 23.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2011, 1, 17.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2012, 1, 18.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2013, 1, 20.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2014, 1, 21.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2015, 1, 22.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2016, 1, 20.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2017, 1, 29.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2018, 1, 22.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2019, 1, 28.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2020, 1, 22.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2021, 1, 32.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2022, 1, 28.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2023, 1, 24.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 5, 2024, 1, 24.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2004, 1, 5.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2005, 1, 5.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2006, 1, 4.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2007, 1, 3.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2008, 1, 3.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2009, 1, 5.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2010, 1, 4.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2011, 1, 3.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2012, 1, 3.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2013, 1, 3.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2014, 1, 3.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2015, 1, 3.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2016, 1, 4.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2017, 1, 4.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2018, 1, 3.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2019, 1, 3.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2020, 1, 4.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2021, 1, 4.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2022, 1, 3.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2023, 1, 3.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 6, 2024, 1, 2.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2004, 1, 213.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2005, 1, 225.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2006, 1, 228.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2007, 1, 212.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2008, 1, 228.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2009, 1, 190.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2010, 1, 198.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2011, 1, 203.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2012, 1, 196.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2013, 1, 195.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2014, 1, 191.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2015, 1, 178.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2016, 1, 164.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2017, 1, 171.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2018, 1, 178.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2019, 1, 176.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2020, 1, 181.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2021, 1, 182.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2022, 1, 186.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2023, 1, 181.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 7, 2024, 1, 178.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2004, 1, 187.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2005, 1, 195.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2006, 1, 197.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2007, 1, 181.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2008, 1, 208.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2009, 1, 167.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2010, 1, 171.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2011, 1, 175.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2012, 1, 172.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2013, 1, 171.96);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2014, 1, 168.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2015, 1, 151.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2016, 1, 138.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2017, 1, 145.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2018, 1, 148.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2019, 1, 147.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2020, 1, 150.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2021, 1, 146.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2022, 1, 146.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2023, 1, 144.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 8, 2024, 1, 143.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2004, 1, 24.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2005, 1, 23.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2006, 1, 23.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2007, 1, 24.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2008, 1, 27.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2009, 1, 28.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2010, 1, 25.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2011, 1, 25.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2012, 1, 26.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2013, 1, 27.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2014, 1, 28.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2015, 1, 27.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2016, 1, 25.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2017, 1, 25.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2018, 1, 22.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2019, 1, 22.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2020, 1, 20.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2021, 1, 22.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2022, 1, 20.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2023, 1, 22.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('SGP', 9, 2024, 1, 21.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2004, 1, 173000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2005, 1, 189000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2006, 1, 222000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2007, 1, 263000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2008, 1, 291000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2009, 1, 282000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2010, 1, 341000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2011, 1, 371000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2012, 1, 398000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2013, 1, 420000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2014, 1, 407000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2015, 1, 401000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2016, 1, 413000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2017, 1, 456000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2018, 1, 507000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2019, 1, 544000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2020, 1, 500000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2021, 1, 506000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2022, 1, 496000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2023, 1, 516000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 1, 2024, 1, 527000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2004, 1, 6.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2005, 1, 4.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2006, 1, 4.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2007, 1, 5.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2008, 1, 1.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2009, 1, -0.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2010, 1, 7.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2011, 1, 0.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2012, 1, 7.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2013, 1, 2.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2014, 1, 0.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2015, 1, 3.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2016, 1, 3.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2017, 1, 4.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2018, 1, 4.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2019, 1, 2.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2020, 1, -6.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2021, 1, 1.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2022, 1, 2.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2023, 1, 2.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 2, 2024, 1, 2.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2004, 1, 65452047.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2005, 1, 66017420.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2006, 1, 66567687.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2007, 1, 67102394.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2008, 1, 67619830.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2009, 1, 68121080.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2010, 1, 68579447.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2011, 1, 69007208.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2012, 1, 69436098.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2013, 1, 69845114.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2014, 1, 70216367.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2015, 1, 70540795.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2016, 1, 70859841.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2017, 1, 71160187.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2018, 1, 71376079.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2019, 1, 71522271.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2020, 1, 71641484.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2021, 1, 71727332.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2022, 1, 71735329.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2023, 1, 71702435.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 3, 2024, 1, 71668011.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2004, 1, 2.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2005, 1, 4.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2006, 1, 4.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2007, 1, 2.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2008, 1, 5.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2009, 1, -0.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2010, 1, 3.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2011, 1, 3.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2012, 1, 3.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2013, 1, 2.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2014, 1, 1.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2015, 1, -0.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2016, 1, 0.19);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2017, 1, 0.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2018, 1, 1.06);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2019, 1, 0.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2020, 1, -0.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2021, 1, 1.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2022, 1, -1.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2023, 1, 8.48);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 4, 2024, 1, 1.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2004, 1, 3.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2005, 1, 4.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2006, 1, 4.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2007, 1, 3.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2008, 1, 2.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2009, 1, 2.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2010, 1, 4.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2011, 1, 0.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2012, 1, 3.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2013, 1, 3.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2014, 1, 1.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2015, 1, 2.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2016, 1, 0.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2017, 1, 1.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2018, 1, 2.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2019, 1, 1.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2020, 1, -0.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2021, 1, 3.04);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2022, 1, 2.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2023, 1, 2.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 5, 2024, 1, 2.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2004, 1, 1.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2005, 1, 1.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2006, 1, 1.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2007, 1, 1.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2008, 1, 1.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2009, 1, 1.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2010, 1, 0.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2011, 1, 0.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2012, 1, 0.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2013, 1, 0.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2014, 1, 0.58);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2015, 1, 0.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2016, 1, 0.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2017, 1, 0.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2018, 1, 0.77);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2019, 1, 0.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2020, 1, 1.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2021, 1, 1.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2022, 1, 0.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2023, 1, 0.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 6, 2024, 1, 0.78);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2004, 1, 65.97);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2005, 1, 68.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2006, 1, 68.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2007, 1, 68.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2008, 1, 71.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2009, 1, 64.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2010, 1, 66.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2011, 1, 70.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2012, 1, 68.95);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2013, 1, 67.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2014, 1, 68.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2015, 1, 67.64);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2016, 1, 67.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2017, 1, 66.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2018, 1, 64.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2019, 1, 59.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2020, 1, 51.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2021, 1, 58.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2022, 1, 65.37);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2023, 1, 65.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 7, 2024, 1, 70.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2004, 1, 61.44);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2005, 1, 69.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2006, 1, 65.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2007, 1, 61.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2008, 1, 69.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2009, 1, 54.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2010, 1, 60.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2011, 1, 68.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2012, 1, 68.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2013, 1, 65.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2014, 1, 62.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2015, 1, 57.20);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2016, 1, 53.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2017, 1, 54.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2018, 1, 56.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2019, 1, 50.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2020, 1, 46.31);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2021, 1, 58.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2022, 1, 67.49);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2023, 1, 63.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 8, 2024, 1, 66.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2004, 1, 24.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2005, 1, 27.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2006, 1, 26.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2007, 1, 25.46);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2008, 1, 26.45);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2009, 1, 23.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2010, 1, 23.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2011, 1, 25.84);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2012, 1, 26.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2013, 1, 25.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2014, 1, 24.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2015, 1, 24.53);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2016, 1, 23.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2017, 1, 23.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2018, 1, 22.79);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2019, 1, 22.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2020, 1, 23.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2021, 1, 23.51);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2022, 1, 23.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2023, 1, 22.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('THA', 9, 2024, 1, 22.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2004, 1, 45427854693.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2005, 1, 57633255738.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2006, 1, 66371664817.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2007, 1, 77414425532.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2008, 1, 99130304099.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2009, 1, 106000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2010, 1, 147000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2011, 1, 173000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2012, 1, 196000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2013, 1, 214000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2014, 1, 233000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2015, 1, 239000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2016, 1, 257000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2017, 1, 281000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2018, 1, 310000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2019, 1, 334000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2020, 1, 347000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2021, 1, 366000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2022, 1, 413000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2023, 1, 434000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 1, 2024, 1, 476000000000.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2004, 1, 7.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2005, 1, 7.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2006, 1, 6.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2007, 1, 7.13);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2008, 1, 5.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2009, 1, 5.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2010, 1, 6.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2011, 1, 6.41);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2012, 1, 5.50);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2013, 1, 5.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2014, 1, 6.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2015, 1, 6.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2016, 1, 6.69);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2017, 1, 6.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2018, 1, 7.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2019, 1, 7.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2020, 1, 2.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2021, 1, 2.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2022, 1, 8.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2023, 1, 5.07);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 2, 2024, 1, 7.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2004, 1, 80338971.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2005, 1, 81088313.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2006, 1, 82167897.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2007, 1, 83633375.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2008, 1, 85175788.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2009, 1, 86460018.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2010, 1, 87455152.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2011, 1, 88468314.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2012, 1, 89510356.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2013, 1, 90573104.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2014, 1, 91679578.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2015, 1, 92823254.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2016, 1, 94000117.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2017, 1, 95176977.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2018, 1, 96237319.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2019, 1, 97173776.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2020, 1, 98079191.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2021, 1, 98935098.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2022, 1, 99680655.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2023, 1, 100352192.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 3, 2024, 1, 100987686.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2004, 1, 7.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2005, 1, 8.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2006, 1, 7.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2007, 1, 8.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2008, 1, 23.12);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2009, 1, 6.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2010, 1, 9.21);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2011, 1, 18.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2012, 1, 9.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2013, 1, 6.59);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2014, 1, 4.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2015, 1, 0.63);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2016, 1, 2.67);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2017, 1, 3.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2018, 1, 3.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2019, 1, 2.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2020, 1, 3.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2021, 1, 1.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2022, 1, 3.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2023, 1, 3.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 4, 2024, 1, 3.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2004, 1, 3.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2005, 1, 3.39);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2006, 1, 3.62);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2007, 1, 8.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2008, 1, 9.66);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2009, 1, 7.17);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2010, 1, 5.43);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2011, 1, 4.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2012, 1, 4.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2013, 1, 4.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2014, 1, 3.94);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2015, 1, 4.93);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2016, 1, 4.90);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2017, 1, 5.01);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2018, 1, 5.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2019, 1, 4.82);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2020, 1, 4.56);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2021, 1, 4.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2022, 1, 4.33);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2023, 1, 4.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 5, 2024, 1, 4.23);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2004, 1, 2.14);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2005, 1, 2.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2006, 1, 2.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2007, 1, 2.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2008, 1, 1.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2009, 1, 1.74);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2010, 1, 1.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2011, 1, 1.00);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2012, 1, 1.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2013, 1, 1.32);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2014, 1, 1.26);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2015, 1, 1.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2016, 1, 1.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2017, 1, 1.87);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2018, 1, 1.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2019, 1, 1.68);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2020, 1, 2.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2021, 1, 2.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2022, 1, 1.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2023, 1, 1.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 6, 2024, 1, 1.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2004, 1, 59.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2005, 1, 63.70);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2006, 1, 67.72);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2007, 1, 70.52);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2008, 1, 70.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2009, 1, 62.61);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2010, 1, 54.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2011, 1, 61.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2012, 1, 63.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2013, 1, 66.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2014, 1, 69.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2015, 1, 72.92);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2016, 1, 74.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2017, 1, 81.76);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2018, 1, 84.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2019, 1, 85.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2020, 1, 84.38);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2021, 1, 93.85);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2022, 1, 93.42);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2023, 1, 86.47);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 7, 2024, 1, 90.15);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2004, 1, 73.29);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2005, 1, 67.02);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2006, 1, 70.60);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2007, 1, 84.09);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2008, 1, 83.98);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2009, 1, 72.10);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2010, 1, 59.80);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2011, 1, 64.08);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2012, 1, 59.75);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2013, 1, 64.05);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2014, 1, 65.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2015, 1, 71.99);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2016, 1, 71.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2017, 1, 79.22);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2018, 1, 80.24);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2019, 1, 79.55);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2020, 1, 78.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2021, 1, 92.83);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2022, 1, 89.73);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2023, 1, 78.35);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 8, 2024, 1, 83.71);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2004, 1, 33.25);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2005, 1, 31.27);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2006, 1, 31.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2007, 1, 35.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2008, 1, 31.81);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2009, 1, 33.86);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2010, 1, 35.16);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2011, 1, 30.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2012, 1, 28.65);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2013, 1, 28.30);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2014, 1, 28.40);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2015, 1, 30.18);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2016, 1, 29.89);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2017, 1, 30.54);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2018, 1, 30.34);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2019, 1, 30.36);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2020, 1, 30.28);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2021, 1, 31.03);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2022, 1, 30.57);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2023, 1, 30.11);
INSERT INTO public.fact_economic_data (country_id, indicator_id, year_id, source_id, value) VALUES ('VNM', 9, 2024, 1, 29.02);

INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2004, 1, 'BND', 1.6900);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2005, 1, 'BND', 1.6600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2006, 1, 'BND', 1.5800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2007, 1, 'BND', 1.5000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2008, 1, 'BND', 1.4100);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2009, 1, 'BND', 1.4500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2010, 1, 'BND', 1.3600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2011, 1, 'BND', 1.2500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2012, 1, 'BND', 1.2400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2013, 1, 'BND', 1.2500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2014, 1, 'BND', 1.2600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2015, 1, 'BND', 1.3700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2016, 1, 'BND', 1.3800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2017, 1, 'BND', 1.3800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2018, 1, 'BND', 1.3400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2019, 1, 'BND', 1.3600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2020, 1, 'BND', 1.3700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2021, 1, 'BND', 1.3400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2022, 1, 'BND', 1.3700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2023, 1, 'BND', 1.3400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('BRN', 2024, 1, 'BND', 1.3500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2004, 1, 'KHR', 4016.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2005, 1, 'KHR', 4092.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2006, 1, 'KHR', 4103.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2007, 1, 'KHR', 4064.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2008, 1, 'KHR', 4065.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2009, 1, 'KHR', 4139.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2010, 1, 'KHR', 4184.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2011, 1, 'KHR', 4060.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2012, 1, 'KHR', 4037.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2013, 1, 'KHR', 4027.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2014, 1, 'KHR', 4037.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2015, 1, 'KHR', 4067.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2016, 1, 'KHR', 4057.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2017, 1, 'KHR', 4045.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2018, 1, 'KHR', 4049.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2019, 1, 'KHR', 4059.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2020, 1, 'KHR', 4077.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2021, 1, 'KHR', 4068.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2022, 1, 'KHR', 4085.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2023, 1, 'KHR', 4115.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('KHM', 2024, 1, 'KHR', 4135.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2004, 1, 'IDR', 8938.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2005, 1, 'IDR', 9705.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2006, 1, 'IDR', 9159.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2007, 1, 'IDR', 9141.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2008, 1, 'IDR', 9699.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2009, 1, 'IDR', 10390.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2010, 1, 'IDR', 9090.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2011, 1, 'IDR', 8770.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2012, 1, 'IDR', 9386.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2013, 1, 'IDR', 10461.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2014, 1, 'IDR', 11865.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2015, 1, 'IDR', 13389.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2016, 1, 'IDR', 13308.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2017, 1, 'IDR', 13380.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2018, 1, 'IDR', 14236.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2019, 1, 'IDR', 14147.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2020, 1, 'IDR', 14582.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2021, 1, 'IDR', 14312.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2022, 1, 'IDR', 14850.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2023, 1, 'IDR', 15255.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('IDN', 2024, 1, 'IDR', 15850.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2004, 1, 'LAK', 10595.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2005, 1, 'LAK', 10654.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2006, 1, 'LAK', 10159.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2007, 1, 'LAK', 9610.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2008, 1, 'LAK', 8745.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2009, 1, 'LAK', 8516.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2010, 1, 'LAK', 8258.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2011, 1, 'LAK', 8029.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2012, 1, 'LAK', 7994.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2013, 1, 'LAK', 7816.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2014, 1, 'LAK', 8029.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2015, 1, 'LAK', 8130.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2016, 1, 'LAK', 8121.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2017, 1, 'LAK', 8220.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2018, 1, 'LAK', 8409.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2019, 1, 'LAK', 8679.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2020, 1, 'LAK', 9075.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2021, 1, 'LAK', 10188.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2022, 1, 'LAK', 15415.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2023, 1, 'LAK', 19500.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('LAO', 2024, 1, 'LAK', 21800.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2004, 1, 'MYR', 3.8000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2005, 1, 'MYR', 3.7800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2006, 1, 'MYR', 3.6600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2007, 1, 'MYR', 3.4300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2008, 1, 'MYR', 3.3300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2009, 1, 'MYR', 3.5200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2010, 1, 'MYR', 3.2200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2011, 1, 'MYR', 3.0600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2012, 1, 'MYR', 3.0800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2013, 1, 'MYR', 3.1500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2014, 1, 'MYR', 3.2700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2015, 1, 'MYR', 3.9000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2016, 1, 'MYR', 4.1400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2017, 1, 'MYR', 4.3000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2018, 1, 'MYR', 4.0300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2019, 1, 'MYR', 4.1400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2020, 1, 'MYR', 4.2000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2021, 1, 'MYR', 4.1400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2022, 1, 'MYR', 4.4000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2023, 1, 'MYR', 4.5600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MYS', 2024, 1, 'MYR', 4.7200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2004, 1, 'MMK', 5.7500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2005, 1, 'MMK', 5.7600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2006, 1, 'MMK', 5.8000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2007, 1, 'MMK', 5.4300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2008, 1, 'MMK', 5.3700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2009, 1, 'MMK', 5.4000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2010, 1, 'MMK', 5.4200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2011, 1, 'MMK', 5.4300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2012, 1, 'MMK', 821.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2013, 1, 'MMK', 933.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2014, 1, 'MMK', 984.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2015, 1, 'MMK', 1162.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2016, 1, 'MMK', 1234.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2017, 1, 'MMK', 1360.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2018, 1, 'MMK', 1429.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2019, 1, 'MMK', 1518.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2020, 1, 'MMK', 1382.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2021, 1, 'MMK', 1643.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2022, 1, 'MMK', 1930.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2023, 1, 'MMK', 2100.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('MMR', 2024, 1, 'MMK', 3250.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2004, 1, 'PHP', 56.0400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2005, 1, 'PHP', 55.0800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2006, 1, 'PHP', 51.3100);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2007, 1, 'PHP', 46.1400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2008, 1, 'PHP', 44.4700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2009, 1, 'PHP', 47.6300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2010, 1, 'PHP', 45.1000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2011, 1, 'PHP', 43.3100);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2012, 1, 'PHP', 42.2200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2013, 1, 'PHP', 42.4400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2014, 1, 'PHP', 44.3900);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2015, 1, 'PHP', 45.5000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2016, 1, 'PHP', 47.5000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2017, 1, 'PHP', 50.4000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2018, 1, 'PHP', 52.6600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2019, 1, 'PHP', 51.7900);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2020, 1, 'PHP', 49.6200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2021, 1, 'PHP', 49.2500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2022, 1, 'PHP', 54.4700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2023, 1, 'PHP', 55.6300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('PHL', 2024, 1, 'PHP', 56.5000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2004, 1, 'SGD', 1.6900);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2005, 1, 'SGD', 1.6600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2006, 1, 'SGD', 1.5800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2007, 1, 'SGD', 1.5000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2008, 1, 'SGD', 1.4100);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2009, 1, 'SGD', 1.4500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2010, 1, 'SGD', 1.3600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2011, 1, 'SGD', 1.2500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2012, 1, 'SGD', 1.2400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2013, 1, 'SGD', 1.2500);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2014, 1, 'SGD', 1.2600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2015, 1, 'SGD', 1.3700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2016, 1, 'SGD', 1.3800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2017, 1, 'SGD', 1.3800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2018, 1, 'SGD', 1.3400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2019, 1, 'SGD', 1.3600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2020, 1, 'SGD', 1.3700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2021, 1, 'SGD', 1.3400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2022, 1, 'SGD', 1.3700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2023, 1, 'SGD', 1.3400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('SGP', 2024, 1, 'SGD', 1.3400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2004, 1, 'THB', 40.2200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2005, 1, 'THB', 40.2200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2006, 1, 'THB', 37.8800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2007, 1, 'THB', 34.5200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2008, 1, 'THB', 33.3100);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2009, 1, 'THB', 34.2800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2010, 1, 'THB', 31.6800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2011, 1, 'THB', 30.4900);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2012, 1, 'THB', 31.0800);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2013, 1, 'THB', 30.7200);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2014, 1, 'THB', 32.4700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2015, 1, 'THB', 34.2400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2016, 1, 'THB', 35.2900);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2017, 1, 'THB', 33.9300);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2018, 1, 'THB', 32.3100);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2019, 1, 'THB', 31.0400);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2020, 1, 'THB', 31.2900);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2021, 1, 'THB', 31.9700);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2022, 1, 'THB', 35.0600);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2023, 1, 'THB', 34.8000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('THA', 2024, 1, 'THB', 35.5000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2004, 1, 'VND', 15746.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2005, 1, 'VND', 15859.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2006, 1, 'VND', 15994.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2007, 1, 'VND', 16105.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2008, 1, 'VND', 16302.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2009, 1, 'VND', 17065.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2010, 1, 'VND', 18612.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2011, 1, 'VND', 20509.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2012, 1, 'VND', 20828.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2013, 1, 'VND', 20933.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2014, 1, 'VND', 21148.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2015, 1, 'VND', 21697.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2016, 1, 'VND', 22365.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2017, 1, 'VND', 22717.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2018, 1, 'VND', 23031.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2019, 1, 'VND', 23228.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2020, 1, 'VND', 23239.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2021, 1, 'VND', 22943.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2022, 1, 'VND', 23413.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2023, 1, 'VND', 23985.0000);
INSERT INTO public.fact_exchange_rates (country_id, year_id, source_id, local_currency_code, usd_exchange_rate) VALUES ('VNM', 2024, 1, 'VND', 24850.0000);

INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2004, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2005, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2006, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2007, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2008, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2009, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2010, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2011, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2012, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2013, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2014, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2015, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2016, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2017, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2018, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2019, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2020, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2021, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2022, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2023, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('BRN', 2024, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2004, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2005, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2006, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2007, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2008, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2009, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2010, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2011, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2012, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2013, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2014, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2015, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2016, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2017, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2018, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2019, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2020, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2021, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2022, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2023, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('KHM', 2024, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2004, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2005, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2006, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2007, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2008, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2009, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2010, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2011, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2012, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2013, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2014, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2015, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2016, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2017, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2018, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2019, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2020, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2021, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2022, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2023, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('IDN', 2024, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2004, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2005, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2006, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2007, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2008, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2009, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2010, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2011, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2012, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2013, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2014, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2015, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2016, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2017, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2018, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2019, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2020, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2021, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2022, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2023, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('LAO', 2024, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2004, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2005, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2006, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2007, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2008, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2009, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2010, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2011, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2012, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2013, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2014, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2015, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2016, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2017, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2018, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2019, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2020, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2021, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2022, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2023, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MYS', 2024, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2004, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2005, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2006, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2007, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2008, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2009, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2010, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2011, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2012, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2013, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2014, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2015, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2016, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2017, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2018, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2019, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2020, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2021, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2022, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2023, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('MMR', 2024, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2004, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2005, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2006, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2007, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2008, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2009, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2010, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2011, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2012, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2013, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2014, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2015, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2016, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2017, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2018, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2019, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2020, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2021, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2022, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2023, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('PHL', 2024, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2004, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2005, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2006, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2007, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2008, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2009, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2010, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2011, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2012, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2013, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2014, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2015, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2016, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2017, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2018, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2019, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2020, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2021, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2022, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2023, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('SGP', 2024, 4);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2004, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2005, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2006, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2007, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2008, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2009, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2010, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2011, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2012, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2013, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2014, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2015, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2016, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2017, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2018, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2019, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2020, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2021, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2022, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2023, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('THA', 2024, 3);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2004, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2005, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2006, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2007, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2008, 1);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2009, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2010, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2011, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2012, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2013, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2014, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2015, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2016, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2017, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2018, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2019, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2020, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2021, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2022, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2023, 2);
INSERT INTO public.fact_country_income (country_id, year_id, income_group_id) VALUES ('VNM', 2024, 2);

CREATE INDEX idx_indicator_2000_2004 ON fact_economic_data_2000_2004(country_id,indicator_id);
CREATE INDEX idx_indicator_2005_2009 ON fact_economic_data_2005_2009(country_id,indicator_id);
CREATE INDEX idx_indicator_2010_2014 ON fact_economic_data_2010_2014(country_id,indicator_id);
CREATE INDEX idx_indicator_2015_2019 ON fact_economic_data_2015_2019(country_id,indicator_id);
CREATE INDEX idx_indicator_2020_2024 ON fact_economic_data_2020_2024(country_id,indicator_id);

CLUSTER fact_economic_data_2000_2004 USING idx_indicator_2000_2004;
CLUSTER fact_economic_data_2005_2009 USING idx_indicator_2005_2009;
CLUSTER fact_economic_data_2010_2014 USING idx_indicator_2010_2014;
CLUSTER fact_economic_data_2015_2019 USING idx_indicator_2015_2019;
CLUSTER fact_economic_data_2020_2024 USING idx_indicator_2020_2024;

DROP VIEW IF EXISTS country_economic_profile; 
CREATE OR REPLACE VIEW country_economic_profile AS
SELECT fact_economic_data.year_id,dim_time.is_crisis_year,dim_income_groups.label,dim_countries.country_name,dim_indicators.indicator_name,fact_economic_data.value,dim_units.unit_name,dim_sources.source_name
FROM fact_economic_data
INNER JOIN dim_time ON fact_economic_data.year_id = dim_time.year_id
INNER JOIN dim_countries ON fact_economic_data.country_id = dim_countries.country_id
INNER JOIN fact_country_income ON fact_economic_data.country_id = fact_country_income.country_id AND fact_economic_data.year_id = fact_country_income.year_id
INNER JOIN dim_income_groups ON fact_country_income.income_group_id = dim_income_groups.income_group_id
INNER JOIN dim_indicators ON fact_economic_data.indicator_id = dim_indicators.indicator_id
INNER JOIN dim_units ON dim_indicators.unit_id = dim_units.unit_id
INNER JOIN dim_sources ON fact_economic_data.source_id = dim_sources.source_id;

DROP VIEW IF EXISTS country_financial_profile;
CREATE OR REPLACE VIEW country_financial_profile AS
SELECT fact_exchange_rates.year_id,dim_countries.country_name,fact_exchange_rates.usd_exchange_rate,fact_exchange_rates.local_currency_code,dim_sources.source_name
FROM fact_exchange_rates 
INNER JOIN dim_countries ON dim_countries.country_id = fact_exchange_rates.country_id
INNER JOIN dim_time ON dim_time.year_id = fact_exchange_rates.year_id
INNER JOIN dim_sources ON dim_sources.source_id = fact_exchange_rates.source_id;
SELECT * FROM country_financial_profile;

DROP VIEW IF EXISTS country_regional_profile;
CREATE OR REPLACE VIEW country_regional_profile as
SELECT dim_countries.country_name, dim_regions.region_name
FROM dim_countries
INNER JOIN dim_regions on dim_countries.region_id = dim_regions.region_id;

DROP VIEW IF EXISTS indicator_unit_description;
CREATE OR REPLACE VIEW indicator_unit_description as
SELECT dim_indicators.indicator_name, dim_units.unit_name, dim_indicators.definition
FROM dim_indicators 
INNER JOIN dim_units ON dim_indicators.unit_id = dim_units.unit_id; 
SELECT * FROM indicator_unit_description;

DROP PROCEDURE IF EXISTS summarize(text,text,text); 
CREATE OR REPLACE PROCEDURE summarize(
    syntax_mode TEXT,
    syntax_country_year TEXT,
    syntax_indicator_name TEXT 
)
LANGUAGE plpgsql
AS $$
DECLARE
    sum_indicator_id INT;
    sum_indicator_name TEXT;
    sum_header TEXT;
    sum_obs BIGINT;
    sum_mean NUMERIC;
    sum_std NUMERIC;
    sum_var NUMERIC;
    sum_min NUMERIC;
    sum_max NUMERIC;
BEGIN
    SELECT indicator_id, indicator_name 
    INTO sum_indicator_id, sum_indicator_name
    FROM dim_indicators 
    WHERE indicator_name ILIKE '%' || syntax_indicator_name || '%'
    LIMIT 1;
    IF sum_indicator_id IS NULL THEN
        RAISE EXCEPTION 'Indicator "%" not found.', p_indicator_name;
    END IF;
    IF LOWER(syntax_mode) = 'country' THEN
        sum_header := 'Country: ' || UPPER(syntax_country_year);
        
        SELECT COUNT(value), AVG(value), STDDEV(value), VARIANCE(value), MIN(value), MAX(value)
        INTO sum_obs, sum_mean, sum_std, sum_var, sum_min, sum_max
        FROM fact_economic_data
        WHERE country_id = UPPER(syntax_country_year) AND indicator_id = sum_indicator_id;

    ELSIF LOWER(syntax_mode) = 'year' THEN
        sum_header := 'Year:    ' || syntax_country_year;
        
        SELECT COUNT(value), AVG(value), STDDEV(value), VARIANCE(value), MIN(value), MAX(value)
        INTO sum_obs, sum_mean, sum_std, sum_var, sum_min, sum_max
        FROM fact_economic_data
        WHERE year_id = syntax_country_year::INT AND indicator_id = sum_indicator_id;    
    ELSE
        RAISE EXCEPTION 'Invalid Mode. Use "country" or "year".';
    END IF;
    RAISE NOTICE '--------------------------------------------------------------------------------------------';
    RAISE NOTICE ' Mode: % | Indicator: %', RPAD(sum_header, 20), LEFT(sum_indicator_name, 45);
    RAISE NOTICE '--------------------------------------------------------------------------------------------';
    RAISE NOTICE ' Variable      | Obs |    Mean    |  Std. Dev.  |   Variance   |   Min    |   Max';
    RAISE NOTICE '---------------+-----+------------+-------------+--------------+----------+-----------';
    RAISE NOTICE ' Statistics    | % | % | % | % | % | %', 
        LPAD(sum_obs::TEXT, 3), 
        LPAD(ROUND(sum_mean, 2)::TEXT, 10), 
        LPAD(ROUND(sum_std, 2)::TEXT, 11),
        LPAD(ROUND(sum_var, 2)::TEXT, 12),
        LPAD(sum_min::TEXT, 8),
        LPAD(sum_max::TEXT, 9);
    RAISE NOTICE '--------------------------------------------------------------------------------------------';
END;
$$;
CALL summarize('country', 'VNM', 'GDP');
CALL summarize('year', '2024', 'Population');
SELECT * FROM fact_economic_data where country_id = 'VNM' and indicator_id = 2;

CREATE OR REPLACE PROCEDURE correlate(
    p_mode TEXT,               -- 'single' or 'compare'
    syntax_country_id_1 CHAR(3), 
    syntax_ind_name_1 TEXT,
    syntax_ind_name_2 TEXT,
    syntax_country_id_2 CHAR(3) DEFAULT NULL -- Optional for 'single' mode
)
LANGUAGE plpgsql
AS $$
DECLARE
    corr_id1 INT; corr_id2 INT;
    corr_name1 TEXT; corr_name2 TEXT;
    corr_val NUMERIC;
    corr_obs BIGINT;
    interpretation TEXT;
BEGIN
    -- 1. Resolve Indicators (Fuzzy Match)
    SELECT indicator_id, indicator_name INTO corr_id1, corr_name1 
    FROM dim_indicators WHERE indicator_name ILIKE '%' || syntax_ind_name_1 || '%' LIMIT 1;
    
    SELECT indicator_id, indicator_name INTO corr_id2, corr_name2 
    FROM dim_indicators WHERE indicator_name ILIKE '%' || syntax_ind_name_2 || '%' LIMIT 1;

    -- 2. Execute Analysis Logic
    IF p_mode = 'single' THEN
        -- Internal: Var A vs Var B in Country 1
        SELECT CORR(f1.value, f2.value), COUNT(*) INTO corr_val, corr_obs
        FROM fact_economic_data f1
        JOIN fact_economic_data f2 ON f1.year_id = f2.year_id AND f1.country_id = f2.country_id
        WHERE f1.country_id = UPPER(syntax_country_id_1)
          AND f1.indicator_id = corr_id1 AND f2.indicator_id = corr_id2;

    ELSIF p_mode = 'compare' THEN
        -- Comparative: Var A (Country 1) vs Var B (Country 2)
        -- If user passes same indicator name twice, it handles Mode 2 automatically.
        SELECT CORR(f1.value, f2.value), COUNT(*) INTO corr_val, corr_obs
        FROM fact_economic_data f1
        JOIN fact_economic_data f2 ON f1.year_id = f2.year_id
        WHERE f1.country_id = UPPER(syntax_country_id_1) AND f1.indicator_id = corr_id1
          AND f2.country_id = UPPER(syntax_country_id_2) AND f2.indicator_id = corr_id2;
    END IF;

    -- 3. Qualitative Interpretation
    interpretation := CASE 
        WHEN ABS(corr_val) > 0.7 THEN 'Strong'
        WHEN ABS(corr_val) > 0.4 THEN 'Moderate'
        WHEN corr_val IS NULL THEN 'Insufficient Data'
        ELSE 'Weak/None'
    END;

    -- 4. Dynamic Report Header
    RAISE NOTICE '-------------------------------------------------------';
    RAISE NOTICE ' % ANALYSIS REPORT ', UPPER(p_mode);
    RAISE NOTICE '-------------------------------------------------------';
    RAISE NOTICE ' Target 1: % (%)', corr_name1, UPPER(syntax_country_id_1);
    RAISE NOTICE ' Target 2: % (%)', corr_name2, UPPER(COALESCE(syntax_country_id_2, syntax_country_id_1));
    RAISE NOTICE '-------------------------------------------------------';
    RAISE NOTICE ' Correlation (r): % ', ROUND(corr_val, 4);
    RAISE NOTICE ' Relationship:    % ', interpretation;
    RAISE NOTICE ' Observations:    % ', corr_obs;
    RAISE NOTICE '-------------------------------------------------------';
END;
$$;

CALL correlate('single', 'VNM', 'GDP', 'Inflation');
CALL correlate('compare', 'VNM', 'GDP', 'GDP', 'THA');
CALL correlate('compare', 'VNM', 'GDP', 'Inflation', 'THA');

DROP VIEW IF EXISTS v_economic_analysis;
CREATE OR REPLACE VIEW v_economic_analysis AS
WITH yoy_calc AS (
    SELECT 
        fact_economic_data.year_id,
        dim_countries.country_name,
        dim_indicators.indicator_name,
        fact_economic_data.value AS current_value,
        LAG(fact_economic_data.value) OVER (
            PARTITION BY fact_economic_data.country_id, fact_economic_data.indicator_id 
            ORDER BY fact_economic_data.year_id
        ) AS previous_value
    FROM fact_economic_data
    JOIN dim_countries ON fact_economic_data.country_id = dim_countries.country_id
    JOIN dim_indicators ON fact_economic_data.indicator_id = dim_indicators.indicator_id
)

SELECT 
    yoy_calc.year_id,
    yoy_calc.country_name,
    yoy_calc.indicator_name,
    yoy_calc.current_value,
    yoy_calc.previous_value,
    ROUND(
        ((yoy_calc.current_value - yoy_calc.previous_value) / NULLIF(yoy_calc.previous_value, 0)) * 100, 
        2
    ) AS yoy_growth_rate
FROM yoy_calc;
SELECT * FROM v_economic_analysis WHERE country_name = 'Indonesia' and indicator_name = 'Population, total (count)';

DROP FUNCTION IF EXISTS check_missing_data();
CREATE OR REPLACE FUNCTION check_missing_data()
RETURNS TABLE (
    table_name          TEXT,
    column_name         TEXT,
    total_rows          BIGINT,
    missing_count       BIGINT,
    missing_percentage  NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 'dim_countries', 'country_name', COUNT(*), COUNT(*) FILTER (WHERE country_name IS NULL), ROUND(COUNT(*) FILTER (WHERE country_name IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_countries UNION ALL
    SELECT 'dim_countries', 'region_id', COUNT(*), COUNT(*) FILTER (WHERE region_id IS NULL), ROUND(COUNT(*) FILTER (WHERE region_id IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_countries UNION ALL
    SELECT 'dim_indicators', 'indicator_name', COUNT(*), COUNT(*) FILTER (WHERE indicator_name IS NULL), ROUND(COUNT(*) FILTER (WHERE indicator_name IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_indicators UNION ALL
    SELECT 'dim_time', 'decade', COUNT(*), COUNT(*) FILTER (WHERE decade IS NULL), ROUND(COUNT(*) FILTER (WHERE decade IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_time UNION ALL
    SELECT 'dim_regions', 'region_name', COUNT(*), COUNT(*) FILTER (WHERE region_name IS NULL), ROUND(COUNT(*) FILTER (WHERE region_name IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_regions UNION ALL
    SELECT 'dim_income_groups', 'label', COUNT(*), COUNT(*) FILTER (WHERE label IS NULL), ROUND(COUNT(*) FILTER (WHERE label IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_income_groups UNION ALL
    SELECT 'dim_units', 'unit_name', COUNT(*), COUNT(*) FILTER (WHERE unit_name IS NULL), ROUND(COUNT(*) FILTER (WHERE unit_name IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_units UNION ALL
    SELECT 'dim_sources', 'source_name', COUNT(*), COUNT(*) FILTER (WHERE source_name IS NULL), ROUND(COUNT(*) FILTER (WHERE source_name IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM dim_sources UNION ALL
    SELECT 'fact_economic_data', 'value', COUNT(*), COUNT(*) FILTER (WHERE value IS NULL), ROUND(COUNT(*) FILTER (WHERE value IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM fact_economic_data UNION ALL
    SELECT 'fact_exchange_rates', 'usd_exchange_rate', COUNT(*), COUNT(*) FILTER (WHERE usd_exchange_rate IS NULL), ROUND(COUNT(*) FILTER (WHERE usd_exchange_rate IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM fact_exchange_rates UNION ALL
    SELECT 'fact_country_income', 'income_group_id', COUNT(*), COUNT(*) FILTER (WHERE income_group_id IS NULL), ROUND(COUNT(*) FILTER (WHERE income_group_id IS NULL)::NUMERIC / NULLIF(COUNT(*),0)*100,2) FROM fact_country_income;
END;
$$;

CREATE TABLE IF NOT EXISTS audit_log (
    log_id            SERIAL PRIMARY KEY,
    table_name        VARCHAR(50) NOT NULL,
    action            VARCHAR(10) NOT NULL,     
    missing_records   INTEGER,
    status            VARCHAR(10),
    performed_by      VARCHAR(50) DEFAULT CURRENT_USER,
    action_timestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT check_audit_action CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'AUDIT'))
);

DROP PROCEDURE IF EXISTS pr_audit_data_quality();
CREATE OR REPLACE PROCEDURE pr_audit_data_quality()
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_missing BIGINT := 0; 
    v_status TEXT;
BEGIN
    SELECT COALESCE(SUM(missing_count), 0) INTO v_total_missing FROM check_missing_data();
    v_status := CASE WHEN v_total_missing = 0 THEN 'PASSED' ELSE 'FAILED' END;

    INSERT INTO audit_log (table_name, action, missing_records, status, performed_by)
    VALUES ('ALL_TABLES', 'AUDIT', v_total_missing, v_status, CURRENT_USER);

    RAISE NOTICE '====================================================';
    RAISE NOTICE '           AUDIT DATA QUALITY COMPLETED';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'Total missing records : %', v_total_missing;
    RAISE NOTICE 'Final Status          : %', v_status;
    RAISE NOTICE 'Log recorded by       : %', CURRENT_USER;
    RAISE NOTICE '====================================================';
END;
$$;

CREATE OR REPLACE FUNCTION fn_log_all_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, action, missing_records, status, performed_by, action_timestamp)
    VALUES (
        TG_TABLE_NAME,                 
        TG_OP,                          
        0,                             
        'AUTO_LOG',                    
        CURRENT_USER,                   
        CURRENT_TIMESTAMP               
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN 
        SELECT c.relname AS table_name
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public'
          AND c.relkind IN ('r', 'p') 
          AND (c.relname LIKE 'dim_%' OR c.relname LIKE 'fact_%')
          AND c.relname != 'audit_log'
          AND c.relispartition = false 
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_changes ON %I', t);
        
        EXECUTE format('CREATE TRIGGER trg_audit_changes 
                        AFTER INSERT OR UPDATE OR DELETE ON %I 
                        FOR EACH ROW EXECUTE FUNCTION fn_log_all_changes()', t);
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE pr_regression_cross_sectional(
    p_mode TEXT,        
    p_year INT,        
    p_y TEXT,           
    p_x1 TEXT,          
    p_x2 TEXT DEFAULT NULL 
)
LANGUAGE plpgsql AS $$
DECLARE
    id_y INT; id_x1 INT; id_x2 INT; name_y TEXT; name_x1 TEXT; name_x2 TEXT;
    b1 NUMERIC; b2 NUMERIC; r2 NUMERIC; obs INT;
    se1 NUMERIC; se2 NUMERIC; t1 NUMERIC; t2 NUMERIC;
BEGIN
    SELECT indicator_id, indicator_name INTO id_y, name_y FROM dim_indicators WHERE indicator_name ILIKE '%' || p_y || '%' LIMIT 1;
    SELECT indicator_id, indicator_name INTO id_x1, name_x1 FROM dim_indicators WHERE indicator_name ILIKE '%' || p_x1 || '%' LIMIT 1;
    
    IF p_mode = 'simple' THEN
        SELECT COUNT(*), REGR_SLOPE(y.value, x1.value), REGR_R2(y.value, x1.value),
               (SQRT((REGR_SYY(y.value, x1.value) - (POWER(REGR_SXY(y.value, x1.value), 2) / REGR_SXX(y.value, x1.value))) / (COUNT(*) - 2)) / SQRT(REGR_SXX(y.value, x1.value)))
        INTO obs, b1, r2, se1 FROM fact_economic_data y JOIN fact_economic_data x1 ON y.country_id = x1.country_id AND y.year_id = x1.year_id
        WHERE y.year_id = p_year AND y.indicator_id = id_y AND x1.indicator_id = id_x1;
        t1 := b1 / NULLIF(se1, 0);
    ELSE
        SELECT indicator_id, indicator_name INTO id_x2, name_x2 FROM dim_indicators WHERE indicator_name ILIKE '%' || p_x2 || '%' LIMIT 1;
        WITH ds AS (
            SELECT y.value AS y_v, x1.value AS x1_v, x2.value AS x2_v FROM fact_economic_data y 
            JOIN fact_economic_data x1 ON y.country_id = x1.country_id AND y.year_id = x1.year_id
            JOIN fact_economic_data x2 ON y.country_id = x2.country_id AND y.year_id = x2.year_id
            WHERE y.year_id = p_year AND y.indicator_id = id_y AND x1.indicator_id = id_x1 AND x2.indicator_id = id_x2
        )
        SELECT COUNT(*), REGR_SLOPE(y_v, x1_v), REGR_SLOPE(y_v, x2_v), REGR_R2(y_v, x1_v),
               (SQRT((REGR_SYY(y_v, x1_v) - (POWER(REGR_SXY(y_v, x1_v), 2) / REGR_SXX(y_v, x1_v))) / (COUNT(*) - 2)) / SQRT(REGR_SXX(y_v, x1_v))),
               (SQRT((REGR_SYY(y_v, x2_v) - (POWER(REGR_SXY(y_v, x2_v), 2) / REGR_SXX(y_v, x2_v))) / (COUNT(*) - 2)) / SQRT(REGR_SXX(y_v, x2_v)))
        INTO obs, b1, b2, r2, se1, se2 FROM ds;
        t1 := b1 / NULLIF(se1, 0); t2 := b2 / NULLIF(se2, 0);
    END IF;

    RAISE NOTICE '--------------------------------------------------------------------------';
    RAISE NOTICE ' CROSS-SECTIONAL % | Year: % | Obs: %', UPPER(p_mode), p_year, obs;
    RAISE NOTICE ' Variable       |  Coefficient  |  Std. Err.  |     t     ';
    RAISE NOTICE '----------------+---------------+-------------+-----------';
    RAISE NOTICE ' % |  % |  % |  %    ', RPAD(LEFT(name_x1, 14), 14), LPAD(ROUND(b1, 4)::TEXT, 12), LPAD(ROUND(se1, 4)::TEXT, 11), LPAD(ROUND(t1, 2)::TEXT, 9);
    IF p_mode = 'multiple' THEN
        RAISE NOTICE ' % |  % |  % |  %  ', RPAD(LEFT(name_x2, 14), 14), LPAD(ROUND(b2, 4)::TEXT, 12), LPAD(ROUND(se2, 4)::TEXT, 11), LPAD(ROUND(t2, 2)::TEXT, 9);
    END IF;
    RAISE NOTICE ' R-squared      =  %', ROUND(r2, 4);
END; $$;


CALL pr_audit_data_quality();
SELECT * FROM check_missing_data();

CALL pr_regression_cross_sectional('simple', 2023, 'GDP', 'Inflation');
CALL pr_regression_cross_sectional('multiple', 2023, 'GDP', 'Inflation', 'Foreign direct');

INSERT INTO dim_units (unit_name) VALUES ('Test unit');
UPDATE dim_units SET unit_name = 'Test unit 2' WHERE unit_name = 'Test unit';
DELETE FROM dim_units WHERE unit_name = 'Test unit 2';

SELECT * FROM audit_log

