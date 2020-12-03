# Gale-Shapley Algorithm

## References

* [Gale-Shapley Algorithm Wiki](https://en.wikipedia.org/wiki/Gale%E2%80%93Shapley_algorithm)

## Simple Examples

The traditional algorithm describes a way to find a stable bijection between two sets such that no two elements prefer each other to their current partners. We start with two equally sized sets.
```prolog
apps([a,b,c]).
slots([x,y,z]).
```

### Natural Positions
```prolog
prefs(a,[x,y,z]).
prefs(b,[y,x,z]).
prefs(c,[z,y,x]).
prefs(x,[a,b,c]).
prefs(y,[b,a,c]).
prefs(z,[c,b,a]).
```
The matching outcome should be [a,x], [b,y], [c,z] regardless of order of proposals.

If [a,b,c] are proposers:
```
?- gsa(slot,R).
--------------------------------------
Proposers with preferences: [[x,[a,b,c]],[y,[b,a,c]],[z,[c,b,a]]]
Accepters: [[a,om],[b,om],[c,om]]
Accepter preferences: [[x,y,z],[y,x,z],[z,y,x]]
--------------------------------------
x is proposing to a
The accumulator state is: []
--------------------------------------
New accumulator state is: [[a,x]]
New unpaired state is: [[b,om],[c,om]]
--------------------------------------
y is proposing to b
The accumulator state is: [[a,x]]
--------------------------------------
New accumulator state is: [[a,x],[b,y]]
New unpaired state is: [[c,om]]
--------------------------------------
z is proposing to c
The accumulator state is: [[a,x],[b,y]]
--------------------------------------
New accumulator state is: [[a,x],[b,y],[c,z]]
New unpaired state is: []
R = [[a, x], [b, y], [c, z]] .
```

If [x,y,z] are proposers:
```
?- gsa(app,R).
--------------------------------------
Proposers with preferences: [[a,[x,y,z]],[b,[y,x,z]],[c,[z,y,x]]]
Accepters: [[x,om],[y,om],[z,om]]
Accepter preferences: [[a,b,c],[b,a,c],[c,b,a]]
--------------------------------------
a is proposing to x
The accumulator state is: []
--------------------------------------
New accumulator state is: [[x,a]]
New unpaired state is: [[y,om],[z,om]]
--------------------------------------
b is proposing to y
The accumulator state is: [[x,a]]
--------------------------------------
New accumulator state is: [[x,a],[y,b]]
New unpaired state is: [[z,om]]
--------------------------------------
c is proposing to z
The accumulator state is: [[x,a],[y,b]]
--------------------------------------
New accumulator state is: [[x,a],[y,b],[z,c]]
New unpaired state is: []
R = [[x, a], [y, b], [z, c]] .
```

Stability predicate confirms no other stable pairing for the given inputs.
```
?- is_stable([[x, a], [y, b], [z, c]]).
true .
?- is_stable([[x, c], [y, b], [z, a]]).
false.
?- is_stable([[x, b], [y, a], [z, c]]).
false.
?- is_stable([[x, b], [y, c], [z, a]]).
false.
?- is_stable([[x, a], [y, c], [z, b]]).
false.
```

### 

Change `b` preferences to `[x,y,z]` should change nothing.

```prolog
prefs(a,[x,y,z]).
prefs(b,[x,y,z]).
prefs(c,[z,y,x]).
prefs(x,[a,b,c]).
prefs(y,[b,a,c]).
prefs(z,[c,b,a]).
```
The matching outcome is still [a,x], [b,y], [c,z] regardless of order of proposals. Stability is also unchanged:

```
?- is_stable([[a, x], [b, y], [c, z]]).
true .
?- is_stable([[a, y], [b, x], [c, z]]).
false.
?- is_stable([[a, y], [b, z], [c, x]]).
false.
?- is_stable([[a, z], [b, x], [c, y]]).
false.
```
Why? By the gale-shapley algorithm, each proposer proposes to their highest remaining preference, in order, until they are paired or no preferences remains (in the current implementation, unpairable proposers are *tossed*, but they are also an impossibility if there is a bijection between proposer and accepter sets (proof is not *exercise*, go outside for exercise)).

```
?- gsa(app,R).
R = [[x, a], [y, b], [z, c]] .
```

It starts with `a` proposing to its top choice `x`. Then `b` proposes to its top choice `x`, but `x` prefers `a` to `b` so it rejects `b`'s proposal.

```prolog
apps([a,b,c]).
slots([x,y,z]).
prefs(a,[x,y,z]).
prefs(b,[x,y,z]).
prefs(c,[z,y,x]).
prefs(x,[a,b,c]).
prefs(y,[b,a,c]).
prefs(z,[c,b,a]).
```

The output for the query writes all relevant proposal information as it happens.

```
?- gsa(app,R).
--------------------------------------
Proposers with preferences: [[a,[x,y,z]],[b,[x,y,z]],[c,[z,y,x]]]
Accepters: [[x,om],[y,om],[z,om]]
Accepter preferences: [[a,b,c],[b,a,c],[c,b,a]]
--------------------------------------
a is proposing to x
The accumulator state is: []
--------------------------------------
New accumulator state is: [[x,a]]
New unpaired state is: [[y,om],[z,om]]
--------------------------------------
b is proposing to x
The accumulator state is: [[x,a]]
--------------------------------------
x rejects proposal from b
--------------------------------------
b is proposing to y
The accumulator state is: [[x,a]]
--------------------------------------
New accumulator state is: [[x,a],[y,b]]
New unpaired state is: [[z,om]]
--------------------------------------
c is proposing to z
The accumulator state is: [[x,a],[y,b]]
--------------------------------------
New accumulator state is: [[x,a],[y,b],[z,c]]
New unpaired state is: []
R = [[x, a], [y, b], [z, c]] .
```

If we change the proposer set, nothing changes because `a` proposes to `x` and, even though `b` prefers `x` to `y`, `b` never gets a proposal from `x`, so they end up *settling* for `y`.

```
?- gsa(slot,R).
--------------------------------------
Proposers with preferences: [[x,[a,b,c]],[y,[b,a,c]],[z,[c,b,a]]]
Accepters: [[a,om],[b,om],[c,om]]
Accepter preferences: [[x,y,z],[x,y,z],[z,y,x]]
--------------------------------------
x is proposing to a
The accumulator state is: []
--------------------------------------
New accumulator state is: [[a,x]]
New unpaired state is: [[b,om],[c,om]]
--------------------------------------
y is proposing to b
The accumulator state is: [[a,x]]
--------------------------------------
New accumulator state is: [[a,x],[b,y]]
New unpaired state is: [[c,om]]
--------------------------------------
z is proposing to c
The accumulator state is: [[a,x],[b,y]]
--------------------------------------
New accumulator state is: [[a,x],[b,y],[c,z]]
New unpaired state is: []
R = [[a, x], [b, y], [c, z]] .
```

Some natural questions arise. Does anything change if we also make `c`'s preferences the same as `a` and `b`?
```prolog
apps([a,b,c]).
slots([x,y,z]).
prefs(a,[x,y,z]).
prefs(b,[x,y,z]).
prefs(c,[x,y,z]).
prefs(x,[a,b,c]).
prefs(y,[b,a,c]).
prefs(z,[c,b,a]).
```

**TODO: when does the stable matching change?**