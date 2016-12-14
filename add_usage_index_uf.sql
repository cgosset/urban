alter table fd94.pnb_uf_2013
add column idusage4 int;

alter table fd94.pnb_uf_2013
add column idusage8 int;

alter table fd94.pnb_uf_2013
add column idusage16 int;

WITH classe4 AS (
	SELECT 	iduf,
		CASE nlocmaison+nlocappt WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nloccom WHEN 0 THEN 0 ELSE 1 END AS c2
	FROM fd94.pnb_uf_2013
	),
	classe8 AS (
	SELECT 	iduf,
		CASE nlocmaison WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nlocappt WHEN 0 THEN 0 ELSE 1 END   AS c2, 
		CASE nloccom WHEN 0 THEN 0 ELSE 1 END    AS c4
	FROM fd94.pnb_uf_2013
	),
	classe16 AS (
	SELECT 	iduf,
		CASE nlocdep WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nlocmaison WHEN 0 THEN 0 ELSE 1 END AS c2, 
		CASE nlocappt WHEN 0 THEN 0 ELSE 1 END   AS c4, 
		CASE nloccom WHEN 0 THEN 0 ELSE 1 END    AS c8
	FROM fd94.pnb_uf_2013
	)
UPDATE fd94.pnb_uf_2013 u
SET idusage4=foo.idusage4, idusage8=foo.idusage8, idusage16=foo.idusage16
FROM (
	SELECT 
		u1.iduf as iduf,
		us1.idusage as idusage4,
		us2.idusage as idusage8,
		us3.idusage as idusage16
	FROM 
		classe4 c1, classe8 c2, classe16 c3,
		fd94.usage_4classes us1, fd94.usage_8classes us2, fd94.usage_16classes us3,
		fd94.pnb_uf_2013 u1
	WHERE 
		u1.iduf=c1.iduf AND u1.iduf=c2.iduf AND u1.iduf=c3.iduf
		AND c1.c1 + 2*c1.c2 = us1.idusage 
		AND c2.c1 + 2*c2.c2 + 4*c2.c4= us2.idusage
		AND c3.c1 + 2*c3.c2 + 4*c3.c4 + 8*c3.c8 = us3.idusage
	) AS foo
WHERE foo.iduf=u.iduf
