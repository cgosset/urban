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
		count(idpar) npar,  -- nombre de parcelles composant l'UF
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

delete from fd94.pnb_uf_2013
where (idpar, geom) in (
	select uf.idpar, uf.geom
	from (
		select idpar, max(nlocal) nloc, max(npar) npar, max(st_area(geom)) surf
		from fd94.pnb_uf_2013
		group by idpar
		having count(*)>1
		) foo,
		fd94.pnb_uf_2013 uf
	where uf.idpar=foo.idpar
	except
	select uf.idpar, uf.geom
	from (
		select idpar, max(nlocal) nloc, max(npar) npar, max(st_area(geom)) surf
		from fd94.pnb_uf_2013
		group by idpar
		having count(*)>1
		) foo,
		fd94.pnb_uf_2013 uf
	where uf.idpar=foo.idpar and foo.nloc=uf.nlocal and foo.npar=uf.npar and surf=st_area(uf.geom)
	);


ALTER TABLE fd94.pnb_uf_2013 ADD PRIMARY KEY (idpar);

CREATE INDEX pnb_uf_2013_idpar_idx ON fd94.pnb_uf_2013 (idpar);

CREATE INDEX pnb_uf_2013_geompar_idx
  ON fd94.pnb_uf_2013
  USING gist
  (geom);

