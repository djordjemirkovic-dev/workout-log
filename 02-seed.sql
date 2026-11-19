INSERT INTO muscle_groups (name) VALUES
('Chest'),
('Back'),
('Legs'), 
('Shoulders'), 
('Biceps'), 
('Triceps'), 
('Abs');

-- Exercise catalog. 78 exercises.
-- Grip and stance variations are separate exercises by design.
INSERT INTO exercises (name) VALUES
-- Chest
('Barbell Bench Press'),
('Incline Barbell Bench Press'),
('Flat Dumbbell Press'),
('Incline Dumbbell Press'),
('Machine Chest Press'),
('Cable Chest Press'),
('Low Cable Crossover'),
('Flat Dumbbell Fly'),
('Incline Dumbbell Fly'),
('Plate Press'),
('Push-Up'),
('Diamond Push-Up'),
('Dip'),
-- Back
('Deadlift'),
('Rack Pull'),
('Good Morning'),
('Back Extension'),
('Barbell Row'),
('T-Bar Row'),
('Seated Cable Row'),
('One-Arm Dumbbell Row'),
('Meadows Row'),
('Hammer Row'),
('High Hammer Row'),
('Lat Pulldown'),
('Wide-Grip Lat Pulldown'),
('Neutral-Grip Lat Pulldown'),
('Reverse-Grip Lat Pulldown'),
('Pull-Up'),
-- Shoulders
('Military Press'),
('Seated Behind-the-Neck Press'),
('Smith Machine Shoulder Press'),
('Arnold Press'),
('Hammer Shoulder Press'),
('Lateral Raise'),
('Incline Lateral Raise'),
('Barbell Front Raise'),
('Reverse Fly'),
('Face Pull'),
('Upright Row'),
('Shrug'),
('Bus Driver'),
-- Biceps
('Barbell Curl'),
('Dumbbell Curl'),
('Incline Dumbbell Curl'),
('Cable Curl'),
('Preacher Curl'),
('Concentration Curl'),
('Spider Curl'),
-- Triceps
('Close-Grip Bench Press'),
('Skull Crusher'),
('Triceps Pushdown'),
('Rope Triceps Extension'),
('Dumbbell Triceps Extension'),
('Triceps Kickback'),
('Tate Press'),
-- Legs
('Back Squat'),
('Front Squat'),
('Box Squat'),
('Goblet Squat'),
('Sumo Goblet Squat'),
('Split Squat'),
('Bulgarian Split Squat'),
('Dumbbell Lunge'),
('Leg Press'),
('Leg Extension'),
('Leg Curl'),
('Romanian Deadlift'),
('Dumbbell Stiff-Leg Deadlift'),
('Hip Thrust'),
('Glute Bridge'),
('Calf Raise'),
-- Abs
('Plank'),
('Russian Twist'),
('Bicycle Crunch'),
('Stability Ball Crunch'),
('Roman Chair Sit-Up');


-- Primary muscle group for each of the 77 exercises.
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, muscle_role) VALUES
-- Chest, exercises 1-13 -> muscle group 1
(1,1,'primary'), (2,1,'primary'), (3,1,'primary'), (4,1,'primary'),
(5,1,'primary'), (6,1,'primary'), (7,1,'primary'), (8,1,'primary'),
(9,1,'primary'), (10,1,'primary'), (11,1,'primary'), (12,1,'primary'),
(13,1,'primary'),
-- Back, exercises 14-29 -> muscle group 2
(14,2,'primary'), (15,2,'primary'), (16,2,'primary'), (17,2,'primary'),
(18,2,'primary'), (19,2,'primary'), (20,2,'primary'), (21,2,'primary'),
(22,2,'primary'), (23,2,'primary'), (24,2,'primary'), (25,2,'primary'),
(26,2,'primary'), (27,2,'primary'), (28,2,'primary'), (29,2,'primary'),
-- Shoulders, exercises 30-42 -> muscle group 4
(30,4,'primary'), (31,4,'primary'), (32,4,'primary'), (33,4,'primary'),
(34,4,'primary'), (35,4,'primary'), (36,4,'primary'), (37,4,'primary'),
(38,4,'primary'), (39,4,'primary'), (40,4,'primary'), (41,4,'primary'),
(42,4,'primary'),
-- Biceps, exercises 43-49 -> muscle group 5
(43,5,'primary'), (44,5,'primary'), (45,5,'primary'), (46,5,'primary'),
(47,5,'primary'), (48,5,'primary'), (49,5,'primary'),
-- Triceps, exercises 50-56 -> muscle group 6
(50,6,'primary'), (51,6,'primary'), (52,6,'primary'), (53,6,'primary'),
(54,6,'primary'), (55,6,'primary'), (56,6,'primary'),
-- Legs, exercises 57-72 -> muscle group 3
(57,3,'primary'), (58,3,'primary'), (59,3,'primary'), (60,3,'primary'),
(61,3,'primary'), (62,3,'primary'), (63,3,'primary'), (64,3,'primary'),
(65,3,'primary'), (66,3,'primary'), (67,3,'primary'), (68,3,'primary'),
(69,3,'primary'), (70,3,'primary'), (71,3,'primary'), (72,3,'primary'),
-- Abs, exercises 73-77 -> muscle group 7
(73,7,'primary'), (74,7,'primary'), (75,7,'primary'), (76,7,'primary'),
(77,7,'primary');
