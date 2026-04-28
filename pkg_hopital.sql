-- =========== Création de types =========

CREATE OR REPLACE TYPE rec_med AS OBJECT(
        idMed NUMBER,
        qte NUMBER
);
/
CREATE OR REPLACE TYPE tab_meds AS TABLE OF rec_med;
/

-- ========= Paquet hoptial =============

CREATE OR REPLACE PACKAGE pkg_hopital AS

    ex_patient_existe EXCEPTION;
    ex_patient_introuvable EXCEPTION;
    ex_long_tel EXCEPTION;
    ex_nom_null EXCEPTION;
    ex_prenom_null EXCEPTION;
    ex_date EXCEPTION;

    ex_ser EXCEPTION;
    ex_sal EXCEPTION;
    ex_n EXCEPTION;
    ex_existe EXCEPTION;
    ex_null EXCEPTION;
    ex_introuvable EXCEPTION;

    ex_pr EXCEPTION;
    ex_stk EXCEPTION;

    ex_rdv_existe EXCEPTION;
    ex_rdv_introuvable EXCEPTION;
    ex_date_invalide EXCEPTION;
    ex_rdv_conflit EXCEPTION;

    ex_stock_insuffisant EXCEPTION;
    ex_medecin_introuvable EXCEPTION;
    ex_presc_existe EXCEPTION;

    ex_hosp_vide EXCEPTION;
    ex_capacite_depasse EXCEPTION;

    ex_med EXCEPTION; --medicament
    ex_statut EXCEPTION;

    -- =============== Procédures Patient ===============

    PROCEDURE ajouter_patient(id IN patient.idPatient%type,
        nom_p IN patient.nom%type, 
        prenom_p IN patient.prenom%type, 
        dateNais_p IN patient.dateNaissance%type, 
        adresse_p IN patient.adresse%type, 
        tel_p IN patient.telephone%type);

    PROCEDURE modifier_patient(id_p IN patient.idPatient%type,
        nom_p IN patient.nom%type, 
        prenom_p IN patient.prenom%type, 
        dateNais_p IN patient.dateNaissance%type, 
        adresse_p IN patient.adresse%type, 
        tel_p IN patient.telephone%type);

    PROCEDURE supprimer_patient(id_p IN patient.idPatient%type);

    PROCEDURE afficher_patient(id_p IN patient.idPatient%type);

    -- =============== Procédures Médecin ===============

    PROCEDURE ajouter_medecin(
        idM IN Medecin.idMedecin%TYPE,
        nomM IN Medecin.nom%TYPE,
        Specialite IN Medecin.specialite%TYPE,
        salaire IN Medecin.Salaire%TYPE,
        idS IN Medecin.idService%TYPE
    );
    PROCEDURE modifier_medecin(
        idM IN Medecin.idMedecin%TYPE,
        nomM IN Medecin.nom%TYPE,
        Specialite IN Medecin.specialite%TYPE,
        salaire IN Medecin.Salaire%TYPE,
        idS IN Medecin.idService%TYPE
    );
    PROCEDURE supprimer_medecin (idM IN Medecin.idMedecin%TYPE);
    
    PROCEDURE afficher_medecin (idM IN  Medecin.idMedecin%TYPE);

    PROCEDURE afficher_rdv_medecin (p_idMedecin IN Medecin.idMedecin%TYPE);

    -- =============== Procédures RDV ===============

    PROCEDURE ajouter_rendezVous(
        id_rdv IN rendezVous.idRdv%type,
        id_patient IN rendezVous.idPatient%type,
        id_medecin IN rendezVous.idMedecin%type,
        date_rdv IN rendezVous.dateRdv%type,
        statut_rdv IN rendezVous.statut%type
        );
    
    PROCEDURE modifier_rendezVous(
        id_rdv IN rendezVous.idRdv%type,
        id_patient IN rendezVous.idPatient%type,
        id_medecin IN rendezVous.idMedecin%type,
        date_rdv IN rendezVous.dateRdv%type,
        statut_rdv IN rendezVous.statut%type
        );

    PROCEDURE supprimer_rendezVous(
        id_rdv IN rendezVous.idRdv%type
    );

    PROCEDURE afficher_rendezVous(
        id_rdv IN rendezVous.idRdv%type
    );

    -- =============== Procédures Médicament ===============

    PROCEDURE ajouter_medicament(
        idM IN Medicament.idMed%TYPE,
        nomM IN Medicament.nom%TYPE,
        Stock IN Medicament.stock%TYPE,
        Prix IN Medicament.prix%TYPE
    );
    PROCEDURE modifier_medicament(
        idM IN Medicament.idMed%TYPE,
        nomM IN Medicament.nom%TYPE,
        m_Stock IN Medicament.stock%TYPE,
        m_Prix IN Medicament.prix%TYPE
    );
    PROCEDURE supprimer_medicament (idM IN Medicament.idMed%TYPE);
    
    PROCEDURE afficher_medicament (idM IN  Medicament.idMed%TYPE);

    -- ============== Procédure liste hospitalisation ===========

    PROCEDURE liste_hospitalisations;

    -- =============== Procédure prescrire medicament =========

    PROCEDURE prescrire_medicament (
        id_presc IN Prescription.idPresc%type,
        id_patient IN Patient.idPatient%type,
        id_medecin IN Medecin.idMedecin%type,
        meds IN tab_meds
    );

    -- ============== Procédure médicaments rupture

    PROCEDURE medicaments_rupture;

    -- ============== Fonctions ================

    FUNCTION nb_patients_service (p_idService IN Service.idService%TYPE)  RETURN NUMBER;

    FUNCTION total_medicaments_patient (p_idPatient IN Patient.idPatient%TYPE)  RETURN NUMBER;

    FUNCTION cout_prescription(p_idPresc IN Ligne_Prescription.idPresc%type) RETURN NUMBER;

