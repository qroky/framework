---
id: RISK-002
date: 2026-07-05
kind: risk-acceptance
status: answered
atom: ATOM-005
trigger: backfill
answered_by: Ghenadie (human risk-taker)
recorded_by: ATOM-005 (backfill per DR8)
---

# RISK-002 — Open-core boundary: the standard is free, trust in execution is the product

## Question / Brief
Context: ATOM-005 gives RPF its public face (MANIFEST.md, README.md, LICENSE); publishing requires a decided boundary between what is open and what is commercial. Trigger: E2-class decision — an open-core split is effectively irreversible once strangers build on the open part, and it accepts a named commercial risk: the methodology can be copied by anyone, including competitors, at zero cost. Blocked: the licensing of the repository and the "what is open / what is commercial" section of the manifest. Options considered: (1) fully open, including enforcement tooling — maximal adoption, nothing left to sell but services; (2) open core: the standard (constitution, templates, base roles, reference runtime binding, this repository) under Apache-2.0, with the enforcement harness, domain verticals, and managed offering commercial and separate — copyable methodology, defensible execution; (3) closed or source-available — protects the text, kills standardization and distribution. Recommendation: option 2.

## Answer (verbatim)
OPEN (Apache License 2.0): the constitution (four framework documents), templates, base roles, the reference runtime binding, this repository. COMMERCIAL (closed, separate): the enforcement harness (isolated verification service, tamper-evident logs, real budget stops, metrics dashboards), domain verticals (regulated-industry knowledge profiles and role packs), managed/hosted offering. One-line rationale for the record: *the standard is free; proven trust in execution is the product.* Accepted risk: the methodology can be copied — traded for standardization, brand, and distribution.

*Reconstruction (DR5): sourced from `products/framework-v1/005-manifest/INPUT.md` §3.4 ("Open-core boundary"), which records the decision as accepted by the human on 2026-07-05.*

## Consequences
Unblocks ATOM-005: `LICENSE` at the repository root carries the verbatim Apache License 2.0 text (copyright 2026 Ghenadie Cernei); MANIFEST.md and README.md each reference it in one line and state the open/commercial boundary publicly. Everything currently in this repository is open under that license; enforcement-harness, vertical, and managed-offering products, when formulated, are separate products outside this repository. The named risk — free copying of the methodology — is accepted by the human risk-taker in exchange for standardization, brand, and distribution.

## Fed back to
MANIFEST.md ("What is open, what is commercial" section) and README.md (license line + repo-map row) — the public statements of this boundary; LICENSE (the legal instrument itself). No role-spec or knowledge change needed: the boundary is a product decision, recorded here.
