-- workout_log: personal gym training diary.
-- Records completed workouts: which exercises were done, in what order,
-- and every single set with its reps, weight and reps-in-reserve.
-- Exercises and muscle groups are catalogs; workouts and sets are events.
-- Running this script drops all six tables and recreates them empty.

DROP TABLE IF EXISTS exercise_sets;
DROP TABLE IF EXISTS workout_exercises;
DROP TABLE IF EXISTS workouts;
DROP TABLE IF EXISTS exercise_muscle_groups;
DROP TABLE IF EXISTS exercises;
DROP TABLE IF EXISTS muscle_groups;

CREATE TABLE muscle_groups(
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

CREATE TABLE exercises(
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

CREATE TABLE exercise_muscle_groups(
	id SERIAL PRIMARY KEY,
	exercise_id	INTEGER	NOT NULL REFERENCES exercises(id),
	muscle_group_id	INTEGER	NOT NULL REFERENCES muscle_groups(id),
	muscle_role	TEXT NOT NULL CHECK (muscle_role IN ('primary', 'secondary')),
	UNIQUE (exercise_id, muscle_group_id)
);

CREATE TABLE workouts(
	id SERIAL PRIMARY KEY,
	workout_date DATE NOT NULL,
	duration_minutes INTEGER,
	notes TEXT
);

CREATE TABLE workout_exercises(
	id SERIAL PRIMARY KEY,
	workout_id	INTEGER	NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
	exercise_id	INTEGER	NOT NULL REFERENCES exercises(id),
	position	INTEGER	NOT NULL CHECK (position > 0),
	UNIQUE (workout_id, position)
);

CREATE TABLE exercise_sets(
	id SERIAL PRIMARY KEY,
	workout_exercise_id	INTEGER	NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
	set_number INTEGER	NOT NULL CHECK (set_number > 0),
	reps INTEGER NOT NULL CHECK (reps > 0),
	weight_kg NUMERIC(5,2) CHECK (weight_kg >= 0),
	rir	INTEGER,
	UNIQUE (workout_exercise_id, set_number)
);








