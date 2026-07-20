# vse — voter satisfaction efficiency, in kanso

A Monte-Carlo simulator for comparing voting methods by **Voter Satisfaction
Efficiency** (VSE), written in [kanso](https://github.com/kanso-lang/kanso).
Modeled on Jameson Quinn's [vse-sim](https://github.com/electionscience/vse-sim).

VSE of a method = `(social utility of the winner − mean candidate utility) /
(max candidate utility − mean utility)`, averaged over many random elections. 1.0
is a utilitarian-optimal winner every time; 0.0 is picking at random.

## Status

Honest-voting slice, spatial electorate (voters and candidates as points; utility
= −distance). Runs byte-identical on kanso's interpreter and native engines.

The simulator is also the compiler's memory-model proving ground: a full run —
a thousand elections, six methods each, about four million loop iterations —
completes in ~0.11s at a flat **1.9 MB** peak, because the compiler brackets
the simulation's loops and sweeps each iteration's scratch automatically. No
annotations in the source; the numbers below never move by a digit.

| method | VSE |
|---|---|
| score (0–5) | 0.979 |
| STAR | 0.975 |
| minimax (Condorcet) | 0.970 |
| approval | 0.914 |
| IRV | 0.854 |
| plurality | 0.686 |

Score > STAR > Condorcet > approval ≫ IRV ≫ plurality—the canonical
honest-voting ordering, including IRV's center squeeze, reproduced rather than
assumed.

Score is genuine 0–5 integer ballots; discretizing from continuous moves it by
~0.0003 — the "roundings scatter and cancel" result, measured rather than
asserted.

## Run

```
kanso run .
```

A kanso module is a directory: `enumerable.kso` (fold-rooted collection
helpers), `methods.kso` (the voting methods), and `main.kso` (electorate
models, the VSE metric, the Monte Carlo driver) share one namespace, each file
alphabetically ordered. When cross-module `import` lands these become separate
packages (the Enumerable layer is the seed of kanso's stdlib).

## Roadmap

- **Rating methods:** majority judgment.
- **Ranked methods:** Borda, Bucklin, ranked pairs / Schulze.
- **Strategic layer:** per-voter viability as a blend of a true poll and a
  random guess at ignorance level α; sweep α from 0 (perfect info) to 1 (pure
  guess) and plot VSE per method — the point being that the method *ranking* is
  robust across the whole axis, not any single α.
- **Faithful voter models:** gaussian positions, dimension weights.

Methods are implemented faithfully and report whatever the simulation produces —
no method is favored by construction.
