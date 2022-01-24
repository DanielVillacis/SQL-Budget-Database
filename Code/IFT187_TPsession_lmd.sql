-- Système de contrôle budgetaire.
-- IFT187 : Projet de session 
-- Date : 05 décembre 2021
-- Auteurs : Mathieu Blanchard 
--           Carlos Reyes Marquez
--           Daniel Villacis


------------------------------------------------------------------------------------------------------------------------
-- TRIGGER
------------------------------------------------------------------------------------------------------------------------

-- Ajuster solde compte (solde ou montant à rembourser) ----------------------------------------------------------------
DROP FUNCTION IF EXISTS f_maj_soldeCompte() CASCADE;
DROP TRIGGER IF EXISTS check_maj ON transaction;

CREATE FUNCTION f_maj_soldeCompte()
    RETURNS TRIGGER AS $$
    DECLARE
        soldeCourant decimal(10,2);
        detteCourante decimal(10,2);
        typeCompte varchar(6);
    BEGIN
    -- comptes actif
    SELECT type INTO typeCompte FROM comptebancaire WHERE comptebancaire.no_compte = NEW.no_compte;
    IF typeCompte = 'Actif'
    THEN
        soldeCourant = (SELECT solde FROM comptebancaire WHERE comptebancaire.no_compte = NEW.no_compte);
        UPDATE comptebancaire SET solde = (NEW.montant + soldeCourant)
        WHERE no_compte = NEW.no_compte;
    END IF;
    -- comptes Passif
    IF typeCompte = 'Passif'
    THEN
        detteCourante = (SELECT a_rembourser FROM comptebancaire WHERE comptebancaire.no_compte = NEW.no_compte);
        UPDATE comptebancaire SET a_rembourser = (NEW.montant + detteCourante)
        WHERE no_compte = NEW.no_compte;
    END IF;
    RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

-- Creation du trigger pour f_maj_soldeCompte()
CREATE TRIGGER check_maj
    AFTER UPDATE OR INSERT ON transaction
    FOR EACH ROW
    EXECUTE FUNCTION f_maj_soldeCompte();

-- TEST du trigger check_maj
-- test d'insertion de valeurs sur une transaction
INSERT INTO transaction VALUES (12,'Paiement hydro Sherbrooke', '2021-12-04', 80, 2, 1);
-- Cette insertion va créer une nouvelle transaction, laquelle va être deduit du compte bancaire no.2.
-- verifier le que le montant de 80$ ait un effet sur notre solde du compte bancaire
SELECT solde FROM comptebancaire WHERE no_compte = 2;
-- le montant a bien été mis à jour. Dans le cas d'un montant négatif,
-- le montant de la transaction vas réduire le solde du compte



-- Ajuster le solde de l'Avance de fond --------------------------------------------------------------------------------
-- Fonction pour ajuster le solde de l'avance de fond
DROP FUNCTION IF EXISTS  f_maj_avfnd() CASCADE;
CREATE OR REPLACE FUNCTION f_maj_avfnd()
    RETURNS TRIGGER AS $$
    DECLARE
        montant_courant_avfnd numeric(10, 2);
        rembourse_avfnd varchar(1);
        nouveau_solde numeric(10,2);
        ecart_avfnd numeric(10,2);
    BEGIN
        IF NEW.no_avfnd IS NOT NULL THEN
            RAISE NOTICE 'Nouvelle vancde de fond % ', NEW.no_avfnd;
            -- verifier si l'avance de fond est rembourse ou non (montant = 0)
            SELECT montant
            INTO montant_courant_avfnd
            FROM avancefond
            WHERE no_avfnd = NEW.no_avfnd;
            -- if pour verifier l'update
            IF OLD IS NULL THEN
                nouveau_solde = montant_courant_avfnd + NEW.montant;
                RAISE NOTICE 'acien solde % et montant %', montant_courant_avfnd, NEW.montant;
                UPDATE avancefond SET montant = nouveau_solde
                WHERE no_avfnd = NEW.no_avfnd;
                IF nouveau_solde = 0 THEN rembourse_avfnd = 'O'; ELSE rembourse_avfnd = 'N'; END IF;
                UPDATE avancefond SET rembourse = rembourse_avfnd
                WHERE avancefond.no_avfnd = NEW.no_avfnd;

            ELSE
                RAISE NOTICE 'C''est une mise a jour';
                ecart_avfnd = NEW.montant - OLD.montant;
                UPDATE avancefond SET montant = montant_courant_avfnd + ecart_avfnd
                WHERE no_avfnd = NEW.no_avfnd;
                IF nouveau_solde = 0 THEN rembourse_avfnd = 'O'; ELSE rembourse_avfnd = 'N'; END IF;
                UPDATE avancefond SET rembourse = rembourse_avfnd
                WHERE avancefond.no_avfnd = NEW.no_avfnd;


            END IF;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

