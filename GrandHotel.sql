--2.1	Clients et coordonn�es
--A.	Clients pour lesquels on n�a pas de num�ro de portable (id, nom) 
--	Renvoi 85 lignes
select CLI_ID, CLI_NOM 
from CLIENT
where CLI_ID not in (
	select C.CLI_ID
		from CLIENT C
		inner join TELEPHONE T on C.CLI_ID = T.CLI_ID
	where TYP_CODE = 'GSM')
go


--B.	Clients pour lesquels on a au moins un N� de portable ou une adresse mail
-- Renvoi 57 lignes
select CLI_ID, CLI_NOM
from CLIENT
where CLI_ID not in (	
	select distinct C.CLI_ID
	from CLIENT C
		left outer join TELEPHONE T on C.CLI_ID = T.CLI_ID
		left outer join EMAIL E on C.CLI_ID = E.CLI_ID
	where TYP_CODE = 'GSM' or EML_ID is not null)
go

--C.	Mettre � jour les num�ros de t�l�phone pour qu�ils soient au format � +33XXXXXXXXX � au lieu de � 0X-XX-XX-XX-XX � 
begin tran
update TELEPHONE set TEL_NUMERO = '+33' + SUBSTRING(REPLACE(TEL_NUMERO, '-', ''), 2, 9)
where TYP_CODE in ('TEL', 'GSM')
rollback
go

select * from TELEPHONE

--D.	Clients qui ont pay� avec au moins deux moyens de paiement diff�rents au cours d�un m�me mois (id, nom)
-- Aucune ligne renvoy�e
select F.CLI_ID, C.CLI_NOM 
from FACTURE F
inner join CLIENT C on F.CLI_ID = C.CLI_ID
group by F.CLI_ID, C.CLI_NOM, (LEFT(CONVERT(nvarchar, FAC_DATE, 102), 7))
having COUNT(*) > 1
go

--E.	Clients de la m�me ville qui se sont d�j� retrouv�s en m�me temps � l�h�tel
-- Renvoi 32 lignes
create view vwPaireDateVille as (
	select CPC.PLN_JOUR, A.ADR_VILLE, C.CLI_ID, C.CLI_NOM
	from CLIENT C
		inner join ADRESSE A on C.CLI_ID = A.CLI_ID
		inner join CHB_PLN_CLI CPC on C.CLI_ID = CPC.CLI_ID
	group by A.ADR_VILLE, CPC.PLN_JOUR, C.CLI_ID, C.CLI_NOM)
go

select distinct PDV.CLI_NOM, PDV.ADR_VILLE
from
	-- Paires Jour/Ville pour rechercher le nom des clients
	(select A.PLN_JOUR, A.ADR_VILLE
	from (
		select PLN_JOUR, ADR_VILLE, CLI_ID, CLI_NOM
		from vwPaireDateVille
		group by ADR_VILLE, PLN_JOUR, CLI_ID, CLI_NOM) A
	group by A.PLN_JOUR, A.ADR_VILLE
	having COUNT(*) > 1) P
inner join vwPaireDateVille PDV on P.ADR_VILLE = PDV.ADR_VILLE and P.PLN_JOUR = PDV.PLN_JOUR
order by 1, 2
go

drop view vwPaireDateVille
go

