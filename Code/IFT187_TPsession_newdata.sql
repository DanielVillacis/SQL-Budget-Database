-- Système de contrôle budgetaire. 
-- IFT187 : Projet de session 
-- Date : 05 décembre 2021
-- Auteurs : Mathieu Blanchard 
--           Carlos Reyes Marquez
--           Daniel Villacis

DELETE FROM transactionligne;
DELETE FROM transaction;
DELETE FROM comptebancaire;
DELETE FROM planificationbudgetaire;
DELETE FROM lignebudgetaire;
DELETE FROM categoriebudgetaire;
DELETE FROM bien;
DELETE FROM fond;
DELETE FROM avancefond;


INSERT INTO comptebancaire VALUES (1, 'Compte stratégique étudiant', NULL, NULL, 120.00, 'Actif'),
                                  (2, 'Compte d''épargne - CELI', NULL, NULL, 2000.00, 'Actif'),
                                  (3, 'Marge de crédit stratégique étudiant',5000.00, '2024-01-01', NULL, 'Passif'),
                                  (4, 'Prêt étudiant',23000.00, '2026-01-01', NULL, 'Passif'),
                                  (5, 'Visa remise Desjardins',1500.00, '2021-12-12', NULL, 'Passif');

INSERT INTO categoriebudgetaire VALUES (1, 'Habitation', 'Dépense'),
                                       (2, 'Alimentation', 'Dépense'),
                                       (3, 'Communication', 'Dépense'),
                                       (4, 'Travail', 'Revenu'),
                                       (5, 'Bourse', 'Revenu'),
                                       (6, 'Études', 'Dépense'),
                                       (7, 'Transport', 'Dépense'),
                                       (8, 'Autres dépenses', 'Dépense'),
                                       (9, 'Autres revenus', 'Revenu');

INSERT INTO bien VALUES (1, 'Voiture'),
                        (2, 'Maison'),
                        (3, 'Ordinateur'),
                        (4, 'Piscine'),
                        (5, 'Collection de cartes de hockey');

INSERT INTO fond VALUES (1, 'Général', 10000.00),
                        (2, 'Voyage', 5000.00),
                        (3, 'Entretien de voiture', 2000.00),
                        (4, 'Impôts', 300.00),
                        (5, 'Études', 10000.00);

INSERT INTO lignebudgetaire VALUES ('ALI001', 'Épicerie', 2, NULL),
                                   ('ALI002', 'Restaurant', 2, NULL),
                                   ('HAB001', 'Loyer', 1, NULL),
                                   ('HAB002', 'Chauffage', 1, NULL),
                                   ('HAB003', 'Rénovation', 1, 2),
                                   ('HAB004', 'Électricité', 1, NULL),
                                   ('COM001', 'Forfait cellulaire', 3, NULL),
                                   ('TRA001', 'Salaire Ubisoft', 4, NULL),
                                   ('TRA002', 'Salaire Stage', 4, NULL),
                                   ('BOU001', 'Bourse CRSNG', 5, NULL),
                                   ('BOU002', 'Bourse FRQNT', 5, NULL),
                                   ('BOU003', 'Prêt et bourse gouv', 5, NULL),
                                   ('ETU001', 'Frais scolaire', 6, NULL),
                                   ('ETU002', 'Matériel scolaire', 6, NULL),
                                   ('TRS001', 'Essence', 7, NULL),
                                   ('TRS002', 'Permis de conduire', 7, NULL),
                                   ('TRS003', 'Entretien et réparations', 7, 1),
                                   ('TRS004', 'Passe d''autobus', 7, NULL),
                                   ('AUD000', 'Dépenses diverses', 8, NULL),
                                   ('AUR000', 'Revenu diverses', 9, NULL);

INSERT INTO avancefond VALUES (1,50.00, '2021-12-11', 'Daniel', 'N'),
                              (2,150.00, '2021-11-13', 'Mathieu', 'O');

INSERT INTO transaction VALUES (1, 'Big mac McDo', '2021-11-02', -12.10, 5, 1),
                               (2, 'Achat Provigo', '2021-10-04', -50.43, 5, 1),
                               (3, 'Remboursement Mathieu', '2021-11-15', 150, 1, 1),
                               (4, 'Facture Esso', '2021-10-11', -34.98, 5, 1),
                               (5, 'Facture 034 Université', '2021-09-01', -1200, 1, 5),
                               (6, 'Remboursement provenant de la marge', '2021-10-05', 578, 1, 1),
                               (7, 'Avance vers EOP', '2021-10-05', -578, 3, 1),
                               (8, 'Virement gouv QC', '2021-09-03', -1200, 4, 1),
                               (9, 'Dépôt gouv QC', '2021-09-03', 1200, 1, 1),
                               (10, 'Achat écran Acer Best Buy', '2021-10-09', -123.54, 5, 1),
                               (11, 'Restaurant au Coin du Vietnam', '2022-02-06', 60.00, 5, 1);

INSERT INTO transactionligne VALUES (1, 1, 12.10, 'ALI002', NULL, NULL),   -- Lier une avance de fond et un bien à cet endroit + un montant de répartition?
                                    (2, 2, 50.43, 'ALI001', NULL, NULL),   -- Splitter l'épicerie avec l'avance de fond (20$ avance de fond)
                                    (3, 4, 34.98, 'TRS001', NULL, NULL),
                                    (4, 5, 1200, 'ETU001', NULL, NULL),
                                    (5, 8, 1200, 'BOU003', NULL, NULL),   -- Une partie qui est bourse : ex 1000$
                                    (6, 10, 123.54, 'AUD000', 3, NULL),  -- Serait pertinant de le mixer avec un bien (Ordinateur, 10, NULL, NULL)
                                    (7, 3, 150, NULL, NULL, 2);

INSERT INTO planificationbudgetaire VALUES (1, 2022, 'ALI001', 100, 0),
                                           (2, 2022, 'ALI001', 150, 0),
                                           (3, 2022, 'ALI001', 110, 0),
                                           (4, 2022, 'ALI001', 100, 0),
                                           (5, 2022, 'ALI001', 160, 0),
                                           (6, 2022, 'ALI001', 100, 0),
                                           (7, 2022, 'ALI001', 100, 0),
                                           (8, 2022, 'ALI001', 100, 0),
                                           (9, 2022, 'ALI001', 100, 0),
                                           (1, 2022, 'ALI002', 100, 0),
                                           (2, 2022, 'ALI002', 150, 0),
                                           (3, 2022, 'ALI002', 110, 0),
                                           (4, 2022, 'ALI002', 100, 0),
                                           (5, 2022, 'ALI002', 160, 0),
                                           (6, 2022, 'ALI002', 100, 0),
                                           (7, 2022, 'ALI002', 100, 0),
                                           (8, 2022, 'ALI002', 100, 0),
                                           (9, 2022, 'ALI002', 100, 0);