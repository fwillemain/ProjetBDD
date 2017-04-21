-- Nettoie la BDD
exec usp_TestAndDropAllTablesAndFK
go


-- Cr�ation des tables de la BDD
exec usp_CreateAllTablesAndFK
go


-- Chargement des message d'erreur propre � la BDD
exec usp_LoadErrorMessage
go


-- Rempli les tables avec des donn�es par d�faut
exec usp_LoadDefaultData
go


-- Cr�ation d'une tache de production
begin tran
exec usp_CreationTacheProd 'VAR_ALLELE', 'ANT', 'GENOMICA', '2.00', 25, 'TVA - Test sur variations all�liques'
rollback
go


-- Cr�ation d'une tache annexe
begin tran
exec usp_CreationTacheAnnexe 'EVT', 'D�placement � un colloque sur le C#'
rollback
go


-- Ajout/Modification du temps pass� sur une tache sur une date 
begin tran
exec usp_AjouterTempsTache 2, 'MWEBER', 4, '2017-10-01'
exec usp_AjouterTempsTache 2, 'MWEBER', 6, '2017-10-01'
exec usp_AjouterTempsTache 1, 'MWEBER', 10, '2017-10-01'
rollback
go


-- Cr�ation d'une vue avec toutes les infos n�cessaire pour la saisie des temps
exec usp_TestAndDropView 'vwInfoSaisiesTemps' 
go

create view vwInfoSaisiesTemps as (
	select  V.Logiciel_Code as Logiciel,
			V.Version as Version,
			M.Libell� as Module,
			A.Libell� as Activit�,
			(CONVERT(nvarchar, T.Id) + ' - ' + T.Libell�) as T�che,
			TP.DureePrevu as Pr�visionInitiale
			
	from jo.Version V
	inner join jo.TacheProd TP on V.Version = TP.Version_Version
	inner join jo.Tache T on TP.Id = T.Id
	inner join jo.Module M on TP.Module_Code = M.Code
	inner join jo.Activite A on T.Activite_Code = A.Code
)
go


-- V�rifie les horaires de l'�quipe de Balthazar NORMAND sur le 21/04/2017
-- Les personnes n'ayant pas travaill� ce jour-l� ne sont pas pris en compte
exec usp_VerifHorairesEquipe 'BNORMAND', '2017-04-21'
go


-- Supprime toutes les donn�es dans les tables concern�es pour la version 2.00 du logiciel GENOMICA
begin tran
exec usp_SupprimerDonn�esVersionLogiciel 'GENOMICA', '2.00'
rollback
go


