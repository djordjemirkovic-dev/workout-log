# workout-log

A personal strength training log built on PostgreSQL.

Every set I do in the gym goes in here: the exercise, the weight, the reps
and the reps in reserve. The point is to replace a paper notebook with
something I can query, so I can follow progression on a single exercise
across months instead of flipping through pages.

## Schema

Six tables, split into catalogs and events.

**Catalogs** describe what exists. They change rarely.

| Table | One row is |
|---|---|
| `muscle_groups` | one muscle group |
| `exercises` | one exercise |
| `exercise_muscle_groups` | one muscle group worked by one exercise, primary or secondary |

**Events** describe what happened. They grow with every session.

| Table | One row is |
|---|---|
| `workouts` | one training session, with its date and duration |
| `workout_exercises` | one exercise performed in one session, with its position |
| `exercise_sets` | one set, with its weight, reps and RIR |

The chain runs `workouts` to `workout_exercises` to `exercise_sets`.
Each level references exactly one level above it.

## Design decisions

### One row per set

A set is the smallest thing that actually varies. Storing `3x8` in a single
column would force every set to share one weight and one rep count, which is
never true: a real top set looks like 80x8, 80x7, 75x6. It would also make
drop sets and myo-reps impossible to record at all. The cost is more typing
at entry time, which is the right trade for a log whose only purpose is
tracking progression.

### A junction table between workouts and exercises

The same exercise appears in many sessions, and every session contains many
exercises, so neither table can hold a foreign key to the other.
`workout_exercises` also carries a `position` column, which records the order
exercises were performed in, and it allows an exercise to exist in a session
with zero sets, for when I start something and drop it.

### Muscle groups in their own table

A foreign key prevents the same group being spelled three different ways over
time. More importantly, `GROUP BY` can only report values that exist in the
data: if I skip legs for two months, a text column would make legs vanish from
a volume report entirely rather than show zero. Starting from the catalog and
joining outward keeps the zero visible, and the zero is the interesting part.

### CASCADE down the event chain, RESTRICT on catalogs

A set has no meaning without the workout exercise it belongs to, and that has
none without its workout, so deleting a workout takes its children with it.
Catalogs are the opposite: deleting `Bench Press` from the catalog would
silently erase months of bench press history, so the database refuses and
forces a deliberate decision instead.

### NUMERIC, not FLOAT, for weight

Floating point types are approximate. Summing many 2.5 kg increments drifts,
and two sets that should match can compare as different. Weight is both summed
and compared here, so `NUMERIC(5,2)` is the correct type.

### Surrogate primary keys

Every table uses a meaningless `SERIAL` id rather than a natural key such as
the workout date. A natural key is real data, and real data eventually needs
correcting, which would mean changing a value that foreign keys in other
tables point at. Uniqueness where it is genuinely required is enforced with
`UNIQUE` constraints instead, which is a different concern from identity.

## How to run

```sql
CREATE DATABASE workout_log;
```

Then, connected to that database, run `01-schema.sql` followed by
`02-seed.sql`. The schema script drops and recreates all six tables, so it is
safe to run repeatedly while the database is still empty.

## Example queries