END pkg_hopital;
/


-- ============== PACKAGE BODY ============

CREATE OR REPLACE PACKAGE BODY pkg_hopital AS

    -- ================ Procédures Patient ===========

    PROCEDURE ajouter_patient(id IN patient.idPatient%type,
        nom_p IN patient.nom%type, 
        prenom_p IN patient.prenom%type, 
        dateNais_p IN patient.dateNaissance%type, 
        adresse_p IN patient.adresse%type, 
        tel_p IN patient.telephone%type) IS
        nb_p INTEGER;
        BEGIN
            SELECT COUNT(*) INTO nb_p FROM Patient WHERE idPatient=id;
            IF nb_p>0 THEN
                RAISE ex_patient_existe;
            END IF;

            IF LENGTH(tel_p)<>8 THEN
                RAISE ex_long_tel;
            END IF;

            IF nom_p IS NULL THEN
                RAISE ex_nom_null;
            END IF;
            IF prenom_p IS NULL THEN
                RAISE ex_prenom_null;
            END IF;

            IF dateNais_p >= SYSDATE THEN
                RAISE ex_date;
            END IF;
            INSERT INTO Patient VALUES (id, nom_p, prenom_p, dateNais_p, adresse_p, tel_p);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('La patient a ete ajoute avec succes');
        EXCEPTION
            WHEN ex_date THEN
                DBMS_OUTPUT.PUT_LINE('Date de naissance invalide');
            WHEN ex_patient_existe THEN
                DBMS_OUTPUT.PUT_LINE('Le Patient '||id||' deja existant');
            WHEN ex_long_tel THEN
                DBMS_OUTPUT.PUT_LINE('Le longueur du numero de telephone doit etre 8');
            WHEN ex_nom_null THEN
                DBMS_OUTPUT.PUT_LINE('Le nom est obligatoire');
            WHEN ex_prenom_null THEN
                DBMS_OUTPUT.PUT_LINE('Le prenom est obligatoire');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
                ROLLBACK;
        END ajouter_patient;

PROCEDURE modifier_patient(id_p IN patient.idPatient%type,
        nom_p IN patient.nom%type, 
        prenom_p IN patient.prenom%type, 
        dateNais_p IN patient.dateNaissance%type, 
        adresse_p IN patient.adresse%type, 
        tel_p IN patient.telephone%type) IS
        nb_p INTEGER;
        BEGIN
            SELECT COUNT(*) INTO nb_p FROM patient WHERE idPatient=id_p;
            IF nb_p=0 THEN
                RAISE ex_patient_introuvable;
            END IF;

            IF LENGTH(tel_p)<>8 THEN
                RAISE ex_long_tel;
            END IF;

            IF nom_p IS NULL THEN
                RAISE ex_nom_null;
            END IF;
            IF prenom_p IS NULL THEN
                RAISE ex_prenom_null;
            END IF;

            UPDATE Patient SET nom=nom_p,
                               prenom=prenom_p,
                               telephone=tel_p,
                               adresse=adresse_p,
                               dateNaissance=dateNais_p
            WHERE idPatient=id_p;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Le patient '||id_p||' a ete modifie avec succes');
        EXCEPTION
            WHEN ex_patient_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('Le Patient '||id_p||' n''existe pas');
            WHEN ex_long_tel THEN
                DBMS_OUTPUT.PUT_LINE('Le longueur du numero de telephone doit etre 8');
            WHEN ex_nom_null THEN
                DBMS_OUTPUT.PUT_LINE('Le nom est obligatoire');
            WHEN ex_prenom_null THEN
                DBMS_OUTPUT.PUT_LINE('Le prenom est obligatoire');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
                ROLLBACK;
        END modifier_patient;

