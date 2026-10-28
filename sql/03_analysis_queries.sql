-- Q1: Overall attendance rate
SELECT COUNT(*) AS total_members,
       SUM(is_present) AS present,
       ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS attendance_rate_pct
FROM gym_attendance;

-- Q2: Attendance by membership type
SELECT membership_type, COUNT(*) AS members,
       ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS attendance_rate_pct
FROM gym_attendance
GROUP BY membership_type
ORDER BY attendance_rate_pct DESC;

-- Q3: Monthly attendance with month-over-month change (LAG)
WITH monthly AS (
    SELECT month, month_name, COUNT(*) AS members,
           ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS rate_pct
    FROM gym_attendance
    GROUP BY month, month_name
)
SELECT month_name, members, rate_pct,
       ROUND(rate_pct - LAG(rate_pct) OVER (ORDER BY month), 1) AS mom_change_pts
FROM monthly
ORDER BY month;

-- Q4: Weekday attendance, ranked
SELECT weekday, COUNT(*) AS members,
       ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS rate_pct,
       RANK() OVER (ORDER BY SUM(is_present)::numeric / COUNT(*) DESC) AS rank
FROM gym_attendance
GROUP BY weekday
ORDER BY rank;

-- Q5: Weekend vs weekday
SELECT CASE WHEN is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
       COUNT(*) AS members,
       ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS rate_pct
FROM gym_attendance
GROUP BY is_weekend;

-- Q6: Workout type performance (present members only for averages)
SELECT workout_type,
       COUNT(*) AS members,
       ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS attendance_rate_pct,
       ROUND(AVG(workout_duration_minutes) FILTER (WHERE is_present = 1), 1) AS avg_duration_min,
       ROUND(AVG(calories_burned) FILTER (WHERE is_present = 1), 0) AS avg_calories
FROM gym_attendance
GROUP BY workout_type
ORDER BY attendance_rate_pct DESC;

-- Q7: Age group x gender attendance
SELECT age_group, gender, COUNT(*) AS members,
       ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS rate_pct
FROM gym_attendance
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- Q8: Time-of-day buckets
SELECT CASE WHEN check_in_hour BETWEEN 5 AND 11 THEN '1-Morning (5-11)'
            WHEN check_in_hour BETWEEN 12 AND 16 THEN '2-Afternoon (12-16)'
            ELSE '3-Evening (17-22)' END AS time_slot,
       COUNT(*) AS check_ins,
       ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS rate_pct
FROM gym_attendance
GROUP BY 1
ORDER BY 1;

-- Q9: Top workout type within each membership type (window + CTE)
WITH combo AS (
    SELECT membership_type, workout_type, COUNT(*) AS members,
           ROUND(100.0 * SUM(is_present) / COUNT(*), 1) AS rate_pct
    FROM gym_attendance
    GROUP BY membership_type, workout_type
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY membership_type ORDER BY rate_pct DESC) AS rnk
    FROM combo
)
SELECT membership_type, workout_type, members, rate_pct
FROM ranked
WHERE rnk = 1;

-- Q10: Data quality - absent members that still have workout metrics
SELECT attendance_status,
       COUNT(*) AS rows,
       COUNT(*) FILTER (WHERE workout_duration_minutes > 0) AS with_duration,
       COUNT(*) FILTER (WHERE calories_burned > 0) AS with_calories
FROM gym_attendance
GROUP BY attendance_status;
