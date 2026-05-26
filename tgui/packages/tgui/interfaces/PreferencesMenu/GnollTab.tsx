import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type GnollData = {
  gnoll_name: string;
  gnoll_pronouns: string;
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
};

type Data = {
  gnoll: GnollData;
};

export const GnollTab = (props) => {
  const { act, data } = useBackend<Data>();
  const g = data.gnoll;
  if (!g) {
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
              <Button onClick={() => gAct('choose_pronouns')}>
                {g.gnoll_pronouns}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Pelt Pattern">
              <Button onClick={() => gAct('choose_pelt')}>{g.pelt_label}</Button>
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
            <LabeledList.Item label="Height">
              <Button onClick={() => gAct('choose_descriptor', { slot: 'height' })}>
                {g.height_label}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Build">
              <Button onClick={() => gAct('choose_descriptor', { slot: 'body' })}>
                {g.body_label}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Coat">
              <Button onClick={() => gAct('choose_descriptor', { slot: 'fur' })}>
                {g.fur_label}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Voice">
              <Button onClick={() => gAct('choose_descriptor', { slot: 'voice' })}>
                {g.voice_label}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Muzzle Shape">
              <Button onClick={() => gAct('choose_descriptor', { slot: 'muzzle' })}>
                {g.muzzle_label}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Expression">
              <Button
                onClick={() => gAct('choose_descriptor', { slot: 'expression' })}
              >
                {g.expression_label}
              </Button>
            </LabeledList.Item>
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
