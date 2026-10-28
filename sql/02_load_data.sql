\copy gym_attendance FROM 'data/clean/gym_clean.csv' WITH (FORMAT csv, HEADER true);

SELECT COUNT(*) AS total_rows FROM gym_attendance; 
