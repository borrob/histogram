histogram
=========

A postgresql function to generate a histogram. It takes the data from the given table, makes a temp table to generate the bins (user can provide start and stop values and the binwidth) and generates a new table with the histogram.

install
-------
Execute the sql file. This will create two functions: one that creates the histogram and one helper function.

howto
-----
Use an SQL statement to call the function:

    SELECT create_histogram(dataname, datacol, start, stop, spacing, outtab);

where:
	dataname: table with the daa
	datacol: columnname you want the histogram from
	start: starting value of the histogram
	stop: stop value of the histogram
	spacing: binwidth
	outtab: name for the output table

Please note that the dataname, datacol and outtab need to have quotes around them because they are strings.

example
-------
Create a table with data:

```
DROP TABLE IF EXISTS histogram_data CASCADE;
CREATE TABLE histogram_data
(
	id SERIAL PRIMARY KEY,
	val real
);

INSERT INTO histogram_data (val) SELECT random()*100 FROM generate_series(1,100);
```
Create the histogram:

```
SELECT create_histogram('histogram_data','val',0,100,2,'histogram');
```
