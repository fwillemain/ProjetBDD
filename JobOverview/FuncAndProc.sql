-- Teste la pr�sence d'une routine (proc�dure ou fonction) et la drop si elle existe
if exists(select 1
			from INFORMATION_SCHEMA.ROUTINES
			where specific_name = 'usp_TestAndDropRoutine')
	drop procedure usp_TestAndDropRoutine
go

create procedure usp_TestAndDropRoutine @Func varchar(50), @Schema varchar(20) = 'dbo'
as
begin
	declare @TypeRoutine varchar(20)
	if exists(select 1
			from INFORMATION_SCHEMA.ROUTINES
			where ROUTINE_SCHEMA = @Schema
				and ROUTINE_NAME = @Func)
	begin
		select @TypeRoutine = ROUTINE_TYPE from INFORMATION_SCHEMA.ROUTINES
			where ROUTINE_SCHEMA = @Schema
				and ROUTINE_NAME = @Func
		declare @SQL nvarchar(max)
		set @SQL = 'Drop ' + @TypeRoutine + ' ' + @Schema + '.' + @Func
		print @SQL
		exec sp_Executesql @SQL
	end
end					
go


-- Teste la pr�sence d'une vue et la drop si elle existe
exec usp_TestAndDropRoutine 'usp_TestAndDropView'
go

create procedure usp_TestAndDropView @Vue varchar(20)
as
begin
	if exists(select 1
			from INFORMATION_SCHEMA.VIEWS
			where TABLE_NAME = @Vue)
	begin
		declare @SQL nvarchar(max) 
		set @SQL = 'Drop view ' + @Vue
		print @SQL
		exec sp_Executesql @SQL
	end
end	
go


-- Supprime toutes les tables de la base si il y en a
exec usp_TestAndDropRoutine 'usp_TestAndDropAllTablesAndFK'
go

create procedure usp_TestAndDropAllTablesAndFK
as
begin
	declare @SQLDropFK nvarchar(max) = '' 
	declare @SQLDropTable nvarchar(max) = '' 
	
	-- Pour chaque FK, je rajoute le drop de cette derni�re dans la variable @SQLDropFK
	select @SQLDropFK = @SQLDropFK + 'Alter table ' + TABLE_SCHEMA + '.' + TABLE_NAME + ' drop constraint ' + CONSTRAINT_NAME + CHAR(13)
	from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	where CONSTRAINT_TYPE = 'FOREIGN KEY'
	
	-- J'affiche la requete puis l'execute
	print @SQLDropFK
	exec sp_Executesql @SQLDropFK
	
	-- Pour chaque table, je rajoute le drop de cette derni�re dans la variable @SQLDropTable
	select @SQLDropTable = @SQLDropTable + 'Drop table ' + TABLE_SCHEMA + '.' + TABLE_NAME+ CHAR(13)
	from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE'
		
	-- J'affiche le drop de mes tables et l'execute
	print @SQLDropTable
	exec sp_Executesql @SQLDropTable
end
go


-- Cr�� toutes les tables et leurs contraintes
exec usp_TestAndDropRoutine 'usp_CreateAllTablesAndFK'
go

create procedure usp_CreateAllTablesAndFK
as
begin
	CREATE  TABLE jo.Activite
	(
    Code VARCHAR (15) NOT NULL ,
    Libell� NVARCHAR (40) NOT NULL ,
    Type NVARCHAR (40) NOT NULL
	 )
	
	ALTER TABLE jo.Activite ADD CONSTRAINT Activite_PK PRIMARY KEY CLUSTERED (Code)
	
	CREATE  TABLE jo.Equipe
	(
    Id           INTEGER NOT NULL ,
    Service_Code VARCHAR (15) NOT NULL ,
    Filiere_Code VARCHAR (15) NOT NULL
	)
	

ALTER TABLE jo.Equipe ADD CONSTRAINT Equipe_PK PRIMARY KEY CLUSTERED (Id)


CREATE  TABLE jo.Filiere
  (
    Code          VARCHAR (15) NOT NULL ,
    Production_Id INTEGER NOT NULL ,
    Libell� NVARCHAR (40) NOT NULL
  )


ALTER TABLE jo.Filiere ADD CONSTRAINT Filiere_PK PRIMARY KEY CLUSTERED (Code) 


