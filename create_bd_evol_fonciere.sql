-- 1) préparation : duplication temporaire des tables uf creees/detruites
drop table if exists fd94.ufd;
drop table if exists fd94.ufc;
create table fd94.ufd as select * from fd94.pnb_uf_destroyed;
create table fd94.ufc as select * from fd94.pnb_uf_created;

-- 2) création de la table des périmètres d'opération multimillésimes
drop table if exists fd94.pnb_per_multi;
create table if not exists fd94.pnb_per_multi (
	idper serial NOT NULL,
	annee int,
	nufe int,
	nufs int,
	surfe int,
	surfs int,
	idufe_l varchar(25)[],
	idufs_l varchar(25)[],
	typetxt varchar(10),
	geom geometry
	);

alter table fd94.pnb_per_multi add primary key (idper);
create index pnb_per_multi_idx on fd94.pnb_per_multi (idper);
create index pnb_per_multi_geom_idx on fd94.pnb_per_multi using gist (geom);


-- 3) recherche des divisions parfaites
insert into fd94.pnb_per_multi (annee, nufe, nufs, idufe_l, idufs_l, surfe, surfs, typetxt, geom)
	select d.annee, 1 nufe, count(c.iduf) nufs, 
		array[d.iduf] idufe_l, array_agg(c.iduf) idufs_l,
		st_area(d.geom) surfe, st_area(st_union(st_accum(c.geom))) surfs, 'DIV',
		st_union(st_accum(c.geom)) geom
	from fd94.ufc c, fd94.ufd d
	where st_contains(d.geom, c.geom) and
		not st_equals(c.geom, d.geom) and c.annee=d.annee
	group by d.annee, d.geom, d.iduf
	having st_equals(d.geom, st_union(st_accum(c.geom)));

-- 4) suppression des divisions parfaites dans les tables ufc et ufd
delete from fd94.ufd
where iduf in (
	select d.iduf
	from fd94.ufc c, fd94.ufd d
	where st_contains(d.geom, c.geom) and
		not st_equals(c.geom, d.geom) and c.annee=d.annee
	group by d.annee, d.geom, d.iduf
	having st_equals(d.geom, st_union(st_accum(c.geom)))
	);
delete from fd94.ufc
where iduf in (
	select c.iduf
	from fd94.ufc c, fd94.pnb_per_multi d
	where st_contains(d.geom, c.geom) and
		not st_equals(c.geom, d.geom) and c.annee=d.annee
	);

-- 5) recherche des fusions parfaites
insert into fd94.pnb_per_multi (annee, nufe, nufs, idufe_l, idufs_l, surfe, surfs, typetxt, geom)
	select c.annee, count(c.iduf) nufe, 1 nufs, 
		array_agg(d.iduf) idufe_l, array[c.iduf] idufs_l, 
		st_area(st_union(st_accum(d.geom))) surfe, st_area(c.geom) surfe, 'FUS',
		st_union(st_accum(d.geom)) geom
	from fd94.ufc c, fd94.ufd d
	where st_contains(c.geom, d.geom) and
		not st_equals(c.geom, d.geom) and c.annee=d.annee
	group by c.annee, c.geom, c.iduf
	having st_equals(c.geom, st_union(st_accum(d.geom)));

-- 6) suppression des fusions parfaites dans les tables ufc et ufd
delete from fd94.ufc
where iduf in (
	select c.iduf
	from fd94.ufc c, fd94.ufd d
	where st_contains(c.geom, d.geom) and
		not st_equals(c.geom, d.geom) and c.annee=d.annee
	group by c.annee, c.geom, c.iduf
	having st_equals(c.geom, st_union(st_accum(d.geom)))
	);
delete from fd94.ufd
where iduf in (
	select d.iduf
	from fd94.ufd d, fd94.pnb_per_multi c
	where st_contains(c.geom, d.geom) and
		not st_equals(c.geom, d.geom) and c.annee=d.annee
	);


-------------------------------------------
-- traitement des opérations imparfaites --
-------------------------------------------

