DROP TABLE IF EXISTS gym_attendance;

CREATE TABLE gym_attendance (
    member_id                 INT PRIMARY KEY,
    visit_date                DATE NOT NULL,
    age                       INT,
    gender                    VARCHAR(10),
    membership_type           VARCHAR(15),
    workout_type              VARCHAR(30),
    workout_duration_minutes  INT,
    calories_burned           INT,
    check_in_time             TIME,
    attendance_status         VARCHAR(10),
    check_in_hour             INT,
    month                     INT,
    month_name                VARCHAR(10),
    weekday                   VARCHAR(10),
    is_weekend                BOOLEAN,
    age_group                 VARCHAR(10),
    is_present                INT
);
