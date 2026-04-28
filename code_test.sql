SET SERVEROUTPUT ON;

-- ==================== TEST PATIENTS ====================

-- Ajouter patients
EXEC pkg_hopital.ajouter_patient(1, 'Ben Ali', 'Mohamed', DATE '2000-01-15', 'Tunis', '12345678');
EXEC pkg_hopital.ajouter_patient(2, 'Trabelsi', 'Sarra', DATE '1990-05-20', 'Sfax', '87654321');
EXEC pkg_hopital.ajouter_patient(3, 'Mansouri', 'Karim', DATE '1985-03-10', 'Sousse', '11223344');

-- Tester patient deja existant
EXEC pkg_hopital.ajouter_patient(1, 'Ben Ali', 'Mohamed', DATE '2000-01-15', 'Tunis', '12345678');

-- Tester telephone invalide
EXEC pkg_hopital.ajouter_patient(4, 'Jaziri', 'Ines', DATE '1995-07-07', 'Tunis', '123');

-- Tester nom null
EXEC pkg_hopital.ajouter_patient(5, NULL, 'Ines', DATE '1995-07-07', 'Tunis', '99887766');

-- Tester date invalide (future)
EXEC pkg_hopital.ajouter_patient(6, 'Chaabi', 'Ali', DATE '2030-01-01', 'Tunis', '99887766');

-- Afficher patient
EXEC pkg_hopital.afficher_patient(1);

-- Afficher patient inexistant
EXEC pkg_hopital.afficher_patient(999);

-- Modifier patient
EXEC pkg_hopital.modifier_patient(1, 'Ben Ali', 'Mohamed Updated', DATE '2000-01-15', 'Ariana', '11112222');

-- Modifier patient inexistant
EXEC pkg_hopital.modifier_patient(999, 'X', 'X', DATE '2000-01-01', 'X', '12345678');

