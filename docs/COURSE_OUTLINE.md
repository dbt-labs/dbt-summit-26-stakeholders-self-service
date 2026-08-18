# Course Outline — dbt Summit HOL

**Course title:** Scaling trusted self-service for dbt stakeholders

**Presenters:** Kyle Tuft and Matteo Dijoux
**Format:** Hands-on lab (HOL) · 90 minutes · up to 120 participants · 1 session
**Prerequisites:** Basic familiarity with dbt concepts (models, sources, tests, docs)
**Environment:** Sandbox dbt platform + data platform provided

---

## The story this course tells

The audience in the room isn't the stakeholder—it's the practitioner who'd have to *let go* of being the gatekeeper.

- **Their Need to Believe:** *"I can open data up to self-service without drowning in cleanup, wrong numbers, or losing control of my models."*
- **Our Reason to Believe:** A live moment where a non-developer asks a real business question and gets the right, *blessed* answer in seconds—because the guardrails (docs, tests, ownership, governed access) are now doing the gatekeeping that the practitioner used to do by hand.

The 90 minutes follow that arc: **open on the pain → hit the spark early → spend the lab earning the trust behind it → close by handing them the checklist to recreate the moment at home.** Every component in this course has a job in that story instead of being a feature on a list.

---

## Course overview

Scale dbt beyond the build team by enabling stakeholders to find, understand, and confidently reuse trusted data products—without requiring everyone to become a developer, and without forcing your team to babysit every question. In this hands-on lab you'll watch a stakeholder self-serve a trusted answer, then build the layer that makes that possible: documentation that answers stakeholder questions, trust signals that make answers believable, ownership that makes them accountable, and a governed access model that lets people get answers without touching your developer workflow. You'll leave able to recreate that "self-service moment" on your own project.

---

## Learning outcomes

By the end of this course, you will be able to:

1. **Define** the components of trusted self-service across people, process, platform signals, and the governed answer surface.
2. **Implement** stakeholder-friendly documentation patterns—definitions, intended use, grain, and caveats—directly in your dbt project.
3. **Establish** ownership and support workflows for questions, requests, and change management.
4. **Design** a scalable stakeholder access model—including a governed answer surface—that expands consumption while protecting developer workflows.

---

## The framework (five components)

Trusted self-service stands on five things. The first three make a data product *trustworthy*; the fourth makes someone *accountable* for it; the fifth turns trusted products into trusted **answers**—and that fifth piece is the spark.

1. **People** — clear ownership; someone stands behind the data.
2. **Process** — workflows for questions, requests, and change management.
3. **Platform signals** — docs, tests, freshness, lineage, certification.
4. **Governed access** — the right people can consume the right things, safely.
5. **Governed answer surface** *(the spark)* — discovery + the Semantic Layer + AI (dbt Catalog, dbt Copilot / the dbt MCP server) that let a stakeholder go from question to trusted answer without writing SQL or pinging the data team.

---

## Course outline

*Targets a ~50/50 split between hands-on exercises and lecture/discussion. Each lesson maps to a learning outcome and to a beat in the story. Tags: **[Concept]** = lecture/discussion/demo, **[Lab]** = hands-on in the sandbox.*

### Lesson 1: The pain, and the spark (12 mins) — [Concept + live demo]
*Story beat: Need → Reason · Maps to Outcome 1*

- The failure mode: the stakeholder who pings the data team for the fifth time this week—and the practitioner who can't scale themselves
- Name the Need to Believe in the room: "I can let go without losing control"
- **The spark (instructor demo):** a non-developer asks a real question in plain language and gets a trusted, governed answer back—with lineage and trust signals attached—via dbt Catalog / dbt Copilot on the Semantic Layer
- Reframe: the rest of the lab is how we *earn* that moment. Introduce the five-component framework.

### Lesson 2: Documentation — how the model explains itself (18 mins) — [Concept 3 / Lab 15]
*Story beat: earning the trust · Maps to Outcome 2*

