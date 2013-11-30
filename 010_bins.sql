CREATE OR REPLACE FUNCTION create_bins(start double precision, stop double precision, spacing double precision, tabname text)
RETURNS VOID AS
$BODY$
BEGIN
	EXECUTE 'DROP TABLE IF EXISTS '||$4||' CASCADE;';
	EXECUTE 'CREATE TABLE '||$4|| ' AS
		SELECT
			generate_series(1,('||$2||' - '||$1||')/'||$3||'+2) AS bin,
			' ||$1||' + '||$3||'*generate_series(0,('||$2||' - '||$1||')/'||$3||'+1)::double precision AS binval_low,
			' ||$1||' + '||$3||'*generate_series(1,('||$2||' - '||$1||')/'||$3||'+2)::double precision AS binval_high
	;';
	EXECUTE 'UPDATE '||$4||' SET binval_low=''-Infinity'' WHERE bin=1;';
	EXECUTE 'UPDATE '||$4||' SET binval_high=''Infinity'' WHERE bin='||($2 - $1)/$3+2||';';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_bin_idx ON '||$4|| ' (bin);';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_binvallow_idx ON '||$4|| ' (binval_low);';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_binvalhigh_idx ON '||$4|| ' (binval_high);';
END
$BODY$
LANGUAGE plpgsql;
