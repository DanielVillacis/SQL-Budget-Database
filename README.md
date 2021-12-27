SQL-Budget-Database 
Budget management database project using PostgreSQL.

Description :
Ce projet de session comporte sur la conception d’une base de données SQL représentant un système de contrôle budgétaire personnel. Ce système permet, principalement, à l’utilisateur d’ajouter ses revenus et contrôler ses dépenses en les catégorisant selon le type de transactions. Il permet également d’ajouter des comptes afin de contrôler les entrées et sorties de chaque type de compte (compte d’épargne ou compte-chèques par exemple). En contrôlant les transactions de forme quotidienne, nous pourrons réaliser des suivis budgétaires de forme mensuelle et de plus, faire des projections des habitudes de dépense personnelle. À long terme, il nous sera aussi possible de faire des observations statistiques sur notre historique de dépenses.
Le système, étant un type de classeur, est destiné seulement à utilisation personnelle et potentiellement à une utilisation partagée, un couple par exemple. Ce système ne permet pas de faire des transactions sous forme officielle à des comptes bancaires, mais seulement de les enregistrer pour besoin personnel.


Main description of the entities, functions and procedures of the code :

Entités
1. CompteBancaire : Contiens les différents comptes bancaires d’un utilisateur et la description du compte.

2. Transaction : Contiens les transactions faites par un utilisateur en tenant en compte le numéro de compte bancaire et le fond duquel le montant va être déduit ou ajouté.

3. TransactionLigne : Contiens de différentes lignes de transactions qui vont contenir plusieurs transactions regroupées dans une ligne.

4. LigneBudgetaire : Divise les différentes catégories budgétaires sous différents types de dépense ou revenus. Ex : Catégorie : Alimentation (#2) / LigneBudgetaire : Épicerie (#2) , Restaurant (#2).

5. PlanificationBudgetaire : Fais une comparaison entre un montant prévu pour une dépense et le montant réel dépensé dans une ligne budgétaire.

6. CatégorieBudgetaire : Catégorise principalement les divers types de dépenses et revenus possibles.

7. AvanceFond : Table qui contient les différentes avances de fonds fait à une autre personne ou utilisateur et va déterminer si l’avance de fond a été remboursée ou non.

8. Fond : Permets de créer un fond pour mettre de côté de l’argent afin de poursuivre un projet en générale. Ex. : Mise de fonds pour un futur voyage.

Associations
1. Se produit dans : Une ou plusieurs transactions se produisent dans un compte bancaire.

2. Se sépare en : Une transaction se sépare en une ou plusieurs lignes de transactions.

3. Pige dans : Une ou plusieurs transactions pigent un montant à partir d’un fond.

4. Réfère à : Une ou plusieurs lignes de transactions réfèrent à une ligne budgétaire.

5. Se trouve dans : Une ligne budgétaire se retrouve dans une ou plusieurs planifications budgétaires.


