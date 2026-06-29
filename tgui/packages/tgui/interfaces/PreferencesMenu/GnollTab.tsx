import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';
// Searchable drop-in: stock Dropdown for short lists, adds a filter box once a
// list passes 7 options. (Replaces the per-tab RawDropdown + inline-Box wrapper.)
import { SearchableDropdown as Dropdown } from '../common/SearchableDropdown';

type GnollData = {
  gnoll_name: string;
  gnoll_pronouns: string;
  pronoun_label: string;
  pelt_label: string;
  genitals: { penis: 0 | 1; vagina: 0 | 1; breasts: 0 | 1 };
  height_label: string;
  body_label: string;
  fur_label: string;
  voice_label: string;
  muzzle_label: string;
  expression_label: string;
  gnoll_flavortext_len: number;
  gnoll_ooc_notes_len: number;
  pronoun_options: string[];
  pelt_options: string[];
  height_options: string[];
  body_options: string[];
  fur_options: string[];
  voice_options: string[];
  muzzle_options: string[];
  expression_options: string[];
};

type Data = {
  gnoll: Partial<GnollData>;
  gnoll_static: Partial<GnollData>;
};

type GnollTabProps = { data: Data; act: ActFunctionType };

export const GnollTab = ({ data, act }: GnollTabProps) => {
  // Merge static option lists into the dynamic gnoll selections.
  const g = { ...data.gnoll_static, ...data.gnoll } as GnollData;
  if (!data.gnoll) {
    return <Box color="label">Gnoll preferences not initialized.</Box>;
  }

  const gAct = (gaction: string, extra: Record<string, string> = {}) =>
    act('gnoll_action', { gaction, ...extra });

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="Gnoll Form — spread terror in the name of the GORESTAR">
          <LabeledList>
            <LabeledList.Item label="Name">
              <Button onClick={() => gAct('set_name')}>{g.gnoll_name}</Button>
              <Button ml={1} onClick={() => gAct('random_name')}>
                Random
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Pronouns">
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={g.pronoun_label}
                displayText={g.pronoun_label}
                options={g.pronoun_options}
                onSelected={(value) =>
                  value !== g.pronoun_label &&
                  gAct('choose_pronouns', { picked_name: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Pelt Pattern">
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={g.pelt_label}
                displayText={g.pelt_label}
                options={g.pelt_options}
                onSelected={(value) =>
                  value !== g.pelt_label &&
                  gAct('choose_pelt', { picked_name: value })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Anatomy">
          <LabeledList>
            <LabeledList.Item label="Penis">
              <Button
                color={g.genitals.penis ? 'good' : 'default'}
                onClick={() =>
                  gAct('toggle_genital', {
                    genital: 'penis',
                    toggle: g.genitals.penis ? 'disable' : 'enable',
                  })
                }
              >
                {g.genitals.penis ? 'Yes' : 'No'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Vagina">
              <Button
                color={g.genitals.vagina ? 'good' : 'default'}
                onClick={() =>
                  gAct('toggle_genital', {
                    genital: 'vagina',
                    toggle: g.genitals.vagina ? 'disable' : 'enable',
                  })
                }
              >
                {g.genitals.vagina ? 'Yes' : 'No'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Breasts">
              <Button
                color={g.genitals.breasts ? 'good' : 'default'}
                onClick={() =>
                  gAct('toggle_genital', {
                    genital: 'breasts',
                    toggle: g.genitals.breasts ? 'disable' : 'enable',
                  })
                }
              >
                {g.genitals.breasts ? 'Yes' : 'No'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Descriptors">
          <LabeledList>
            {(
              [
                ['Height', 'height', g.height_label, g.height_options],
                ['Build', 'body', g.body_label, g.body_options],
                ['Coat', 'fur', g.fur_label, g.fur_options],
                ['Voice', 'voice', g.voice_label, g.voice_options],
                ['Muzzle Shape', 'muzzle', g.muzzle_label, g.muzzle_options],
                ['Expression', 'expression', g.expression_label, g.expression_options],
              ] as [string, string, string, string[]][]
            ).map(([label, slot, current, options]) => (
              <LabeledList.Item key={slot} label={label}>
                <Dropdown
                  width="200px"
                  menuWidth="240px"
                  selected={current}
                  displayText={current}
                  options={options}
                  onSelected={(value) =>
                    value !== current &&
                    gAct('choose_descriptor', { slot, picked_name: value })
                  }
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Gnoll-only Flavor (overrides normal flavor in gnoll form)">
          <LabeledList>
            <LabeledList.Item label="Gnoll Flavortext">
              <Button onClick={() => gAct('set_flavortext')}>Edit</Button>
              {g.gnoll_flavortext_len > 0 && (
                <Button
                  ml={1}
                  color="bad"
                  onClick={() => gAct('clear_flavortext')}
                >
                  Clear
                </Button>
              )}
              <Box inline ml={1} color="label">
                {g.gnoll_flavortext_len === 0
                  ? '(none — uses normal flavor)'
                  : `${g.gnoll_flavortext_len} chars`}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Gnoll OOC Notes">
              <Button onClick={() => gAct('set_ooc_notes')}>Edit</Button>
              {g.gnoll_ooc_notes_len > 0 && (
                <Button
                  ml={1}
                  color="bad"
                  onClick={() => gAct('clear_ooc_notes')}
                >
                  Clear
                </Button>
              )}
              <Box inline ml={1} color="label">
                {g.gnoll_ooc_notes_len === 0
                  ? '(none — uses normal OOC)'
                  : `${g.gnoll_ooc_notes_len} chars`}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
