-- Nettoie la BDD
exec usp_TestAndDropAllTablesAndFK
go


-- Création des tables de la BDD
exec usp_CreateAllTablesAndFK
go


-- Chargement des message d'erreur propre à la BDD
exec usp_LoadErrorMessage
go


-- Rempli les tables avec des données par défaut
exec usp_LoadDefaultData
go


-- Création d'une tache de production
begin tran
exec usp_CreationTacheProd 'VAR_ALLELE', 'ANT', 'GENOMICA', '2.00', 25, 'TVA - Test sur variations alléliques'
rollback
go


-- Création d'une tache annexe
begin tran
exec usp_CreationTacheAnnexe 'EVT', 'Déplacement à un colloque sur le C#'
rollback
go


-- Ajout/Modification du temps passé sur une tache sur une date 
begin tran
exec usp_AjouterTempsTache 2, 'MWEBER', 4, '2017-10-01'
exec usp_AjouterTempsTache 2, 'MWEBER', 6, '2017-10-01'
exec usp_AjouterTempsTache 1, 'MWEBER', 10, '2017-10-01'
rollback
go


-- Création d'une vue avec toutes les infos nécessaire pour la saisie des temps
exec usp_TestAndDropView 'vwInfoSaisiesTemps' 
go

create view vwInfoSaisiesTemps as (
	select  V.Logiciel_Code as Logiciel,
			V.Version as Version,
			M.Libellé as Module,
			A.Libellé as Activité,
			(CONVERT(nvarchar, T.Id) + ' - ' + T.Libellé) as Tâche,
			TP.DureePrevu as PrévisionInitiale
			
	from jo.Version V
	inner join jo.TacheProd TP on V.Version = TP.Version_Version
	inner join jo.Tache T on TP.Id = T.Id
	inner join jo.Module M on TP.Module_Code = M.Code
	inner join jo.Activite A on T.Activite_Code = A.Code
)
go


-- Vérifie les horaires de l'équipe de Balthazar NORMAND sur le 21/04/2017
-- Les personnes n'ayant pas travaillé ce jour-là ne sont pas pris en compte
exec usp_VerifHorairesEquipe 'BNORMAND', '2017-04-21'
go


-- Supprime toutes les données dans les tables concernées pour la version 2.00 du logiciel GENOMICA
begin tran
exec usp_SupprimerDonnéesVersionLogiciel 'GENOMICA', '2.00'
rollback
go