PROCEDURE supprimer_patient(id_p IN patient.idPatient%type) IS
    nb_p INTEGER;
    BEGIN
        SELECT COUNT(*) INTO nb_p FROM Patient WHERE idPatient=id_p;
        IF nb_p=0 THEN
            RAISE ex_patient_introuvable;
        END IF;
        DELETE FROM Patient WHERE idPatient=id_p;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Le patient '||id_p||' est supprime avec succes');
    EXCEPTION
        WHEN ex_patient_introuvable THEN
            DBMS_OUTPUT.PUT_LINE('Patient '||id_p||' n''existe pas');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
            ROLLBACK;
    END supprimer_patient;

PROCEDURE afficher_patient(id_p IN patient.idPatient%type) IS
    rec Patient%rowtype;
    BEGIN
        SELECT * INTO rec FROM Patient WHERE idPatient=id_p;
        DBMS_OUTPUT.PUT_LINE('Patient: '||rec.idPatient);
        DBMS_OUTPUT.PUT_LINE('Nom: '||rec.nom);
        DBMS_OUTPUT.PUT_LINE('Prenom: '||rec.prenom);
        DBMS_OUTPUT.PUT_LINE('Date de naissance: '||rec.dateNaissance);
        DBMS_OUTPUT.PUT_LINE('Adresse: '||rec.adresse);
        DBMS_OUTPUT.PUT_LINE('Numero de telephone: '||rec.telephone);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Le patient '||id_p||' n''existe pas');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
    END afficher_patient;

-- ============= Procédures Médecin ===============

PROCEDURE ajouter_medecin (
        idM IN Medecin.idMedecin%TYPE,
        nomM IN Medecin.nom%TYPE,
        Specialite IN Medecin.specialite%TYPE,
        salaire IN Medecin.Salaire%TYPE,
        idS IN Medecin.idService%TYPE
        ) IS
        nb_s NUMBER;
        nb NUMBER;
        BEGIN
            SELECT COUNT(*) INTO nb FROM Medecin WHERE idMedecin=idM;
            IF nb > 0 THEN
                RAISE ex_existe;
            END IF;
            SELECT COUNT(*) INTO nb_s FROM Service WHERE idService=idS;
            IF nb_s = 0 THEN 
                RAISE ex_ser;
            END IF;
            IF salaire <= 0 THEN
                RAISE ex_sal;
            END IF;
            IF nomM IS NULL THEN
                RAISE ex_null;
            END IF;
            IF Specialite IS NULL THEN
                RAISE ex_null;
            END IF;

            INSERT INTO Medecin VALUES (idM,nomM,Specialite,salaire,idS);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Le Medecin '||idM||' a ete ajoute avec succes');

        EXCEPTION
            WHEN ex_existe THEN
                DBMS_OUTPUT.PUT_LINE('Le Medecin '||idM||' existe deja ');
            WHEN ex_ser THEN
                DBMS_OUTPUT.PUT_LINE('Service inexistant');
            WHEN ex_sal THEN
                DBMS_OUTPUT.PUT_LINE('Salaire invalide');
            WHEN ex_null THEN
                DBMS_OUTPUT.PUT_LINE('tous les champs sont obligatoires');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
                ROLLBACK;
        END ajouter_medecin;

    PROCEDURE modifier_medecin (
        idM IN Medecin.idMedecin%TYPE,
        nomM IN Medecin.nom%TYPE,
        Specialite IN Medecin.specialite%TYPE,
        salaire IN Medecin.Salaire%TYPE,
        idS IN Medecin.idService%TYPE) IS
        nb_s NUMBER;
        nb_m NUMBER;
        BEGIN
            SELECT COUNT(*) INTO nb_m FROM Medecin WHERE idMedecin=idM;
            IF nb_m = 0 THEN
                RAISE ex_introuvable;
            END IF;
            SELECT COUNT(*) INTO nb_s FROM Service WHERE idService=idS;
            IF nb_s = 0 THEN 
                RAISE ex_ser;
            END IF;
            IF salaire <= 0 THEN
                RAISE ex_sal;
            END IF;
            IF nomM IS NULL THEN
                RAISE ex_null;
            END IF;
            IF Specialite IS NULL THEN
                RAISE ex_null;
            END IF;

            UPDATE Medecin 
            SET nom=nomM,
                specialite=Specialite,
                Salaire=salaire,
                idService=idS
                WHERE idMedecin=idM;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Le Medecin '||idM||' a ete modifie avec succes');

        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('ID deja existant');
            WHEN ex_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('ID introuvable');
            WHEN ex_ser THEN
                DBMS_OUTPUT.PUT_LINE('Service inexistant');
            WHEN ex_sal THEN
                DBMS_OUTPUT.PUT_LINE('Salaire invalide');
            WHEN ex_null THEN
                DBMS_OUTPUT.PUT_LINE('tous les champs sont obligatoires');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
                ROLLBACK;
        END modifier_medecin;

    PROCEDURE supprimer_medecin (idM IN Medecin.idMedecin%TYPE) IS
        nb_m NUMBER;
    BEGIN
        SELECT COUNT(*) INTO nb_m FROM Medecin WHERE idMedecin=idM;
        IF nb_m = 0 THEN
            RAISE ex_introuvable;
        END IF;
        DELETE FROM Medecin WHERE idMedecin=idM;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Le Medecin '||idM||' a ete supprime avec succes');
    EXCEPTION
        WHEN ex_introuvable THEN
            DBMS_OUTPUT.PUT_LINE('ID introuvable');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
            ROLLBACK;
    END supprimer_medecin;

    PROCEDURE afficher_medecin (idM IN Medecin.idMedecin%TYPE ) IS
        m Medecin%ROWTYPE;
    BEGIN
        SELECT * INTO m FROM Medecin WHERE idMedecin=idM;
        DBMS_OUTPUT.PUT_LINE('Nom de Medecin: '||m.nom||' - Specialite: '||m.specialite||' - Salaire: '||m.salaire);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Le Medecin '||idM||'n existe pas');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
    END afficher_medecin;

