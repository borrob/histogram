------ HELPER FUNCTION TO CREATE BINS

CREATE OR REPLACE FUNCTION create_bins(start double precision, stop double precision, spacing double precision, tabname text)
RETURNS VOID AS
$BODY$
BEGIN
	EXECUTE 'DROP TABLE IF EXISTS '||$4||' CASCADE;';
	EXECUTE 'CREATE TABLE '||$4|| ' AS
		SELECT
			generate_series(1, ceil(' || ($2-$1)/$3||')::integer) AS bin,
			' ||$1||' + '||$3||'*generate_series(0,ceil('||($2-$1)/$3||')::integer-1)::double precision AS binval_low,
			' ||$1||' + '||$3||'*generate_series(1,ceil('||($2-$1)/$3||')::integer)::double precision AS binval_high
	;';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_bin_idx ON '||$4|| ' (bin);';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_binvallow_idx ON '||$4|| ' (binval_low);';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_binvalhigh_idx ON '||$4|| ' (binval_high);';
END
$BODY$
LANGUAGE plpgsql;

------ FUNCTION FOR HISTOGRAM

CREATE OR REPLACE FUNCTION create_histogram(dataname text, datacol text, start real, stop real, spacing real, outtab text)
-- dataname: tablename with the data
-- datacol: columns with the data to build a histogram with
-- start: lowest binvalue for histogram
-- stop: highest binvalue for histogram
-- spacing: binwidth of histrogram
-- outtab: outputtable for the histogram (overwrite)
RETURNS VOID AS
$BODY$
BEGIN
	--function creates table for bins and makes the histogram
	--TODO: check if stop>start
	EXECUTE 'SELECT CREATE_BINS('||$3||','||$4||','||$5||',''bintmp'');';
	EXECUTE 'DROP TABLE IF EXISTS '||$6|| ' CASCADE;';
	EXECUTE 'CREATE TABLE ' ||$6|| ' AS
		SELECT
			b.bin AS bin,
			b.binval_low AS binval_low,
			b.binval_high AS binval_high,
			count(*)  AS histogram
		FROM
			'||$1||' AS d
		RIGHT JOIN bintmp AS b
		ON
			d.'||$2||' >= b.binval_low
		AND
			d.' ||$2||' <b.binval_high
		GROUP BY
			b.bin,
			b.binval_low,
			b.binval_high
		ORDER BY
			bin
		;';
	--cleanup
	EXECUTE 'DROP TABLE bintmp CASCADE;';
END
$BODY$
LANGUAGE plpgsql;
