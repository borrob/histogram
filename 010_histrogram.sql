CREATE OR REPLACE FUNCTION create_bins(start real, stop real, spacing real, tabname text)
RETURNS VOID AS
$BODY$
BEGIN
	EXECUTE 'DROP TABLE IF EXISTS '||$4||' CASCADE;';
	EXECUTE 'CREATE TABLE '||$4|| ' AS
		SELECT
			generate_series(1,('||$2||' - '||$1||')/'||$3||'+2) AS bin,
			' ||$1||' + '||$3||'*generate_series(0,('||$2||' - '||$1||')/'||$3||'+1) AS binval
	;';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_bin_idx ON '||$4|| ' (bin);';
	EXECUTE 'CREATE UNIQUE INDEX '||REPLACE($4,'.','_')||'_binval_idx ON '||$4|| ' (binval);';
END
$BODY$
LANGUAGE plpgsql;
