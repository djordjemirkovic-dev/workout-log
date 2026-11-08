-- 04-queries.sql
-- Analytical queries over workout_log.
-- Run 01-schema.sql and 02-seed.sql first, then insert workouts.


-- 1. All sets of a single workout, in the order they were performed.
--    Change the date to look at a different session.
SELECT
    exercises.name,
    workout_exercises.position,
    exercise_sets.set_number,
    exercise_sets.weight_kg,
    exercise_sets.reps,
    workouts.workout_date
FROM workouts
INNER JOIN workout_exercises
    ON workout_exercises.workout_id = workouts.id
INNER JOIN exercise_sets
    ON exercise_sets.workout_exercise_id = workout_exercises.id
INNER JOIN exercises
    ON exercises.id = workout_exercises.exercise_id
WHERE workouts.workout_date = '2026-10-26'
ORDER BY workout_exercises.position, exercise_sets.set_number;


-- 2. The exercise catalog with the primary muscle of each exercise.
--    muscle_role is filtered explicitly, so adding secondary muscles later
--    will not silently change the row count.
SELECT
    exercises.name AS exercise,
    muscle_groups.name AS muscle_group
FROM exercises
INNER JOIN exercise_muscle_groups
    ON exercise_muscle_groups.exercise_id = exercises.id
INNER JOIN muscle_groups
    ON muscle_groups.id = exercise_muscle_groups.muscle_group_id
WHERE exercise_muscle_groups.muscle_role = 'primary'
ORDER BY muscle_groups.name, exercises.name;


-- 3. Data check: bodyweight exercises must not store a weight of 0.
--    0 would mean "lifted nothing" and would be counted by AVG;
--    NULL means "not measured" and is skipped.
--    This should return no rows.
SELECT
    exercise_sets.id,
    exercises.name,
    exercise_sets.weight_kg
FROM exercises
INNER JOIN workout_exercises
    ON workout_exercises.exercise_id = exercises.id
INNER JOIN exercise_sets
    ON exercise_sets.workout_exercise_id = workout_exercises.id
WHERE exercises.name = 'Push-Up'
  AND exercise_sets.weight_kg = 0;


-- 4. Total tonnage per workout, that is the sum of reps * weight over all sets.
--    Bodyweight exercises carry NULL weight, so they drop out of the sum.
--    Grouping is by workouts.id, not by date, so two sessions on the same
--    day stay separate.
SELECT
    workouts.workout_date,
    SUM(exercise_sets.reps * exercise_sets.weight_kg) AS total_tonnage
FROM workouts
INNER JOIN workout_exercises
    ON workout_exercises.workout_id = workouts.id
INNER JOIN exercise_sets
    ON exercise_sets.workout_exercise_id = workout_exercises.id
GROUP BY workouts.id
ORDER BY workouts.workout_date;


-- 5. Total number of workouts and total number of sets.
--    After the joins every set becomes one row, so a workout with 20 sets
--    appears 20 times. COUNT(DISTINCT ...) counts each workout only once.
--    INNER JOIN drops workouts that have no sets yet, so a workout entered
--    without any sets would not be counted here.
SELECT
    COUNT(DISTINCT workouts.id) AS total_workouts,
    COUNT(exercise_sets.id) AS total_sets
FROM workouts
INNER JOIN workout_exercises
    ON workout_exercises.workout_id = workouts.id
INNER JOIN exercise_sets
    ON exercise_sets.workout_exercise_id = workout_exercises.id;


-- 6. Number of sets per exercise, from highest to lowest.
--    Grouping is by exercises.id, not by name, so two exercises with the
--    same name would stay separate. The second sort key (name) makes the
--    order of ties stable between runs.
SELECT
    exercises.name AS exercise,
    COUNT(exercise_sets.id) AS total_sets
FROM exercise_sets
INNER JOIN workout_exercises
    ON workout_exercises.id = exercise_sets.workout_exercise_id
INNER JOIN exercises
    ON exercises.id = workout_exercises.exercise_id
GROUP BY exercises.id
ORDER BY total_sets DESC, exercises.name ASC;


-- 7. Total tonnage per week.
--    DATE_TRUNC('week', ...) returns the Monday of the week, so all workouts
--    from the same week get the same value and can be grouped together.
--    It returns a timestamp with time zone (the offset changes with daylight
--    saving time), so ::date turns it into a plain date.
--    ORDER BY can use the alias because it runs after SELECT. GROUP BY repeats
--    the full expression, since an alias there is not standard SQL.
SELECT
    DATE_TRUNC('week', workouts.workout_date)::date AS week_start,
    SUM(exercise_sets.reps * exercise_sets.weight_kg) AS total_tonnage
FROM workouts
INNER JOIN workout_exercises
    ON workout_exercises.workout_id = workouts.id
INNER JOIN exercise_sets
    ON exercise_sets.workout_exercise_id = workout_exercises.id
GROUP BY DATE_TRUNC('week', workouts.workout_date)
ORDER BY week_start;


