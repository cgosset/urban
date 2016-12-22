-- alimentation des tables multimillésimes des UF et parcelles


insert into fd94.pnb_uf_multi
	(iduf, annee, idpar, idpar_l, npar, nlocal, nlocmaison, nlocappt, nloccom, nloccomrdc, nloccomter, nlocdep,
		nlocburx, npevph, stoth, stotdsueic, nhabvacant, nactvacant, nloghlm, npevp, stotd, spevtot, nlot,
		geom, idprocpte, idusage4, idusage8, idusage16)
	select iduf, annee, idpar, idpar_l, npar, nlocal, nlocmaison, nlocappt, nloccom, nloccomrdc, nloccomter, nlocdep,
		nlocburx, npevph, stoth, stotdsueic, nhabvacant, nactvacant, nloghlm, npevp, stotd, spevtot, nlot,
		geom, idprocpte, idusage4, idusage8, idusage16
	from fd94.pnb_uf_2013;

insert into fd94.pnb_par_created
	select idpar, 2013, geompar
	from fd94.pnb_par_2013
	where idpar in (
		select idpar from fd94.pnb_par_2013
		  except
		select idpar from fd94.pnb_par_2012
		);
		
insert into fd94.pnb_par_destroyed
	select idpar, 2013, geompar
	from fd94.pnb_par_2012
	where idpar in (
		select idpar from fd94.pnb_par_2012
		  except
		select idpar from fd94.pnb_par_2013
		);

insert into fd94.pnb_uf_created
	select iduf, 2013, geom
	from fd94.pnb_uf_2013
	where iduf in (
		select iduf from fd94.pnb_uf_2013
		  except
		select iduf from fd94.pnb_uf_2012
		);

insert into fd94.pnb_uf_destroyed
	select iduf, 2013, geom
	from fd94.pnb_uf_2012
	where iduf in (
		select iduf from fd94.pnb_uf_2012
		  except
		select iduf from fd94.pnb_uf_2013
		);
