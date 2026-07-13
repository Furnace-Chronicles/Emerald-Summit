import { Box, Button, Section, Stack } from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';
// Searchable drop-in: stock Dropdown for short lists, adds a filter box once a
// list passes 7 options.
import { SearchableDropdown as Dropdown } from '../common/SearchableDropdown';

type MarkingEntry = {
  name: string;
  color: string;
  index: number;
  can_move_up: 0 | 1;
  can_move_down: 0 | 1;
};

// Static fields per zone — species-keyed, refreshed only on set_species.
type MarkingZoneStatic = {
  key: string;
  label: string;
  all_candidates: string[];
};

// Dynamic fields per zone — current marking list, changes on add/remove/move.
type MarkingZoneDynamic = {
  key: string;
  markings: MarkingEntry[];
};

// Merged view consumed by ZoneCard. `available` is derived client-side by
// subtracting the current selections from `all_candidates`.
export type MarkingZone = {
  key: string;
  label: string;
  markings: MarkingEntry[];
  can_add: boolean;
  available: string[];
};

export type MarkingsDynamicData = {
  zones: MarkingZoneDynamic[];
};

export type MarkingsStaticData = {
  max_per_limb: number;
  has_presets: 0 | 1;
  species_has_no_markings: 0 | 1;
  zones: MarkingZoneStatic[];
};

// Legacy combined type kept for IdentityTab's import.
export type MarkingsData = MarkingsStaticData & MarkingsDynamicData;

type Data = {
  markings: MarkingsDynamicData;
  markings_static: MarkingsStaticData;
};

type MarkingsSectionProps = { data: Data; act: ActFunctionType };

// Anatomical 3-row grid for body markings. Each row has cells with explicit
// grow weights so single-zone rows don't stretch full width:
//   Row 1:  pad(1)  | Head(3) | pad(1)            — Head sits above the arm row's center trio
//   Row 2:  L Hand  | L Arm | Chest | R Arm | R Hand  (5 equal columns)
//   Row 3:  pad(1)  | L Leg | pad(1) | R Leg | pad(1)  — legs aligned under L Arm and R Arm
type GridCell = { key: string | null; grow: number };

const MARKING_GRID: GridCell[][] = [
  [
    { key: null, grow: 1 },
    { key: 'head', grow: 3 },
    { key: null, grow: 1 },
  ],
  [
    { key: 'l_hand', grow: 1 },
    { key: 'l_arm', grow: 1 },
    { key: 'chest', grow: 1 },
    { key: 'r_arm', grow: 1 },
    { key: 'r_hand', grow: 1 },
  ],
  [
    { key: null, grow: 1 },
    { key: 'l_leg', grow: 1 },
    { key: null, grow: 1 },
    { key: 'r_leg', grow: 1 },
    { key: null, grow: 1 },
  ],
];

