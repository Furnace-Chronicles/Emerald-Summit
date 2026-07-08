# Map-Placement Guide — `economy-take-2` branch

Complete list of every structure/landmark the branch's port (AP #7000 economy + #6849 items + Quest 2, all Chunks 1–7)
introduces that needs **manual `.dmm` placement**. The whole branch compiles clean; **everything below is mappable now**
(no code-blocked items remain).

**Current map state (checked 2026-07-08):** the maps are essentially bare of these — only the navigator is placed
(base + blackmarket, on `dun_world`; `roguetest` has none). Assume you are placing everything else from scratch on your
target map.

## Global placement rules
- **No `enforce_placement` gate** — discipline is entirely on the mapper.
- All are `anchored`. All are `density=TRUE` **except** `steward_export` (invisible floor marker) and the zadcotes/navigator (`/obj/item` machines).
- Deposit/recycler/commission machines **spill held items + coins onto their own tile** on break or rejected deposit → place on **plain open floor, not a table**, and leave one adjacent walkable tile (all use adjacent-only UIs).

---

## TIER 1 — Essential (the feature is dead without it)

### Banking — one vaultbank per institution
- [ ] `/obj/structure/roguemachine/vaultbank/church` ×1 → sacristy / clergy treasury behind altar. Bishop/Martyr = loans + Benefactor writs; Acolyte alerts; anyone deposits.
- [ ] `/obj/structure/roguemachine/vaultbank/innkeeper` ×1 → behind the bar / back room. "TAVERN JAWBANK," deposit/withdraw only.
- [ ] `/obj/structure/roguemachine/vaultbank/merchant` ×1 → counting house near the harbor. Emerald Trading Company; Merchant = loans/indentures + Charter writs.
- [ ] `/obj/structure/roguemachine/vaultbank/bathhouse` ×1 → reception near the attendant's desk. Nightmaster = loans + Token writs.

### Foreign trade — the harbor
- [ ] `/obj/structure/roguemachine/goldface` (base) ×1 → the docks. **This is the Harbor trade vendor** — hail ships, buy foreign-realm cultural stock (all of the 11-realm content routes through here). Without it that content is unreachable.
- [ ] `/obj/structure/roguemachine/ship_fulfillment` ×1 → waterfront cargo apron by the pier. Deposit goods to fulfill docked-ship demands (needs a Meister account; Merchant/Shophand work the duty ledger).

### Crown warehouse — Chunk 6
- [ ] `/obj/structure/roguemachine/steward_export` ×1 (`density=FALSE`, invisible) → mid-floor of the Crown warehouse beside the Stewardry; keep a clear 3×3 footprint on plain floor. The Steward's trade panel scans that 3×3 to fulfill warehouse/potion equipment orders; without it they fail with *"No warehouse dock manifest is registered."*

### Boards & services
- [ ] `/obj/structure/roguemachine/noticeboard` ×1 → town square / tavern wall. Scout regions, charters, market state, economic events, mercenary roster, and the door into the City Assembly.
- [ ] `/obj/structure/roguemachine/talkstatue/mercenary` ×1 → tavern or market square. The adventurer-for-hire post — **merc hiring silently no-ops if this is absent.** ⚠️ **DMI:** needs a `mercstatue` icon_state (you add the sprite; blank until then, not a crash).

### Quest 2 board — Chunks 1–7
- [ ] `/obj/structure/roguemachine/contractledger` ×1–2 → tavern (mercenary post); **add a 2nd in the Steward's office** for local blockade-defense commissioning. All ledgers share one pool. Innkeeper seeds rumor jobs (Rumors tab); crown authority commissions defense writs (Steward tab); any Fellowship poster posts towner jobs (Towner tab).
  - 🔴 **HARD CONSTRAINT:** the tile directly **SOUTH** (y−1) must be clear walkable open floor — it auto-stamps a `marker_export` decal there that turn-ins depend on. Don't put its south face against a wall/table.

