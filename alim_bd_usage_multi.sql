-- Table de variation des usages des UF
-- Enregistrement des variations dans le nombre et l'affectation des locaus
-- lors du passage d'un millésime à un autre

create table fd94.usage_uf_multi (
	iduf text NOT NULL,
	annee_avant integer NOT NULL,
	npar bigint,
	nlocal bigint,
	nlocmaison bigint,
	nlocappt bigint,
	nloclog bigint,
	nloccom bigint,
	nlocdep bigint,
	npevph bigint,
	stoth bigint,
	npevp bigint,
	stotp bigint,
	npevd bigint,
	stotd bigint,
	spevtot bigint,

	annee_apres integer,
	diff_npar bigint,
	diff_nlocal bigint,
	diff_nlocmaison bigint,
	diff_nlocappt bigint,
	diff_nloclog bigint,
	diff_nloccom bigint,
	diff_nlocdep bigint,
	diff_npevph bigint,
	diff_stoth bigint,
	diff_npevp bigint,
	diff_stotp bigint,
	diff_npevd bigint,
	diff_stotd bigint,
	diff_spevtot bigint
	);

-- alter table fd94.usage_uf_multi
-- add primary key (iduf, annee_avant, annee_apres);

insert into fd94.usage_uf_multi
	select
		p1.iduf ,
		p1.annee ,
		p1.npar ,
		p1.nlocal ,
		p1.nlocmaison ,
		p1.nlocappt ,
		p1.nloclog ,
		p1.nloccom ,
		p1.nlocdep ,
		p1.npevph ,
		p1.stoth ,
		p1.npevp ,
		p1.stotp ,
		p1.npevd ,
		p1.stotd ,
		p1.spevtot ,

		p2.annee ,
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
		
	from fd94.pnb_uf_2013 p1, fd94.pnb_uf_2014 p2
	where p1.idpar=p2.idpar and 
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

