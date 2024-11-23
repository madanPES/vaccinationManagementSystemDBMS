DROP DATABASE IF EXISTS VMS;
CREATE DATABASE VMS;
USE VMS;

-- Table: patient
CREATE TABLE Patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE, -- Date of birth cannot be in the future
    gender ENUM('Male', 'Female', 'Other') NOT NULL,       -- Gender should be restricted to valid options
    blood_group VARCHAR(3) CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-')), -- Valid blood groups
    phone_number VARCHAR(15) CHECK (phone_number REGEXP '^[0-9]+$'), -- Ensure phone number contains only digits
    email VARCHAR(100) UNIQUE,                             -- Ensure email is unique per patient
    address VARCHAR(255),
    password VARCHAR(255) NOT NULL -- Adjust the length based on your hashing strategy
);

-- Table: Vaccine Manufacturer
CREATE TABLE Vaccine_Manufacturer (
    manufacturer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) CHECK (phone_number REGEXP '^[0-9]+$'), -- Only digits allowed in phone number
    email VARCHAR(100) UNIQUE,                                      -- Ensure manufacturer's email is unique
    address VARCHAR(255)
);

-- Table: Vaccine
CREATE TABLE Vaccine (
    vaccine_id INT PRIMARY KEY AUTO_INCREMENT,
    vaccine_name VARCHAR(100) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('Inactivated', 'Live', 'Subunit', 'mRNA', 'Vector')), -- Limited to specific vaccine types
    manufacturer_id INT,
    dosage_amount DECIMAL(5,2) NOT NULL CHECK (dosage_amount > 0),  -- Dosage must be positive
    required_doses INT NOT NULL CHECK (required_doses >= 1),        -- Must require at least one dose
    side_effects VARCHAR(255),
    storage_conditions VARCHAR(255),
    FOREIGN KEY (manufacturer_id) REFERENCES Vaccine_Manufacturer(manufacturer_id)
);

-- Table: Facility
CREATE TABLE Facility (
    facility_id INT PRIMARY KEY AUTO_INCREMENT,
    facility_name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    phone_number VARCHAR(15) CHECK (phone_number REGEXP '^[0-9]+$'),
    email VARCHAR(100) UNIQUE, -- Make email unique
    facility_type VARCHAR(50) CHECK (facility_type IN ('Hospital', 'Clinic', 'Vaccination Center')), -- Restrict to certain facility types
    max_storage_capacity INT NOT NULL CHECK (max_storage_capacity > 0) -- Capacity must be a positive number
);

-- Table: Health Worker
CREATE TABLE Health_Worker (
    health_worker_id VARCHAR(10) PRIMARY KEY, -- Use VARCHAR to allow IDs like "HW123"
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    facility_id INT,
    phone_number VARCHAR(15) CHECK (phone_number REGEXP '^[0-9]+$'),
    email VARCHAR(100) UNIQUE, -- Make email unique
    address VARCHAR(255),
    password VARCHAR(255) NOT NULL, -- Adjust the length based on your hashing strategy 
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id) -- Reference to Facility
);


-- Table: Facility Manager
CREATE TABLE Facility_Manager (
    facility_manager_id VARCHAR(10) PRIMARY KEY, -- Use VARCHAR to allow IDs like "FM123"
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) CHECK (phone_number REGEXP '^[0-9]+$'), -- Ensure phone number contains only digits
    email VARCHAR(100) UNIQUE,                             -- Ensure email is unique per patient
    address VARCHAR(255),
    facility_id INT,
    password VARCHAR(255) NOT NULL, -- Adjust the length based on your hashing strategy 
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id) -- Reference to Facility
);

-- Table: Inventory (now tracking batches of vaccines)
CREATE TABLE Inventory (
    batch_number VARCHAR(50) PRIMARY KEY,
    facility_id INT,          -- which facility stores this batch
    vaccine_id INT,           -- which vaccine type (conceptual)
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0), -- Stock cannot be negative
    expiry_date DATE NOT NULL, -- Expiry date cannot be in the past
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id),
    FOREIGN KEY (vaccine_id) REFERENCES Vaccine(vaccine_id)
);

-- Table: Vaccination Record
CREATE TABLE Vaccination_Record (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    vaccine_id INT,
    health_worker_id VARCHAR(10),
    vaccination_date DATE NOT NULL, -- Vaccination date cannot be in the future
    dose_given INT NOT NULL CHECK (dose_given > 0),              -- Dose must be a positive amount
    batch_number VARCHAR(50),             -- Track the batch the dose comes from
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (vaccine_id) REFERENCES Vaccine(vaccine_id),
    FOREIGN KEY (health_worker_id) REFERENCES Health_Worker(health_worker_id),
    FOREIGN KEY (batch_number) REFERENCES Inventory(batch_number)
);

