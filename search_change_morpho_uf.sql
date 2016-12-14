-- recherche des uf contenant des parcelles créées
-- evolution fonciere avec remembrement parcellaire (5 catégories)
select iduf, npar
from fd94.pnb_uf_2013
where npar>1
  except
select iduf as id, npar
from (
	SELECT generate_subscripts(idpar_l, 1) AS s, idpar_l, iduf, npar
	FROM (select idpar_l, iduf, npar from fd94.pnb_uf_2013) bar
	) foo
where idpar_l[s] in (select idpar from fd94.pnb_par_2012)
group by idpar_l, iduf, npar
having array_length(idpar_l,1)=array_length(array_agg(idpar_l[s]),1)