CREATE TABLE jo.Logiciel
  (
    Code         VARCHAR (15) NOT NULL ,
    Filiere_Code VARCHAR (15) NOT NULL
  )


ALTER TABLE jo.Logiciel ADD CONSTRAINT Logiciel_PK PRIMARY KEY CLUSTERED (Code)


CREATE TABLE jo.Metier
  (
    Code VARCHAR (15) NOT NULL ,
    Libell� NVARCHAR (40) NOT NULL
  )
 


ALTER TABLE jo.Metier ADD CONSTRAINT Metier_PK PRIMARY KEY CLUSTERED (Code)


CREATE TABLE jo.MetierActivite
  (
    Metier_Code   VARCHAR (15) NOT NULL ,
    Activite_Code VARCHAR (15) NOT NULL
  )


ALTER TABLE jo.MetierActivite ADD CONSTRAINT MetierActivite_PK PRIMARY KEY CLUSTERED (Metier_Code, Activite_Code)


CREATE TABLE jo.Module
  (
    Code           VARCHAR (15) NOT NULL ,
    SurModule_Code VARCHAR (15) ,
    Logiciel_Code  VARCHAR (15) NOT NULL ,
    Libell� NVARCHAR (40) NOT NULL
  )


ALTER TABLE jo.Module ADD CONSTRAINT Module_PK PRIMARY KEY CLUSTERED (Code) 


CREATE TABLE jo.Personne
  (
    Login         VARCHAR (15) NOT NULL ,
    Equipe_Id     INTEGER ,
    Manager_Login VARCHAR (15) ,
    Metier_Code   VARCHAR (15) NOT NULL ,
    TauxProd      REAL NOT NULL DEFAULT 1 ,
    Nom NVARCHAR (40) NOT NULL ,
    Pr�nom NVARCHAR (40) NOT NULL
  ) 


ALTER TABLE jo.Personne ADD CONSTRAINT Personne_PK PRIMARY KEY CLUSTERED (Login) 


CREATE TABLE jo.Production
  (
    Id INTEGER NOT NULL
  )


ALTER TABLE jo.Production ADD CONSTRAINT Production_PK PRIMARY KEY CLUSTERED (
Id)


CREATE TABLE jo.Release
  (
    Id              INTEGER NOT NULL ,
    Version_Version VARCHAR (15) NOT NULL ,
    Logiciel_Code VARCHAR (15) NOT NULL ,
    DateCreation    DATE NOT NULL
  )
  
ALTER TABLE jo.Release
ADD
CHECK ( Id BETWEEN 1 AND 999 )

ALTER TABLE jo.Release ADD CONSTRAINT Release_PK PRIMARY KEY CLUSTERED (Id, Version_Version, Logiciel_Code) 


CREATE TABLE jo.Service
  (
    Code VARCHAR (15) NOT NULL ,
    Libell� NVARCHAR (40) NOT NULL
  )


ALTER TABLE jo.Service ADD CONSTRAINT Service_PK PRIMARY KEY CLUSTERED (Code)


CREATE TABLE jo.Tache
  (
    Id            INTEGER NOT NULL IDENTITY NOT FOR REPLICATION ,
    Activite_Code VARCHAR (15) NOT NULL ,
    Libell� NVARCHAR (40) NOT NULL ,
    Description NVARCHAR (100) ,
    Type NVARCHAR (40) NOT NULL
  )


ALTER TABLE jo.Tache ADD CONSTRAINT Tache_PK PRIMARY KEY CLUSTERED (Id)


CREATE TABLE jo.TacheProd
  (
    Id              INTEGER NOT NULL ,
    Version_Version VARCHAR (15) NOT NULL ,
    Module_Code     VARCHAR (15) NOT NULL ,
    Logiciel_Code VARCHAR (15) NOT NULL ,
    DureePrevu FLOAT NOT NULL ,
    TempsRestantEstime FLOAT
  )


ALTER TABLE jo.TacheProd ADD CONSTRAINT TacheProd_PK PRIMARY KEY CLUSTERED (Id) 


CREATE TABLE jo.TravailPT
  (
                   DATE DATE NOT NULL ,
    Personne_Login VARCHAR (15) NOT NULL ,
    Tache_Id       INTEGER NOT NULL ,
    TauxProd       REAL ,
    Temps FLOAT NOT NULL
  )


