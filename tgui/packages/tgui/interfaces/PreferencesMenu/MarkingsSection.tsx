import { useState } from 'react';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';
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

// Merged view consumed by ZoneEditor. `available` is derived client-side by
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

// Preferred display order for zone selector buttons.
const ZONE_ORDER = [
  'head',
  'chest',
  'l_arm',
  'r_arm',
  'l_hand',
  'r_hand',
  'l_leg',
  'r_leg',
];

const ZoneEditor = ({
  zone,
  act,
}: {
  zone: MarkingZone;
  act: (action: string, payload?: object) => void;
}) => (
  <Section title={zone.label} style={{ height: '100%' }}>
    {zone.markings.length === 0 ? (
      zone.available.length > 0 ? (
        <Dropdown
          fluid
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
            <Stack align="center">
              <Stack.Item grow={1}>
                <b>{m.name}</b>
              </Stack.Item>
              <Stack.Item>
                <span title={m.color ? '#' + m.color : '(unset)'}>
                  <Box
                    inline
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
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="trash"
                  color="bad"
                  tooltip="Remove"
                  onClick={() =>
                    act('marking_remove', { zone: zone.key, name: m.name })
                  }
                />
              </Stack.Item>
            </Stack>
            {zone.available.length > 0 && (
              <Box mt={0.5}>
                <Dropdown
                  fluid
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
          </Box>
        ))}
      </>
    )}
  </Section>
);

export const MarkingsSection = ({ data, act }: MarkingsSectionProps) => {
  const [selectedKey, setSelectedKey] = useState<string | null>(null);

  const markingsStatic = data.markings_static;
  const markingsDynamic = data.markings;
  if (!markingsStatic || !markingsDynamic) return null;

  const dynamicByKey = new Map<string, MarkingZoneDynamic>();
  for (const z of markingsDynamic.zones) {
    dynamicByKey.set(z.key, z);
  }
  const maxPerLimb = markingsStatic.max_per_limb;

  // Build merged zones sorted by preferred display order.
  const staticSorted = [...markingsStatic.zones].sort((a, b) => {
    const ai = ZONE_ORDER.indexOf(a.key);
    const bi = ZONE_ORDER.indexOf(b.key);
    return (ai === -1 ? 999 : ai) - (bi === -1 ? 999 : bi);
  });

  const zones: MarkingZone[] = staticSorted.map((s) => {
    const d = dynamicByKey.get(s.key);
    const currentMarkings = d?.markings || [];
    const pickedNames = new Set(currentMarkings.map((m) => m.name));
    const available = s.all_candidates.filter((n) => !pickedNames.has(n));
    return {
      key: s.key,
      label: s.label,
      markings: currentMarkings,
      can_add: currentMarkings.length < maxPerLimb && available.length > 0,
      available,
    };
  });

  const activeKey = selectedKey ?? zones[0]?.key ?? null;
  const activeZone = zones.find((z) => z.key === activeKey) ?? null;

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
        <Box color="label" mb={1}>
          Your species has no body markings available.
        </Box>
      )}
      <Stack>
        {/* Left: zone selector */}
        <Stack.Item width="130px">
          <Stack vertical>
            {zones.map((zone) => (
              <Stack.Item key={zone.key}>
                <Button
                  fluid
                  selected={zone.key === activeKey}
                  onClick={() => setSelectedKey(zone.key)}
                >
                  <Stack>
                    <Stack.Item grow={1}>{zone.label}</Stack.Item>
                    {zone.markings.length > 0 && (
                      <Stack.Item>
                        <Box
                          inline
                          style={{
                            opacity: 0.7,
                            fontSize: '0.85em',
                          }}
                        >
                          {zone.markings.length}
                        </Box>
                      </Stack.Item>
                    )}
                  </Stack>
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
        {/* Right: full-width zone editor — dropdowns have room to expand freely */}
        <Stack.Item grow={1} style={{ minWidth: 0 }}>
          {activeZone && <ZoneEditor zone={activeZone} act={act} />}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