-- 7) création des périmètres non parfaits
drop table if exists fd94.pnb_per_created;
create table if not exists fd94.pnb_per_created (
	idper serial,
	annee int,
	geom geometry
	);

alter table fd94.pnb_per_created add primary key (idper);
create index pnb_per_created_idx on fd94.pnb_per_created (idper);
create index pnb_per_created_geom_idx on fd94.pnb_per_created using gist (geom);


drop table if exists fd94.pnb_per_destroyed;
create table if not exists fd94.pnb_per_destroyed (
	idper serial,
	annee int,
	geom geometry
	);

alter table fd94.pnb_per_destroyed add primary key (idper);
create index pnb_per_destroyed_idx on fd94.pnb_per_destroyed (idper);
create index pnb_per_destroyed_geom_idx on fd94.pnb_per_destroyed using gist (geom);


insert into fd94.pnb_per_created (annee, geom)
	select annee, (st_dump(st_union(st_accum(geom)))).geom geom
	from fd94.ufc
	group by annee;

insert into fd94.pnb_per_destroyed (annee, geom)
	select annee, (st_dump(st_union(st_accum(geom)))).geom geom
	from fd94.ufd
	group by annee;

insert into fd94.pnb_per_multi (annee, geom)
	select annee, (st_dump(st_union(st_accum(geom)))).geom geom
	from (
		select annee, geom 
		from fd94.pnb_per_created	
		  union
		select annee, geom 
		from fd94.pnb_per_destroyed
		) foo
	group by annee;



-- division foncière imparfaite
update fd94.pnb_per_multi p
set nufe=1, nufs=c, idufe_l=array[iduf], idufs_l=iduf_l, typetxt='DIV',
	surfe=cast(st_area(foo.geomd) as int), surfs=cast(st_area(foo.geom) as int)
from (
	select p1.annee, p1.geom geomp, d.iduf iduf, d.geom geomd, count(c.iduf) c, 
		array_agg(c.iduf) iduf_l, st_union(st_accum(c.geom)) geom
	from fd94.pnb_per_multi p1, fd94.ufd d, fd94.ufc c
	where p1.annee=c.annee and p1.annee=d.annee and
		st_area(d.geom)>0.95*st_area(p1.geom) and
		st_contains(p1.geom, d.geom) and
		st_contains(p1.geom, c.geom) --and
	group by p1.geom, p1.annee, d.iduf, d.geom
	having st_area(st_union(st_accum(c.geom)))>0.95*st_area(p1.geom) --and
	) foo
where p.annee=foo.annee and 
	p.geom=foo.geomp;

-- fusion foncière imparfaite
update fd94.pnb_per_multi p
set nufe=c, nufs=1, idufe_l=iduf_l, idufs_l=array[iduf], typetxt='FUS',
	surfe=cast(st_area(foo.geom) as int), surfs=cast(st_area(foo.geomc) as int)
from (
	select p1.annee, p1.geom geomp, c.iduf iduf, c.geom geomc, count(d.iduf) c, 
		array_agg(d.iduf) iduf_l, st_union(st_accum(d.geom)) geom
	from fd94.pnb_per_multi p1, fd94.ufd d, fd94.ufc c
	where p1.annee=c.annee and p1.annee=d.annee and
		st_area(c.geom)>0.95*st_area(p1.geom) and
		st_contains(p1.geom, c.geom) and
		st_contains(p1.geom, d.geom)
	group by p1.geom, p1.annee, c.iduf, c.geom
	having st_area(st_union(st_accum(d.geom)))>0.95*st_area(p1.geom)
	) foo
where p.annee=foo.annee and 
	p.geom=foo.geomp;


-- autres opérations
update fd94.pnb_per_multi p
set nufs=foo.nufs, idufs_l=foo.idufs_l, typetxt='AUTRE',
	surfs=cast(st_area(foo.geom) as int)