-- 8. Only exercises that have more than 10 sets in total.
--    WHERE filters individual rows before GROUP BY, HAVING filters groups
--    after GROUP BY. COUNT does not exist yet when WHERE runs, so a condition
--    on an aggregate must go in HAVING.
--    Logical order: FROM/JOIN, WHERE, GROUP BY, HAVING, SELECT, ORDER BY.
--    That is also why HAVING cannot use the SELECT alias.
SELECT
    exercises.name AS exercise,
    COUNT(exercise_sets.id) AS total_sets
FROM exercise_sets
INNER JOIN workout_exercises
    ON workout_exercises.id = exercise_sets.workout_exercise_id
INNER JOIN exercises
    ON exercises.id = workout_exercises.exercise_id
GROUP BY exercises.id
HAVING COUNT(exercise_sets.id) > 10
ORDER BY total_sets DESC, exercises.name ASC;


-- 9. Personal record: the highest weight per exercise.
--    Bodyweight sets (weight NULL) are removed in WHERE, before grouping,
--    so exercises without any weighted set do not appear at all.
--    IS NOT NULL states the intent directly. A condition like weight > 0
--    would also drop NULLs, but only as a side effect: a comparison with
--    NULL is UNKNOWN, and WHERE keeps only rows where the condition is TRUE.
SELECT
    exercises.name AS exercise,
    MAX(exercise_sets.weight_kg) AS record_kg
FROM exercise_sets
INNER JOIN workout_exercises
    ON workout_exercises.id = exercise_sets.workout_exercise_id
INNER JOIN exercises
    ON exercises.id = workout_exercises.exercise_id
WHERE exercise_sets.weight_kg IS NOT NULL
GROUP BY exercises.id
ORDER BY record_kg DESC, exercises.name ASC;


-- 10. Average number of reps per exercise, rounded to one decimal place.
--     Bodyweight exercises stay in, because their reps are recorded even
--     though their weight is NULL.
SELECT
    exercises.name AS exercise,
    ROUND(AVG(exercise_sets.reps), 1) AS average_reps
FROM exercise_sets
INNER JOIN workout_exercises
    ON workout_exercises.id = exercise_sets.workout_exercise_id
INNER JOIN exercises
    ON exercises.id = workout_exercises.exercise_id
GROUP BY exercises.id
ORDER BY average_reps DESC, exercises.name ASC;


-- 11. Every exercise in the catalog and in how many workouts it was done,
--     including exercises never done (shown as 0).
--     Definition: counts workouts in which the exercise appeared. An exercise
--     done twice in the same workout counts once, hence COUNT(DISTINCT ...).
--     LEFT JOIN keeps exercises without a match; for them it still returns
--     one row, with all workout_exercises columns NULL.
--     COUNT(*) counts rows, so it would return 1 for those exercises.
--     COUNT(column) skips NULLs, so it correctly returns 0.
SELECT
    exercises.name AS exercise,
    COUNT(DISTINCT workout_exercises.workout_id) AS times_done
FROM exercises
LEFT JOIN workout_exercises
    ON workout_exercises.exercise_id = exercises.id
GROUP BY exercises.id
ORDER BY exercises.name;


-- 12. Number of sets per rep category.
--     1 to 5 reps: strength, 6 to 12: hypertrophy, 13 and more: endurance.
--     CASE checks conditions top to bottom and the first TRUE one wins,
--     so each WHEN only needs an upper limit.
--     No ELSE on purpose: a set with NULL reps would otherwise be labelled
--     endurance; without ELSE it gets a NULL category and stays visible.
--     The three totals must add up to the total from query 5.
--     GROUP BY uses the alias, which PostgreSQL allows but standard SQL
--     (and SQL Server) does not.
SELECT
    CASE
        WHEN exercise_sets.reps < 6 THEN 'strength'
        WHEN exercise_sets.reps < 13 THEN 'hypertrophy'
        WHEN exercise_sets.reps >= 13 THEN 'endurance'
    END AS rep_category,
    COUNT(exercise_sets.id) AS total_sets
FROM exercise_sets
GROUP BY rep_category
ORDER BY rep_category;


-- 13. Data check: number of bodyweight sets (weight NULL) per exercise.
--     Expected result: only bodyweight exercises. A weighted exercise
--     appearing here means its weight was forgotten during data entry.
--     SUM and AVG ignore NULL values: they are skipped, not treated as 0.
--     That is why bodyweight sets drop out of tonnage, while a stored 0
--     would wrongly pull an average down.
SELECT
    exercises.name AS exercise,
    COUNT(exercise_sets.id) AS bodyweight_sets
FROM exercise_sets
INNER JOIN workout_exercises
    ON workout_exercises.id = exercise_sets.workout_exercise_id
INNER JOIN exercises
    ON exercises.id = workout_exercises.exercise_id
WHERE exercise_sets.weight_kg IS NULL
GROUP BY exercises.id
ORDER BY bodyweight_sets DESC, exercises.name ASC;