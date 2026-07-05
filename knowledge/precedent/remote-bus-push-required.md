---
source: ATOM-003 INPUT §3.4 (incident of 2026-07-04, recorded at formulation by the human + advisor agent)
date: 2026-07-04
type: precedent
tags: [remote-bus, delivery, closure, git]
---

# A product is not on the bus until it is pushed

**What happened.** On 2026-07-04, a consumer running against a remote clone of this repository could not reach a product that its producer considered delivered. The producing atom had written the product to the file bus and committed locally, but had not pushed. For every consumer that does not share the producer's working copy, the product did not exist.

**The lesson.** Local delivery satisfies O1.1 only for local consumers. When a git remote is configured, atom closure (L7) must include commit *and* push; a product counts as delivered on the bus for remote consumers only after the push succeeds. Formalized as RB1 in `framework/REPO-STRUCTURE.md`. When formulating an atom whose consumers may be remote, treat "committed but not pushed" as not delivered.