const MarkingsGrid = ({
  zones,
  act,
}: {
  zones: MarkingZone[];
  act: (action: string, payload?: object) => void;
}) => {
  const zoneByKey = new Map<string, MarkingZone>();
  for (const z of zones) {
    zoneByKey.set(z.key, z);
  }
  return (
    <Stack vertical>
      {MARKING_GRID.map((row, rowIdx) => {
        const hasAnyZone = row.some(
          (cell) => cell.key && zoneByKey.has(cell.key),
        );
        if (!hasAnyZone) return null;
        return (
          <Stack.Item key={rowIdx}>
            <Stack>
              {row.map((cell, colIdx) => (
                <Stack.Item
                  key={colIdx}
                  grow={cell.grow}
                  basis={0}
                  style={{ minWidth: 0, overflow: 'hidden' }}
                >
                  {cell.key && zoneByKey.has(cell.key) ? (
                    <ZoneCard zone={zoneByKey.get(cell.key)!} act={act} />
                  ) : null}
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

const ZoneCard = ({
  zone,
  act,
}: {
  zone: MarkingZone;
  act: (action: string, payload?: object) => void;
}) => (
  <Section title={zone.label}>
    {zone.markings.length === 0 ? (
      zone.available.length > 0 ? (
        <Dropdown
          fluid
          menuWidth="200px"
          selected={null}
          displayText="+ Add marking…"
          options={zone.available}
          onSelected={(value) =>
            act('marking_add_direct', { zone: zone.key, name: value })
          }
        />
      ) : (
        <Box color="label">No markings available.</Box>
      )
    ) : (
      <>
        {!!zone.can_add && zone.available.length > 0 && (
          <Box mb={1}>
            <Dropdown
              fluid
              menuWidth="200px"
              selected={null}
              displayText="+ Add another marking…"
              options={zone.available}
              onSelected={(value) =>
                act('marking_add_direct', { zone: zone.key, name: value })
              }
            />
          </Box>
        )}
        {zone.markings.map((m) => (
          <Box key={m.name} mb={1}>
            <Box>
              <b>{m.name}</b>
              {/* Native span carries the HTML title attribute (tgui's
                  Box doesn't whitelist it); Box keeps the swatch styling. */}
              <span title={m.color ? '#' + m.color : '(unset)'}>
                <Box
                  inline
                  ml={1}
                  width="32px"
                  height="14px"
                  backgroundColor={'#' + (m.color || 'ffffff')}
                  style={{
                    cursor: 'pointer',
                    border: '1px solid #000',
                    verticalAlign: 'middle',
                  }}
                  onClick={() =>
                    act('marking_color', { zone: zone.key, name: m.name })
                  }
                />
              </span>
            </Box>
            {zone.available.length > 0 && (
              <Box mt={0.5}>
                <Dropdown
                  fluid
                  menuWidth="200px"
                  selected={null}
                  displayText="Change to…"
                  options={zone.available}
                  onSelected={(value) =>
                    act('marking_change_direct', {
                      zone: zone.key,
                      from: m.name,
                      to: value,
                    })
                  }
                />
              </Box>
            )}
            <Box mt={0.5}>
              <Button
                icon="trash"
                color="bad"
                tooltip="Remove"
                onClick={() =>
                  act('marking_remove', { zone: zone.key, name: m.name })
                }
              />
            </Box>
          </Box>
        ))}
      </>
    )}
  </Section>
);

export const MarkingsSection = ({ data, act }: MarkingsSectionProps) => {
  const markingsStatic = data.markings_static;
  const markingsDynamic = data.markings;
  if (!markingsStatic || !markingsDynamic) return null;

  // Merge static zones (label + all_candidates) with dynamic zones (current
  // markings list) by zone key. `available` is computed here by subtracting
  // already-picked names from the candidate pool, and `can_add` from limb
  // capacity vs. the merged availability. This is the same filtering the
  // server used to do per push.
  const dynamicByKey = new Map<string, MarkingZoneDynamic>();
  for (const z of markingsDynamic.zones) {
    dynamicByKey.set(z.key, z);
  }
  const maxPerLimb = markingsStatic.max_per_limb;
  const zones: MarkingZone[] = markingsStatic.zones.map((s) => {
    const d = dynamicByKey.get(s.key);
    const currentMarkings = d?.markings || [];
    const pickedNames = new Set(currentMarkings.map((m) => m.name));
    const available = s.all_candidates.filter((n) => !pickedNames.has(n));
    return {
      key: s.key,
      label: s.label,
      markings: currentMarkings,
      can_add:
        currentMarkings.length < maxPerLimb && available.length > 0,
      available,
    };
  });

  return (
    <Section
      title="Markings"
      buttons={
        <>
          <Button
            disabled={!markingsStatic.has_presets}
            onClick={() => act('markings_use_preset')}
          >
            Use Preset
          </Button>
          <Button color="bad" onClick={() => act('markings_clear_all')}>
            Clear All
          </Button>
        </>
      }
    >
      {!!markingsStatic.species_has_no_markings && (
        <Box color="label">Your species has no body markings available.</Box>
      )}
      <MarkingsGrid zones={zones} act={act} />
    </Section>
  );
};