ALTER TABLE jo.TravailPT ADD CONSTRAINT TravailPT_PK PRIMARY KEY CLUSTERED (Personne_Login, Tache_Id, DATE) 


CREATE TABLE jo.Version 
  (
    Version       VARCHAR (15) NOT NULL ,
    Logiciel_Code VARCHAR (15) NOT NULL ,
    Millesime NVARCHAR (40) NOT NULL ,
    DateOuverture     DATE NOT NULL ,
    DateSortieEstimee DATE NOT NULL ,
    DateSortieReelle  DATE
  ) 


ALTER TABLE jo.Version ADD CONSTRAINT Version_PK PRIMARY KEY CLUSTERED (Version, Logiciel_Code)



ALTER TABLE jo.Equipe
ADD CONSTRAINT Equipe_Filiere_FK FOREIGN KEY
(
Filiere_Code
)
REFERENCES jo.Filiere
(
Code
)

ALTER TABLE jo.Equipe
ADD CONSTRAINT Equipe_Service_FK FOREIGN KEY
(
Service_Code
)
REFERENCES jo.Service
(
Code
)

ALTER TABLE jo.MetierActivite
ADD CONSTRAINT FK_ASS_3 FOREIGN KEY
(
Metier_Code
)
REFERENCES jo.Metier
(
Code
)

ALTER TABLE jo.MetierActivite
ADD CONSTRAINT FK_ASS_4 FOREIGN KEY
(
Activite_Code
)
REFERENCES jo.Activite
(
Code
)

ALTER TABLE jo.Filiere
ADD CONSTRAINT Filiere_Production_FK FOREIGN KEY
(
Production_Id
)
REFERENCES jo.Production
(
Id
)

ALTER TABLE jo.Logiciel
ADD CONSTRAINT Logiciel_Filiere_FK FOREIGN KEY
(
Filiere_Code
)
REFERENCES jo.Filiere
(
Code
)

ALTER TABLE jo.Module
ADD CONSTRAINT Module_Logiciel_FK FOREIGN KEY
(
Logiciel_Code
)
REFERENCES jo.Logiciel
(
Code
)

ALTER TABLE jo.Module
ADD CONSTRAINT Module_SurModule_FK FOREIGN KEY
(
SurModule_Code
)
REFERENCES jo.Module
(
Code
)

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Equipe_FK FOREIGN KEY
(
Equipe_Id
)
REFERENCES jo.Equipe
(
Id
)

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Manager_FK FOREIGN KEY
(
Manager_Login
)
REFERENCES jo.Personne
(
Login
)

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Metier_FK FOREIGN KEY
(
Metier_Code
)
REFERENCES jo.Metier
(
Code
)

ALTER TABLE jo.Release
ADD CONSTRAINT Release_Version_FK FOREIGN KEY
(
Version_Version,
Logiciel_Code
)
REFERENCES jo.Version
(
Version,
Logiciel_Code
)

ALTER TABLE jo.TacheProd
ADD CONSTRAINT TacheProd_Module_FK FOREIGN KEY
(
Module_Code
)
REFERENCES jo.Module
(
Code
)


ALTER TABLE jo.TacheProd
ADD CONSTRAINT TacheProd_Tache_FK FOREIGN KEY
(
Id
)
REFERENCES jo.Tache
(
Id
)

ALTER TABLE jo.TacheProd
ADD CONSTRAINT TacheProd_Version_FK FOREIGN KEY
(
Version_Version,
Logiciel_Code
)
REFERENCES jo.Version
(
Version,
Logiciel_Code
)

ALTER TABLE jo.Tache
ADD CONSTRAINT Tache_Activite_FK FOREIGN KEY
(
Activite_Code
)
REFERENCES jo.Activite
(
Code
)

ALTER TABLE jo.TravailPT
ADD CONSTRAINT TravailPT_Personne_FK FOREIGN KEY
(
Personne_Login
)
REFERENCES jo.Personne
(
Login
)

ALTER TABLE jo.TravailPT
ADD CONSTRAINT TravailPT_Tache_FK FOREIGN KEY
(
Tache_Id
)
REFERENCES jo.Tache
(
Id
)

