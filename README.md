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
forty thousand elections, six methods each, about a hundred and sixty million
loop iterations — finishes in about 10.6s and peaks at **3.8 MB**, of which
2.1 MB is arena. The compiler brackets the simulation's loops and sweeps each
iteration's scratch automatically, with no annotations in the source. Ten
thousand trials peak at 3.83 MB and forty thousand at 3.82 MB: the peak does
not grow with the trial count.

The dice come from `math/random`, which seeds from entropy, so a run varies
unless you pin it: `KANSO_SEED=1 ./out` reproduces exactly.

| method | VSE |
|---|---|
| STAR | 0.971 |
| score (0–5) | 0.970 |
| minimax (Condorcet) | 0.950 |
| approval | 0.922 |
| IRV | 0.851 |
| plurality | 0.674 |

Means over eight seeds at forty thousand trials each, where the figures are
stable to about a thousandth.

Score and STAR ≫ Condorcet > approval ≫ IRV ≫ plurality—the canonical
honest-voting ordering, including IRV's center squeeze, reproduced rather than
assumed. Score and STAR are the one pair this does **not** separate: they land
within a thousandth of each other and swap places by seed, so the simulation
says they tie rather than that either wins.

The tie is expected from what this slice models. STAR's runoff is live — at
the pinned seed it overturns the score leader in 4,016 of 40,000 elections —
but honest ballots leave it little to fix: each overturn trades a sliver of
summed utility for a majority preference, and the two effects net to about
zero. STAR pulls ahead of score under *strategic* voting, which is the
roadmap's strategic layer, not modeled here — so this table measures the one
regime where the two are supposed to agree.

Score is genuine 0–5 integer ballots; discretizing from continuous moves it by
~0.0003 — the "roundings scatter and cancel" result, measured rather than
asserted.

## Run

```
kanso run .
```

Each run draws a fresh electorate: kanso seeds its generator from entropy, so
the numbers move a little while the ordering holds. To reproduce the exact
table above, pin the stream:

```
KANSO_SEED=2685821657736338717 kanso run .
```

A kanso module is a directory: `enumerable.kso` (fold-rooted collection
helpers), `methods.kso` (the voting methods), `sim.kso` (electorate models,
the VSE metric, the Monte Carlo driver), and `main.kso` (the entry) share one
namespace, each file alphabetically ordered. The std pieces arrive through
kanso's import system—`import "std/list"` enrolls `list/map` and friends
alongside the local helpers, one overload space, specificity picking the arm.

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
