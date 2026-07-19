# vse — voter satisfaction efficiency, in kanso

A Monte-Carlo simulator for comparing voting methods by **Voter Satisfaction
Efficiency** (VSE), written in [kanso](https://github.com/ClayShentrup/kanso).
Modeled on Jameson Quinn's [vse-sim](https://github.com/electionscience/vse-sim).

VSE of a method = `(social utility of the winner − mean candidate utility) /
(max candidate utility − mean utility)`, averaged over many random elections. 1.0
is a utilitarian-optimal winner every time; 0.0 is picking at random.

## Status

Honest-voting slice, spatial electorate (voters and candidates as points; utility
= −distance). Runs byte-identical on kanso's interpreter and native engines.

| method | VSE |
|---|---|
| plurality | 0.686 |
| approval | 0.914 |
| score (0–5) | 0.979 |

Score is genuine 0–5 integer ballots; discretizing from continuous moves it by
~0.0003 — the "roundings scatter and cancel" result, measured rather than
asserted.

## Run

```
kanso run vse.kso
```

Single file for now: kanso's module/import system isn't built yet, so the
`enumerable` / `methods` / `main` layers live in one alphabetically-ordered file.
Once imports land, this splits into real modules (an Enumerable stdlib, a
methods library, a thin entry).

## Roadmap

- **Rating methods:** STAR (score + automatic runoff), majority judgment.
- **Ranked methods:** IRV, Borda, Bucklin, a Condorcet variant (minimax /
  ranked pairs).
- **Strategic layer:** per-voter viability as a blend of a true poll and a
  random guess at ignorance level α; sweep α from 0 (perfect info) to 1 (pure
  guess) and plot VSE per method — the point being that the method *ranking* is
  robust across the whole axis, not any single α.
- **Faithful voter models:** gaussian positions, dimension weights.

Methods are implemented faithfully and report whatever the simulation produces —
no method is favored by construction.
