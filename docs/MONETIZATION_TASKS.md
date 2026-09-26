# Monetization revival — actionable items

**Status:** punch list only (2026-09-26). No payment code in this PR.  
**Guiding doc:** [PR #30](https://github.com/k-dot-greyz/neuro-spicy-devkit/pull/30) / `docs/MONETIZATION_RESEARCH.md` (sibling branch).  
**Product constraint:** this repo stays a **bash leaf**. No Python 3.14, no keys, no marketplace.

Check a box only when the artifact exists and the matching test is green. Operator confirms (bottom) block any live CTA.

---

## Guiding user story (MVP)

> As a visitor on this GitHub repo (donor, buyer, or future agent-buyer),  
> I want **one honest Support surface** that shows only **enabled** ways to pay,  
> so I can tip or buy a SKU **without** decimal-integer wallet dumps, dead badge URLs, or surprise chains.

Secondary story (operator / next agent):

> As Kaspars,  
> I want a **bash + jq renderer** that hydrates README + `.github/FUNDING.yml` from funding cards,  
> so presentation cannot drift from the private SSOT and nothing secret lands in git.

Out of story: minting NFTs, Fiverr, Link-for-agents as a seller wallet, Stripe Connect marketplace.

---

## MVP UX flow (keep this as the north star)

Happy path, README as the UI (no Astro yet):

1. Visitor opens `README.md` → **Support** heading.
2. **One primary CTA** (Ko-fi **or** Stripe Payment Link — not both competing). Visible label, not color-only. Keyboard reachable.
3. Optional second line: GitHub Sponsors, only if that card is `enabled: true`.
4. **Crypto is behind a disclosure** (`<details>` or equivalent). Closed by default.
5. Inside disclosure: chain name + **correctly formatted** address + copy hint. SOL may show a `solana:` Pay URL / QR **after** operator confirm. No Sui. No decimal integers.
6. GitHub repo **Sponsor** button (`.github/FUNDING.yml`) matches the same enabled cards. No link into a missing heading.
7. Operator runs `scripts/render-funding-surfaces.sh --dry-run` → sees the exact markdown that would be written. No files change.
8. Operator runs without `--dry-run` → README + FUNDING.yml update only from enabled cards. Git diff is reviewable.

Failure / empty states:

- Zero enabled cards → Support section says “funding options not published yet”, **does not** keep the broken ETH/SUI blobs.
- Crypto card enabled but env `CRYPTO_SOL_TIP_ADDRESS` unset → card omitted, stderr warning, exit non-zero in CI, not a silent README hole.
- Address fails format check (see tests) → renderer **refuses to write**.

Accessibility bar: WCAG 2.2 AA via existing `.cursor/skills/a11y-compliance-audit`. Focus visible, labels, `prefers-reduced-motion` if a QR lands later.

---

## TDD — write these tests first

Add cases to `scripts/test-integration.sh` (or a sibling `scripts/test-funding-render.sh` sourced by it). **Red before the renderer exists.**

Do **not** use `scripts/test-bash-scripts.sh` (`set -euo pipefail` + `((total_tests++))` from 0).

### Renderer contract

- [ ] `--help` prints usage and exits 0
- [ ] `--dry-run` prints planned writes and does **not** touch `README.md` or `.github/FUNDING.yml`
- [ ] Missing cards file → non-zero exit + message, no partial write
- [ ] `set -euo pipefail` + `printf %q` for any value written from env (no raw interpolation)

### Card filtering

- [ ] Only `enabled: true` cards appear in output
- [ ] Disabled `crypto_sol` / `crypto_eth` do not appear even if addresses exist in fixtures
- [ ] Primary CTA is exactly one of `{ko_fi, stripe_payment_link}` per fixture; never both as peer buttons

### Address hygiene (the README bug)

- [ ] Fixture ETH decimal integer `281850633879433659883248666004562161466203055170` → **reject**, do not render
- [ ] Fixture SUI decimal integer → **reject**
- [ ] Valid ETH `0x` + 40 hex → render only if `crypto_eth` enabled **and** operator-confirm flag/env is set
- [ ] Valid SOL base58 → render only if `crypto_sol` enabled and `CRYPTO_SOL_TIP_ADDRESS` matches the card
- [ ] BTC bech32 rendered only when that card is enabled (do not add BTC just because README has one today)
- [ ] Output never contains the string `github.com/neuro-spicy-devkit` as a donate href
- [ ] Output never contains a new Sui address or Sui CTA (Phantom Sui deprecated 2026-09-24)

### Git hygiene

- [ ] Renderer does not commit
- [ ] `git grep` / secrets scan on output: no `sk_`, `rk_`, `NFT_PRIVATE_KEY`, hex private keys
- [ ] `.github/FUNDING.yml` is valid YAML (`yamllint` or python/yaml) and uses `github:` / `ko_fi:` / `custom:` from **cards**, not a hardcoded README fragment

Fixture dir suggestion: `tests/fixtures/funding/` with `cards.enabled.json`, `cards.empty.json`, `cards.bad-eth.json`.

---

## Leaf repo (this PR’s implementation follow-up)

Do these in **neuro-spicy-devkit**. Small bash. Keep `CORE_FOCUS_PLAN.md`.

### 0. Tests (this section above)

- [ ] Land failing tests + fixtures. No renderer yet.

### 1. Cards snapshot

- [ ] Add `portable-dev-env/funding/funding_cards.json` (or `docs/funding/`) as a **checked-in snapshot** of enabled cards.
- [ ] Add `docs/funding/README.md` one-pager: snapshot is generated from private `dev-master` `dex/07-data/funding/`; regen notes; never edit prices/URLs by hand in the README.
- [ ] JSON validates against a **copied** schema file (vendored schema, not a live private-repo import).

### 2. Renderer

- [ ] `scripts/render-funding-surfaces.sh` — `--help`, `--dry-run`, `--cards <path>`, writes:
  - README Support section (replace the current novel, keep the rest of README)
  - `.github/FUNDING.yml`
- [ ] Addresses from env at render time: `CRYPTO_SOL_TIP_ADDRESS` (and ETH only if we ever enable it). Never commit the env file.
- [ ] Wire `--help` / `--dry-run` into `scripts/test-integration.sh` script-interface loop (same as `health-check-core.sh`).

### 3. Stop the bleeding in presentation

- [ ] Delete decimal ETH / SUI blobs from README as part of the first successful render (not a hand-edit that reintroduces them).
- [ ] Fix donate badge href: this repo is `k-dot-greyz/neuro-spicy-devkit`, not `github.com/neuro-spicy-devkit`.
- [ ] Restore `.github/FUNDING.yml` **from cards**, using orchestrator commit `2a4fd6d` only as a shape reference (custom URL must match a real heading).
- [ ] `docs/Donate_Crypto_Template.md` — either delete after render owns the surface, or shrink to “how to add a chain in the SSOT”, no placeholder widget `#`.

### 4. A11y + copy

- [ ] One primary CTA label is a verb + destination (`Support on Ko-fi`, `Pay with Stripe`).
- [ ] Crypto `<details>` has a real `<summary>`.
- [ ] No “addresses rotate for privacy” unless that is actually true; lying copy is a bug.

---

## Private `dev-master` (SSOT — not this repo)

Track on Linear. Do not port this Python into the leaf.

- [ ] Restore `zen.monetization.funding.cli` **or** replace it with the same bash/jq renderer. Wrapper `dex/04-scripts/render-funding-surfaces.sh` must not call a missing module.
- [ ] Schema bump: channel kinds `stripe_payment_link`, `solana_pay`. Phantom QR is presentation of `crypto_sol`, not a new processor.
- [ ] Keep `ko_fi` + `github_sponsors` as the only enabled channels until operator confirms.
- [ ] Shop SKUs stay `url: null` until a real Stripe Payment Link exists (ZEN-213 / ZEN-219).
- [ ] Do **not** revive `NFT_PRIVATE_KEY`, placeholder `ipfs.io` uploads, or the Fiverr “API” stubs into any public surface.

---

## Payment rails (when a SKU URL is real)

Only after operator confirms and SSOT has a URL.

- [ ] **Stripe Payment Link** (or Checkout Session) for the first SKU or donate. Restricted key `rk_` in private env, never here.
- [ ] Enable **Stripe Link** on that Checkout / Payment Link in Dashboard (buyer conversion). Do not treat Link as a payout rail.
- [ ] Omit `payment_method_types` (dynamic methods). API version note: `2026-07-29.dahlia`.
- [ ] **Solana Pay** `solana:` URL for SOL/USDC tip **after** public address confirm. Verify on-chain (`findReference` / `validateTransfer`) in private backend, not “Phantom connected = paid”.
- [ ] USDC mint if used: `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v`.
- [ ] **Link for agents** (`link.com/agents`) is a later **buyer** experiment. Needs MCP OAuth. Not a seller flow. Do not block MVP on it.
- [ ] Stripe Connect Accounts v2: **skip** until GlitchWorks is actually multi-creator.

---

## Operator confirms (block live CTAs)

Answer in Linear or a private note. Implementation may ship the renderer + empty/disabled cards without these; it may **not** enable crypto or fiat URLs.

- [ ] Ko-fi handle `zenOS` is claimed and is the public tip jar.
- [ ] GitHub Sponsors is live on `k-dot-greyz`.
- [ ] Public SOL tip address: README `Eh8yq5CWVVJu5dM73XxQzTnptaRwpKGeXMNqnTKPqqkw` vs `CRYPTO_SOL_TIP_ADDRESS` — which one?
- [ ] ETH decoded `0x315e9e99c09c7bf45e995d9d7d3d1b18bd422442` — use, replace, or drop?
- [ ] BTC `bc1q3rfg8nxtqtmqvqk9yted68j3ny9v3xzlh2tqen` — public tip jar yes/no?
- [ ] Add `dev-master` to this Cloud environment `repositoryDependencies` so the private compiler can be restored in-place? (yes/no)
- [ ] Link MCP OAuth for agent-buyer tests: later / skip.

---

## Explicitly out of scope

- Porting `zen/monetization/nft_marketplace.py` or `NFT_PRIVATE_KEY`
- New Sui surfaces
- Charges API / Card Element
- Hardcoded `payment_method_types`
- Python 3.14 on this leaf
- Interactive `init.sh` donate wizard
- Astro storefront (GlitchWorks owns shop UX; this repo renders GitHub surfaces)

---

## Suggested implement order (one PR per bite)

1. Failing tests + fixtures (this list, TDD).
2. Renderer `--dry-run` + help, still no README rewrite.
3. README + FUNDING.yml from **disabled-crypto** cards only (Ko-fi / Sponsors if confirmed, else empty honest state).
4. Private SSOT compiler restore + schema bump (private repo PR).
5. Enable SOL / Stripe URLs only after operator ticks.

---

## Definition of done (MVP)

A donor who never heard of zenOS can open this GitHub repo and:

- see one real, labeled way to support **or** an honest “not published yet”;
- never see a decimal-integer “address”;
- never hit a 404 donate badge;
- and `scripts/render-funding-surfaces.sh --dry-run` shows the same text the README would get.

Research context: [PR #30](https://github.com/k-dot-greyz/neuro-spicy-devkit/pull/30). Linear: ZEN-219, ZEN-213, ZEN-212, ZEN-283, ZEN-205, ZEN-118.
