CREATE OR REPLACE FUNCTION create_histogram(dataname text, datacol text, start real, stop real, spacing real, outtab text)
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
	EXECUTE 'DROP TABLE bintmp CASCADE;';
END
$BODY$
LANGUAGE plpgsql;
