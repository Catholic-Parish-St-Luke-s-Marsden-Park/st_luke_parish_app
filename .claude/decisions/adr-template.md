# Architecture Decision Records

One file per decision: `.claude/decisions/NNNN-short-title.md` (zero-padded, incrementing). Created by the BA or Coder agent when a non-obvious technical or architecture choice is made that a future session needs the "why" for (e.g. a package choice, a deviation from the default layered structure, a scraping-strategy tradeoff). Reviewed by the verifier-agent during traceability review when a decision affects a requirement's implementation.

## Template

- **Decision ID:** ADR-XXXX
- **Title:**
- **Feature:** (feature ID/slug this decision relates to, if any)
- **Date:**
- **Status:** proposed / accepted / superseded
- **Context:** (what problem forced this decision)
- **Decision:** (what was chosen)
- **Alternatives Considered:**
- **Consequences:** (tradeoffs accepted, follow-up implications)