from (
	select p1.annee, p1.geom geomp, array_agg(c.iduf) idufs_l, count(c.iduf) nufs,
		st_union(st_accum(c.geom)) geom
	from fd94.pnb_per_multi p1, fd94.ufc c
	where p1.annee=c.annee and st_contains(p1.geom, c.geom)
	group by p1.geom, p1.annee
	) foo
where p.annee=foo.annee and p.geom=foo.geomp;

update fd94.pnb_per_multi p
set nufe=foo.nufe, idufe_l=foo.idufe_l, surfe=cast(st_area(foo.geom) as int)
from (
	select p1.annee, p1.geom geomp, array_agg(d.iduf) idufe_l, count(d.iduf) nufe,
		st_union(st_accum(d.geom)) geom
	from fd94.pnb_per_multi p1, fd94.ufd d
	where p1.annee=d.annee and st_contains(p1.geom, d.geom)
	group by p1.geom, p1.annee
	) foo
where p.annee=foo.annee and p.geom=foo.geomp;


----------------------------------------
-- suppression des tables temporaires --
----------------------------------------
drop table fd94.ufc;
drop table fd94.ufd;




-- -- autre remembrement
-- update fd94.pnb_per_multi p
-- set nufe=foo.nufe, nufs=foo.nufs, idufe_l=foo.idufe_l, idufs_l=foo.idufs_l, typetxt='AUTRE',
-- 	surfe=cast(st_area(geome) as int), surfs=cast(st_area(geoms) as int)
-- from (
-- 	select p1.annee, p1.geom geomp, 
-- 		array_agg(d.iduf) idufe_l, count(d.iduf) nufe, st_union(st_accum(d.geom)) geome,
-- 		array_agg(c.iduf) idufs_l, count(c.iduf) nufs, st_union(st_accum(c.geom)) geoms
-- 	from (select *
-- 		from fd94.pnb_per_multi
-- 		except
-- 		select *
-- 		from fd94.pnb_per_multi
-- 		where idufe_l is not null) p1,
-- 		fd94.ufd d, 
-- 		fd94.ufc c
-- 	where p1.annee=c.annee and p1.annee=d.annee and
-- 		st_contains(p1.geom, c.geom) and
-- 		st_contains(p1.geom, d.geom)
-- 	group by p1.geom, p1.annee
-- 	) foo
-- where p.annee=foo.annee and 
-- 	p.geom=foo.geomp;
-- 	
-- update fd94.pnb_per_multi p
-- set nufe=foo.nufe, idufe_l=foo.idufe_l, typetxt='AUTRE',
-- 	surfe=cast(st_area(geome) as int)
-- from (
-- 	select p1.annee, p1.geom geomp, 
-- 		array_agg(d.iduf) idufe_l, count(d.iduf) nufe, st_union(st_accum(d.geom)) geome
-- 	from (select *
-- 		from fd94.pnb_per_multi
-- 		except
-- 		select *
-- 		from fd94.pnb_per_multi
-- 		where idufe_l is not null) p1,
-- 		fd94.ufd d
-- 	where  p1.annee=d.annee and
-- 		st_contains(p1.geom, d.geom)
-- 	group by p1.geom, p1.annee
-- 	) foo
-- where p.annee=foo.annee and 
-- 	p.geom=foo.geomp;
-- 
-- update fd94.pnb_per_multi p
-- set nufs=foo.nufs, idufs_l=foo.idufs_l, typetxt='AUTRE',
-- 	surfs=cast(st_area(geoms) as int)
-- from (
-- 	select p1.annee, p1.geom geomp, 
-- 		array_agg(c.iduf) idufs_l, count(c.iduf) nufs, st_union(st_accum(c.geom)) geoms
-- 	from (select *
-- 		from fd94.pnb_per_multi
-- 		except
-- 		select *
-- 		from fd94.pnb_per_multi
-- 		where idufe_l is not null) p1,
-- 		fd94.pnb_uf_created c
-- 	where p1.annee=c.annee and
-- 		st_contains(p1.geom, c.geom)
-- 	group by p1.geom, p1.annee
-- 	) foo
-- where p.annee=foo.annee and 
-- 	p.geom=foo.geomp;