### Quest 2 landmarks — wilderness (invisible)
- [ ] `/obj/effect/landmark/quest_spawner/generic` ×**~30–40** (≈4–6 per wilderness region) — where targets spawn. Its `quest_type` list covers **kill / retrieval / courier / recovery + blockade-defense + both towner types**, so towner quests need no dedicated landmark.
- [ ] `/obj/effect/landmark/quest_spawner/defense` ×**one per region** (~5–6) — blockade-defense–only anchor; place at each region's road/chokepoint approach.
  - Both need: an area whose `threat_region` is set (ES wilderness areas already carry `THREAT_REGION_*` ✅) **and** non-dense open floor of the **same area** within `view(7)` (else mobs cram onto the marker tile).

---

## TIER 2 — Recommended (feature works but is degraded/absent without it)

### Resident vendors (undercut the harbor with local margins)
- [ ] `/obj/structure/roguemachine/goldface/public/smith` ×1 → smithy storefront. Public arms/armor vendor.
- [ ] `/obj/structure/roguemachine/goldface/public/tailor` ×1 → tailor storefront. Public clothing/light-armor.
- [ ] `/obj/structure/roguemachine/goldface/public/apothecary` ×1 → apothecary / physician's office. Public potions.

### Commissioner boards + scrap buyers (craft economy)
- [ ] `/obj/structure/roguemachine/escrow` ×1 → guild entry / smithy counter. "COMMISSIONER" — post smithing orders + coin; **Crafter's Guild key** fulfills.
- [ ] `/obj/structure/roguemachine/escrow/tailor` ×1 → tailor's front counter. Garment orders; **tailor key OR guild key**.
- [ ] `/obj/structure/roguemachine/scrapper/smith` ×1 → forge entrance, public-facing. Buys scrap metal; **Crafter's Guild key** funds.
- [ ] `/obj/structure/roguemachine/scrapper/tailor` ×1 → tailor. Buys textiles/hides. ⚠️ **Key quirk:** its funding key is `crafterguild/craftermaster`, NOT the tailor key (likely upstream oversight) — place at the tailor anyway or beside the guild to match the gate. Your call.

### Crow post — Step 12 (set `zadcage_dir` on each)
- [ ] `/obj/item/roguemachine/zadcote/steward` ×1 → Stewardry / crown message room.
- [ ] `/obj/item/roguemachine/zadcote/merchant` ×1 → merchant counting house.
- [ ] `/obj/item/roguemachine/zadcote/bathhouse` ×1 → bathhouse.
  - Set `zadcage_dir` on each so its starter zadcage auto-spawns on the adjacent tile in that direction — **leave that adjacent tile clear.**

---

## TIER 3 — Optional / situational
- [ ] `/obj/structure/roguemachine/talkstatue/church` ×1 → church, if you want the clergy statue variant.
- [ ] `/obj/item/roguemachine/navigator` and `/blackmarket` — already placed on `dun_world` (base + blackmarket); place on `roguetest` too if you test there.
- [ ] `/obj/structure/roguemachine/goldface/public/wretch_cat` — "Vile Vheslie" beast-den vendor. AP maps it ONLY on a coast/away map. Place into an ES wilderness/coast lair if one exists; otherwise **omit**.

---

## Known DMI / sprite flags (you handle DMIs)
- `talkstatue/mercenary` → `mercstatue` icon_state (add the sprite).
- Blockade writ → `scroll_quest_info` / `scroll_quest_closed` states in `questing.dmi` (came over with the wholesale AP copy — treat as present).
- Zadcote scryed-on alert → `scryingeye` state in `screen_alert.dmi` (merged previously).

_Last updated 2026-07-08 — full end-of-port scope (Quest 2 Chunks 6-7 landed; steward_export un-blocked; added the previously-omitted noticeboard / mercenary statue / harbor goldface / zadcotes). Built from a code enumeration of every placeable ported type cross-checked against current map placements._
