# workout-log

Licna baza za evidenciju treninga u teretani, na PostgreSQL-u.

Ovde ulazi svaka serija koju odradim: vezba, kilaza, broj ponavljanja i RIR.
Smisao je da zamenim svesku necim sto mogu da upitam, pa da pratim progresiju
na jednoj vezbi kroz mesece umesto da listam stranice.

## Sema

Sest tabela, podeljenih na kataloge i dogadjaje.

**Katalozi** opisuju sta postoji. Menjaju se retko.

| Tabela | Jedan red je |
|---|---|
| `muscle_groups` | jedna misicna grupa |
| `exercises` | jedna vezba |
| `exercise_muscle_groups` | jedna misicna grupa koju vezba pogadja, primarno ili pomocno |

**Dogadjaji** opisuju sta se desilo. Rastu sa svakim treningom.

| Tabela | Jedan red je |
|---|---|
| `workouts` | jedan trening, sa datumom i trajanjem |
| `workout_exercises` | jedna vezba na jednom treningu, sa svojim rednim brojem |
| `exercise_sets` | jedna serija, sa kilazom, ponavljanjima i RIR-om |

Lanac ide `workouts`, pa `workout_exercises`, pa `exercise_sets`.
Svaki nivo pokazuje tacno jedan nivo iznad sebe.

## Odluke pri projektovanju

### Jedan red po seriji

Serija je najmanja stvar koja se stvarno menja. Da `3x8` stoji u jednoj
koloni, sve serije bi morale da dele istu kilazu i isti broj ponavljanja, a to
nikad nije tacno: pravi benc ide 80x8, 80x7, 75x6. Uz to, dropset i myoset se
tako uopste ne bi mogli zapisati. Cena je vise kucanja pri unosu, i to je
ispravna razmena za dnevnik cija je jedina svrha pracenje napretka.

### Vezna tabela izmedju treninga i vezbe

Ista vezba se pojavljuje na mnogo treninga, a svaki trening sadrzi mnogo
vezbi, pa nijedna tabela ne moze da drzi strani kljuc ka drugoj.
`workout_exercises` nosi i kolonu `position`, koja pamti redosled izvodjenja,
i dozvoljava da vezba postoji na treningu bez ijedne serije, za slucaj kad je
zapocnem pa odustanem.

### Misicne grupe u svojoj tabeli

Strani kljuc sprecava da se ista grupa kroz vreme napise na tri nacina. Jos
vaznije, `GROUP BY` moze da prikaze samo vrednosti koje postoje u podacima:
ako dva meseca preskacem noge, tekstualna kolona bi ih potpuno izbacila iz
izvestaja o obimu umesto da pokaze nulu. Kad se krene od kataloga pa spoji
nadalje, nula ostaje vidljiva, a bas ona je zanimljiva.

### CASCADE niz lanac dogadjaja, RESTRICT na katalozima

Serija nema znacenje bez vezbe na treningu kojoj pripada, a ta nema bez svog
treninga, pa brisanje treninga povlaci i sve ispod njega. Katalozi su obrnut
slucaj: brisanje `Bench Press` iz kataloga bi tiho obrisalo mesece istorije
benca, pa baza odbija i tera na svesnu odluku.

### NUMERIC, ne FLOAT, za kilazu

Tipovi sa pokretnim zarezom su priblizni. Sabiranje mnogo prirastaja od 2.5 kg
odlazi u stranu, a dve serije koje bi trebalo da budu jednake mogu da se
porede kao razlicite. Kilaza se ovde i sabira i poredi, pa je `NUMERIC(5,2)`
ispravan tip.

### Besmisleni primarni kljucevi

Svaka tabela koristi `SERIAL` id bez znacenja, a ne prirodan kljuc poput
datuma treninga. Prirodan kljuc je pravi podatak, a pravi podatak se pre ili
kasnije mora ispraviti, sto bi znacilo menjanje vrednosti na koju pokazuju
strani kljucevi iz drugih tabela. Jedinstvenost tamo gde je stvarno potrebna
postize se ogranicenjem `UNIQUE`, a to je odvojeno pitanje od identiteta.

## Kako se pokrece

```sql
CREATE DATABASE workout_log;
```

Zatim, povezan na tu bazu, pusti `01-schema.sql` pa `02-seed.sql`. Skripta sa
semom brise i ponovo pravi svih sest tabela, pa se moze pustati vise puta dok
je baza jos prazna.

## Primeri upita

Dolaze kad bude dovoljno podataka da imaju smisla.