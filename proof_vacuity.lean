/-
VACUITY EXPERIMENT — candidate proof.

One proof term closes all three goals, because it never touches the conclusion:
it derives a contradiction from the hypotheses alone. That is the definition of
a vacuous theorem, and it is why (C) proving `False` is the diagnostic. If the
hypotheses of a theorem entail `False`, the theorem says nothing at all — and
nothing in the toolchain will tell you.

For reference, the FAITHFUL version over ℝ, which is not vacuous and does have
content (requires Mathlib; lemma name varies by release):

    theorem recip_gt_one (x : ℝ) (h0 : 0 < x) (h1 : x < 1) : 1 < 1 / x := by
      rw [lt_div_iff₀ h0, one_mul]
      exact h1
-/

-- (A) the intended-looking conclusion
theorem recip_gt_one' (n : Nat) (h0 : 0 < n) (h1 : n < 1) : 1 < 1 / n :=
  absurd h1 (Nat.not_lt.mpr h0)

-- (B) a completely different conclusion — SAME proof term
theorem recip_eq (n : Nat) (h0 : 0 < n) (h1 : n < 1) : (0 : Nat) = 1 :=
  absurd h1 (Nat.not_lt.mpr h0)

-- (C) outright False — the hypotheses are unsatisfiable
theorem recip_false (n : Nat) (h0 : 0 < n) (h1 : n < 1) : False :=
  absurd h1 (Nat.not_lt.mpr h0)

#print axioms recip_gt_one'
#print axioms recip_eq
#print axioms recip_false
