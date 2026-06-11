import {
  Box,
  Button,
  LabeledList,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { CustomizerCard, CustomizerEntry } from './CustomizerCard';
// Searchable drop-in: stock Dropdown for short lists, adds a filter box once a
// list passes 7 options. (Replaces the per-tab RawDropdown + inline-Box wrapper.)
import { SearchableDropdown as Dropdown } from '../common/SearchableDropdown';

export type BodyData = {
  use_skintones: 0 | 1;
  skin_tone_wording: string;
  species_id: string;
  has_lamian_tail: 0 | 1;
  has_harpy: 0 | 1;
  has_mutcolors: 0 | 1;
  skin_tone: string;
  skin_tone_name: string;
  skin_tone_options: string[];
  update_mutant_colors: 0 | 1;
  mcolor?: string;
  mcolor2?: string;
  mcolor3?: string;
  voice_color: string;
  highlight_color: string;
  voice_pitch: number;
  voice_pitch_min: number;
  voice_pitch_max: number;
  char_accent: string;
  accent_options: string[];
  body_size_pct: number;
  body_size_min_pct: number;
  body_size_max_pct: number;
  body_size_locked: 0 | 1;
};

type CustomizerEntryStatic = {
  customizer_type: string;
  name: string;
  allows_disabling: 0 | 1;
  has_multiple_choices: 0 | 1;
  choice_options: string[];
};

type CustomizerEntryDynamic = {
  customizer_type: string;
  disabled: 0 | 1;
  choice_name: string;
  pref_data: any[];
};

type Data = {
  // Dynamic — selections + trait flags.
  body: Partial<BodyData>;
  // Static — option lists (skin tones, accents, body-size bounds).
  body_static: Partial<BodyData>;
  customizers?: { entries: CustomizerEntryDynamic[] };
  customizers_static?: { entries: CustomizerEntryStatic[] };
};

const ColorSwatch = ({ hex }: { hex?: string }) => (
  <Box
    inline
    width="20px"
    height="14px"
    style={{
      backgroundColor: '#' + (hex || 'ffffff'),
      border: '1px solid #161616',
      verticalAlign: 'middle',
      marginRight: '4px',
    }}
  />
);

export const BodySection = () => {
  const { act, data } = useBackend<Data>();
  // Merge static option lists into the dynamic body data so existing
  // body.skin_tone_options / body.accent_options references resolve.
  const body = { ...data.body_static, ...data.body } as BodyData;
  if (!data.body) return null;
  // Ears was lifted out of the FeaturesTab customizer grid and rendered
  // here in the right column; if the species doesn't expose an Ears
  // customizer, the right column simply doesn't appear. Match the static
  // catalog entry (which carries the name) with the dynamic entry
  // (which carries current selections) by customizer_type, then spread
  // them together so CustomizerCard sees a unified entry.
  const earsStatic =
    data.customizers_static?.entries.find((c) => c.name === 'Ears') || null;
  const earsDynamic = earsStatic
    ? data.customizers?.entries.find(
        (c) => c.customizer_type === earsStatic.customizer_type,
      )
    : null;
  const earsCustomizer =
    earsStatic && earsDynamic
      ? ({ ...earsStatic, ...earsDynamic } as CustomizerEntry)
      : null;
  return (
    <Section title="Body">
      <Stack>
        <Stack.Item grow basis={0}>
      <LabeledList>
        <LabeledList.Item label="Update Colors With Change">
          <Button onClick={() => act('toggle_update_mutant_colors')}>
            {body.update_mutant_colors ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>

        {!!body.use_skintones && !body.has_lamian_tail && (
          <LabeledList.Item label={body.skin_tone_wording || 'Skin tone'}>
            <Dropdown
              width="180px"
              menuWidth="220px"
              selected={body.skin_tone_name}
              displayText={body.skin_tone_name}
              options={[
                body.skin_tone_name,
                ...body.skin_tone_options.filter(
                  (n) => n !== body.skin_tone_name,
                ),
              ]}
              onSelected={(value) =>
                value !== body.skin_tone_name &&
                act('set_skin_tone_direct', { name: value })
              }
            />
            {body.species_id !== 'lupian' && (
              <Box mt={0.5}>
                <Button
                  icon="circle-question"
                  tooltip="Skin color reference list"
                  onClick={() => act('show_skin_color_ref')}
                />
              </Box>
            )}
          </LabeledList.Item>
        )}

        {!!body.has_mutcolors &&
          !body.has_lamian_tail &&
          !body.has_harpy && (
            <>
              <LabeledList.Item label="Mutant Color #1">
                <ColorSwatch hex={body.mcolor} />
                <Button onClick={() => act('set_mutant_color', { index: 1 })}>
                  Change
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Mutant Color #2">
                <ColorSwatch hex={body.mcolor2} />
                <Button onClick={() => act('set_mutant_color', { index: 2 })}>
                  Change
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Mutant Color #3">
                <ColorSwatch hex={body.mcolor3} />
                <Button onClick={() => act('set_mutant_color', { index: 3 })}>
                  Change
                </Button>
              </LabeledList.Item>
            </>
          )}

        {!!body.has_lamian_tail && (
          <>
            <LabeledList.Item label="Skin/scales color #1">
              <ColorSwatch hex={body.mcolor} />
              <Button onClick={() => act('set_skin_choice_pick')}>
                Change
              </Button>
              <Button
                ml={1}
                icon="circle-question"
                tooltip="Skin color reference list"
                onClick={() => act('show_skin_color_ref')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Feature Color #1">
              <ColorSwatch hex={body.mcolor2} />
              <Button onClick={() => act('set_mutant_color', { index: 2 })}>
                Change
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Feature Color #2">
              <ColorSwatch hex={body.mcolor3} />
              <Button onClick={() => act('set_mutant_color', { index: 3 })}>
                Change
              </Button>
            </LabeledList.Item>
          </>
        )}

        {!!body.has_harpy && (
          <>
            <LabeledList.Item label="Skin/Feathers color #1">
              <ColorSwatch hex={body.mcolor} />
              <Button onClick={() => act('set_skin_feathers_pick')}>
                Change
              </Button>
              <Button
                ml={1}
                icon="circle-question"
                tooltip="Skin color reference list"
                onClick={() => act('show_skin_color_ref')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Feature Color #1">
              <ColorSwatch hex={body.mcolor2} />
              <Button onClick={() => act('set_mutant_color', { index: 2 })}>
                Change
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Feature Color #2">
              <ColorSwatch hex={body.mcolor3} />
              <Button onClick={() => act('set_mutant_color', { index: 3 })}>
                Change
              </Button>
            </LabeledList.Item>
          </>
        )}

        <LabeledList.Item label="Voice Color">
          <ColorSwatch hex={body.voice_color?.replace('#', '')} />
          <Button onClick={() => act('set_voice_color')}>Change</Button>
        </LabeledList.Item>
        <LabeledList.Item label="Nickname Color">
          <ColorSwatch hex={body.highlight_color?.replace('#', '')} />
          <Button onClick={() => act('set_highlight_color')}>Change</Button>
        </LabeledList.Item>
        <LabeledList.Item label="Voice Pitch">
          <Box width="220px" inline>
            <Slider
              minValue={body.voice_pitch_min}
              maxValue={body.voice_pitch_max}
              value={body.voice_pitch}
              step={0.01}
              stepPixelSize={5}
              format={(v) => v.toFixed(2)}
              onChange={(_e, value) =>
                act('set_voice_pitch_direct', { value })
              }
            />
          </Box>
          <Box inline ml={1} color="label">
            (lower is deeper)
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Accent">
          <Dropdown
            width="180px"
            menuWidth="220px"
            selected={body.char_accent}
            displayText={body.char_accent}
            options={body.accent_options}
            onSelected={(value) =>
              value !== body.char_accent &&
              act('set_char_accent_direct', { name: value })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Sprite Scale">
          <Box width="220px" inline>
            <Slider
              minValue={body.body_size_min_pct}
              maxValue={body.body_size_max_pct}
              value={body.body_size_pct}
              step={1}
              stepPixelSize={20}
              unit="%"
              disabled={!!body.body_size_locked}
              onChange={(_e, value) =>
                act('set_body_size_direct', { value })
              }
            />
          </Box>
          {!!body.body_size_locked && (
            <Box inline ml={1} color="label">
              locked by virtue
            </Box>
          )}
        </LabeledList.Item>
      </LabeledList>
        </Stack.Item>
        {earsCustomizer && (
          <Stack.Item grow basis={0}>
            <CustomizerCard customizer={earsCustomizer} act={act} />
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
