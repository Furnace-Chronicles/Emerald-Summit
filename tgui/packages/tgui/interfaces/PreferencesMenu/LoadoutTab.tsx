import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type LoadoutSlot = {
  slot: number;
  name: string;
  desc?: string;
  hex?: string;
};

type LoadoutData = {
  slots: LoadoutSlot[];
};

type Data = {
  loadout: LoadoutData;
};

const SLOT_LABELS = ['I', 'II', 'III', 'IV', 'V', 'VI'];

export const LoadoutTab = (props) => {
  const { act, data } = useBackend<Data>();
  const loadout = data.loadout;

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
                <Button
                  onClick={() => act('set_loadout_slot', { slot: s.slot })}
                  tooltip={s.desc || undefined}
                >
                  {s.name}
                </Button>
                <Box
                  inline
                  ml={1}
                  width="32px"
                  height="14px"
                  backgroundColor={s.hex || '#ffffff'}
                  title={s.hex || '(no color set)'}
                  style={{
                    cursor: 'pointer',
                    border: '1px solid #161616',
                    verticalAlign: 'middle',
                  }}
                  onClick={() => act('set_loadout_hex', { slot: s.slot })}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
