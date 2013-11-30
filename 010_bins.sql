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