ALTER TABLE jo.Version
ADD CONSTRAINT Version_Logiciel_FK FOREIGN KEY
	(
	Logiciel_Code
	)
	REFERENCES jo.Logiciel
	(
	Code
	)
end
go


-- Remplie les tables avec les donn�es par d�faut fourni dans le projet
exec usp_TestAndDropRoutine 'usp_LoadDefaultData'
go

create procedure usp_LoadDefaultData
as
begin
	insert jo.Production(Id) values (0)	
	
	insert jo.Filiere(Code, Libell�, Production_Id) values 
		('BIOH', 'Biologie humaine', 0),
		('BIOA', 'Biologie animale', 0),
		('BIOV', 'Biologie v�g�tale', 0)

	insert jo.Service(Code, Libell�) values
		('MKT', 'Marketing'),
		('DEV', 'D�veloppement'),
		('TEST', 'Test'),
		('SL', 'Support Logiciel')

	insert jo.Equipe(Id, Filiere_Code, Service_Code) values
		(0, 'BIOH', 'MKT'),
		(1, 'BIOH', 'DEV'),
		(2, 'BIOH', 'TEST'),
		(3, 'BIOH', 'SL'),
		(4, 'BIOA', 'MKT'),
		(5, 'BIOV', 'TEST')

	insert jo.Metier(Code, Libell�) values
		('ANA', 'Analyste'),
		('CDP', 'Chef de projet'),
		('DEV', 'D�veloppeur'),
		('DES', 'Designer'),
		('TES', 'Testeur')

	-- Taux de production � 1 (100%), par d�faut
	insert jo.Personne(Login, Pr�nom, Nom, Metier_Code, Manager_Login) values 
		('GLECLERCK', 'Genevi�ve', 'LECLERCQ', 'ANA', 'BNORMAND'),
		('AFERRAND', 'Ang�le', 'FERRAND', 'ANA', 'BNORMAND'),
		('BNORMAND', 'Balthazar', 'NORMAND', 'CDP', NULL),
		('RFISHER', 'Raymond', 'FISHER', 'DEV', 'BNORMAND'),
		('LBUTLER', 'Lucien', 'BUTLER', 'DEV', 'BNORMAND'),
		('RBEAUMONT', 'Roseline', 'BEAUMONT', 'DEV', 'BNORMAND'),
		('MWEBER', 'Marguerite', 'WEBER', 'DES', 'BNORMAND'),
		('HKLEIN', 'Hilaire', 'KLEIN', 'TES', 'BNORMAND'),
		('NPALMER', 'Nino', 'PALMER', 'TES', 'BNORMAND')
	
	insert jo.Activite(Code, Libell�, Type) values
		('DBE', 'D�finition des besoin', 'P'),
		('ARF', 'Architecture fonctionnelle', 'P'),
		('ANF', 'Analyse fonctionnelle', 'P'),
		('DES', 'Design', 'P'),
		('INF', 'Infographie', 'P'),
		('ART', 'Architecture technique', 'P'),
		('ANT', 'Analyse technique', 'P'),
		('DEV', 'D�veloppement', 'P'),
		('RPT', 'R�daction de plan de test', 'P'),
		('TES', 'Test', 'P'),
		('GDP', 'Gestion de projet', 'P'),
		('APE', 'Appui des personnes de l''�quipe', 'A'),
		('APA', 'Appui des personnes d''autres services', 'A'),
		('FOR', 'Formation re�ue', 'A'),
		('FOD', 'Formation dispens�e', 'A'),
		('TDP', 'Travail de d�l�gu� du personnel', 'A'),
		('EVT', 'D�placement � des �v�nements divers', 'A')

	insert jo.MetierActivite(Metier_Code, Activite_Code) values
		('ANA', 'DBE'),
		('ANA', 'ARF'),
		('ANA', 'ANF'),
		('CDP', 'ARF'),
		('CDP', 'ANF'),
		('CDP', 'ART'),
		('CDP', 'TES'),
		('CDP', 'GDP'),
		('DEV', 'ANF'),
		('DEV', 'ART'),
		('DEV', 'ANT'),
		('DEV', 'DEV'),
		('DEV', 'TES'),
		('DES', 'ANF'),
		('DES', 'DES'),
		('DES', 'INF'),
		('TES', 'RPT'),
		('TES', 'TES')
	
	insert jo.Logiciel(Code, Filiere_Code) values ('GENOMICA', 'BIOA')
	
	insert jo.Module(Code, Libell�, Logiciel_Code, SurModule_Code) values
		('SEQUENCAGE', 'S�quen�age', 'GENOMICA', NULL),
		('MARQUAGE', 'Marquage', 'GENOMICA', 'SEQUENCAGE'),
		('SEPARATION', 'S�paration', 'GENOMICA', 'SEQUENCAGE'),
		('ANALYSE', 'Analyse', 'GENOMICA', 'SEQUENCAGE'),
		('POLYMORPHISME', 'Polymorphisme g�n�tique', 'GENOMICA', NULL),
		('VAR_ALLELE', 'Varations all�liques', 'GENOMICA', NULL),
		('UTIL_DROITS', 'Utilisateurs et droits', 'GENOMICA', NULL),
		('PARAMETRES', 'Param�trage', 'GENOMICA', NULL)
	
	insert jo.Version(Version, Logiciel_Code, Millesime, DateOuverture, DateSortieEstimee, DateSortieReelle) values
		('1.00', 'GENOMICA', '2017', '2016-01-02', '2017-01-01', '2017-01-08'),
		('2.00', 'GENOMICA', '2018', '2016-12-28', '2017-05-15', NULL)
	
	-- Id en auto-incr�ment
	insert jo.Release(Id, Logiciel_Code, Version_Version, DateCreation) values
		(1, 'GENOMICA', '1.00', '2016-01-02'),
		(2, 'GENOMICA', '1.00', '2016-10-10'),
		(3, 'GENOMICA', '1.00', '2017-01-08'),
		(1, 'GENOMICA', '2.00', '2061-12-28')
	
	-- Id en auto-incr�ment
	insert jo.Tache(Activite_Code, Libell�, Type) values
		('ANT', 'AT saisie des utilisateurs et droits', 'P'), -- Tache 1
		('EVT', 'D�placement � la Geek Expo', 'A') -- Tache 2
		
	insert jo.TacheProd(Id, Logiciel_Code, Version_Version, Module_Code, DureePrevu, TempsRestantEstime) values
		(1, 'GENOMICA', '2.00', 'UTIL_DROITS', 16, 12)
	
	insert jo.TravailPT(DATE, Personne_Login, Tache_Id, TauxProd, Temps) values 
		('2017-04-21', 'BNORMAND', 1, 1, 2.5),
		('2017-04-21', 'MWEBER', 2, NULL, 2)	
