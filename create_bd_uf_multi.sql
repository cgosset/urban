-- créations des tables multimillésimes des UF et parcelles à partir du millésime 2014
-- contient les UF et parcelles de tous les millésimes

drop table if exists fd94.pnb_uf_multi;
create table fd94.pnb_uf_multi as
	select *
	from fd94.pnb_uf_2014;

CREATE INDEX pnb_uf_multi_geom_idx
  ON fd94.pnb_uf_multi
  USING gist (geom);

alter table fd94.pnb_uf_multi
add primary key (iduf, annee);

drop table if exists fd94.pnb_par_created;
create table fd94.pnb_par_created as
	select idpar, 2014
	from fd94.pnb_par_2014
	where idpar in (
		select idpar from fd94.pnb_par_2014
		  except
		select idpar from fd94.pnb_par_2013
		);

drop table if exists fd94.pnb_par_destroyed;
create table fd94.pnb_par_destroyed as
	select idpar, 2014
	from fd94.pnb_par_2013
	where idpar in (
		select idpar from fd94.pnb_par_2013
		  except
		select idpar from fd94.pnb_par_2014
		);

drop table if exists fd94.pnb_uf_created;
create table fd94.pnb_uf_created as
	select iduf, 2014
	from fd94.pnb_uf_2014
	where iduf in (
		select iduf from fd94.pnb_uf_2014
		  except
		select iduf from fd94.pnb_uf_2013
		);

drop table if exists fd94.pnb_uf_destroyed;
create table fd94.pnb_uf_destroyed as
	select iduf, 2014
	from fd94.pnb_uf_2013
	where iduf in (
		select iduf from fd94.pnb_uf_2013
		  except
		select iduf from fd94.pnb_uf_2014
		);

alter table fd94.pnb_par_created
add primary key (idpar);
alter table fd94.pnb_par_destroyed
add primary key (idpar);
alter table fd94.pnb_uf_created
add primary key (iduf);
alter table fd94.pnb_uf_destroyed
add primary key (iduf);
	
