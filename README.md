# Code for "A weekend with verify_proof"

    export AXLE_API_KEY=...
    pip install axiom-axle aiohttp
    python run_axle.py                                        # statement.lean / proof.lean
    python run_axle.py statement.lean proof_negative.lean      # the dropped-hypothesis variant
    python run_axle.py statement_vacuity.lean proof_vacuity.lean

Three files, three runs. `statement.lean` + `proof.lean` is Theorem 1 of
arXiv:1908.03173, formalized. `proof_negative.lean` drops one hypothesis and
still proves a true theorem — `verify_proof` catches it on signature, not on
the math. `statement_vacuity.lean` + `proof_vacuity.lean` is the ℕ/ℝ toy from
the note.
