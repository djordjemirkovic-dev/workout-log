/*INSERT INTO workouts (workout_date, duration_minutes, notes) VALUES ('2026-10-26', NULL, NULL) RETURNING id;*/



/*INSERT INTO workout_exercises (workout_id, exercise_id, position) VALUES
(4, 2, 1),
(4, 51, 2),
(4, 32, 3),
(4, 11, 4),
(4, 35, 5),
(4, 52, 6),
(4, 66, 7)

RETURNING id;
*/

INSERT INTO exercise_sets (workout_exercise_id, set_number, reps, weight_kg, rir) VALUES
(31, 3, 12, 40, NULL);

