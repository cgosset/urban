-- alimentation des tables multimillésimes des UF et parcelles


insert into fd94.pnb_uf_multi
	(iduf, annee, idpar, idpar_l, npar, nlocal, nlocmaison, nlocappt, nloccom, nloccomrdc, nloccomter, nlocdep,
		nlocburx, npevph, stoth, stotdsueic, nhabvacant, nactvacant, nloghlm, npevp, stotd, spevtot, nlot)
	select iduf, annee, idpar, idpar_l, npar, nlocal, nlocmaison, nlocappt, nloccom, nloccomrdc, nloccomter, nlocdep,
		nlocburx, npevph, stoth, stotdsueic, nhabvacant, nactvacant, nloghlm, npevp, stotd, spevtot, nlot
	from fd94.pnb_uf_2012;

insert into fd94.pnb_par_created
	select idpar, 2012
	from fd94.pnb_par_2012
	where idpar in (
		select idpar from fd94.pnb_par_2012
		  except
		select idpar from fd94.pnb_par_2011
		);
		
insert into fd94.pnb_par_destroyed
	select idpar, 2012
	from fd94.pnb_par_2011
	where idpar in (
		select idpar from fd94.pnb_par_2011
		  except
		select idpar from fd94.pnb_par_2012
		);

insert into fd94.pnb_uf_created
	select iduf, 2012
	from fd94.pnb_uf_2012
	where iduf in (
		select iduf from fd94.pnb_uf_2012
		  except
		select iduf from fd94.pnb_uf_2011
		);

insert into fd94.pnb_uf_destroyed
	select iduf, 2012
	from fd94.pnb_uf_2011
	where iduf in (
		select iduf from fd94.pnb_uf_2011
		  except
		select iduf from fd94.pnb_uf_2012
		);