end
go


-- Cr�� tous les messages d'erreur propre � notre BDD
exec usp_TestAndDropRoutine 'usp_LoadErrorMessage'
go

create procedure usp_LoadErrorMessage
as
begin
	exec sp_addmessage @msgnum = 50001, @severity = 12,
	@msgText = 'Working hours can''t be superior to 8 on a given date', @lang='us_english',
	@replace = 'replace'

	exec sp_addmessage @msgnum = 50001, @severity = 12,
	@msgText = 'Il n''est pas possible de d�passer 8h de travail pour une date donn�e', @lang='French',
	@replace = 'replace'
end
go


-- Cr�� une tache de production
exec usp_TestAndDropRoutine 'usp_CreationTacheProd'
go

create procedure usp_CreationTacheProd @CodeModule varchar(15), 
							@CodeActivit� varchar(15), @LogicielCode varchar(15), @VersionLog varchar(15),
							@Dur�ePr�vue float, @Libell� nvarchar(40), 
							@TempsRestantEstim� float = NULL, @Description nvarchar(200) = NULL
as
begin
	insert jo.Tache(Activite_Code, Libell�, Type, Description) 
	values (@CodeActivit�, @Libell�, 'P', @Description)
	
	-- Permet de r�cup�rer le dernier Id rentr� dans la table jo.Tache
	-- Attention, ceci ne g�re pas la possibilit� d'autres insertions entre notre insertion et le test qui suit!
	declare @IdTache int
	select @IdTache = MAX(Id) from jo.Tache
	
	insert jo.TacheProd(Id, Version_Version, Logiciel_Code, Module_Code, DureePrevu, TempsRestantEstime) 
	values (@IdTache, @VersionLog, @LogicielCode, @CodeModule, @Dur�ePr�vue, @TempsRestantEstim�)