-- Creation du trigger pour f_maj_avfnd()
DROP TRIGGER IF EXISTS check_avfnd ON transactionligne;
CREATE TRIGGER check_avfnd
    AFTER UPDATE OR INSERT ON transactionligne
    FOR EACH ROW
    EXECUTE FUNCTION f_maj_avfnd();

-- TEST du trigger check_avfnd
-- test d'insertion de valeurs
INSERT INTO transactionligne VALUES(10,3,66,NULL,NULL,2);
SELECT montant FROM avancefond WHERE no_avfnd = 2;
-- test d'UPDATE
UPDATE transactionligne SET montant = 50 WHERE id = 10;
-- Ce test doit mettre à jour le montant de l'avance de fond no.2
SELECT montant FROM avancefond WHERE no_avfnd = 2;



-- Ajuster le solde du fond ----------------------------------------------------------------------------------------------
-- Fonction pour ajuster le solde du fond
DROP FUNCTION IF EXISTS f_maj_fond() CASCADE;
CREATE OR REPLACE FUNCTION f_maj_fond()
    RETURNS TRIGGER AS $$
    DECLARE
        solde_fond numeric(10,2);
        nouveau_solde_fond numeric(10,2);
        ecart_fond numeric(10,2);
    BEGIN
        RAISE NOTICE 'Nouveau solde de fond % ', NEW.no_fond;
        SELECT fond.solde
        INTO solde_fond
        FROM fond
        WHERE no_fond = NEW.no_fond;

        IF OLD ISNULL THEN
            nouveau_solde_fond = solde_fond + NEW.montant;
            UPDATE fond SET solde = nouveau_solde_fond
            WHERE no_fond = NEW.no_fond;

        ELSE
            ecart_fond = NEW.montant - OLD.montant;
            UPDATE fond SET solde = solde_fond + ecart_fond
            WHERE no_fond = NEW.no_fond;
        END IF;
    --RAISE NOTICE 'acien solde % et montant %', solde_fond, NEW.montant;
    --UPDATE fond SET solde = nouveau_solde_fond
    --WHERE no_fond = NEW.no_fond;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


-- Creation du trigger pour f_maj_fond()
DROP TRIGGER IF EXISTS check_soldeFond ON transaction;
CREATE TRIGGER check_soldeFond
    AFTER UPDATE OR INSERT ON transaction
    FOR EACH ROW
    EXECUTE FUNCTION f_maj_fond();

-- TEST du trigger check_soldeFond
-- Cette insertion va ajouter la valeur de -1500$ à notre fond no.5 (Etudes).
-- Ce test represente un exemple de paiement de facture scolaire, cette valeur de -1500 doit être reduite de notre fond
-- dedié aux études.
INSERT INTO transaction VALUES (17, 'Facture 034 Université', '2021-10-01', 145, 1,5);
-- verifier que le montant soit deduit de notre fond no.5
SELECT solde FROM fond WHERE no_fond = 5;
-- test d'UPDATE
UPDATE transaction SET montant = 80 WHERE no_transaction = 17;
-- verifier que la mise a jour soit faite
SELECT solde FROM fond WHERE no_fond =5;

