import {
  Box,
  Dropdown as RawDropdown,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';

// Wraps RawDropdown in an inline-Box constraint so the width prop actually
// limits the dropdown — without this, the dropdown stretches to fill its
// LabeledList.Item content cell instead of honoring its declared width.
const Dropdown = (props: any) => (
  <Box inline style={{ width: props.width }}>
    <RawDropdown {...props} />
  </Box>
);

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

const SLOT_LABELS = ['I', 'II', 'III', 'IV', 'V', 'VI'];

export const LoadoutTab = (props) => {
  const { act, data } = useBackend<Data>();
  // Merge static option lists (item_options, color_options) into the
  // dynamic loadout (slots). Default slots to [] so the brief gap before
  // the server's set_tab reply lands doesn't crash on slots.map(...).
  const loadout = {
    slots: [],
    item_options: [],
    color_options: [],
    ...data.loadout_static,
    ...data.loadout,
  } as LoadoutData;

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
                <Box
                  inline
                  ml={1}
                  width="20px"
                  height="14px"
                  backgroundColor={s.hex || '#ffffff'}
                  title={s.hex || '(no color set)'}
                  style={{
                    border: '1px solid #161616',
                    verticalAlign: 'middle',
                  }}
                />
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
