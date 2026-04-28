-- Création de la table Patient
CREATE TABLE Patient (
    idPatient NUMBER,
    nom VARCHAR2(30) NOT NULL,
    prenom VARCHAR2(30) NOT NULL,
    dateNaissance DATE,
    adresse VARCHAR2(100),
    telephone VARCHAR2(8),
    CONSTRAINT pk_patient PRIMARY KEY (idPatient)
);

-- Création de la table Service
CREATE TABLE Service(
    idService NUMBER,
    nomService VARCHAR2(30) NOT NULL,
    capacite NUMBER,
    CONSTRAINT pk_service PRIMARY KEY (idService),
    CONSTRAINT ck_capacite
    CHECK (capacite>=0)
);

-- Création de la table Medecin
CREATE TABLE Medecin(
    idMedecin NUMBER,
    nom VARCHAR2(50) NOT NULL,
    specialite VARCHAR2(50),
    Salaire NUMBER(8,2),
    idService NUMBER,
    CONSTRAINT pk_medecin PRIMARY KEY (idMedecin),
    CONSTRAINT fk_medecin_service FOREIGN KEY (idService) REFERENCES Service(idService),
    CONSTRAINT ck_salaire CHECK (Salaire>0)
);

-- Création de la table RendezVous
CREATE TABLE RendezVous(
    idRdv NUMBER,
    idPatient NUMBER NOT NULL,
    idMedecin NUMBER NOT NULL,
    dateRdv DATE NOT NULL,
    statut VARCHAR2(20),
    CONSTRAINT pk_rendezvous PRIMARY KEY (idRdv),
    CONSTRAINT fk_rendezvous_patient 
    FOREIGN KEY (idPatient) REFERENCES Patient(idPatient) ON DELETE CASCADE,
    CONSTRAINT fk_rendezvous_medecin
    FOREIGN KEY (idMedecin) REFERENCES Medecin(idMedecin) 
);

-- Création de la table Hospitalisation
CREATE TABLE Hospitalisation(
    idHosp NUMBER,
    idPatient NUMBER NOT NULL,
    idService NUMBER NOT NULL,
    dateEntree DATE NOT NULL,
    dateSortie DATE,
    CONSTRAINT pk_hospitalisation PRIMARY KEY (idHosp),
    CONSTRAINT fk_hospitalisation_patient
    FOREIGN KEY (idPatient) REFERENCES Patient(idPatient),
    CONSTRAINT fk_hospitalisation_service
    FOREIGN KEY (idService) REFERENCES Service(idService),
    CONSTRAINT ck_date_hosp
    CHECK (dateSortie >= dateEntree OR dateSortie IS NULL)
);

-- Création de la table Medicament
CREATE TABLE Medicament(
    idMed NUMBER,
    nom VARCHAR2(50) NOT NULL,
    stock NUMBER DEFAULT 0,
    prix NUMBER(8,2),
    CONSTRAINT pk_medicament PRIMARY KEY (idMed),
    CONSTRAINT ck_stock CHECK (stock>=0),
    CONSTRAINT ck_prix CHECK (prix>0)
);

-- Création de la table prescription
CREATE TABLE Prescription(
    idPresc NUMBER,
    idPatient NUMBER NOT NULL,
    idMedecin NUMBER NOT NULL,
    datePresc DATE,
    CONSTRAINT pk_prescription PRIMARY KEY (idPresc),
    CONSTRAINT fk_prescription_patient
    FOREIGN KEY (idPatient) REFERENCES Patient(idPatient),
    CONSTRAINT fk_prescription_medecin
    FOREIGN KEY (idMedecin) REFERENCES Medecin(idMedecin)
);

-- Création de la table Ligne_Prescription
CREATE TABLE Ligne_Prescription(
    idPresc NUMBER,
    idMed NUMBER,
    quantite NUMBER NOT NULL,
    CONSTRAINT pk_ligne_prescription
    PRIMARY KEY (idPresc,idMed),
    CONSTRAINT fk_lignepresc_presc
    FOREIGN KEY (idPresc) REFERENCES Prescription(idPresc),
    CONSTRAINT fk_ligne_presc_medicament
    FOREIGN KEY (idMed) REFERENCES Medicament(idMed),
    CONSTRAINT ck_quantite CHECK (quantite>0)
);

