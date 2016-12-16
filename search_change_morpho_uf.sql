-- recherche des uf contenant des parcelles créées
-- evolution fonciere avec remembrement parcellaire (5 catégories)
drop table fd94.pnb_uf_evol_par_2013;
create table fd94.pnb_uf_evol_par_2013 as
	select iduf, idpar_l, npar
	from fd94.pnb_uf_2013
	  except
	select iduf, idpar_l, npar
	from (
		SELECT generate_subscripts(idpar_l, 1) AS s, idpar_l, iduf, npar
		FROM (select idpar_l, iduf, npar from fd94.pnb_uf_2013) bar
		) foo
	where idpar_l[s] in (select idpar from fd94.pnb_par_2012)
	group by idpar_l, iduf, npar
	having array_length(idpar_l,1)=array_length(array_agg(idpar_l[s]),1)
;
-- recherche des uf n'ayant pas été modifiée
-- méthode géométrique
create table fd94.pnb_uf_no_evol_2013 as
	select count(u1.*)
	from fd94.pnb_uf_2013 u1, fd94.pnb_uf_2012 u2
	where st_equals(u1.geom, u2.geom)
;

select count(u1.*)
from fd94.pnb_uf_2013 u1    --, fd94.pnb_uf_2012 u2
group by u1.geom, idprocpte
where st_equals(u1.geom, u2.geom)


-- uf ayant subi une évolution fonciere sans remembrement parcellaire (3 catégories)
select idpar
from fd94.pnb_uf_2013
  except
select idpar
from fd94.pnb_uf_2013 u
where 
	u.idpar in (select idpar from fd94.pnb_uf_no_evol_2013) or
	u.idpar in (select idpar from fd94.pnb_uf_evol_par_2013)

