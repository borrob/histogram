--Create a schema and use demodata
DROP SCHEMA IF EXISTS histogram;
CREATE SCHEMA histogram;
COMMENT ON SCHEMA histogram IS 'Example for the histogram tool';

DROP TABLE IF EXISTS histogram.data CASCADE;
CREATE TABLE histogram.data
(
	id SERIAL PRIMARY KEY,
	val real
);

INSERT INTO histogram.data (val) SELECT random()*100 FROM generate_series(1,100);