--2.2	Fr�quentation
--A.	Taux moyen d�occupation de l�h�tel par mois-ann�e. Autrement dit, pour chaque mois-ann�e valeur moyenne 
-- sur les chambres du ratio (nombre de jours d'occupation dans le mois / nombre de jours du mois)

-- Table pour r�cup�rer le nombre de jour par mois
declare @NbJourMoisAnn�e table (Ann�e int, Mois int, NbJour int)

insert @NbJourMoisAnn�e
select distinct YEAR(PLN_JOUR) Ann�e, MONTH(PLN_JOUR) Mois, COUNT(*) over (partition by LEFT(convert(nvarchar, PLN_JOUR, 102), 7))NbJours
from PLANNING


select distinct LEFT(CONVERT(nvarchar, PLN_JOUR, 102), 7) ANNEE_MOIS,
		COUNT(1) over(partition by LEFT(CONVERT(nvarchar, PLN_JOUR, 102), 7)) * 100 
			/ (N.NbJour * (select COUNT(*) NbChambre from CHAMBRE)) ToHotel
from CHB_PLN_CLI CPC
inner join @NbJourMoisAnn�e N on YEAR(CPC.PLN_JOUR) = N.Ann�e and MONTH(CPC.PLN_JOUR) = N.Mois
where CHB_PLN_CLI_OCCUPE = 1
go

--B.	Taux moyen d�occupation de chaque �tage par ann�e
select distinct ANNEE, A.CHB_ETAGE Etage,  Round(convert(float, NbChMoyen / ( NbChEtage  * 3.65)), 2) TOMoyen
from (
	-- Pour r�cup�rer le nombre de chambres lou�es par ann�e,
	select distinct DATEPART(year, PLN_JOUR) ANNEE, 
				C.CHB_ETAGE,
				SUM(1) over (partition by DATEPART(year, PLN_JOUR), C.CHB_ETAGE) as NbChMoyen
	from CHB_PLN_CLI CPC
		inner join CHAMBRE C on CPC.CHB_ID = C.CHB_ID
	where CPC.CHB_PLN_CLI_OCCUPE = 1) A
	-- Pour r�cup�rer le nombre de chambre par �tage
	inner join 	(select CHB_ETAGE, COUNT(*) over (partition by CHB_ETAGE) NbChEtage
		from CHAMBRE) B on A.CHB_ETAGE = B.CHB_ETAGE
go

--C.	Chambre la plus occup�e pour chacune des ann�es
-- Pas fini
select distinct CHB_ID, YEAR(PLN_JOUR) Ann�e, COUNT(*) over (partition by YEAR(PLN_JOUR), CHB_ID) NbOccAnn�e
from CHB_PLN_CLI


--D.	Taux moyen de r�servation par mois-ann�e

--E.	Clients qui ont pass� au total au moins 7 jours � l�h�tel au cours d�un m�me mois (Id, Nom, mois o� ils ont pass� au moins 7 jours).

--F.	Nombre de clients qui sont rest�s � l�h�tel au moins deux jours de suite au cours de l�ann�e 2015

--G.	Clients qui ont fait un s�jour � l�h�tel au moins deux mois de suite

--H.	Nombre quotidien moyen de clients pr�sents dans l�h�tel pour chaque mois de l�ann�e 2016, en tenant compte du nombre de personnes dans les chambres

--I.	Clients qui ont r�serv� plusieurs fois la m�me chambre au cours d�un m�me mois, mais pas deux jours d�affil�e


--2.3	Chiffre d�affaire
--A.	Valeur absolue et pourcentage d�augmentation du tarif de chaque chambre sur l�ensemble de la p�riode

-- Solution avec multiple partition by (pas opti)
select distinct CHB_ID,
				MAX (TRF_CHB_PRIX)  over(partition by CHB_ID) - MIN(TRF_CHB_PRIX) over(partition by CHB_ID) [Aug. Tarif - Val],
				(MAX (TRF_CHB_PRIX)  over(partition by CHB_ID) - MIN(TRF_CHB_PRIX) over(partition by CHB_ID)) * 100 / 
				 MIN(TRF_CHB_PRIX) over(partition by CHB_ID) [Aug. Tarif - %age]
from TRF_CHB
go

-- Solution avec table m�moire (mieux)
declare @AugmValChb table (CHB_ID int, AugmVal money)  
insert @AugmValChb
select distinct CHB_ID, (MAX (TRF_CHB_PRIX)  over(partition by CHB_ID) - MIN(TRF_CHB_PRIX) over(partition by CHB_ID))
from TRF_CHB

select distinct A.CHB_ID,
				A.AugmVal [Aug. Tarif - Val],
				A.AugmVal * 100 / MIN(TRF_CHB_PRIX) over(partition by T.CHB_ID) [Aug. Tarif - %age]
from TRF_CHB T
inner join @AugmValChb A on T.CHB_ID = A.CHB_ID
go


--B.	Chiffre d'affaire de l�h�tel par trimestre de chaque ann�e
select distinct DATEPART(YEAR, F.FAC_DATE) ANNEE, 
				DATEPART(Q, F.FAC_DATE) TRIMESTRE, 
				convert(money, SUM(LF.LIF_MONTANT * LF.LIF_QTE * (1 + LF.LIF_TAUX_TVA / 100) * 
									(1 - isnull(LF.LIF_REMISE_POURCENT, 0) / 100) - isnull(LF.LIF_REMISE_MONTANT, 0))   
								over (partition by DATEPART(YEAR, F.FAC_DATE), DATEPART(Q, F.FAC_DATE))) CA
from FACTURE F
inner join LIGNE_FACTURE LF on F.FAC_ID = LF.FAC_ID
order by 1, 2
go


--C.	Chiffre d'affaire de l�h�tel par mode de paiement et par an, avec les modes de paiement en colonne et les ann�es en ligne.
select ANNEE, [CB], [CHQ], [ESP]
from 
(select PMCODE, 
		DATEPART(YEAR, FAC_DATE) as ANNEE, 
		convert(money, (LF.LIF_MONTANT * LF.LIF_QTE * (1 + LF.LIF_TAUX_TVA / 100) * 
					(1 - isnull(LF.LIF_REMISE_POURCENT, 0) / 100) - isnull(LF.LIF_REMISE_MONTANT, 0))) as CA 
from FACTURE F
inner join LIGNE_FACTURE LF on F.FAC_ID = LF.FAC_ID
) as Source
pivot (
	SUM(CA)
	for PMCODE in ([CB],[CHQ],[ESP])
) as Toto
go


--D.	D�lai moyen de paiement des factures par ann�e et par mode de paiement, avec les modes de paiement en colonne et les ann�es en ligne.
select ANNEE, [CB], [CHQ], [ESP]
from 
(select PMCODE, 
		DATEPART(YEAR, FAC_DATE) as ANNEE, 
		DATEDIFF(day, FAC_DATE, FAC_PMDATE) as DIF 
from FACTURE F
inner join LIGNE_FACTURE LF on F.FAC_ID = LF.FAC_ID
) as Source
pivot (
	AVG(DIF)
	for PMCODE in ([CB], [CHQ], [ESP])
) as Toto
go


--E.	Compter le nombre de clients dans chaque tranche de 5000 F de chiffre d�affaire total g�n�r�, en partant de 20000 F jusqu�� + de 45 000 F. 
select COUNT(*) [NOMBRE CLIENTS], Cat [TRANCHE CA]
from (
	select CLI_ID,						
			case
				when C.CAClient < 20000 then '0 - 20k'
				when C.CAClient < 25000 then '20k - 25k'
				when C.CAClient < 30000 then '25k - 30k'
				when C.CAClient < 35000 then '30k - 35k'
				when C.CAClient < 40000 then '35k - 40k'
				when C.CAClient < 45000 then '40k - 45k'
				else '45k +'
			end as Cat
	from (
		select distinct CLI_ID, convert(money, SUM(LF.LIF_MONTANT * LF.LIF_QTE * (1 + LF.LIF_TAUX_TVA / 100) * 
								(1 - isnull(LF.LIF_REMISE_POURCENT, 0) / 100) - isnull(LF.LIF_REMISE_MONTANT, 0))   
								over (partition by CLI_ID)) CAClient		
		from FACTURE F
			inner join LIGNE_FACTURE LF on F.FAC_ID = LF.FAC_ID) C
	) D
group by Cat
go


--F.	A partir du 01/09/2017, augmenter les tarifs des chambres du rez-de-chauss�e de 5%, celles du 1er �tage de 4% et celles du 2d �tage de 2%.
begin tran
-- Ajouter d'abord la date dans TARIF car elle est clef �trang�re dans TRF_CHB
insert TARIF(TRF_DATE_DEBUT, TRF_TAUX_TAXES, TRF_PETIDEJEUNE) values ('2017-09-01', 20.6, 50) 

insert into TRF_CHB(CHB_ID, TRF_DATE_DEBUT, TRF_CHB_PRIX)
select CHB_ID, 
		'2017-09-01',
		(case
			when CHB_ETAGE = 'RDC' then TRF_CHB_PRIX * 1.05
			when CHB_ETAGE = '1er' then TRF_CHB_PRIX * 1.04
			when CHB_ETAGE = '2e' then TRF_CHB_PRIX * 1.02		
		end) as TRF_CHB_PRIX
from (
		select distinct C.CHB_ID, C.CHB_ETAGE, MAX(TRF_CHB_PRIX) over (partition by C.CHB_ID) as TRF_CHB_PRIX
		from TRF_CHB TC
	inner join CHAMBRE C on TC.CHB_ID = C.CHB_ID) A
rollback
go