- The four questions every stakeholder (and every AI assistant) asks: *What is this? When should I use it? What's the grain? What should I watch out for?*
- Why good docs are now double-duty: they brief humans *and* power the answer surface (Copilot/Catalog can only describe what you've documented)
- Patterns via `description` and `meta`; drafting a first pass with dbt Copilot
- **Lab:** Document a mart model end to end—description, grain statement, intended-use and caveat notes, column-level descriptions—then view it in dbt Catalog as a stakeholder would.

### Lesson 3: Trust signals — why the answer is believable (18 mins) — [Concept 3 / Lab 15]
*Story beat: earning the trust · Maps to Outcomes 1 & 2*

- Signals that build confidence: data tests, source freshness, model health, certification/maturity markers
- Surfacing trust in dbt Catalog so a consumer can see *why* to believe a number
- Using `meta`, tags, and groups to mark "blessed"
- **Lab:** Add tests and a freshness check, tag the model as certified, then explore lineage and health in dbt Catalog from the consumer's point of view.

### Lesson 4: Ownership & support — who stands behind it (14 mins) — [Concept 7 / Lab 7]
*Story beat: earning the trust · Maps to Outcome 3*

- Making ownership visible (model owners, groups, exposures) so questions have a destination
- Lightweight workflows for questions, change requests, and deprecation
- Exposures: connecting a model to the dashboards and stakeholders that depend on it
- **Lab:** Add an owner and group to a set of models and define an exposure tying a model to a downstream consumer.

### Lesson 5: Governed access & the answer surface — getting answers without touching dev (22 mins) — [Concept 10 / Lab 12]
*Story beat: completing the spark · Maps to Outcome 4 (+ component 5)*

- Expanding consumption without exposing developer workflows: model access (`public` / `private` / `protected`), groups, and contracts as guardrails
- The governed answer surface: dbt Catalog for discovery, the Semantic Layer for consistent metrics, dbt Copilot / the dbt MCP server for natural-language asks from the tools stakeholders already use
- Why this *is* control, not the loss of it: the guardrails do the gatekeeping
- **Lab:** Set model access and a contract to expose a curated "public" interface while keeping work-in-progress models private—then see your documented, tested, owned model show up as a trusted, answerable product (closing the loop back to the Lesson 1 spark).

### Lesson 6: Recreate the moment + next steps (6 mins) — [Concept]
*Story beat: hand them the checklist · Maps to all outcomes*

- Recap as a checklist: the five components that earn a self-service moment
- How to roll this out incrementally on a real project (start with one blessed mart)
- Resources, community links, and survey

---

## Time budget check

| Segment | Concept | Lab | Total |
|---|---|---|---|
| L1 Pain + spark | 12 | 0 | 12 |
| L2 Documentation | 3 | 15 | 18 |
| L3 Trust signals | 3 | 15 | 18 |
| L4 Ownership/support | 7 | 7 | 14 |
| L5 Access + answer surface | 10 | 12 | 22 |
| L6 Recreate + wrap | 6 | 0 | 6 |
| **Total** | **41** | **49** | **90** |

Hands-on time ≈ 54% — on target for a balanced HOL.

---

## Notes on the hands-on anchor

With the narrative in place, the spine is now clear: the lab builds toward **"make this model answer-ready,"** so **documentation (L2) + trust signals (L3)** carry the bulk of hands-on time because they're what the answer surface depends on and they run reliably at scale for 120 people. **Ownership (L4)** is a shorter guided segment. The **answer surface itself (L5)** is shown live by the instructor and partially built by participants (access + contract), since a full natural-language/AI moment is hard to run uniformly for 120 people in a sandbox. *(Final call before the Starter Repository milestone.)*

---

## Notes & flags

- **Naming:** Uses **dbt platform** (not "dbt Cloud"), **dbt Catalog**, **dbt Copilot**, **Semantic Layer**, and **dbt MCP server** per current naming. The provided "Getting Started" example doc still says "dbt Cloud"—confirm the current convention with PMM before the slide deck (active naming transition).
- **To verify before the deck:** current capabilities/labels for model health and certification in dbt Catalog; Semantic Layer + Copilot/MCP scope for the spark demo and Lesson 5; whether the sandbox can support a live natural-language ask. (dbt docs search was unavailable when drafting—flagging for a quick check.)
- **Two-instructor split** (Kyle / Matteo) is a separate milestone (Course agenda, due July 24). Lessons split cleanly, e.g. L1–L3 / L4–L6, or pain-and-spark (Kyle) handing to lab build-out (Matteo). Whoever opens with the L1 spark should also close the loop in L5 so the bookend lands in one voice.
- **Spark demo delivery is undecided:** live against a pre-configured instructor project, pre-recorded, or annotated screenshots. Live is the strongest proof and the highest risk; recorded is the safest and still lands the moment; screenshots are the weakest but bulletproof. Decide before the deck locks, since the L1 and L5 slides differ depending on the choice.

---

*Milestone: Course outline · Due July 10, 2026 · Draft v0.3 — presenter correction (Tyler Rouze → Matteo Dijoux), spark-demo delivery options flagged*
