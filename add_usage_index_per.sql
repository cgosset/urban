------------------------------------------------------
-- creation de la table des perimetres d'operation  --
------------------------------------------------------
drop table if exists fd94.usage_per_multi;
create table fd94.usage_per_multi (
	idper int,
	annee int,
	us4_av int,
	us8_av int,
	us16_av int,
	npar_av int,
	nlocal_av int,
	nlocmaison_av int,
	nlocappt_av int,
	nloclog_av int,
	nloccom_av int,
	nlocdep_av int,
	npevph_av int,
	stoth_av int,
	npevp_av int,
	stotp_av int,
	npevd_av int,
	stotd_av int,
	spevtot_av int,
	us4_ap int,
	us8_ap int,
	us16_ap int,
	npar_ap int,
	nlocal_ap int,
	nlocmaison_ap int,
	nlocappt_ap int,
	nloclog_ap int,
	nloccom_ap int,
	nlocdep_ap int,
	npevph_ap int,
	stoth_ap int,
	npevp_ap int,
	stotp_ap int,
	npevd_ap int,
	stotd_ap int,
	spevtot_ap int,
	typetxt varchar(10)
	);
	
---------------------------------------------------------------
-- usage des perimetres d'operation avant evolution fonciere --
---------------------------------------------------------------

-- traitement des divisions
insert into fd94.usage_per_multi (
	idper,
	annee ,
	us4_av ,
	us8_av ,
	us16_av ,
	npar_av ,
	nlocal_av ,
	nlocmaison_av ,
	nlocappt_av ,
	nloclog_av ,
	nloccom_av ,
	nlocdep_av ,
	npevph_av ,
	stoth_av ,
	npevp_av ,
	stotp_av ,
	npevd_av ,
	stotd_av ,
	spevtot_av,
	typetxt)
	select
		p.idper ,
		p.annee ,
		u.idusage4,
		u.idusage8,
		u.idusage16,
		u.npar ,
		u.nlocal ,
		u.nlocmaison ,
		u.nlocappt,
		u.nloclog ,
		u.nloccom ,
		u.nlocdep ,
		u.npevph ,
		u.stoth ,
		u.npevp ,
		u.stotp ,
		u.npevd ,
		u.stotd ,
		u.spevtot,
		'DIV'
	from fd94.pnb_per_multi p, fd94.pnb_uf_multi u
	where p.typetxt='DIV' and st_equals(p.geom, u.geom) and
		p.annee-1=u.annee and
		u.iduf in (select iduf from fd94.pnb_uf_destroyed);

update fd94.usage_per_multi p
set
npar_ap=npar,
nlocal_ap=nlocal,
nlocmaison_ap=nlocmaison,
nlocappt_ap=nlocappt,
nloclog_ap=nloclog,
nloccom_ap=nloccom,
nlocdep_ap=nlocdep,
npevph_ap=npevph,
stoth_ap=stoth,
npevp_ap=npevp,
stotp_ap=stotp,
npevd_ap=npevd,
stotd_ap=stotd,
spevtot_ap=spevtot
from (
	select
		p.idper,
		p.annee,
		sum(u.npar) npar,
		sum(u.nlocal) nlocal ,
		sum(u.nlocmaison) nlocmaison ,
		sum(u.nlocappt) nlocappt,
		sum(u.nloclog) nloclog ,
		sum(u.nloccom) nloccom ,
		sum(u.nlocdep) nlocdep ,
		sum(u.npevph) npevph ,
		sum(u.stoth) stoth ,
		sum(u.npevp) npevp ,
		sum(u.stotp) stotp ,
		sum(u.npevd) npevd ,
		sum(u.stotd) stotd ,
		sum(u.spevtot) spevtot
	from fd94.pnb_per_multi p, fd94.pnb_uf_multi u
	where p.typetxt='DIV' and st_contains(p.geom, u.geom) and
		p.annee=u.annee and
		u.iduf in (select iduf from fd94.pnb_uf_created)
	group by p.geom, p.idper, p.annee
	) foo
where p.idper=foo.idper and foo.annee=p.annee;

-- traitement des fusions
insert into fd94.usage_per_multi (
	idper,
	annee ,
	us4_ap ,
	us8_ap ,
	us16_ap ,
	npar_ap ,
	nlocal_ap ,
	nlocmaison_ap ,
	nlocappt_ap ,
	nloclog_ap ,
	nloccom_ap ,
	nlocdep_ap ,
	npevph_ap ,
	stoth_ap ,
	npevp_ap ,
	stotp_ap ,
	npevd_ap ,
	stotd_ap ,
	spevtot_ap,
	typetxt)
	select
		p.idper ,
		p.annee ,
		u.idusage4,
		u.idusage8,
		u.idusage16,
		u.npar ,
		u.nlocal ,
		u.nlocmaison ,
		u.nlocappt,
		u.nloclog ,
		u.nloccom ,
		u.nlocdep ,
		u.npevph ,
		u.stoth ,
		u.npevp ,
		u.stotp ,
		u.npevd ,
		u.stotd ,
		u.spevtot,
		'FUS'
	from fd94.pnb_per_multi p, fd94.pnb_uf_multi u
	where p.typetxt='FUS' and st_equals(p.geom, u.geom) and
		p.annee=u.annee and
		u.iduf in (select iduf from fd94.pnb_uf_created);