-- le montant sera ajouté au numéro de fond choisi


-- Ajuster le montant réel de la planification budgétaire --------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_maj_mnt_reel_budget()
RETURNS TRIGGER AS $$
    DECLARE
        mois_trans  INTEGER;
        annee_trans INTEGER;
        ecart_montant_reel DECIMAL(10,2);
    BEGIN
        SELECT EXTRACT(YEAR FROM (SELECT date FROM transaction WHERE no_transaction = NEW.no_transaction))
        INTO annee_trans;

        SELECT EXTRACT(MONTH FROM (SELECT date FROM transaction WHERE no_transaction = NEW.no_transaction))
        INTO mois_trans;

        IF OLD ISNULL THEN
            RAISE NOTICE 'C''est une nouvelle donnée!';
            UPDATE planificationbudgetaire SET montant_reel = montant_reel + NEW.montant
            WHERE annee = annee_trans
            AND mois = mois_trans
            AND nlb = NEW.nlb;
        ELSE
            RAISE NOTICE 'C''est une mise à jour ancienne donnée';
            ecart_montant_reel = NEW.montant - OLD.montant;
            UPDATE planificationbudgetaire SET montant_reel = montant_reel + ecart_montant_reel
            WHERE annee = annee_trans
            AND mois = mois_trans
            AND nlb = NEW.nlb;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS TRG_update_real_planif ON transactionligne;
CREATE TRIGGER TRG_update_real_planif
    AFTER INSERT OR UPDATE ON transactionligne
    FOR EACH ROW
    EXECUTE FUNCTION f_maj_mnt_reel_budget();

-- TESTS du TRG_update_real_planif
    -- test d'INSERT
    INSERT INTO transactionligne VALUES (8, 11, 60, 'ALI002', NULL, NULL);
    -- Cette insertion devrait mettre la valeur réelle 'montant_reel' à 60.00 pour la nlb ALI002, du mois 02, année 2022.
    -- La requête suivante permet de valider que la réponse est bien 60.00 :
    SELECT montant_reel FROM planificationbudgetaire WHERE mois = 2 AND annee = 2022 AND nlb = 'ALI002';
    -- test d'UPDATE
    UPDATE transactionligne SET montant = 89.20 WHERE id = 8;
    -- Cette mise à jour devrait actualiser le 'montant_reel' à 89.20 pour la nlb ALI002, du mois 02, année 2022.
    -- La requête suivante permet de valider que la réponse est bien 89.20 :
    SELECT montant_reel FROM planificationbudgetaire WHERE mois = 2 AND annee = 2022 AND nlb = 'ALI002';

-- Trigger BEFORE INSERT and UPDATE
    -- Vérifier l'entrée dans la table des compte bancaires selon le type choisis (Actif, Passif)
CREATE OR REPLACE FUNCTION FUN_VerifierCompte()
RETURNS TRIGGER AS $$
    DECLARE
	-- Declarations des variables
        type_compte VARCHAR(7);
        a_rembourser DECIMAL(10,2);
        date_fin    DATE;
        solde       DECIMAL(10,2);
    BEGIN
        type_compte = new.type;
        a_rembourser = new.a_rembourser;
        date_fin = new.date_fin;
        solde = new.solde;
        IF type_compte = 'Passif' THEN
            new.solde = NULL;
            IF a_rembourser is NULL OR a_rembourser <= 0 OR date_fin is NULL THEN
                RAISE EXCEPTION 'Veuillez remplir les champs adéquatement';
            END IF;
        ELSE
            new.a_rembourser = NULL;
            new.date_fin = NULL;
            IF solde is NULL THEN
                RAISE EXCEPTION 'Veuillez remplir les champs adéquatement';
            END IF;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS TRG_verifier_comptebancaire ON comptebancaire;

CREATE TRIGGER TRG_verifier_comptebancaire
BEFORE INSERT OR UPDATE ON comptebancaire
FOR EACH ROW
    EXECUTE FUNCTION FUN_VerifierCompte();

