drop table if exists fd94.pnb_uf_2013;
create table fd94.pnb_uf_2013 as
	with 
	uf as (
		select (st_dump(ST_Union(ST_Accum(geompar)))).geom geom
		from fd94.pnb_par_2013
		where vecteur='V'
		group by idprocpte
		)
	select
		concat(max(idpar), count(idpar), cast(avg(st_area(geompar)) as int)) iduf,
		max(idpar) idpar,
		2013 annee,
		array_agg(idpar) idpar_l,	-- array des idpar constituant l'uf
		count(idpar) npar,  		-- nombre de parcelles composant l'UF
		sum(nlocal) nlocal,
		sum(nlocmaison) nlocmaison,
		sum(nlocappt) nlocappt,
		sum(nloccom) nloccom,
		sum(nloccomrdc) nloccomrdc,
		sum(nloccomter) nloccomter,
		sum(nloccomsec) nloccomsec,
		sum(nlocdep) nlocdep,
		sum(nlocburx) nlocburx,
		sum(npevph) npevph,
		sum(stoth) stoth,
		sum(stotdsueic) stotdsueic,
		sum(nhabvacant) nhabvacant,
		sum(nactvacant) nactvacant,
		sum(nloghlm) nloghlm,
		sum(npevp) npevp, -- nb pev professionnelles
		sum(stotp) stotp, -- surf total des pev pro
		sum(npevd) npevd, -- nb pev dependance
		sum(stotd) stotd, -- surf tot dep
		sum(spevtot) spevtot,
		sum(nlot) nlot, -- somme des lots de copropriété
		geom
	from uf, fd94.pnb_par_2013 p
	where st_contains(uf.geom, geompar)
	group by geom
;

-- création d'un index spatial
CREATE INDEX pnb_uf_2013_geompar_idx
  ON fd94.pnb_uf_2013
  USING gist
  (geom);

-- suppression des inclusions (méthode non optimale)
delete from fd94.pnb_uf_2013
where geom in (
	select p2.geom
	from fd94.pnb_uf_2013 p1, fd94.pnb_uf_2013 p2
	where st_contains(p1.geom,p2.geom) and not st_equals(p1.geom, p2.geom)
	);
delete from fd94.pnb_uf_2013
where idpar in (
	select idpar
	from fd94.pnb_uf_2013
	group by idpar
	having count(idpar)>1
	);

-- création d'une clé primaire et d'un index sur cette clé
ALTER TABLE fd94.pnb_uf_2013 ADD PRIMARY KEY (idpar);

CREATE INDEX pnb_uf_2013_idpar_idx ON fd94.pnb_uf_2013 (idpar);

-- création du champ idprocpte
alter table fd94.pnb_uf_2013
add column idprocpte varchar(11);

-- maj du champ idprocpte
update fd94.pnb_uf_2013 u
set idprocpte=p.idprocpte
from fd94.pnb_par_2013 p
where u.idpar=p.idpar;


-- creation de colonnes caractérisant l'usage en 4, 8 et 16 classes
alter table fd94.pnb_uf_2013
add column idusage4 int;

alter table fd94.pnb_uf_2013
add column idusage8 int;

alter table fd94.pnb_uf_2013
add column idusage16 int;

-- maj des colonnes de caractérisation des usages
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
WHERE foo.iduf=u.iduf;