--- CURSEUR PARAMETRE---

    PROCEDURE afficher_rdv_medecin (
    p_idMedecin Medecin.idMedecin%TYPE
    ) IS
        CURSOR cur_rdv (p_idMedecin Medecin.idMedecin%TYPE) IS 
            SELECT r.dateRdv,r.statut,p.nom FROM RendezVous r INNER JOIN Patient p ON r.idPatient=p.idPatient  WHERE r.idMedecin=p_idMedecin ORDER BY r.dateRdv;
        rdv cur_rdv%ROWTYPE;
        r_count NUMBER :=0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Rendez-vous du medecin ID: ' || p_idMedecin || ' ---');
        OPEN cur_rdv (p_idMedecin);
        LOOP
            FETCH cur_rdv INTO rdv;
            EXIT WHEN cur_rdv%NOTFOUND;
            r_count:=r_count+1;
            DBMS_OUTPUT.PUT_LINE('Date: '||TO_CHAR(rdv.dateRdv,'DD/MM/YYYY HH24:MI')||' - Nom Patient: '||rdv.nom||' - Statut: '||rdv.statut);
        END LOOP;
        CLOSE cur_rdv;
        IF r_count=0 THEN
            DBMS_OUTPUT.PUT_LINE('Aucun rendez-vous trouve pour ce medecin.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Erreur Inattendu '||SQLERRM);
    END afficher_rdv_medecin;

-- =================== Procédures RDV =================
PROCEDURE ajouter_rendezVous(
        id_rdv IN rendezVous.idRdv%type,
        id_patient IN rendezVous.idPatient%type,
        id_medecin IN rendezVous.idMedecin%type,
        date_rdv IN rendezVous.dateRdv%type,
        statut_rdv IN rendezVous.statut%type
        ) IS
        nb_rdv INTEGER;
        nb_patient INTEGER;
        nb_medecin INTEGER;
        BEGIN
            SELECT COUNT(*) INTO nb_rdv FROM rendezVous WHERE idRdv=id_rdv;
            IF nb_rdv>0 THEN
                RAISE ex_rdv_existe;
            END IF;
            
            SELECT COUNT(*) INTO nb_patient FROM Patient WHERE idPatient=id_patient;
            IF nb_patient=0 THEN
                RAISE ex_patient_introuvable;
            END IF;
            
            SELECT COUNT(*) INTO nb_medecin FROM Medecin WHERE idMedecin=id_medecin;
            IF nb_medecin=0 THEN
                RAISE ex_medecin_introuvable;
            END IF;
            
            IF date_rdv IS NULL OR date_rdv<SYSDATE THEN
                RAISE ex_date_invalide;
            END IF;
            
            IF statut_rdv NOT IN ('planifie','annule','termine') THEN
                RAISE ex_statut;
            END IF;

            INSERT INTO rendezVous VALUES (id_rdv, id_patient, id_medecin, date_rdv, statut_rdv);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Rendez-Vous ajoute avec succcees');
        EXCEPTION
            WHEN ex_statut THEN
                DBMS_OUTPUT.PUT_LINE('statut invalide');
            WHEN ex_rdv_existe THEN
                DBMS_OUTPUT.PUT_LINE('Le rendez_vous '||id_rdv||' existe deja');
            WHEN ex_patient_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('Le patient '||id_patient||' est introuvable');
            WHEN ex_medecin_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('Le medecin '||id_medecin||' est introuvable');
            WHEN ex_date_invalide THEN
                DBMS_OUTPUT.PUT_LINE('Date invalide');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
                ROLLBACK;
        END ajouter_rendezVous;

