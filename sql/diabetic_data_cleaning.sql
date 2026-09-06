/*
Project: Readmission
Database: healthcare_analytics
Author: Kardin Nguyen
Description:
This project aims to identify factors associated with 30-day readmission
among diabetic patients and develop an effective logistic regression model.
The analysis will involve data cleaning, variable selection, model diagnostics, 
and comparison to alternative models to identify a strong model with good 
predictive performance and interpretation.
*/

USE healthcare_analytics;

CREATE TABLE diabetic_data1 LIKE diabetic_data_raw;
    
INSERT INTO diabetic_data1
SELECT * 
FROM diabetic_data_raw;

SELECT * 
FROM diabetic_data1;

-- 1. CHECKING/REMOVING DUPLICATES

SELECT * 
FROM(
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY encounter_id
			ORDER BY encounter_id
		)row_num
	FROM diabetic_data1
)t
WHERE row_num > 1;

-- 2. HANDLE MISSING DATA

-- Excluding weight from the modeling dataset because
-- nearly all patients had no weight recorded.
SELECT weight, 
COUNT(*) AS count
FROM diabetic_data1
GROUP BY weight
ORDER BY count DESC;

ALTER TABLE diabetic_data1
DROP COLUMN weight;

-- Replacing missing payer_code values (?) with "Unknown" 
SELECT payer_code, COUNT(*) AS count
FROM diabetic_data1
GROUP BY payer_code
ORDER BY count DESC;

UPDATE diabetic_data1 
SET payer_code = 'Unknown'
WHERE payer_code = '?';

-- Replacing missing medical_specialty values (?) with "Unknown"
UPDATE diabetic_data1
SET medical_specialty = 'Unknown'
WHERE medical_specialty = '?';

-- 3. GROUPING VARIABLES

-- Combining all medical_specialty_id values with less than 800 patients to "Other"
UPDATE diabetic_data1
SET medical_specialty = 'Other'
WHERE medical_specialty IN(
	SELECT medical_specialty
	FROM(
		SELECT medical_specialty
		FROM diabetic_data1
		GROUP BY medical_specialty
		HAVING COUNT(*) < 800
		)low_count
	);

ALTER TABLE diabetic_data_clean
ADD COLUMN age_decade INT;

UPDATE diabetic_data_clean
SET age_decade = 
	CASE
		WHEN age = '[0-10)' THEN 1
        WHEN age = '[10-20)' THEN 2
		WHEN age = '[20-30)' THEN 3
        WHEN age = '[30-40)' THEN 4
        WHEN age = '[40-50)' THEN 5
        WHEN age = '[50-60)' THEN 6
        WHEN age = '[60-70)' THEN 7
        WHEN age = '[70-80)' THEN 8
        WHEN age = '[80-90)' THEN 9
        WHEN age = '[90-100)' THEN 10
	END;
    
ALTER TABLE diabetic_data_clean
DROP COLUMN age;

-- Grouping diagnoses codes to their respective categories
-- diag_1
ALTER TABLE diabetic_data1
ADD COLUMN diag1ver2 TEXT;

UPDATE diabetic_data1
SET diag1ver2 =
    CASE
		WHEN diag_1 = '?' THEN 'Unknown'
        
		WHEN diag_1 LIKE 'V%' THEN 'Supplemental'
        WHEN diag_1 LIKE 'E%' THEN 'Injury/Poisoning'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 1 AND 139
            THEN 'Infectious/Parasitic'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 140 AND 239
            THEN 'Neoplasms'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 240 AND 279
            THEN 'Endocrine/Metabolic/Immunity'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 280 AND 289
            THEN 'Blood'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 290 AND 319
            THEN 'Mental'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 320 AND 389
            THEN 'Nervous System/ Sense Organ'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 390 AND 459
            THEN 'Circulatory'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 460 AND 519
            THEN 'Respiratory'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 520 AND 579
            THEN 'Digestive'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 580 AND 629
            THEN 'Genitourinary'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 630 AND 679
            THEN 'Pregnancy'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 680 AND 709
            THEN 'Skin'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 710 AND 739
            THEN 'Musculoskeletal'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 740 AND 759
            THEN 'Congenital'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 760 AND 779
            THEN 'Perinatal'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 780 AND 799
            THEN 'Symptoms/Signs'
        
        WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 800 AND 999
            THEN 'Injury/Poisoning'
        
        ELSE 'Other'
END;

ALTER TABLE diabetic_data1
DROP COLUMN diag_1;

ALTER TABLE diabetic_data1
RENAME COLUMN diag1ver2 TO diag_1;

-- diag_2
ALTER TABLE diabetic_data1
ADD COLUMN diag2ver2 TEXT;

