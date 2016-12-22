-- Table de variation des usages des UF
-- Enregistrement des variations dans le nombre et l'affectation des locaus
-- lors du passage d'un millésime à un autre

insert into fd94.usage_uf_multi
	select
		p1.iduf ,
		p1.annee ,
		p2.annee ,
		p1.idusage4,
		p2.idusage4,
		p1.idusage8,
		p2.idusage8,
		p1.idusage16,
		p2.idusage16,
		p2.npar - p2.npar ,
		p2.nlocal - p1.nlocal ,
		p2.nlocmaison - p1.nlocmaison ,
		p2.nlocappt - p1.nlocappt,
		p2.nloclog - p1.nloclog ,
		p2.nloccom - p1.nloccom ,
		p2.nlocdep - p1.nlocdep ,
		p2.npevph - p1.npevph ,
		p2.stoth - p1.stoth,
		p2.npevp - p1.npevp,
		p2.stotp - p1.stotp,
		p2.npevd - p1.npevd,
		p2.stotd - p1.stotd,
		p2.spevtot - p1.spevtot
		
	from fd94.pnb_uf_2012 p1, fd94.pnb_uf_2013 p2
	where p1.iduf=p2.iduf and 
		(abs(p2.npar - p2.npar) +
		abs(p2.nlocal - p1.nlocal) +
		abs(p2.nlocmaison - p1.nlocmaison) +
		abs(p2.nlocappt - p1.nlocappt) +
		abs(p2.nloclog - p1.nloclog) +
		abs(p2.nloccom - p1.nloccom) +
		abs(p2.nlocdep - p1.nlocdep) +
		abs(p2.npevph - p1.npevph) +
		abs(p2.stoth - p1.stoth) +
		abs(p2.npevp - p1.npevp) +
		abs(p2.stotp - p1.stotp) +
		abs(p2.npevd - p1.npevd) +
		abs(p2.stotd - p1.stotd) +
		abs(p2.spevtot - p1.spevtot)
		) <> 0;

