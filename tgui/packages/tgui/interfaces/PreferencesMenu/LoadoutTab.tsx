import {
  Box,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';
// Searchable drop-in: stock Dropdown for short lists, adds a filter box once a
// list passes 7 options. (Replaces the per-tab RawDropdown + inline-Box wrapper.)
import { SearchableDropdown as Dropdown } from '../common/SearchableDropdown';

type LoadoutSlot = {
  slot: number;
  name: string;
  desc?: string;
  hex?: string;
  color_name: string;
};

type LoadoutDynamicData = {
  slots: LoadoutSlot[];
};

type LoadoutStaticData = {
  item_options: string[];
  color_options: string[];
};

type LoadoutData = LoadoutDynamicData & LoadoutStaticData;

type Data = {
  loadout: LoadoutDynamicData;
  loadout_static: LoadoutStaticData;
};

type LoadoutTabProps = { data: Data; act: ActFunctionType };

const SLOT_LABELS = ['I', 'II', 'III', 'IV', 'V', 'VI'];

export const LoadoutTab = ({ data, act }: LoadoutTabProps) => {
  // Merge static option lists (item_options, color_options) into the
  // dynamic loadout (slots). Defaults are applied post-spread so the brief
  // gap before the server's set_tab reply lands doesn't crash on
  // slots.map(...) — declaring them before the spread would trigger TS2783
  // duplicate-key errors when the typed spreads already declare the same
  // keys.
  const merged = { ...data.loadout_static, ...data.loadout };
  const loadout: LoadoutData = {
    slots: merged.slots ?? [],
    item_options: merged.item_options ?? [],
    color_options: merged.color_options ?? [],
  };

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="Loadout Items">
          <Box mb={1} color="label" italic>
            Loadout items are not given at spawn. RMB a tree, statue, or clock
            to collect them.
          </Box>
          <LabeledList>
            {loadout?.slots.map((s) => (
              <LabeledList.Item
                key={s.slot}
                label={`Item ${SLOT_LABELS[s.slot - 1]}`}
              >
                <Dropdown
                  width="240px"
                  menuWidth="280px"
                  selected={s.name}
                  displayText={s.name}
                  options={loadout.item_options}
                  onSelected={(value) =>
                    value !== s.name &&
                    act('set_loadout_slot_direct', {
                      slot: s.slot,
                      name: value,
                    })
                  }
                />
                {/* Native span carries the HTML title attribute (tgui's
                    Box doesn't whitelist it); Box keeps the swatch
                    styling. */}
                <span title={s.hex || '(no color set)'}>
                  <Box
                    inline
                    ml={1}
                    width="20px"
                    height="14px"
                    backgroundColor={s.hex || '#ffffff'}
                    style={{
                      border: '1px solid #161616',
                      verticalAlign: 'middle',
                    }}
                  />
                </span>
                <Box inline ml={1}>
                  <Dropdown
                    width="160px"
                    menuWidth="220px"
                    selected={s.color_name}
                    displayText={s.color_name}
                    options={loadout.color_options}
                    onSelected={(value) =>
                      value !== s.color_name &&
                      act('set_loadout_hex_direct', {
                        slot: s.slot,
                        name: value,
                      })
                    }
                  />
                </Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