end
go


-- Cr�� une tache annexe
exec usp_TestAndDropRoutine 'usp_CreationTacheAnnexe'
go

create procedure usp_CreationTacheAnnexe @CodeActivit� varchar(15), @Libell� varchar(40)								
as
begin
	insert jo.Tache(Activite_Code, Libell�, Type) 
	values (@CodeActivit�, @Libell�, 'A')
end
go


-- Indique le temps pass� pour une tache � la date donn�e, si cette entr�e existe d�j�, �crase le temps pr�c�demment renseign�
-- Si le temps de travail sur une journ�e d�passe 8h, une erreur sera renvoy�e
exec usp_TestAndDropRoutine 'usp_AjouterTempsTache'
go

create procedure usp_AjouterTempsTache @IdTache int, @LoginEmployee varchar(15), @Temps float, @Date date
as
begin
	-- V�rifie si le rajout/modif du temps ne fait pas d�passer le total de temps de travail dans la journ�e
	-- de la limite des 8 heures
	if isnull((select SUM(Temps) 
		from jo.TravailPT 
		where Personne_Login = @LoginEmployee
				and DATE = @Date
				and Tache_Id != @IdTache), 0) + @Temps > 8
			RAISERROR(50001, 12, 1)
	-- Si l'entr�e existe, la mettre � jour
	else
	begin
		if exists (select 1 from jo.TravailPT 
						where DATE = @Date 
							and Personne_Login = @LoginEmployee
							and Tache_Id = @IdTache)
		begin
			update jo.TravailPT
			set Temps = @Temps
			where DATE = @Date
					and Personne_Login = @LoginEmployee
					and Tache_Id = @IdTache
		end
		-- Sinon la cr�er 
		else
		begin
			-- R�cup�rer le Taux de production de l'employee si la tache � modifier est une tache prod ('P')
			declare @TauxProd real = NULL
			if exists (select 1 from jo.Tache where Id = @IdTache and Type = 'P')
				select @TauxProd = TauxProd from jo.Personne where Login = @LoginEmployee
		
			insert jo.TravailPT(DATE, Personne_Login, Tache_Id, TauxProd, Temps)
			values (@Date, @LoginEmployee, @IdTache, @TauxProd , @Temps)
		end
	end
end
go


-- Permet au manager de v�rifier si les personnes de son �quipe ont bien saisi tous leurs
-- 8h de travail au jour donn� (si ils ont travaill�)
exec usp_TestAndDropRoutine 'usp_VerifHorairesEquipe'
go

create procedure usp_VerifHorairesEquipe @LoginManager varchar(15), @Date date
as
begin
	select P.Login, SUM(Temps) as Temps
	from jo.Personne P
	left outer join jo.TravailPT TP on P.Login = TP.Personne_Login
	where Manager_Login = @LoginManager and DATE = @Date
	group by DATE, P.Login
	having SUM(Temps) < 8
end
go


-- Supprime toutes les donn�es dans les tables concern�es pour une version donn�e d'un logiciel
exec usp_TestAndDropRoutine 'usp_SupprimerDonn�esVersionLogiciel'
go

create procedure usp_SupprimerDonn�esVersionLogiciel @Logiciel varchar(15), @Version varchar(15)
as
begin
	
	delete from jo.Release
	where Version_Version = @Version and Logiciel_Code = @Logiciel
	
	-- Je stocke les Id pour effacer jo.TravailPT et jo.Tache
	declare @IdTacheVersion table(Id int)
	insert @IdTacheVersion
	select Id
	from jo.TacheProd
	where Version_Version = @Version and Logiciel_Code = @Logiciel
	
	delete TP from jo.TacheProd TP
	inner join @IdTacheVersion I on TP.Id = I.Id
	
	delete TPT from jo.TravailPT TPT
	inner join @IdTacheVersion I on TPT.Tache_Id = I.Id

	delete T from jo.Tache T
	inner join @IdTacheVersion I on T.Id = I.Id
	
	delete from jo.Version
	where Version = @Version and Logiciel_Code = @Logiciel
end
go