update fd94.usage_per_multi p
set
npar_av=npar,
nlocal_av=nlocal,
nlocmaison_av=nlocmaison,
nlocappt_av=nlocappt,
nloclog_av=nloclog,
nloccom_av=nloccom,
nlocdep_av=nlocdep,
npevph_av=npevph,
stoth_av=stoth,
npevp_av=npevp,
stotp_av=stotp,
npevd_av=npevd,
stotd_av=stotd,
spevtot_av=spevtot
from (
	select
		p.idper,
		p.annee,
		sum(u.npar) npar,
		sum(u.nlocal) nlocal ,
		sum(u.nlocmaison) nlocmaison ,
		sum(u.nlocappt) nlocappt,
		sum(u.nloclog) nloclog ,
		sum(u.nloccom) nloccom ,
		sum(u.nlocdep) nlocdep ,
		sum(u.npevph) npevph ,
		sum(u.stoth) stoth ,
		sum(u.npevp) npevp ,
		sum(u.stotp) stotp ,
		sum(u.npevd) npevd ,
		sum(u.stotd) stotd ,
		sum(u.spevtot) spevtot
	from fd94.pnb_per_multi p, fd94.pnb_uf_multi u
	where p.typetxt='FUS' and st_contains(p.geom, u.geom) and
		p.annee-1=u.annee and
		u.iduf in (select iduf from fd94.pnb_uf_destroyed)
	group by p.geom, p.idper, p.annee
	) foo
where p.idper=foo.idper and foo.annee=p.annee;

------------------------------------------------------------
-- maj de l'indicateur d'usage des périmètres d'operation --
------------------------------------------------------------

-- usage apres operation (division)
WITH classe4 AS (
	SELECT 	idper,
		CASE nlocmaison_ap+nlocappt_ap WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nloccom_ap WHEN 0 THEN 0 ELSE 1 END AS c2
	FROM fd94.usage_per_multi
	),
	classe8 AS (
	SELECT 	idper,
		CASE nlocmaison_ap WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nlocappt_ap WHEN 0 THEN 0 ELSE 1 END   AS c2, 
		CASE nloccom_ap WHEN 0 THEN 0 ELSE 1 END    AS c4
	FROM fd94.usage_per_multi
	),
	classe16 AS (
	SELECT 	idper,
		CASE nlocdep_ap WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nlocmaison_ap WHEN 0 THEN 0 ELSE 1 END AS c2, 
		CASE nlocappt_ap WHEN 0 THEN 0 ELSE 1 END   AS c4, 
		CASE nloccom_ap WHEN 0 THEN 0 ELSE 1 END    AS c8
	FROM fd94.usage_per_multi
	)
UPDATE fd94.usage_per_multi p
SET us4_ap=foo.idusage4, us8_ap=foo.idusage8, us16_ap=foo.idusage16
FROM (
	SELECT 
		p1.idper as idper, p1.annee,
		us1.idusage as idusage4,
		us2.idusage as idusage8,
		us3.idusage as idusage16
	FROM 
		classe4 c1, classe8 c2, classe16 c3,
		fd94.usage_4classes us1, fd94.usage_8classes us2, fd94.usage_16classes us3,
		fd94.usage_per_multi p1
	WHERE 
		p1.idper=c1.idper AND p1.idper=c2.idper AND p1.idper=c3.idper
		AND c1.c1 + 2*c1.c2 = us1.idusage 
		AND c2.c1 + 2*c2.c2 + 4*c2.c4= us2.idusage
		AND c3.c1 + 2*c3.c2 + 4*c3.c4 + 8*c3.c8 = us3.idusage
	) AS foo
WHERE foo.idper=p.idper and foo.annee=p.annee;

-- usage avant operation (fusion)
WITH classe4 AS (
	SELECT 	idper,
		CASE nlocmaison_av+nlocappt_av WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nloccom_av WHEN 0 THEN 0 ELSE 1 END AS c2
	FROM fd94.usage_per_multi
	),
	classe8 AS (
	SELECT 	idper,
		CASE nlocmaison_av WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nlocappt_av WHEN 0 THEN 0 ELSE 1 END   AS c2, 
		CASE nloccom_av WHEN 0 THEN 0 ELSE 1 END    AS c4
	FROM fd94.usage_per_multi
	),
	classe16 AS (
	SELECT 	idper,
		CASE nlocdep_av WHEN 0 THEN 0 ELSE 1 END AS c1, 
		CASE nlocmaison_av WHEN 0 THEN 0 ELSE 1 END AS c2, 
		CASE nlocappt_av WHEN 0 THEN 0 ELSE 1 END   AS c4, 
		CASE nloccom_av WHEN 0 THEN 0 ELSE 1 END    AS c8
	FROM fd94.usage_per_multi
	)
UPDATE fd94.usage_per_multi p
SET us4_av=foo.idusage4, us8_av=foo.idusage8, us16_av=foo.idusage16
FROM (
	SELECT 
		p1.idper as idper, p1.annee,
		us1.idusage as idusage4,
		us2.idusage as idusage8,
		us3.idusage as idusage16
	FROM 
		classe4 c1, classe8 c2, classe16 c3,
		fd94.usage_4classes us1, fd94.usage_8classes us2, fd94.usage_16classes us3,
		fd94.usage_per_multi p1
	WHERE 
		p1.idper=c1.idper AND p1.idper=c2.idper AND p1.idper=c3.idper
		AND c1.c1 + 2*c1.c2 = us1.idusage 
		AND c2.c1 + 2*c2.c2 + 4*c2.c4= us2.idusage
		AND c3.c1 + 2*c3.c2 + 4*c3.c4 + 8*c3.c8 = us3.idusage
	) AS foo
WHERE foo.idper=p.idper and foo.annee=p.annee;



