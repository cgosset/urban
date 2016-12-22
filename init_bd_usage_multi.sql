-- Table de variation des usages des UF
-- Enregistrement des variations dans le nombre et l'affectation des locaus
-- lors du passage d'un millésime à un autre

drop table if exists fd94.usage_uf_multi;
create table fd94.usage_uf_multi (
	iduf text NOT NULL,
	annee_avant integer NOT NULL,
	annee_apres integer NOT NULL,
	us4_avant int,
	us4_apres int,
	us8_avant int,
	us8_apres int,
	us16_avant int,
	us16_apres int,
	diff_npar  int,
	diff_nlocal int,
	diff_nlocmaison int,
	diff_nlocappt int,
	diff_nloclog int,
	diff_nloccom int,
	diff_nlocdep int,
	diff_npevph int,
	diff_stoth int,
	diff_npevp int,
	diff_stotp int,
	diff_npevd int,
	diff_stotd int,
	diff_spevtot int
	);

alter table fd94.usage_uf_multi
add primary key (iduf, annee_avant, annee_apres);

create index usage_uf_multi_idx on fd94.usage_uf_multi (iduf, annee_avant, annee_apres);