-- Système de contrôle budgetaire.
-- IFT187 : Projet de session 
-- Date : 05 décembre 2021
-- Auteurs : Mathieu Blanchard 
--           Carlos Reyes Marquez
--           Daniel Villacis


DROP TABLE IF EXISTS CategorieBudgetaire CASCADE;
DROP TABLE IF EXISTS Bien CASCADE;
DROP TABLE IF EXISTS Fond CASCADE;
DROP TABLE IF EXISTS AvanceFond CASCADE;
DROP TABLE IF EXISTS LigneBudgetaire CASCADE;
DROP TABLE IF EXISTS PlanificationBudgetaire CASCADE;
DROP TABLE IF EXISTS CompteBancaire CASCADE;
DROP TABLE IF EXISTS "transaction" CASCADE;
DROP TABLE IF EXISTS TransactionLigne CASCADE;

-- Creation des tables
CREATE TABLE CategorieBudgetaire
(
	no_categorie    INTEGER 		NOT NULL,
	nom 		    VARCHAR(50) 	NOT NULL,
	type            VARCHAR(7)      NOT NULL
	CONSTRAINT check_type check (type IN ('Revenu', 'Dépense')) DEFAULT 'Revenu',
	PRIMARY KEY 	(no_categorie)
);

CREATE TABLE Bien
(
	no_bien 		INTEGER		NOT NULL,
	nom 	        VARCHAR(50) NOT NULL,
	PRIMARY KEY (no_bien)
);

CREATE TABLE Fond
(
	no_fond 	    INTEGER 	    NOT NULL,
	description	    VARCHAR(50)	    NOT NULL,
	solde		    DECIMAL(10,2)	NOT NULL,
	PRIMARY KEY 	(no_fond)
);

CREATE TABLE AvanceFond
(
	no_avfnd 	    INTEGER		    NOT NULL,
	montant 		DECIMAL(10,2)   NOT NULL,
	date 		    DATE		    NOT NULL,
	beneficiare 	VARCHAR(50)     NOT NULL,
	rembourse       VARCHAR(1) DEFAULT 'N' NOT NULL CHECK (rembourse IN('O','N')),
	PRIMARY KEY (no_avfnd)
);

CREATE TABLE LigneBudgetaire
(
	nlb 	VARCHAR(15) 		NOT NULL,
	nom 	VARCHAR(50) 		NOT NULL,
	no_categorie 	INTEGER 	NOT NULL,
    no_bien 	    INTEGER 	NULL,
	PRIMARY KEY (nlb),
	FOREIGN KEY (no_categorie) REFERENCES CategorieBudgetaire
);

CREATE TABLE PlanificationBudgetaire
(
	mois 	numeric(2) 		NOT NULL,
	annee 	numeric(4)		NOT NULL,
	nlb 	VARCHAR(15)		NOT NULL,
	montant_prevu	DECIMAL(10,2) NOT NULL,
	montant_reel	DECIMAL(10,2) NOT NULL,
	PRIMARY KEY (mois, annee, nlb),
	FOREIGN KEY (nlb) REFERENCES LigneBudgetaire
);

CREATE TABLE CompteBancaire
(
	no_compte       INTEGER 		NOT NULL,
	description     VARCHAR(50) 	NOT NULL,
	a_rembourser    DECIMAL(10,2) 	NULL,
	date_fin        DATE 	        NULL,
	solde           DECIMAL(10,2) 	NULL,
	type            VARCHAR(6) 	NOT NULL
	CONSTRAINT check_type check (type IN ('Passif', 'Actif')) DEFAULT 'Passif',
	PRIMARY KEY 	(no_compte)
);

CREATE TABLE "transaction"
(
	no_transaction  INTEGER 		NOT NULL,
	description     VARCHAR(50) 	NOT NULL,
	date            DATE 	        NOT NULL,
	montant         DECIMAL(10,2) 	NOT NULL,
	no_compte 	    INTEGER 		NOT NULL,

	no_fond 	    INTEGER 	    NOT NULL,
	PRIMARY KEY 	(no_transaction),
    FOREIGN KEY     (no_fond)   REFERENCES Fond,
	FOREIGN KEY     (no_compte) REFERENCES CompteBancaire
);

CREATE TABLE TransactionLigne
(
    id              INTEGER,
	no_transaction  INTEGER 		NOT NULL,
	montant         DECIMAL(10,2)   NOT NULL,
	nlb 	        VARCHAR(15),
	no_bien         INTEGER,
	no_avfnd 	    INTEGER,

    PRIMARY KEY     (id),
	FOREIGN KEY     (no_transaction)    REFERENCES transaction,
	FOREIGN KEY     (nlb)               REFERENCES LigneBudgetaire,
    FOREIGN KEY     (no_bien)           REFERENCES Bien,
	FOREIGN KEY     (no_avfnd)          REFERENCES AvanceFond
);
