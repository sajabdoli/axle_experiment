#!/usr/bin/env python3
"""Verify a candidate proof against a formal statement with AXLE, then
print the request id and a permanent share link.

Usage:
    export AXLE_API_KEY=...
    pip install axiom-axle
    python run_axle.py                              # statement.lean / proof.lean
    python run_axle.py statement_vacuity.lean proof_vacuity.lean
    ./run_all.sh                                    # all three experiments

How the id and link are obtained (the typed VerifyProofResponse drops them):
    * the raw JSON returned by /api/v1/verify_proof carries  info.request_id
    * POST /v1/shared-links  {"request_id": ...}  makes it permanently shareable
    * the page is then  https://axle.axiommath.ai/verify_proof#r=<request_id>
"""
import asyncio, json, os, pathlib, sys
import aiohttp
from axle import AxleClient, VerifyProofResponse

HERE = pathlib.Path(__file__).parent
AXLE_URL = os.environ.get("AXLE_API_URL", "https://axle.axiommath.ai").rstrip("/")
ENV = "lean-4.28.0"


async def make_share_link(request_id: str) -> str:
    """Register the request as shareable and return the webapp URL."""
    key = os.environ.get("AXLE_API_KEY")
    if not key:
        raise RuntimeError("AXLE_API_KEY not set")
    headers = {"Authorization": f"Bearer {key}", "Content-Type": "application/json"}
    async with aiohttp.ClientSession(headers=headers) as s:
        async with s.post(f"{AXLE_URL}/v1/shared-links",
                          data=json.dumps({"request_id": request_id})) as resp:
            body = await resp.text()
            if resp.status not in (200, 201):
                raise RuntimeError(f"shared-links {resp.status}: {body}")
    return f"{AXLE_URL}/verify_proof#r={request_id}"


async def main() -> None:
    stmt_file = sys.argv[1] if len(sys.argv) > 1 else "statement.lean"
    prf_file = sys.argv[2] if len(sys.argv) > 2 else "proof.lean"
    statement = (HERE / stmt_file).read_text()
    proof = (HERE / prf_file).read_text()

    async with AxleClient() as client:
        # run_one returns the raw JSON dict, so nothing is lost
        raw = await client.run_one("verify_proof", {
            "formal_statement": statement,
            "content": proof,
            "environment": ENV,
        })

    r = VerifyProofResponse.from_response(raw)
    print(f"files          : {stmt_file} / {prf_file}")
    print(f"okay           : {r.okay}")
    print(f"failed decls   : {r.failed_declarations}")
    for m in r.tool_messages.errors:   print("TOOL ERROR     :", m)
    for m in r.lean_messages.errors:   print("LEAN ERROR     :", m)
    for m in r.lean_messages.warnings: print("lean warn      :", m)

    request_id = (raw.get("info") or {}).get("request_id") or raw.get("request_id")
    if not request_id:
        print("request_id     : not present in response; keys were", sorted(raw.keys()))
        return
    print(f"request_id     : {request_id}")

    try:
        print(f"share_url      : {await make_share_link(request_id)}")
    except Exception as e:  # link creation is optional; the id alone is still useful
        print(f"share_url      : could not create ({e})")
        print(f"                 try manually: {AXLE_URL}/verify_proof#r={request_id}")


asyncio.run(main())