-- Table: Appointment
CREATE TABLE Appointment (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,                    -- Reference to the patient scheduling the appointment
    facility_id INT NOT NULL,                   -- Reference to the facility where the appointment is scheduled
    health_worker_id VARCHAR(10),               -- Reference to the health worker attending the appointment
    vaccine_id INT NOT NULL,                    -- Reference to the vaccine
    appointment_date DATE NOT NULL,             -- Date of the appointment
    time_slot ENUM('Morning', 'Afternoon', 'Evening') NOT NULL, -- Time slot
    status ENUM('Scheduled', 'Completed', 'Canceled') DEFAULT 'Scheduled', -- Status of the appointment
    comments VARCHAR(255),                      -- Optional comments for the appointment
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id),
    FOREIGN KEY (health_worker_id) REFERENCES Health_Worker(health_worker_id),
    FOREIGN KEY (vaccine_id) REFERENCES Vaccine(vaccine_id)
);


INSERT INTO Patient (first_name, last_name, date_of_birth, gender, blood_group, phone_number, email, address, password)
VALUES (
    'Lucas',                               -- first_name
    'Johnson',                                -- last_name
    '1990-05-15',                         -- date_of_birth
    'Male',                               -- gender
    'O+',                                 -- blood_group
    '1234567890',                         -- phone_number (ensure 10-digit format)
    'a@a.com',                -- email (must be unique)
    '123 Maple Street, Springfield, IL',  -- address
    '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'                   -- password (you’ll likely want to hash this in your app)
);

INSERT INTO Patient (first_name, last_name, date_of_birth, gender, blood_group, phone_number, email, address, password)
VALUES (
    'Emily',                               -- first_name
    'Walker',                              -- last_name
    '1985-07-22',                         -- date_of_birth
    'Female',                             -- gender
    'A-',                                 -- blood_group
    '9876543210',                         -- phone_number (ensure 10-digit format)
    'jane.smith@example.com',             -- email (must be unique)
    '456 Oak Avenue, Chicago, IL',        -- address
    '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'  -- password (hashed)
);

INSERT INTO Patient (first_name, last_name, date_of_birth, gender, blood_group, phone_number, email, address, password)
VALUES (
    'Liam',                               -- first_name
    'Davis',                              -- last_name
    '1992-11-05',                         -- date_of_birth
    'Male',                               -- gender
    'O+',                                 -- blood_group
    '1231231234',                         -- phone_number (ensure 10-digit format)
    'liam.davis@example.com',             -- email (must be unique)
    '789 Pine Road, New York, NY',        -- address
    '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'  -- password (hashed)
);

INSERT INTO Patient (first_name, last_name, date_of_birth, gender, blood_group, phone_number, email, address, password)
VALUES (
    'Sophia',                             -- first_name
    'Brown',                              -- last_name
    '1995-01-30',                         -- date_of_birth
    'Female',                             -- gender
    'B+',                                 -- blood_group
    '5559876543',                         -- phone_number (ensure 10-digit format)
    'sophia.brown@example.com',           -- email (must be unique)
    '101 Birch Lane, Dallas, TX',         -- address
    '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'  -- password (hashed)
);

INSERT INTO Patient (first_name, last_name, date_of_birth, gender, blood_group, phone_number, email, address, password)
VALUES (
    'Mason',                              -- first_name
    'Scott',                              -- last_name
    '1988-04-18',                         -- date_of_birth
    'Male',                               -- gender
    'AB-',                                 -- blood_group
    '3141592653',                         -- phone_number (ensure 10-digit format)
    'mason.scott@example.com',            -- email (must be unique)
    '202 Maple Avenue, Seattle, WA',      -- address
    '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'  -- password (hashed)
);


-- Insert five example vaccine manufacturers into the Vaccine_Manufacturer table

INSERT INTO Vaccine_Manufacturer (name, phone_number, email, address)
VALUES 
    ('Pfizer Inc.', '1234567890', 'contact@pfizer.com', '235 East 42nd Street, New York, NY 10017, USA'),
    ('Moderna Therapeutics', '0987654321', 'info@moderna.com', '200 Technology Square, Cambridge, MA 02139, USA'),
    ('Sanofi Pasteur', '1122334455', 'support@sanofipasteur.com', '14 Espace Henry Vallée, Lyon, France'),
    ('AstraZeneca', '5566778899', 'contact@astrazeneca.com', '1 Francis Crick Avenue, Cambridge, UK'),
    ('Johnson & Johnson', '6677889900', 'info@jnj.com', 'One Johnson & Johnson Plaza, New Brunswick, NJ 08933, USA');


