# Map-Placement Manifest — `economy-take-2` branch

Every new economy + Quest 2 structure introduced by this branch's port (AP #7000 economy + #6849 items + Quest 2,
**including Quest 2 Chunks 6 & 7**) that needs **manual map placement**. A code sweep of the whole economy/quest/politics
tree confirms this list is complete — nothing else on the branch requires world placement.

**As of 2026-07-08 the entire branch is code-complete and compiles clean, so EVERYTHING below is mappable now** —
there are no more code-blocked items. (`steward_export` was previously on HOLD for Chunk 6; that chunk has landed, so it
is now a real, self-registering machine — mappable.)

**None of these have an `enforce_placement` gate — placement discipline is entirely on the mapper.**
All are `anchored`. All are `density=TRUE` **except `steward_export`** (an invisible floor tally-marker). The
deposit/recycler/commission machines spill their held items + coins onto **their own tile** on break/rejected-deposit,
so **place on plain open floor, not a table**, and leave one adjacent walkable tile (all use adjacent-only UIs).

---

## 1 — Economy machines (from the #7000 port)

### Church
- [ ] `/obj/structure/roguemachine/vaultbank/church` ×1 — Church treasury. Bishop/Martyr = loans + Benefactor writs; Acolyte alerts. Anyone deposits. → sacristy / clergy treasury behind altar.

### Tavern
- [ ] `/obj/structure/roguemachine/vaultbank/innkeeper` ×1 — "TAVERN JAWBANK." Deposit/withdraw only (no loans). Innkeeper withdraws; Tapster/Cook view. → behind bar / back room.

### Merchant's shop / market quarter
- [ ] `/obj/structure/roguemachine/vaultbank/merchant` ×1 — Emerald Trading Company treasury. Merchant = loans/indentures + Charter writs; Shophand alerts. → counting house / stall near harbor goldface.

### Bathhouse
- [ ] `/obj/structure/roguemachine/vaultbank/bathhouse` ×1 — Bathhouse treasury. Nightmaster = loans + Token writs; Nightswain alerts. → reception near attendant's desk.

### Smithy / Crafter's Guild (craft quarter)
- [ ] `/obj/structure/roguemachine/goldface/public/smith` ×1 — public arms/armor vendor (+50% margin so resident smith undercuts). Open to all buyers. → smithy storefront.
- [ ] `/obj/structure/roguemachine/escrow` ×1 — "COMMISSIONER" board. Anyone posts smithing orders + coin; **Crafter's Guild key** holders claim/fulfill. → guild entry / smithy counter, reachable from market.
- [ ] `/obj/structure/roguemachine/scrapper/smith` ×1 — buys scrap metal from anyone; **Crafter's Guild key** funds/configures. → forge entrance, public-facing.
- [ ] `/obj/structure/roguemachine/scrapper/tailor` ×1 — "rag-picker," buys textiles/hides. ⚠️ **Key quirk:** funding/config key is `crafterguild/craftermaster`, NOT the tailor key (unlike escrow/tailor). Likely upstream oversight — place at tailor anyway, or beside the guild to match the actual key gate. Your call.

### Tailor's shop
- [ ] `/obj/structure/roguemachine/goldface/public/tailor` ×1 — public clothing/light-armor vendor. Open to all. → tailor storefront.
- [ ] `/obj/structure/roguemachine/escrow/tailor` ×1 — "TAILORING COMMISSIONER." Anyone posts garment orders; **tailor key OR guild key** claims. → tailor's front counter.

### Apothecary / infirmary
- [ ] `/obj/structure/roguemachine/goldface/public/apothecary` ×1 — public potions vendor. Open to all. → apothecary/herbalist shop or physician's office.

### Docks / harbor
- [ ] `/obj/structure/roguemachine/ship_fulfillment` ×1 — dockside export crate; deposit goods to fulfill docked trade-ship demands (user needs a Meister bank account; Merchant/Shophand work the duty ledger). → waterfront cargo apron by the pier.

### Crown warehouse / Stewardry  ← Chunk 6 (now live)
- [ ] `/obj/structure/roguemachine/steward_export` ×1 — invisible tally marker (`density=FALSE`). The Steward's trade panel scans a 3×3 zone around it to fulfill warehouse/potion Crown equipment orders; without it those orders fail with *"No warehouse dock manifest is registered."* → mid-floor of the Crown warehouse beside the Stewardry; keep a clear 3×3 footprint on plain floor.

### Away/coast map only — SKIP unless ES has such a map
- [ ] `/obj/structure/roguemachine/goldface/public/wretch_cat` — "Vile Vheslie" beast-den vendor. AP maps it ONLY on its coast/away map, never in town. Map ×1 into an ES wilderness/coast lair if one exists; otherwise **omit**.

---

## 2 — Quest 2 board + landmarks (Chunks 1–7, all live)

### Tavern (Mercenary post) + optionally Steward's office
- [ ] `/obj/structure/roguemachine/contractledger` ×1–2 — quest board. Anyone signs/turns in; Innkeeper seeds rumor jobs; crown authority (Steward/Clerk/Grand Duke) commissions **blockade-defense** writs on its Steward tab; any poster with a Fellowship posts **towner** jobs on its Towner tab. All ledgers share one pool, so **1 in the tavern is enough; add a 2nd in the Steward's office** for local defense-writ commissioning. No separate "towner desk" exists — towner postings are composed on this ledger.
  - 🔴 **HARD CONSTRAINT:** the tile directly **SOUTH** (y−1) must be clear walkable open floor — it auto-stamps a `marker_export` decal there that quest turn-ins depend on. Do NOT put its south face against a wall or table.

### Wilderness (invisible landmarks — placed per region)
- [ ] `/obj/effect/landmark/quest_spawner/generic` ×**~30–40** (≈4–6 per wilderness region) — anchors where targets spawn. Its `quest_type` list covers **everything**: kill / retrieval / courier / recovery **and** blockade-defense **and** both towner types (smith caravan, ore vein). Towner quests need no dedicated landmark — they use these.
- [ ] `/obj/effect/landmark/quest_spawner/defense` ×**one per region** (~5–6) — blockade-defense–only anchor; place at each region's road / chokepoint approach so the blockade "wave" fires somewhere thematically sensible.
  - Both require: an area whose `threat_region` is set (ES wilderness areas already carry `THREAT_REGION_*` ✅), AND non-dense open floor of the **same area** within `view(7)` so mobs have somewhere to spawn (else they cram onto the marker's tile).

---

_Last updated 2026-07-08 (Quest 2 Chunks 6 & 7 landed; `steward_export` un-blocked). Generated from a code audit of every unmapped roguemachine/landmark on the branch._
