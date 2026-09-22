import Mathlib

/-!
NEGATIVE — RIGHT PROOF, WRONG THEOREM. `hfeas` is dropped and the conclusion
weakened to `∀ x ∈ C, f xbar ≤ f x`. This is a TRUE theorem with a CORRECT proof,
and it compiles with no errors — but it is not Theorem 1, because it no longer
claims the limit point is feasible.
Expect: okay = False, failed_declarations = ['penalty_limit_optimal'], no Lean errors.
This is the experiment that matters most: Lean rejects it only because the
statement was written correctly. Nothing checks the statement itself.
-/
theorem penalty_limit_optimal
    {X : Type*} [TopologicalSpace X]
    (f G : X → ℝ) (hf : Continuous f)
    (C : Set X)                                          -- feasible set
    (hG_nonneg : ∀ x, 0 ≤ G x)                           -- penalty ≥ 0
    (c : ℝ) (hc : 0 < c)                                 -- penalty coefficient
    (xstar : X) (hstar : xstar ∈ C)
    (hopt : ∀ x ∈ C, f xstar ≤ f x)                      -- x* optimal
    (xk : ℕ → X)
    (hmin : ∀ k, f (xk k) + c * G (xk k) ≤ f xstar)      -- Lemma 1, as a hypothesis
    (xbar : X) (hlim : Filter.Tendsto xk Filter.atTop (nhds xbar)) :
    ∀ x ∈ C, f xbar ≤ f x := by                          -- NEGATIVE: weakened
  -- Step 1: drop the penalty term, since c * G ≥ 0
  have hk : ∀ k, f (xk k) ≤ f xstar := by
    intro k
    have h1 : 0 ≤ c * G (xk k) := mul_nonneg hc.le (hG_nonneg _)
    linarith [hmin k]
  -- Step 2: f (xk k) → f xbar, because f is continuous
  have hf_lim : Filter.Tendsto (f ∘ xk) Filter.atTop (nhds (f xbar)) :=
    (hf.tendsto xbar).comp hlim
  -- Step 3: a limit of terms ≤ b is ≤ b
  have hbar : f xbar ≤ f xstar :=
    le_of_tendsto' hf_lim (fun k => hk k)
  -- Step 4: x* beats every feasible x, so x̄ does too
  exact fun x hx => hbar.trans (hopt x hx)