-- Insert five example vaccines into the Vaccine table

INSERT INTO Vaccine (vaccine_name, type, manufacturer_id, dosage_amount, required_doses, side_effects, storage_conditions)
VALUES 
    ('COVID-19 Vaccine', 'mRNA', 1, 0.3, 2, 'Fever, fatigue, muscle pain', 'Store at -70°C'),
    ('Influenza Vaccine', 'Inactivated', 2, 0.5, 1, 'Soreness at injection site, mild fever', 'Store at 2-8°C'),
    ('Hepatitis B Vaccine', 'Subunit', 3, 1.0, 3, 'Soreness at injection site, mild fever', 'Store at 2-8°C'),
    ('MMR Vaccine', 'Live', 4, 0.5, 2, 'Mild rash, fever, joint pain', 'Store at -20°C'),
    ('Tetanus Vaccine', 'Inactivated', 4, 0.5, 1, 'Soreness at injection site, fever', 'Store at 2-8°C');

-- Insert one example facility into the Facility table

INSERT INTO Facility (facility_name, location, phone_number, email, facility_type, max_storage_capacity)
VALUES 
    ('Springfield General Hospital', '123 Elm Street, Springfield, IL', '1234567890', 'contact@springfieldhospital.com', 'Hospital', 5000),
    ('Greenwood Medical Center', '456 Oak Avenue, Greenwood, TX', '9876543210', 'info@greenwoodmedical.com', 'Hospital', 3500);


-- Insert one example facility manager into the Facility_Manager table

INSERT INTO Facility_Manager (facility_manager_id, first_name, last_name, phone_number, email, address, facility_id, password)
VALUES 
    ('FM001', 'Alice', 'Johnson', '0987654321', 'alice.johnson@springfieldhospital.com', '456 Oak Avenue, Springfield, IL', 1, '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'),
    ('FM002', 'Robert', 'Smith', '1234567890', 'robert.smith@greenwoodmedical.com', '789 Pine Road, Greenwood, TX', 2, '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze');
    
INSERT INTO Inventory (batch_number, facility_id, vaccine_id, stock_quantity, expiry_date)
VALUES 
    ('BATCH001COVID19', 1, 1, 5, '2025-12-31'),
    ('BATCH002COVID19', 1, 1, 200, '2026-12-31'),   -- COVID-19 Vaccine
    ('BATCH001INFLUENZA', 1, 2, 150, '2024-11-30'), -- Influenza Vaccine
    ('BATCH002INFLUENZA', 2, 2, 150, '2024-11-30'); -- Influenza Vaccine

INSERT INTO Health_Worker (health_worker_id, first_name, last_name, facility_id, phone_number, email, address, password)
VALUES
    ('HW001', 'John', 'Doe', 1, '1234567890', 'john.doe@example.com', '123 Main St, Cityville', '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'),
    ('HW002', 'Jane', 'Smith', 1, '0987654321', 'jane.smith@example.com', '456 Elm St, Townsville', '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze'),
    ('HW003', 'Alice', 'Johnson', 1, '5555555555', 'alice.johnson@example.com', '789 Oak St, Villageburg', '$2a$10$ifl9mFignyKlZA/jq5Kv7u1lUtmq..gehqzs1PMFY0B93.3AxHpze');
    
    INSERT INTO Appointment (patient_id, facility_id, health_worker_id, vaccine_id, appointment_date, time_slot, status, comments)
VALUES 
    (1, 1, 'HW001', 1, '2024-11-05', 'Morning', 'Scheduled', 'Initial consultation for patient 1'),
(3, 1, 'HW003', 3, '2024-11-07', 'Evening', 'Scheduled', 'Blood work follow-up for patient 3'),
(4, 1, 'HW001', 4, '2024-11-08', 'Morning', 'Canceled', 'X-ray appointment for patient 4'),
(5, 1, 'HW002', 5, '2024-11-09', 'Afternoon', 'Scheduled', 'Physical therapy session for patient 5'),
(5, 1, 'HW001', 5, '2024-11-20', 'Evening', 'Scheduled', 'Pre-surgery consultation for patient 5'),
(5, 1, 'HW002', 5, '2024-11-20', 'Evening', 'Scheduled', 'Pre-surgery consultation for patient 5');



DELIMITER $$