PROCEDURE modifier_rendezVous(
        id_rdv IN rendezVous.idRdv%type,
        id_patient IN rendezVous.idPatient%type,
        id_medecin IN rendezVous.idMedecin%type,
        date_rdv IN rendezVous.dateRdv%type,
        statut_rdv IN rendezVous.statut%type
        ) IS
        nb_rdv INTEGER;
        nb_patient INTEGER;
        nb_medecin INTEGER;
        BEGIN
            SELECT COUNT(*) INTO nb_rdv FROM rendezVous WHERE idRdv=id_rdv;
            IF nb_rdv=0 THEN
                RAISE ex_rdv_introuvable;
            END IF;
            
            SELECT COUNT(*) INTO nb_patient FROM Patient WHERE idPatient=id_patient;
            IF nb_patient=0 THEN
                RAISE ex_patient_introuvable;
            END IF;
            
            SELECT COUNT(*) INTO nb_medecin FROM Medecin WHERE idMedecin=id_medecin;
            IF nb_medecin=0 THEN
                RAISE ex_medecin_introuvable;
            END IF;
            
            IF date_rdv<SYSDATE OR date_rdv IS NULL THEN
                RAISE ex_date_invalide;
            END IF;

            IF statut_rdv NOT IN ('planifie','annule','termine') THEN
                RAISE ex_statut;
            END IF;
            
            UPDATE rendezVous SET idPatient=id_patient,
                                  idMedecin=id_medecin,
                                  dateRdv=date_rdv,
                                  statut=statut_rdv
            WHERE idRdv=id_rdv;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Rendez-Vous modifie avec succes');

        EXCEPTION
            WHEN ex_statut THEN
                DBMS_OUTPUT.PUT_LINE('statut invalide');
            WHEN ex_rdv_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('Le rendez-vous '||id_rdv||' est introuvable');
            WHEN ex_patient_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('Le patient '||id_patient||' est introuvable');
            WHEN ex_medecin_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('Le medecin '||id_medecin||' est introuvable');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
                ROLLBACK;
        END  modifier_rendezVous;

        PROCEDURE supprimer_rendezVous(
            id_rdv IN rendezVous.idRdv%type
    ) IS
    nb_rdv INTEGER;
    BEGIN
        SELECT COUNT(*) INTO nb_rdv FROM rendezVous WHERE idRdv=id_rdv;
        IF nb_rdv=0 THEN
            RAISE ex_rdv_introuvable;
        END IF;
        
        DELETE FROM rendezVous WHERE idRdv=id_rdv;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Rendez-Vous supprime avec succes');
    EXCEPTION
        WHEN ex_rdv_introuvable THEN
            DBMS_OUTPUT.PUT_LINE('Le rendez-vous '||id_rdv||' est introuvable');
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
            ROLLBACK;
    END supprimer_rendezVous;

