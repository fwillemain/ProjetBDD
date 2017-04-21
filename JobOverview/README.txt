Description des fichiers
 - FuncAndProc.sql : contient la création de toutes les procédures stockées utiles pour la création de la BDD et les jeux de tests
 - JobOverview.sql : utilisation des procédures stockées pour créer la BDD avec quelques données par défaut et les différents appels de procédures pour tests
 - JobOverview.bak : backup de la BDD JobOverview avec les données par défaut déjà chargées
 - JobOverviewMCD.pdf : MCD de la BDD JobOverview
 - JobOverviewMPD.pdf : MPD de la BDD JobOverview

 
 
 Pour la création de la BDD et le chargement de ses données, choisir une des deux solutions expliquées ci-dessous (avec ou sans le backup).
 
 
SANS CHARGER LE BACKUP
0/ Lancer SSMS

1/ Créer une BDD dans SSMS au nom de JobOverview
	-> Clic droit sur "Databases" et choisir "New Database".
	-> Nommer "JobOverview "
	
2/ Créer un Schema dans SSMS au nom de jo
	-> Aller dans JobOverview > Security 
	-> Clic droit sur "Schemas" et choisir "New Schema"
	-> Nommber "jo"
	
3/ Chargement des données - Attention, vérifier que la BDD selectionnée est bien celle créée (à gauche du bouton "Execute") avant d'executer!
	-> Ouvrir le fichier FuncAndProc.sql et executer le tout (F5).
	-> Ouvrir le fichier JobOverview.sql et executer les 4 premières procédures (séléctionner les 4 premières SP et F5)


	
CHARGER LE BACKUP
0/ Lancer SSMS

1/ Clic droit sur "Databases"
	-> Sélectionner "Restore Database"
	-> Séléctionner "From device" et cliquer sur le bouton "..." à sa droite
	-> Cliquer sur "Add" et choisir le fichier JobOverview.bak
	-> Ne pas oublier de checker la box "Restore" une fois le backup selectionné
	-> Nommer la base ("JobOverview" par exemple) dans le champs "To database". Attention le nom ne doit pas être déjà utilisé par une autre BDD.
	-> Valider
