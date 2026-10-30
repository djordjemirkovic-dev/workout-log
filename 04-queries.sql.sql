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


-- 3a. One-off correction, already applied on 30 Oct 2026.
--     Six push-up sets had been entered with weight 0 instead of NULL.
--     Always run the SELECT above first and compare its row count
--     with the number reported by UPDATE.
UPDATE exercise_sets
SET weight_kg = NULL
WHERE id IN (
    SELECT exercise_sets.id
    FROM exercises
    INNER JOIN workout_exercises
        ON workout_exercises.exercise_id = exercises.id
    INNER JOIN exercise_sets
        ON exercise_sets.workout_exercise_id = workout_exercises.id
    WHERE exercises.name = 'Push-Up'
      AND exercise_sets.weight_kg = 0
);


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