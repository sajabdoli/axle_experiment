/-
VACUITY EXPERIMENT — formal statement.

Informal claim: "for every x with 0 < x < 1, we have 1/x > 1."

Over ℝ this is true and has content. Retyped over ℕ it becomes VACUOUS: no
natural number lies strictly between 0 and 1, so the hypotheses can never both
hold. The three declarations below share identical hypotheses and have wildly
different conclusions — including `False`. All three are provable.

Pure Lean core; no Mathlib required.
-/

-- (A) the intended-looking conclusion
theorem recip_gt_one' (n : Nat) (h0 : 0 < n) (h1 : n < 1) : 1 < 1 / n := by
  sorry

-- (B) a completely different conclusion
theorem recip_eq (n : Nat) (h0 : 0 < n) (h1 : n < 1) : (0 : Nat) = 1 := by
  sorry

-- (C) outright False — the hypotheses are unsatisfiable
theorem recip_false (n : Nat) (h0 : 0 < n) (h1 : n < 1) : False := by
  sorry