PROCEDURE afficher_rendezVous(
    id_rdv IN rendezVous.idRdv%type
) IS
    TYPE rec_type IS RECORD (
        nom_p Patient.nom%type,
        prenom_p Patient.prenom%type,
        nom_m Medecin.nom%type,
        date_rdv rendezVous.dateRdv%type,
        statut_rdv rendezVous.statut%type
    );
    rec rec_type;
    BEGIN
        SELECT 
        p.nom, p.prenom, m.nom, r.dateRdv, r.Statut
        INTO rec.nom_p, rec.prenom_p, rec.nom_m, rec.date_rdv, rec.statut_rdv
        FROM rendezVous r
        INNER JOIN Patient p ON r.idPatient=p.idPatient
        INNER JOIN Medecin m ON r.idMedecin=m.idMedecin
        WHERE r.idRdv=id_rdv;

        DBMS_OUTPUT.PUT_LINE('Rendez-Vous: '||id_rdv);
        DBMS_OUTPUT.PUT_LINE('Nom patient: '||rec.nom_p);
        DBMS_OUTPUT.PUT_LINE('Prenom patient: '||rec.prenom_p);
        DBMS_OUTPUT.PUT_LINE('Nom medecin: '||rec.nom_m);
        DBMS_OUTPUT.PUT_LINE('Date rendez-vous: '||TO_CHAR(rec.date_rdv, 'DD/MM/YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('Statut: '||rec.statut_rdv);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Le rendez-vous '||id_rdv||' est introuvable');
        WHEN OTHERs THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
        
    END afficher_rendezVous;

-- ===================== Procédures médicament ===============

PROCEDURE ajouter_medicament (
        idM IN Medicament.idMed%TYPE,
        nomM IN Medicament.nom%TYPE,
        Stock IN Medicament.stock%TYPE,
        Prix IN Medicament.prix%TYPE
        ) IS
        BEGIN
            IF Stock < 0 THEN
                RAISE ex_stk;
            END IF;
            IF nomM IS NULL THEN
                RAISE ex_null;
            END IF;
            IF Prix <= 0 THEN
                RAISE ex_pr;
            END IF;

            INSERT INTO Medicament VALUES (idM,nomM,Stock,Prix);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Medicament ajoute');

        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('Le Medicament '||idM||' deja existe');
            WHEN ex_stk THEN
                DBMS_OUTPUT.PUT_LINE('stock doit etre positive');
            WHEN ex_pr THEN
                DBMS_OUTPUT.PUT_LINE('prix doit etre positive');
            WHEN ex_null THEN
                DBMS_OUTPUT.PUT_LINE('Tous les champs sont obligatoires');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendu: '||SQLERRM);
                ROLLBACK;
        END ajouter_medicament;

    PROCEDURE modifier_medicament (
        idM IN Medicament.idMed%TYPE,
        nomM IN Medicament.nom%TYPE,
        m_Stock IN Medicament.stock%TYPE,
        m_Prix IN Medicament.prix%TYPE
        ) IS
        nb_m NUMBER;
        BEGIN
            SELECT COUNT(*) INTO nb_m FROM Medicament WHERE idMed=idM;
            IF nb_m = 0 THEN
                RAISE ex_introuvable;
            END IF;
            IF m_Stock < 0 THEN
                RAISE ex_stk;
            END IF;
            IF nomM IS NULL THEN
                RAISE ex_null;
            END IF;
            IF m_Prix <= 0 THEN
                RAISE ex_pr;
            END IF;

            UPDATE Medicament 
            SET nom=nomM,
                stock=m_Stock,
                prix=m_Prix
                WHERE idMed=idM;

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Medicament modifie');

        EXCEPTION
            WHEN ex_introuvable THEN
                DBMS_OUTPUT.PUT_LINE('le Medicament '||idM||' n existe pas');
            WHEN ex_stk THEN
                DBMS_OUTPUT.PUT_LINE('stock doit etre positive');
            WHEN ex_pr THEN
                DBMS_OUTPUT.PUT_LINE('prix doit etre positive');
            WHEN ex_null THEN
                DBMS_OUTPUT.PUT_LINE('Tous les champs sont obligatoires');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
                ROLLBACK;
        END modifier_medicament;

    PROCEDURE supprimer_medicament (idM IN Medicament.idMed%TYPE) IS
        nb_m NUMBER;
    BEGIN
        SELECT COUNT(*) INTO nb_m FROM Medicament WHERE idMed=idM;
        IF nb_m = 0 THEN
            RAISE ex_introuvable;
        END IF;
        DELETE from Medicament WHERE idMed=idM;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Le Medicament '||idM||' a ete supprime avec succes');
    EXCEPTION
        WHEN ex_introuvable THEN
            DBMS_OUTPUT.PUT_LINE('ID introuvable');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
            ROLLBACK;
    END supprimer_medicament;

    PROCEDURE afficher_medicament (idM IN Medicament.idMed%TYPE ) IS
        m Medicament%ROWTYPE;
    BEGIN
        SELECT * INTO m FROM Medicament WHERE idMed=idM;
        DBMS_OUTPUT.PUT_LINE('Nom de Medicament: '||m.nom||' - Stock: '||m.stock||' - Prix: '||m.prix);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Medicament '||idM||' n existe pas');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
    END afficher_medicament;


-- =============Procédure liste_hospitalisation =========

PROCEDURE liste_hospitalisations
IS
    CURSOR cur IS SELECT 
    p.nom, p.prenom, s.nomService,(ROUND(NVL(h.dateSortie,SYSDATE)-h.dateEntree)) AS duree
    FROM Hospitalisation h
    INNER JOIN Patient p ON p.idPatient=h.idPatient
    INNER JOIN Service s ON s.idService=h.idService;
    compteur INTEGER :=0;

BEGIN
    FOR rec IN cur LOOP
    DBMS_OUTPUT.PUT_LINE('============Hospitalisation=============');
        compteur:=compteur+1;
        DBMS_OUTPUT.PUT_LINE('N '||compteur||': Nom patient: '||rec.nom|| '-Prenom patient: '||rec.prenom||'-Nom service: '||rec.nomService||'-Duree de sejour: '||rec.duree||' jours');
    END LOOP;
    IF compteur = 0 THEN
        RAISE ex_hosp_vide;
    END IF;
EXCEPTION
    WHEN ex_hosp_vide THEN
        DBMS_OUTPUT.PUT_LINE('Aucune hospitalisation trouvee');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
END liste_hospitalisations;

-- ============Préscrire medicament ==========
PROCEDURE prescrire_medicament (
    id_presc IN Prescription.idPresc%type,
    id_patient IN Patient.idPatient%type,
    id_medecin IN Medecin.idMedecin%type,
    meds IN tab_meds
) IS
    stock_actuel NUMBER;
    nb_patient NUMBER;
    nb_medecin NUMBER;
    nb_presc NUMBER;
    id_medic Medicament.idMed%type;
    CURSOR cur_stock(p_idMed NUMBER) IS
        SELECT stock FROM Medicament WHERE idMed = p_idMed FOR UPDATE;
BEGIN
    SELECT COUNT(*) INTO nb_medecin FROM Medecin WHERE idMedecin=id_medecin;
    IF nb_medecin=0 THEN
        RAISE ex_medecin_introuvable;
    END IF;

    SELECT COUNT(*) INTO nb_patient FROM Patient WHERE idPatient=id_patient;
    IF nb_patient=0 THEN
        RAISE ex_patient_introuvable;
    END IF;
    IF meds IS NULL OR meds.count=0 THEN
        RAISE ex_med;
    END IF;

    INSERT INTO Prescription VALUES (id_presc, id_patient, id_medecin, SYSDATE);
    FOR i IN 1..meds.COUNT LOOP
        id_medic:=meds(i).idMed;
        OPEN cur_stock(meds(i).idMed);
        FETCH cur_stock INTO stock_actuel;
        CLOSE cur_stock;

        IF stock_actuel<meds(i).qte THEN
            RAISE ex_stock_insuffisant;
        END IF;
    
        INSERT INTO Ligne_Prescription VALUES (id_presc, meds(i).idMed, meds(i).qte);

        UPDATE Medicament
        SET stock=stock-meds(i).qte WHERE idMed=meds(i).idMed;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Prescription N: '||id_presc||' enregistree avec succes');
    
EXCEPTION
    WHEN ex_med THEN
        DBMS_OUTPUT.PUT_LINE('Aucun medicament fourni');
    WHEN ex_stock_insuffisant THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Stock insuffisant pour medicament '||id_medic);
    WHEN ex_medecin_introuvable THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Medecin ID '||id_medecin||' introuvable.');
    WHEN ex_patient_introuvable THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Patient ID '||id_patient||' introuvable.');
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('L''ID Prescription '||id_presc||' et l''ID medicament '||id_medic||' existe deja.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
END prescrire_medicament;

-- =========== Procédure medicaments_rupture ===========
PROCEDURE medicaments_rupture  IS
    TYPE tab IS TABLE OF Medicament.nom%TYPE INDEX BY BINARY_INTEGER;
    med_rup tab; 
    i NUMBER:=0;
BEGIN
    FOR r IN (SELECT nom FROM Medicament WHERE stock = 0) LOOP
        i := i + 1;
        med_rup(i) := r.nom;
    END LOOP;
    IF i = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucun medicament en rupture de stock');
        RETURN;
    END IF;
    DBMS_OUTPUT.PUT_LINE('--- Medicament en rupture ---');
    FOR j IN 1 .. i LOOP
        DBMS_OUTPUT.PUT_LINE('Nom medicament : '||med_rup(j) );
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
END medicaments_rupture;

-- =================FONCTIONS=============
FUNCTION nb_patients_service (p_idService IN Service.idService%TYPE)  RETURN NUMBER 
IS
    nb_p NUMBER :=0 ;
    nb NUMBER :=0;
    BEGIN
        SELECT count(*) INTO nb  FROM Service WHERE idService=p_idService;
        IF nb = 0 THEN
            RAISE ex_introuvable;
        END IF;
        SELECT count(*) INTO nb_p FROM Hospitalisation WHERE idService=p_idService;
        RETURN nb_p;
    EXCEPTION
        WHEN ex_introuvable THEN
            DBMS_OUTPUT.PUT_LINE('Service '||p_idService||' n existe pas');
            RETURN NULL;
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : plusieurs lignes ont ete retournees ');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
            RETURN NULL;
    END nb_patients_service;

FUNCTION total_medicaments_patient (p_idPatient IN Patient.idPatient%TYPE)  RETURN NUMBER 
IS
    nb_med NUMBER :=0 ;
    nb NUMBER :=0;
    BEGIN
        SELECT count(*) INTO nb FROM Patient WHERE idPatient=p_idPatient;
        IF nb = 0 THEN
            RAISE ex_introuvable;
        END IF;
        SELECT NVL(SUM(lp.quantite),0) INTO nb_med FROM Prescription p INNER JOIN Ligne_Prescription lp on p.idPresc=lp.idPresc WHERE p.idPatient=p_idPatient;
        RETURN nb_med;
    EXCEPTION
        WHEN ex_introuvable THEN
            DBMS_OUTPUT.PUT_LINE('Patient '||p_idPatient||' n existe pas');
            RETURN NULL;
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN TOO_MANY_ROWS THEN 
            DBMS_OUTPUT.PUT_LINE('Erreur : plusieurs lignes ont ete retournees');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue '||SQLERRM);
            RETURN NULL;
    END total_medicaments_patient;

FUNCTION cout_prescription(p_idPresc IN Ligne_Prescription.idPresc%type) RETURN NUMBER
IS
    cout NUMBER:=0;
    nb  NUMBER :=0;
    BEGIN
        SELECT count(*) INTO nb FROM Ligne_Prescription WHERE idPresc=p_idPresc ;
        IF nb = 0 THEN
            RAISE ex_introuvable;
        END IF;    
        SELECT NVL(SUM(m.prix*l.quantite),0) INTO cout FROM Ligne_Prescription l
        JOIN Medicament m ON l.idMed=m.idMed
        WHERE l.idPresc=p_idPresc;
        RETURN cout;

    EXCEPTION
        WHEN ex_introuvable THEN
            DBMS_OUTPUT.PUT_LINE('Prescription '||p_idPresc||' n existe pas');
            RETURN NULL;
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('La ligne prescription '||p_idPresc||' est introuvable');
            RETURN 0;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : plusieurs lignes ont ete retournees');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue: '||SQLERRM);
            RETURN NULL;
    END cout_prescription;

END pkg_hopital;
/


-- ================TRIGGERS==================

-- Trigger before delet patient

CREATE OR REPLACE TRIGGER  trg_patient_del 
BEFORE DELETE ON Patient
FOR EACH ROW 
    DECLARE
        nb NUMBER;
    BEGIN
    SELECT COUNT(*) INTO nb FROM Hospitalisation WHERE idPatient=:OLD.idPatient;
    IF nb>0 THEN
        RAISE_APPLICATION_ERROR(-20010,'Patient hospitalise, suppression interdite');
    END IF;
END trg_patient_del;
/

-- Trigger before insert rdv

CREATE OR REPLACE TRIGGER trg_before_insert_rdv
BEFORE INSERT OR UPDATE ON RendezVous
FOR EACH ROW
DECLARE
    nb_conflit NUMBER;
BEGIN
    SELECT COUNT(*) INTO nb_conflit
    FROM RendezVous
    WHERE idMedecin = :NEW.idMedecin
    AND idRdv!=:NEW.idRdv
    AND (ABS(dateRdv-:NEW.dateRdv)*24*60)<30
    AND statut != 'annule';

    IF nb_conflit > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'Conflit : Le medecin '||:NEW.idMedecin||' a deja un rendez-vous a cette date.');
    END IF;