-- Supprimer patient (on supprimera le 3 qui n'est pas hospitalise)
EXEC pkg_hopital.supprimer_patient(3);

-- Supprimer patient hospitalise
INSERT INTO Hospitalisation
VALUES (2, 2, 1, DATE '2026-04-10', DATE '2026-04-15');

EXEC pkg_hopital.liste_hospitalisations;
EXEC pkg_hopital.supprimer_patient(2);
EXEC pkg_hopital.afficher_patient(2);
-- Supprimer patient inexistant
EXEC pkg_hopital.supprimer_patient(999);

-- ==================== TEST MEDECINS ====================

-- Ajouter medecins (supposons que service 1 et 2 existent)
EXEC pkg_hopital.ajouter_medecin(1, 'Dr. Hamdi', 'Cardiologie', 3000, 1);
EXEC pkg_hopital.ajouter_medecin(2, 'Dr. Lassoued', 'Neurologie', 3500, 2);

-- Tester ID deja existant
EXEC pkg_hopital.ajouter_medecin(1, 'Dr. Autre', 'Autre', 2000, 1);

-- Tester service inexistant
EXEC pkg_hopital.ajouter_medecin(3, 'Dr. Test', 'Chirurgie', 2500, 999);

-- Tester salaire invalide
EXEC pkg_hopital.ajouter_medecin(4, 'Dr. Test', 'Chirurgie', -100, 1);

-- Tester nom null
EXEC pkg_hopital.ajouter_medecin(5, NULL, 'Chirurgie', 2500, 1);

-- Afficher medecin
EXEC pkg_hopital.afficher_medecin(1);

-- Afficher medecin inexistant
EXEC pkg_hopital.afficher_medecin(999);

-- Modifier medecin
EXEC pkg_hopital.modifier_medecin(1, 'Dr. Hamdi Updated', 'Cardiologie', 3200, 1);

-- Modifier medecin inexistant
EXEC pkg_hopital.modifier_medecin(999, 'X', 'X', 1000, 1);

-- Supprimer medecin (on supprimera le 2)
EXEC pkg_hopital.supprimer_medecin(2);

-- Supprimer medecin inexistant
EXEC pkg_hopital.supprimer_medecin(999);

-- ==================== TEST RENDEZ-VOUS ====================

-- Ajouter RDV (dates futures)
EXEC pkg_hopital.ajouter_rendezVous(1, 1, 1, SYSDATE+5, 'planifie');
EXEC pkg_hopital.ajouter_rendezVous(2, 2, 1, SYSDATE+10, 'planifie');

-- Tester RDV deja existant
EXEC pkg_hopital.ajouter_rendezVous(1, 1, 1, SYSDATE+5, 'planifie');

-- Tester patient inexistant
EXEC pkg_hopital.ajouter_rendezVous(3, 999, 1, SYSDATE+7, 'planifie');

-- Tester medecin inexistant
EXEC pkg_hopital.ajouter_rendezVous(4, 1, 999, SYSDATE+7, 'planifie');

-- Tester date invalide (passee)
EXEC pkg_hopital.ajouter_rendezVous(5, 1, 1, SYSDATE-1, 'planifie');

-- Tester date null
EXEC pkg_hopital.ajouter_rendezVous(6, 1, 1, NULL, 'planifie');

-- Tester Trigger 
EXEC pkg_hopital.ajouter_rendezVous(3,1,1,SYSDATE+5,'planifie');

-- Afficher RDV
EXEC pkg_hopital.afficher_rendezVous(1);

-- Afficher RDV inexistant
EXEC pkg_hopital.afficher_rendezVous(999);

-- Afficher tous les RDV d'un medecin
EXEC pkg_hopital.afficher_rdv_medecin(1);

-- Afficher RDV d'un medecin sans RDV
EXEC pkg_hopital.afficher_rdv_medecin(999);

-- Modifier RDV
EXEC pkg_hopital.modifier_rendezVous(1, 1, 1, SYSDATE+15, 'confirme');

-- Modifier RDV inexistant
EXEC pkg_hopital.modifier_rendezVous(999, 1, 1, SYSDATE+5, 'planifie');

-- Supprimer RDV
EXEC pkg_hopital.supprimer_rendezVous(2);

-- Supprimer RDV inexistant
EXEC pkg_hopital.supprimer_rendezVous(999);

-- ==================== TEST MEDICAMENTS ====================

-- Ajouter medicaments
EXEC pkg_hopital.ajouter_medicament(1, 'Paracetamol', 100, 2.5);
EXEC pkg_hopital.ajouter_medicament(2, 'Amoxicilline', 50, 5.0);
EXEC pkg_hopital.ajouter_medicament(3, 'Ibuprofene', 0, 3.0);

-- Tester ID deja existant
EXEC pkg_hopital.ajouter_medicament(1, 'Doliprane', 20, 3.0);

-- Tester stock invalide
EXEC pkg_hopital.ajouter_medicament(4, 'Test', -5, 3.0);

-- Tester prix invalide
EXEC pkg_hopital.ajouter_medicament(5, 'Test', 10, -1);

-- Tester nom null
EXEC pkg_hopital.ajouter_medicament(6, NULL, 10, 3.0);

-- Afficher medicament
EXEC pkg_hopital.afficher_medicament(1);

-- Afficher medicament inexistant
EXEC pkg_hopital.afficher_medicament(999);

-- Modifier medicament
EXEC pkg_hopital.modifier_medicament(1, 'Paracetamol 500mg', 1, 3.0);

-- Modifier medicament inexistant
EXEC pkg_hopital.modifier_medicament(999, 'X', 10, 1.0);

-- Supprimer medicament inexistant
EXEC pkg_hopital.supprimer_medicament(999);

-- ==================== TEST LISTE HOSPITALISATIONS ====================
INSERT INTO Hospitalisation
VALUES (1, 1, 1, DATE '2026-04-10', DATE '2026-04-15');

INSERT INTO Hospitalisation
VALUES (3, 1, 1, DATE '2024-02-10', DATE '2024-04-15');


EXEC pkg_hopital.liste_hospitalisations;

-- ==================== TEST MEDICAMENTS EN RUPTURE ====================

EXEC pkg_hopital.medicaments_rupture;

-- Supprimer medicament
EXEC pkg_hopital.supprimer_medicament(3);

-- ==================== TEST FONCTIONS ====================
EXEC pkg_hopital.afficher_patient(1);
-- ==================== TEST PRESCRIRE MEDICAMENT ====================

DECLARE
    v_meds tab_meds := tab_meds(
        rec_med(1, 1),   -- Paracetamol 500mg, quantite 5
        rec_med(2, 3)    -- Amoxicilline, quantite 3
    );
BEGIN
    pkg_hopital.prescrire_medicament(1, 1, 1, v_meds);
END;
/
-- Nombre de patients dans un service
BEGIN
    IF pkg_hopital.nb_patients_service(1) IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Patients dans service 1: ' || pkg_hopital.nb_patients_service(1));
    END IF;
    IF pkg_hopital.nb_patients_service(999) IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Patients dans service 999: ' || pkg_hopital.nb_patients_service(999));
    END IF;
END;
/

-- Total medicaments prescrits a un patient
BEGIN
    IF pkg_hopital.total_medicaments_patient(1) IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Total medicaments patient 1: ' || pkg_hopital.total_medicaments_patient(1));
    END IF;
    IF pkg_hopital.total_medicaments_patient(999) IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Total medicaments patient 999: ' || pkg_hopital.total_medicaments_patient(999));
    END IF;
END;
/

-- Cout d'une prescription
BEGIN
    IF pkg_hopital.cout_prescription(1) IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Cout prescription 1: ' || pkg_hopital.cout_prescription(1));
    END IF;
    IF pkg_hopital.cout_prescription(999) IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Cout prescription 999: ' || pkg_hopital.cout_prescription(999));
    END IF;
END;
/


-- Tester stock insuffisant
DECLARE
    v_meds tab_meds := tab_meds(
        rec_med(1, 99999)
    );
BEGIN
    pkg_hopital.prescrire_medicament(2, 1, 1, v_meds);
END;
/

-- Tester medecin inexistant
DECLARE
    v_meds tab_meds := tab_meds(rec_med(1, 1));
BEGIN
    pkg_hopital.prescrire_medicament(3, 1, 999, v_meds);
END;
/

-- Tester patient inexistant
DECLARE
    v_meds tab_meds := tab_meds(rec_med(1, 1));
BEGIN
    pkg_hopital.prescrire_medicament(4, 999, 1, v_meds);
END;
/

-- Verifier que le stock a bien diminue apres prescription
EXEC pkg_hopital.afficher_medicament(1);
EXEC pkg_hopital.afficher_medicament(2);

-- Verifier medicaments en rupture apres les tests
EXEC pkg_hopital.medicaments_rupture;