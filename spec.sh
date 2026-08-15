#!/bin/sh
# vse had no gate of any kind, which is how a 76% slowdown and a published
# memory figure matching neither the arena nor the process both went unnoticed
# for two weeks. KANSO points at the compiler binary.
#
# Everything here is deterministic. The electorate is drawn from entropy by
# default, so the seed is what makes the run reproducible — with it pinned, two
# consecutive runs give byte-identical output AND byte-identical allocator
# counters, verified before this file was written.
set -e
KANSO=${KANSO:-kanso}
SEED=2685821657736338717
export KANSO_SEED=$SEED

echo "== the simulation still compiles =="
"$KANSO" check .

echo "== the seeded table =="
"$KANSO" run . > /tmp/vse_table.txt
if diff bench/seeded_table.txt /tmp/vse_table.txt; then
  echo "seeded table: the six figures are unchanged"
else
  echo "THE SEEDED TABLE MOVED. The same seed drew the same electorate and the"
  echo "methods scored it differently, so something about the arithmetic or the"
  echo "ordering changed. Read the diff above before regenerating."
  exit 1
fi

echo "== allocator counters =="
KANSO_COUNTERS=1 "$KANSO" run . >/dev/null 2>/tmp/vse_counters.txt
if diff bench/cost_golden.txt /tmp/vse_counters.txt; then
  echo "cost golden: every counter is where it was"
else
  echo "A COUNTER MOVED. Say which way and why in the PR, then regenerate"
  echo "bench/cost_golden.txt. arena_peak_bytes and arena_blocks are the two"
  echo "that carry a published claim: the README says the peak is flat because"
  echo "beats sweep each iteration's scratch, and those are the numbers that"
  echo "say so. They have read 2,097,152 and 2 since the day the claim was"
  echo "written."
  exit 1
fi
