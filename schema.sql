-- =========================================================
-- School Clinic Appointment Management System
-- with SMS and Email Notifications
-- ISAT U Dumangas Campus
-- =========================================================

CREATE DATABASE IF NOT EXISTS clinic_appointment_system
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE clinic_appointment_system;

-- ---------------------------------------------------------
-- Staff accounts: Administrator and School Nurse
-- ---------------------------------------------------------
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    role          ENUM('admin', 'nurse') NOT NULL DEFAULT 'nurse',
    email         VARCHAR(100),
    is_active     TINYINT(1) NOT NULL DEFAULT 1,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Students (self-registered accounts)
-- ---------------------------------------------------------
CREATE TABLE students (
    id                       INT AUTO_INCREMENT PRIMARY KEY,
    student_id               VARCHAR(30)  NOT NULL UNIQUE,
    first_name                VARCHAR(60)  NOT NULL,
    last_name                 VARCHAR(60)  NOT NULL,
    gender                     ENUM('Male', 'Female', 'Other'),
    date_of_birth              DATE,
    course_section              VARCHAR(100),
    email                       VARCHAR(100) NOT NULL UNIQUE,
    password_hash               VARCHAR(255) NOT NULL,
    contact_number               VARCHAR(20)  NOT NULL,
    address                       VARCHAR(255),
    blood_type                    VARCHAR(5),
    allergies                      VARCHAR(255),
    medical_history                 TEXT,
    emergency_contact_name            VARCHAR(100),
    emergency_contact_number           VARCHAR(20),
    is_active                            TINYINT(1) NOT NULL DEFAULT 1,
    created_at                           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Clinic services offered
-- ---------------------------------------------------------
CREATE TABLE services (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    duration_minutes INT DEFAULT 30,
    is_active   TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Health announcements posted by staff
-- ---------------------------------------------------------
CREATE TABLE announcements (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(150) NOT NULL,
    body         TEXT NOT NULL,
    posted_by    INT NULL,
    is_published TINYINT(1) NOT NULL DEFAULT 1,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_announce_user FOREIGN KEY (posted_by) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Appointments
-- ---------------------------------------------------------
CREATE TABLE appointments (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    student_id        INT NOT NULL,
    service_id        INT NOT NULL,
    appointment_date  DATE NOT NULL,
    appointment_time  TIME NOT NULL,
    reason            VARCHAR(255),
    status            ENUM('pending','confirmed','rescheduled','completed','cancelled','no_show')
                        NOT NULL DEFAULT 'pending',
    handled_by        INT NULL,               -- nurse/admin who last updated it
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_appt_student FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_appt_service FOREIGN KEY (service_id) REFERENCES services(id),
    CONSTRAINT fk_appt_staff FOREIGN KEY (handled_by) REFERENCES users(id)
        ON DELETE SET NULL,
    INDEX idx_appt_date (appointment_date, appointment_time)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Consultation records - filled in by the nurse after a visit
-- ---------------------------------------------------------
CREATE TABLE consultation_records (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id      INT NOT NULL UNIQUE,
    nurse_id            INT NULL,
    diagnosis           VARCHAR(255),
    medicine_prescribed  VARCHAR(255),
    notes                TEXT,
    follow_up_date        DATE NULL,
    created_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_consult_appt FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_consult_nurse FOREIGN KEY (nurse_id) REFERENCES users(id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Notification log (email + SMS audit trail)
-- ---------------------------------------------------------
CREATE TABLE notification_logs (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    channel        ENUM('email','sms') NOT NULL,
    recipient      VARCHAR(150) NOT NULL,
    message        TEXT NOT NULL,
    status         ENUM('sent','failed') NOT NULL,
    error_detail   VARCHAR(255),
    sent_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_appt FOREIGN KEY (appointment_id) REFERENCES appointments(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Seed data
-- ---------------------------------------------------------

-- Placeholder staff accounts. The password_hash values below are NOT valid.
-- Generate real ones with: php create_admin_hash.php "YourChosenPassword"
-- then UPDATE these rows (see README).
INSERT INTO users (username, password_hash, full_name, role, email) VALUES
('admin', '$2y$10$REPLACE_WITH_GENERATED_HASH', 'Clinic Administrator', 'admin', 'clinic.admin@isatu-dumangas.edu.ph'),
('nurse.santos', '$2y$10$REPLACE_WITH_GENERATED_HASH', 'Nurse Maria Santos', 'nurse', 'clinic.nurse@isatu-dumangas.edu.ph');

INSERT INTO services (name, description, duration_minutes) VALUES
('General Consultation', 'Basic medical check-up and consultation', 20),
('Dental Check-up', 'Dental consultation and minor procedures', 30),
('First Aid / Injury', 'Treatment of minor injuries and first aid', 15),
('Medical Certificate Request', 'Issuance of medical certificate', 15),
('Vaccination', 'Immunization and vaccine administration', 20);

INSERT INTO announcements (title, body, posted_by, is_published) VALUES
('Clinic Hours for This Semester', 'The campus clinic is open Monday to Friday, 8:00 AM to 5:00 PM. Walk-ins are welcome for emergencies; please book ahead for routine consultations.', 1, 1),
('Flu Season Reminder', 'Please practice good hygiene and rest well. Visit the clinic if you experience persistent fever, cough, or colds.', 1, 1);