CREATE PROCEDURE GetHealthWorkerWithLeastAppointments(IN facilityId INT)
BEGIN
    SELECT 
        hw.health_worker_id
    FROM 
        Health_Worker hw
    LEFT JOIN 
        Appointment a ON hw.health_worker_id = a.health_worker_id
    WHERE 
        hw.facility_id = facilityId
    GROUP BY 
        hw.health_worker_id
    ORDER BY 
        COUNT(a.appointment_id) ASC
    LIMIT 1;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER update_inventory_after_vaccination
AFTER INSERT ON Vaccination_Record
FOR EACH ROW
BEGIN
    -- Decrease the stock quantity for the specific batch
    UPDATE Inventory
    SET stock_quantity = stock_quantity - NEW.dose_given
    WHERE batch_number = NEW.batch_number;

    -- Check if the stock quantity has reached zero and delete the row if it has
    DELETE FROM Inventory
    WHERE batch_number = NEW.batch_number AND stock_quantity <= 0;
END$$

DELIMITER ;

DELIMITER $$

CREATE EVENT remove_expired_batches
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- Delete expired inventory batches
    DELETE FROM Inventory 
    WHERE expiry_date < CURDATE();
END$$

DELIMITER ;

-- Low Stock Alert Table
CREATE TABLE Low_Stock_Alert (
    low_stock_alert_id INT AUTO_INCREMENT PRIMARY KEY,
    vaccine_id INT,
    facility_id INT,
    FOREIGN KEY (vaccine_id) REFERENCES Vaccine(vaccine_id) ON DELETE CASCADE,
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
);

-- Expiry Alert Table
CREATE TABLE Expiry_Alert (
    expiry_alert_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_number VARCHAR(50),
    facility_id INT,
    FOREIGN KEY (batch_number) REFERENCES Inventory(batch_number) ON DELETE CASCADE,
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
);

-- Procedure for Low Stock Alert Refresh
DELIMITER //
CREATE PROCEDURE RefreshLowStockAlerts()
BEGIN
    -- Clear existing low stock alerts
    DELETE FROM Low_Stock_Alert;
    
    -- Insert new low stock alerts
    INSERT INTO Low_Stock_Alert (vaccine_id, facility_id)
    SELECT vaccine_id, facility_id
    FROM (
        SELECT 
            vaccine_id, 
            facility_id, 
            SUM(stock_quantity) AS total_stock
        FROM Inventory
        GROUP BY vaccine_id, facility_id
    ) AS vaccine_stock
    WHERE total_stock < 10;
END //
DELIMITER ;

-- Event Scheduler for Expiry Alerts
DELIMITER //
CREATE EVENT check_vaccine_expiry
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- Clear existing expiry alerts
    DELETE FROM Expiry_Alert;
    
    -- Insert new expiry alerts
    INSERT INTO Expiry_Alert (batch_number, facility_id)
    SELECT batch_number, facility_id
    FROM Inventory
    WHERE expiry_date <= CURDATE() + INTERVAL 10 DAY;
END //
DELIMITER ;

-- Trigger to Refresh Low Stock Alerts on Inventory Update
DELIMITER //
CREATE TRIGGER refresh_low_stock_alerts
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    CALL RefreshLowStockAlerts();
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER refresh_low_stock_alerts_after_insert
AFTER INSERT ON Inventory
FOR EACH ROW
BEGIN
    CALL RefreshLowStockAlerts();
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER refresh_low_stock_alerts_after_delete
AFTER DELETE ON Inventory
FOR EACH ROW
BEGIN
    CALL RefreshLowStockAlerts();
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER update_expiry_alerts
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    -- Remove existing alerts for this batch
    DELETE FROM Expiry_Alert 
    WHERE batch_number = NEW.batch_number;
    
    -- Insert new alert if batch expires within 10 days
    IF NEW.expiry_date <= CURDATE() + INTERVAL 10 DAY THEN
        INSERT INTO Expiry_Alert (batch_number, facility_id)
        VALUES (NEW.batch_number, NEW.facility_id);
    END IF;
END //
DELIMITER ;

-- Also create a similar trigger for INSERT
DELIMITER //
CREATE TRIGGER insert_expiry_alerts
AFTER INSERT ON Inventory
FOR EACH ROW
BEGIN
    IF NEW.expiry_date <= CURDATE() + INTERVAL 10 DAY THEN
        INSERT INTO Expiry_Alert (batch_number, facility_id)
        VALUES (NEW.batch_number, NEW.facility_id);
    END IF;
END //
DELIMITER ;

-- And a trigger for DELETE to remove corresponding alerts
DELIMITER //
CREATE TRIGGER delete_expiry_alerts
AFTER DELETE ON Inventory
FOR EACH ROW
BEGIN
    DELETE FROM Expiry_Alert 
    WHERE batch_number = OLD.batch_number;
END //
DELIMITER ;