------------------------------------------------------------------------------------------------------------------------
-- REQUÊTE
------------------------------------------------------------------------------------------------------------------------
-- Collecte les montants pour chaque catégorie budgétaire
SELECT categoriebudgetaire.nom, SUM(t.montant) as montant
FROM categoriebudgetaire
INNER JOIN lignebudgetaire l on categoriebudgetaire.no_categorie = l.no_categorie
INNER JOIN transactionligne t on l.nlb = t.nlb
GROUP BY categoriebudgetaire.nom
ORDER BY categoriebudgetaire.nom;

-- FONCTION Retourne le total dépensé pour un bien
DROP FUNCTION IF EXISTS f_total_bien(no_bien_target bien.no_bien%TYPE);
CREATE FUNCTION f_total_bien(no_bien_target bien.no_bien%TYPE)
RETURNS transactionligne.montant%TYPE
AS $$
    DECLARE
        montant_total transactionligne.montant%TYPE;
    BEGIN
        SELECT SUM(montant)
        INTO montant_total
        FROM transactionligne
        INNER JOIN bien b ON transactionligne.no_bien = b.no_bien
        WHERE b.no_bien = no_bien_target
        GROUP BY b.no_bien;

        RETURN montant_total;
    END;
$$ LANGUAGE plpgsql;

-- Liste les dépenses associées à un bien
SELECT b.nom AS Bien, f_total_bien(b.no_bien) AS montant
FROM transactionligne
INNER JOIN bien b ON transactionligne.no_bien = b.no_bien
GROUP BY b.no_bien;


------------------------------------------------------------------------------------------------------------------------
-- FONCTION
------------------------------------------------------------------------------------------------------------------------


-- Retourne le solde total dans un nombre de mois X selon la planif budgétaire
DROP FUNCTION IF EXISTS f_solde_futur(date_debut DATE, date_fin DATE);
CREATE FUNCTION f_solde_futur(date_debut DATE, date_fin DATE)
RETURNS comptebancaire.solde%TYPE
AS $$
    DECLARE
        solde_actuel comptebancaire.solde%TYPE;
        total_revenu    DECIMAL(10,2);
        total_depense   DECIMAL(10,2);

    BEGIN
        -- Recueillir le total de mon argent
        SELECT SUM(comptebancaire.solde)
        INTO solde_actuel
        FROM comptebancaire
        WHERE comptebancaire.type = 'Actif';

        -- Recueillir le total de l'argent qui sera dépensé dans la plage de date
        SELECT SUM(planificationbudgetaire.montant_prevu)
        INTO total_depense
        FROM planificationbudgetaire
        INNER JOIN lignebudgetaire l on planificationbudgetaire.nlb = l.nlb
        INNER JOIN categoriebudgetaire c on l.no_categorie = c.no_categorie
        WHERE c.type = 'Dépense'
            AND make_date(planificationbudgetaire.annee::INTEGER, planificationbudgetaire.mois::INTEGER, 1) BETWEEN date_debut AND date_fin;

        -- Recueillir le total de l'argent qui sera recu dans la plage de date
        SELECT SUM(planificationbudgetaire.montant_prevu)
        INTO total_revenu
        FROM planificationbudgetaire
        INNER JOIN lignebudgetaire l on planificationbudgetaire.nlb = l.nlb
        INNER JOIN categoriebudgetaire c on l.no_categorie = c.no_categorie
        WHERE c.type = 'Revenu'
            AND make_date(planificationbudgetaire.annee::INTEGER, planificationbudgetaire.mois::INTEGER, 1) BETWEEN date_debut AND date_fin;

        -- Remplacer les valeurs null
        IF total_revenu ISNULL THEN total_revenu = 0; END IF;
        IF total_depense ISNULL THEN total_depense = 0; END IF;

        RAISE NOTICE 'Entre (%  et %) %$ sera dépensé et %$ sera recu', date_debut, date_fin, total_depense, total_revenu;
        solde_actuel = solde_actuel + total_revenu - total_depense;

        RETURN solde_actuel;
    END;

$$ LANGUAGE plpgsql;