# Contributing to Qroky

Thank you for caring enough to read this. Qroky is built in the open — the
full construction record, decision by decision, is public in
[qroky/lab](https://github.com/qroky/lab) — and outside input is welcome.
This page states honestly how decisions are made, so nobody's time is wasted.

## How decisions are made: BDFL

Qroky has a single owner who decides what enters the core (a BDFL model).
This is not a committee project, and that is deliberate: the product's value
is a *coherent* governed work system, and coherence has one editor. Every
accepted change — including the owner's own — goes through the same
constitutional cycle the framework imposes on itself: formulated as a spec,
executed, **blind-verified by an independent checker**, and accepted at a
recorded human gate. You can watch that cycle run, unedited, in
[qroky/lab](https://github.com/qroky/lab).

## How to propose a change

Open an issue (or a PR) at
[github.com/qroky/framework/issues](https://github.com/qroky/framework/issues).

What happens next — stated plainly so expectations are honest:

- Your issue or PR becomes a **candidate in the touch queue** — the same
  queue the project's own improvement ideas wait in.
- If accepted, it enters the constitutional cycle above: it will be
  formulated as a spec, executed (possibly not by you), independently
  verified, and gated. **The external door leads into the same cycle, never
  around it** — a PR is a proposal, not a patch that merges on green CI.
- If declined, you get a reason. Declined does not mean unwelcome: the
  NOT-DOING list with rationale is part of the project's public record.

Good candidates: a defect report from your first 15 minutes (the most
valuable report there is), a hole in the docs, a real-world case the
constitution handles badly. For anything platform-specific, read the
boundary first: [runtime/INTERFACE.md](runtime/INTERFACE.md) — a feature
that crosses the core/binding boundary in the wrong direction is a defect
by definition.

## Forking: explicitly welcome

You have the right to fork, and it is **welcomed** — not merely tolerated.
Everything is local and open source; the framework is designed to work
without us (see the README's FAQ). If your direction diverges from the
owner's, a healthy fork is the honest resolution, and Apache-2.0 makes it
legal without asking anyone.

**Trademark line:** the code is Apache-2.0 — free to use, modify, and
redistribute. The name **Qroky** is protected as the product's brand: forks
rename. Ship your fork under your own name, state that it derives from
Qroky's Recursive Product Framework, and both projects stay honest.

## Ports to other platforms

The core is platform-neutral by constitution — it names capabilities, never
products. Running Qroky on another runtime (a different agent platform,
scheduler, or model family) is done by writing a **new runtime binding**, not
by editing the core: [runtime/INTERFACE.md](runtime/INTERFACE.md) defines the
seven capabilities a binding must deliver, with
[runtime/claude/](runtime/claude/) as the reference implementation. Ports
live as forks or as contributed bindings under `runtime/<yours>/` — proposed
through the same issue door above.