END trg_before_insert_rdv;
/

-- Trigger before insert hospitalisation

CREATE OR REPLACE TRIGGER trg_before_insert_hosp
BEFORE INSERT ON Hospitalisation
FOR EACH ROW
DECLARE
    v_capacite Service.capacite%TYPE;
    p_nb NUMBER;
    nb NUMBER;
BEGIN
    --capacite de service
    SELECT capacite INTO v_capacite FROM Service WHERE idService=:NEW.idService;
    -- nbre actuel de patients dans ce service
    p_nb := pkg_hopital.nb_patients_service(:NEW.idService);
    IF p_nb >= v_capacite THEN
        RAISE_APPLICATION_ERROR(-20070,'Capacite du service depassee');
    END IF;
    -- double hospitalisation
    SELECT COUNT(*) INTO nb FROM Hospitalisation WHERE idPatient=:NEW.idPatient AND (
            (:NEW.dateEntree BETWEEN dateEntree AND NVL(dateSortie, SYSDATE))
        OR  (:NEW.dateSortie BETWEEN dateEntree AND NVL(dateSortie, SYSDATE)));
    IF nb > 0 THEN
        RAISE_APPLICATION_ERROR(-20060,'Double hospitalisation interdite pour ce patient');
    END IF;
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20071, 'Service '||:NEW.idService||' inexistant');
END trg_before_insert_hosp;
/

-- Trigger after update prescription

CREATE OR REPLACE TRIGGER trg_after_update_presc
AFTER UPDATE ON Prescription
FOR EACH ROW
BEGIN
    FOR rec IN (SELECT idMed,quantite FROM Ligne_Prescription WHERE idPresc=:NEW.idPresc) LOOP
        UPDATE Medicament 
        SET stock=stock-rec.quantite
        WHERE idMed=rec.idMed;
    END LOOP;
END trg_after_update_presc;
/

-- Trigger ddl

CREATE OR REPLACE TRIGGER trg_ddl
AFTER CREATE OR ALTER OR DROP
ON SCHEMA
BEGIN
    DBMS_OUTPUT.PUT_LINE('Une operation DDL detectee: '||ORA_SYSEVENT||' sur l''objet: '||ORA_DICT_OBJ_NAME);
END trg_ddl;
/

-- Trigger d'instance

CREATE OR REPLACE TRIGGER trg_logon_user
AFTER LOGON ON DATABASE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Bienvenue ' || USER ||' - Connexion réussie à la base de données à ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
END trg_logon_user;
/