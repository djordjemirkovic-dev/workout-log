# workout-log

A personal strength training log built on PostgreSQL, analysed with SQL,
Power BI and Python (pandas).

Every set I do in the gym goes in here: the exercise, the weight, the reps
and the reps in reserve. The point is to replace a paper notebook with
something I can query, so I can follow progression on a single exercise
across months instead of flipping through pages.

The project covers the full path from raw data to a report:

- **Database design** in PostgreSQL, normalised for data entry
- **SQL analysis**: aggregations, joins, NULL handling, date grouping
- **Power BI dashboard** connected directly to the database, with DAX measures
- **pandas notebook** reproducing the same analysis in Python

The same totals (sets, workouts, tonnage, records) are calculated in all three
tools and cross-checked against each other.

![Workout Log Dashboard](images/dashboard.png)

## Repository structure

| Path | Contents |
|---|---|
| `01-schema.sql` | Creates all six tables |
| `02-seed.sql` | Fills the catalogs: muscle groups and exercises |
| `03-insert-workout.sql` | Template for entering a training session |
| `04-queries.sql` | Analytical queries and data quality checks |
| `PowerBI/` | Power BI dashboard (`.pbix`) |
| `analysis/` | Jupyter notebooks with pandas analysis |
| `images/` | Screenshots used in this README |

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

In reporting terms, `exercise_sets` is the fact table (it holds the measured
values: reps and weight), while `exercises`, `workouts` and `muscle_groups`
are dimensions. Because exercises reach muscle groups through a bridge table,
the model is a snowflake rather than a pure star schema.

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

### NULL, not 0, for bodyweight exercises

A push-up has no external load. Storing `0` would mean "lifted nothing" and
would pull down every average weight. `NULL` means "not measured", so
aggregate functions skip it and bodyweight sets drop out of tonnage instead
of counting as zero. A data check in `04-queries.sql` makes sure no zeros
slip back in.

### Surrogate primary keys

Every table uses a meaningless `SERIAL` id rather than a natural key such as
the workout date. A natural key is real data, and real data eventually needs
correcting, which would mean changing a value that foreign keys in other
tables point at. Uniqueness where it is genuinely required is enforced with
`UNIQUE` constraints instead, which is a different concern from identity.

## SQL analysis

`04-queries.sql` contains commented queries that answer concrete questions
about the training data, for example:

- total tonnage per workout and per week (`DATE_TRUNC`)
- number of sets per exercise, and exercises above a threshold (`HAVING`)
- personal record per exercise (`MAX`, excluding bodyweight sets)
- every exercise in the catalog with how often it was done, including
  never-done exercises shown as 0 (`LEFT JOIN`, `COUNT(column)` vs `COUNT(*)`)
- sets grouped into strength, hypertrophy and endurance ranges (`CASE`)
- data quality checks for bodyweight sets and incorrectly stored zeros

## Power BI dashboard

The dashboard in `PowerBI/` connects directly to the local PostgreSQL
database in Import mode.

- **Data model**: relationships checked and corrected by hand. Power BI
  detected one relationship as one-to-one from the current data, while the
  schema allows many muscle groups per exercise, so it was set to
  many-to-one.
- **DAX measures**: Total Workouts, Total Sets, Total Tonnage (`SUMX` over
  reps times weight, row by row) and Avg Reps.
- **Calculated column**: `Week Start`, the Monday of each workout's week,
  since Power BI's automatic date hierarchy has no week level.
- **Visuals**: KPI cards, weekly tonnage line chart, sets per exercise,
  and a date slicer. All visuals cross-filter each other.

## pandas analysis

`analysis/01-pandas-basics.ipynb` loads the tables into pandas and reproduces
the SQL analysis in Python:

- data profiling with `info()` and `describe()`, including findings such as
  sparse RIR values and empty columns
- filtering with boolean masks and `isna()` / `notna()`
- merging tables (the pandas equivalent of joins) and cleaning duplicate keys
- grouping with named aggregations, new calculated columns, and converting
  dates from text to `datetime`

## How to run

**Database**

```sql
CREATE DATABASE workout_log;
```

Then, connected to that database, run `01-schema.sql` followed by
`02-seed.sql`. The schema script drops and recreates all six tables, so it is
safe to run repeatedly while the database is still empty. Sessions are added
with `03-insert-workout.sql`.

**Power BI**

Open `PowerBI/workout_dashboard.pbix` in Power BI Desktop, point the
PostgreSQL source to your own server if needed, and click Refresh.

**pandas notebook**

```
pip install pandas sqlalchemy psycopg2-binary python-dotenv ipykernel
```

Create a `.env` file in the repository root with your database password:

```
DB_PASSWORD=your_password
```

`.env` is listed in `.gitignore`, so the password never reaches the
repository. Then open the notebook and run all cells.

## Next steps

- SQL window functions and CTEs for progression tracking (for example,
  comparing each session with the previous one on the same exercise)
- A Python ETL script that reads from the database, transforms the data and
  writes a weekly summary table back for Power BI