UPDATE diabetic_data1
SET diag2ver2 =
    CASE
    
    
   
		WHEN diag_2 = '?' THEN 'Unknown'
        
		WHEN diag_2 LIKE 'V%' THEN 'Supplemental'
        WHEN diag_2 LIKE 'E%' THEN 'Injury/Poisoning'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 1 AND 139
            THEN 'Infectious/Parasitic'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 140 AND 239
            THEN 'Neoplasms'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 240 AND 279
            THEN 'Endocrine/Metabolic/Immunity'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 280 AND 289
            THEN 'Blood'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 290 AND 319
            THEN 'Mental'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 320 AND 389
            THEN 'Nervous System/ Sense Organ'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 390 AND 459
            THEN 'Circulatory'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 460 AND 519
            THEN 'Respiratory'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 520 AND 579
            THEN 'Digestive'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 580 AND 629
            THEN 'Genitourinary'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 630 AND 679
            THEN 'Pregnancy'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 680 AND 709
            THEN 'Skin'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 710 AND 739
            THEN 'Musculoskeletal'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 740 AND 759
            THEN 'Congenital'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 760 AND 779
            THEN 'Perinatal'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 780 AND 799
            THEN 'Symptoms/Signs'
        
        WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 800 AND 999
            THEN 'Injury/Poisoning'
        
        ELSE 'Other'
END;

ALTER TABLE diabetic_data1
DROP COLUMN diag_2;

ALTER TABLE diabetic_data1
RENAME COLUMN diag2ver2 TO diag_2;

-- diag_3
ALTER TABLE diabetic_data1
ADD COLUMN diag3ver2 TEXT;

UPDATE diabetic_data1
SET diag3ver2 =
    CASE
		WHEN diag_3 = '?' THEN 'Unknown'
        
		WHEN diag_3 LIKE 'V%' THEN 'Supplemental'
        WHEN diag_3 LIKE 'E%' THEN 'Injury/Poisoning'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 1 AND 139
            THEN 'Infectious/Parasitic'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 140 AND 239
            THEN 'Neoplasms'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 240 AND 279
            THEN 'Endocrine/Metabolic/Immunity'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 280 AND 289
            THEN 'Blood'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 290 AND 319
            THEN 'Mental'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 320 AND 389
            THEN 'Nervous System/ Sense Organ'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 390 AND 459
            THEN 'Circulatory'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 460 AND 519
            THEN 'Respiratory'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 520 AND 579
            THEN 'Digestive'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 580 AND 629
            THEN 'Genitourinary'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 630 AND 679
            THEN 'Pregnancy'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 680 AND 709
            THEN 'Skin'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 710 AND 739
            THEN 'Musculoskeletal'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 740 AND 759
            THEN 'Congenital'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 760 AND 779
            THEN 'Perinatal'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 780 AND 799
            THEN 'Symptoms/Signs'
        
        WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 800 AND 999
            THEN 'Injury/Poisoning'
        
        ELSE 'Other'
END;

ALTER TABLE diabetic_data1
DROP COLUMN diag_3;

ALTER TABLE diabetic_data1
RENAME COLUMN diag3ver2 TO diag_3;

-- 4. CHANGING DATA TYPES

-- Changing variables 
-- from numeric to categorical variables.
ALTER TABLE diabetic_data1
MODIFY COLUMN admission_type_id TEXT;

ALTER TABLE diabetic_data1
MODIFY COLUMN discharge_disposition_id TEXT;

ALTER TABLE diabetic_data1
MODIFY COLUMN admission_source_id TEXT;

-- 5. CREATING BINARY READMISSION VARIABLE

-- Converting readmission status to binary: 
-- 1 = readmitted within 30 days,
-- 0 = readmitted after 30 days or not readmitted.
ALTER TABLE diabetic_data1
ADD COLUMN readmitted_30 INT;

UPDATE diabetic_data1
SET readmitted_30 =
	CASE
		WHEN readmitted = '<30' THEN 1
        WHEN readmitted = '>30' THEN 0
        WHEN readmitted = 'NO' THEN 0
	END;

ALTER TABLE diabetic_data1
DROP COLUMN readmitted;

ALTER TABLE diabetic_data1
RENAME COLUMN readmitted_30 TO readmitted;

-- 6. CREATING FINAL DATASET

-- Selecting variables to use for analysis. This will exclude 
-- encounter_id and patient_nbr due to relavancy, as well as 
-- citoglipton and examide for only having one level
CREATE TABLE diabetic_data_clean LIKE diabetic_data1;
    
INSERT INTO diabetic_data_clean
SELECT * 
FROM diabetic_data1;

ALTER TABLE diabetic_data_clean
DROP COLUMN encounter_id, 
DROP COLUMN patient_nbr,
DROP COLUMN citoglipton, 
DROP COLUMN examide;

