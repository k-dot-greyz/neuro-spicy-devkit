# Monetization revival research

**Status:** research only (2026-09-26). No payment code shipped in this PR.  
**Audience:** reviewers and the next implementation agent.  
**Scope:** revive creator monetization for **neuro-spicy-devkit** as a lean leaf surface, wired to Stripe, Stripe Link, and crypto (Phantom), without turning this bash toolkit into a marketplace.

Related Linear (status surface): [ZEN-219](https://linear.app/zenos/issue/ZEN-219), [ZEN-213](https://linear.app/zenos/issue/ZEN-213), [ZEN-212](https://linear.app/zenos/issue/ZEN-212), [ZEN-283](https://linear.app/zenos/issue/ZEN-283), [ZEN-205](https://linear.app/zenos/issue/ZEN-205), [ZEN-118](https://linear.app/zenos/issue/ZEN-118).

---

## Headline

The “monetization automation” is not a deleted script in this repo. It is a **split brain**:

| Surface | What it owns | Current state |
| --- | --- | --- |
| **This repo (leaf)** | README donate block, crypto template, GitHub Sponsor button | Half-dead presentation. Addresses are hardcoded. FUNDING.yml is **not on `main`**. |
| **Private `dev-master` (SSOT)** | YAML registry → JSON funding cards → render CLI | Registry + cards + wrapper script exist. **`zen.monetization.funding.cli` is missing.** That is the break. |
| **Linear** | Shipping status for shop / Ko-fi / Stripe | Cash path is GlitchWorks + Ko-fi, not this toolkit. |

This public repo should **render enabled funding cards**, not invent payment policy, not store keys, and not mint NFTs.

---

## Environment snapshot (Cloud agent VM, 2026-09-26)

Canonical doctor is [`k-dot-greyz/env-doctor`](https://github.com/k-dot-greyz/env-doctor) (`env-doctor.sh`), not only `scripts/health-check-core.sh`.

Read-only audit against this checkout: **0 failures**, warnings for Docker, pre-commit, and `gh` missing `repo` scope.

Hydrated here (session-local, not committed): `shellcheck` 0.9.0, `shfmt` v3.14.1, `yamllint`.

| Expected | Reality |
| --- | --- |
| `AGENTS.md` claims `/usr/bin/shellcheck` + `/usr/local/bin/shfmt` after snapshot | Snapshot booted without them; installed during research |
| `health-check-core.sh` 13/13 | Headless VMs fail Cursor / VSCode / Docker / OpenClaw / AI keys / SSH. Expected. |
| env-doctor `--init --tier 2` | Aborts: private monorepo Python floor is **3.14.7+**. This product is bash-only — do not install 3.14 for this leaf. |
| Clone `k-dot-greyz/dev-master` | HTTPS clone **fails** (private + token scope). GitHub MCP **can** read files. |
| Link MCP / Phantom MCP | Link needs OAuth (timed out). Phantom MCP not wired (`PHANTOM_APP_ID` absent). |

`health-check-core.sh` still reports 7 passed / 6 failed after lint tools are present because it counts editor/runtime checks as core. Do not treat that as a monetization blocker.

---

## What exists in this repo

### On `main`

- [`README.md`](../README.md) “Support This Project” section: crypto donate badge + BTC / ETH / SOL / SUI blobs.
- [`docs/Donate_Crypto_Template.md`](Donate_Crypto_Template.md) (commit `e5c6795`, 2025-09-26): placeholder widget + chain list.

### On `origin/greyzxcursor/fullstack-orchestrator-91b7` (not merged to `main`)

- `.github/FUNDING.yml` — `custom:` URL into the README crypto heading.
- Issue / PR templates, `CHANGELOG.md`, `SECURITY.md` (PR [#21](https://github.com/k-dot-greyz/neuro-spicy-devkit/pull/21) / [#28](https://github.com/k-dot-greyz/neuro-spicy-devkit/pull/28)).

### README bugs (do not “fix” by guessing)

1. Markdown fences in the README are broken (`ash` instead of `bash` blocks) — tracked as [#14](https://github.com/k-dot-greyz/neuro-spicy-devkit/issues/14) / Linear [ZEN-228](https://linear.app/zenos/issue/ZEN-228).
2. Clone URL still says `yourusername/neuro-spicy-devkit`.
3. Donate badge points at `https://github.com/neuro-spicy-devkit` (org/user that is not this repo).
4. **ETH and SUI values are decimal integers**, not addresses. Same numeric values decode to:
   - ETH `0x315e9e99c09c7bf45e995d9d7d3d1b18bd422442`
   - SUI `0x9a2c9d37636a27245816b422c41f3facfc1e3a0a40315e1b1442a2b9c1121f92`
5. BTC bech32 and SOL base58 **look** well-formed, but the operator must confirm they are the public tip jar before any renderer enables them.
6. Phantom **Sui support is deprecated 2026-09-24**. Do not add new Sui surfaces.

Likely cause of (4): Phantom MCP / wallet tooling printed integer encodings without chain formatters.

---

## What exists in private `dev-master` (read via GitHub MCP)

### Funding automation (the thing to revive)

| Path | Role |
| --- | --- |
| `dex/07-data/funding/revenue_streams_registry.yaml` | SSOT. Profile `ecosystem-default`, jurisdiction `LV`. |
| `dex/07-data/funding/funding_cards.json` | Generated cards (currently Ko-fi + GitHub Sponsors only). |
| `dex/07-data/funding/README.md` | Render instructions; `CRYPTO_SOL_TIP_ADDRESS` inject. |
| `dex/01-templates/metadata/schemas/funding/funding_card.schema.json` | Card kinds: `donation`, `membership`, `commission`, `shop`, `service`, `crypto`. |
| `dex/01-templates/metadata/schemas/funding/revenue_streams_registry.schema.json` | Channels include github_sponsors, ko_fi, crypto_sol, crypto_eth, fiverr_atlas. **No Stripe / Solana Pay / Link kinds yet.** |
| `dex/04-scripts/render-funding-surfaces.sh` | Wrapper. Runs `python -m zen.monetization.funding.cli render`. |

**Break:** `zen/monetization/` on current `dev-master` HEAD contains:

- `__init__.py`, `cli.py`, `elevenlabs_voice.py`, `nft_marketplace.py`, `gig_platforms.py`, `atlas_fiverr.py`

It does **not** contain `funding/`. Search for `zen.monetization.funding` as a module returned **zero** files. The wrapper and the YAML/JSON still describe a compiler that is gone.

Registry (enabled today):

- `ko_fi.username: zenOS` — enabled
- `github_sponsors.username: k-dot-greyz` — enabled
- `crypto_sol` / `crypto_eth` — disabled until env inject
- Membership / commission tiers — `enabled: false` until Ko-fi handle is claimed
- Shop SKUs (draft, `url: null`): prompt pack €9, MIDI pack €15, config templates €19

### Older crypto CLI (Linear ZEN-118, marked Done)

`zen/monetization/cli.py` is a Click CLI (`voice`, `nft`, `gig`). Implementation is mostly stubs:

- NFT list: `"not fully implemented"`
- Storage/metadata upload: placeholder `ipfs.io` URLs
- Fiverr: comment admits no public seller API; returns a local draft object
- `nft_marketplace.py` accepts `NFT_PRIVATE_KEY` — **do not port into this public repo**

### Marketing sibling (not payments)

`zen/marketing/` + `dex/04-scripts/marketing_automation.py` (Buffer captions/images). Separate lane.

---

## Payment rails (current vendor docs, 2026-09)

Three **different jobs**. Do not smash them into one button.

| Rail | Job | Creator use | Not for |
| --- | --- | --- | --- |
| **Stripe Payment Links / Checkout Sessions** | Fiat donate / SKU / membership | EUR, LV payouts, Ko-fi backend, glitchworks.shop MVP | Charges API, Card Element, hardcoded `payment_method_types` |
| **Stripe Link** (consumer wallet at Checkout) | One-click returning buyers | Enable in Dashboard on Checkout / Payment Links | Treating Link as a seller wallet or payout rail |
| **Link for agents** (`link.com/agents`, Cursor MCP) | Agent **spends** via one-time virtual cards | Later: agent-buyers purchasing SKUs | Receiving creator payouts. OAuth not connected on this VM. |
| **Phantom Connect + Solana Pay** | Crypto tip / pay | SOL + USDC, `solana:` URLs / QR, **on-chain verify** | New Sui. Deprecated injected Bitcoin provider. Client-only “success”. |
| **Phantom MCP** (`@phantom/mcp-server`) | Agent-held wallet | Hydrate public tip addresses; test on **devnet** | Dumping raw integers into README; storing private keys |

Stripe notes (API **2026-07-29.dahlia**):

- Prefer Checkout Sessions / Payment Links.
- Restricted API keys (`rk_`) over `sk_`.
- Omit `payment_method_types` (dynamic methods). Exception: Terminal.
- Connect **Accounts v2** only if this becomes a multi-creator marketplace (GlitchWorks rights-routing). Solo SKUs do not need Connect.

Phantom notes:

- Portal `appId` + allowlisted origins for Connect SDKs.
- Embedded wallets: `signAndSendTransaction` only (no `signTransaction`).
- USDC mint: `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v`.
- Solana Pay: `@solana/pay` `encodeURL` + backend `findReference` / `validateTransfer`.
- Sui: do not start new integrations (deprecate 2026-09-24).

---

## Presentation model already designed

Two JSON-card pipes, one job: hydrate UI from data, not from README prose.

1. **Funding cards** (`funding_card.schema.json`) — README, `.github/FUNDING.yml`, CLI, later Astro.
2. **Offering cards** (Linear ZEN-205 YAML → `cards.json`) — storefront SKUs: price, CTA URL, status, featured.

Neuro-spicy-devkit should **consume generated cards**. One primary CTA (Ko-fi or Stripe Payment Link). Crypto behind a disclosure. Never a decimal dump. Never a surprise chain.

Accessibility: this repo already vendors `.cursor/skills/a11y-compliance-audit` with neuro-spicy defaults. Any donate UI targets **WCAG 2.2 AA** (labels, focus, not color-only paid state, `prefers-reduced-motion` on QR/widgets).

---

## Recommended split (implementation is a follow-up PR)

Keep this toolkit lean (`docs/CORE_FOCUS_PLAN.md`). Do not import Python 3.14, OpenSea, or Fiverr scrapers.

**This repo (leaf)**

- Restore `.github/FUNDING.yml` from the unmerged orchestrator work, driven by **enabled cards**, not a hardcoded README fragment.
- Replace the README donate novel with enabled cards only.
- Tiny renderer: bash + `jq`, `--help` and `--dry-run`, addresses from env at render time (`CRYPTO_SOL_TIP_ADDRESS`), never committed keys.
- Optional local copy of `funding_cards.json` generated from the private SSOT (or a checked-in snapshot + regen notes).

**Private `dev-master` (SSOT)**

- Restore `zen.monetization.funding.cli` **or** replace the Python compiler with the same bash/jq renderer.
- Schema bump: `stripe_payment_link` and `solana_pay` channel kinds.
- Phantom QR is presentation of `crypto_sol`, not a new processor.

**Out of scope for this public repo**

- `NFT_PRIVATE_KEY` / placeholder IPFS minting
- Fiverr “API”
- Link-for-agents as a seller flow
- Multi-creator Stripe Connect (until GlitchWorks is actually a marketplace)

---

## Operator confirms before any live render

These are **not** implementation guesses. They block enabling crypto/fiat CTAs:

1. Is Ko-fi handle `zenOS` actually claimed?
2. Is GitHub Sponsors live on `k-dot-greyz`?
3. Which SOL address is the public tip jar (README vs `CRYPTO_SOL_TIP_ADDRESS`)?
4. Should this Cloud environment add `dev-master` to `repositoryDependencies` so the Python renderer can be restored in-place?
5. Link MCP auth is optional and only needed for agent-buyer tests.

---

## Evidence index

| Item | Where |
| --- | --- |
| Crypto template | `e5c6795` — `docs/Donate_Crypto_Template.md` |
| FUNDING.yml | `2a4fd6d` / `85758e5` on fullstack-orchestrator branch |
| Funding SSOT | `dev-master` `dex/07-data/funding/` |
| Missing compiler | `render-funding-surfaces.sh` vs absent `zen/monetization/funding/` |
| Shop epic | Linear ZEN-219, GitHub `dev-master#316` |
| Stripe processor | Linear ZEN-213, `dev-master` PR #1655 |
| Stripe docs | [Payment Links](https://docs.stripe.com/payment-links), [Link](https://docs.stripe.com/payments/link) |
| Phantom docs | [docs.phantom.com](https://docs.phantom.com), [Solana Pay recipe](https://docs.phantom.com/recipes/payments/request-payment) |
| Link for agents | [link.com/agents](https://link.com/agents) |
