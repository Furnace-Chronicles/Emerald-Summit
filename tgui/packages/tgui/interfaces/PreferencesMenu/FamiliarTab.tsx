import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
// Searchable drop-in: stock Dropdown for short lists, adds a filter box once a
// list passes 7 options. (Replaces the per-tab RawDropdown + inline-Box wrapper.)
import { SearchableDropdown as Dropdown } from '../common/SearchableDropdown';

type FamiliarData = {
  familiar_name?: string;
  familiar_pronouns: string;
  familiar_pronoun_label: string;
  familiar_pronoun_options: string[];
  familiar_specie_name: string;
  familiar_specie_options: string[];
  familiar_lore_blurb?: string;
  familiar_headshot_link?: string;
  familiar_flavortext_len: number;
  familiar_ooc_notes_len: number;
  familiar_ooc_extra_set: 0 | 1;
  in_queue: 0 | 1;
  queue_ready: 0 | 1;
};

type Data = {
  familiar: Partial<FamiliarData>;
  familiar_static: Partial<FamiliarData>;
};

export const FamiliarTab = (props) => {
  const { act, data } = useBackend<Data>();
  // Merge static option lists (pronoun_options, specie_options) into the
  // dynamic familiar block.
  const f = {
    ...data.familiar_static,
    ...data.familiar,
  } as FamiliarData;
  if (!data.familiar) {
    return <Box color="label">Familiar preferences not initialized.</Box>;
  }

  const fAct = (
    preference: string,
    task = 'input',
    extra: Record<string, string> = {},
  ) => act('familiar_action', { preference, task, ...extra });

  return (
    <Stack vertical>
      <Stack.Item>
        <Section
          title="Be a Familiar"
          buttons={
            f.in_queue ? (
              <Button
                color="bad"
                onClick={() => fAct('familiar_queue', 'leave')}
              >
                Leave Queue
              </Button>
            ) : (
              <Button
                color="good"
                disabled={!f.queue_ready}
                tooltip={
                  f.queue_ready
                    ? undefined
                    : 'Set a name, type, and flavor text before joining the queue.'
                }
                onClick={() => fAct('familiar_queue', 'join')}
              >
                Queue Up
              </Button>
            )
          }
        >
          <LabeledList>
            <LabeledList.Item label="Familiar Type">
              <Dropdown
                width="220px"
                menuWidth="260px"
                selected={f.familiar_specie_name}
                displayText={f.familiar_specie_name}
                options={f.familiar_specie_options}
                onSelected={(value) =>
                  value !== f.familiar_specie_name &&
                  fAct('familiar_specie', 'select', { picked_name: value })
                }
              />
            </LabeledList.Item>
            {!!f.familiar_lore_blurb && (
              <LabeledList.Item label="Lore">
                <Box color="label" italic>
                  {f.familiar_lore_blurb}
                </Box>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Name">
              <Button onClick={() => fAct('familiar_name')}>
                {f.familiar_name || '(unset)'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Pronouns">
              <Dropdown
                width="160px"
                menuWidth="200px"
                selected={f.familiar_pronoun_label}
                displayText={f.familiar_pronoun_label}
                options={f.familiar_pronoun_options}
                onSelected={(value) =>
                  value !== f.familiar_pronoun_label &&
                  fAct('familiar_pronouns', 'select', { picked_name: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Headshot">
              <Button onClick={() => fAct('familiar_headshot')}>
                {f.familiar_headshot_link ? 'Change' : 'Set URL'}
              </Button>
              <Box inline ml={1} color="label">
                {f.familiar_headshot_link ? '(set)' : '(unset)'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Flavortext">
              <Button onClick={() => fAct('familiar_flavortext')}>Edit</Button>
              <Box inline ml={1} color="label">
                {f.familiar_flavortext_len === 0
                  ? '(unset)'
                  : `${f.familiar_flavortext_len} chars`}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="OOC Notes">
              <Button onClick={() => fAct('familiar_ooc_notes')}>Edit</Button>
              <Box inline ml={1} color="label">
                {f.familiar_ooc_notes_len === 0
                  ? '(unset)'
                  : `${f.familiar_ooc_notes_len} chars`}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="OOC Extra">
              <Button onClick={() => fAct('familiar_ooc_extra')}>Edit</Button>
              <Box inline ml={1} color="label">
                {f.familiar_ooc_extra_set ? '(set)' : '(unset)'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
