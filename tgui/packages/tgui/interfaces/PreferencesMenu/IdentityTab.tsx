import { Box, Button, Dropdown, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type IdentityData = {
  real_name: string;
  name_is_banned: 0 | 1;
  appearance_banned: 0 | 1;
  nickname: string;
  pronouns: string;
  voice_type: string;
  voice_pack: string;
  age: string;
  species_name: string;
  subspecies_name: string;
  species_psydonic: 0 | 1;
  species_use_titles: 0 | 1;
  selected_title: string;
  has_subspecies_options: 0 | 1;
  origin_name: string;
  origin_gives_language: 0 | 1;
  statpack_name: string;
  virtue_name: string;
  virtuetwo_name: string;
  show_virtuetwo: 0 | 1;
  charflaw_name: string;
  faith_name: string;
  patron_name: string;
  domhand: number;
  dnr_pref: 0 | 1;
  combat_music_name: string;
  agevetted: 0 | 1;
  family: string;
  setspouse: string;
  gender_choice: string;
  xenophobe_pref: number;
  gender: string;
  agender_species: 0 | 1;
  extra_language_name: string;
  has_lamian_tail: 0 | 1;
  tail_type_name?: string;
  tail_color?: string;
  tail_markings_color?: string;
};

type BodyData = {
  use_skintones: 0 | 1;
  skin_tone_wording: string;
  species_id: string;
  has_lamian_tail: 0 | 1;
  has_harpy: 0 | 1;
  has_mutcolors: 0 | 1;
  skin_tone: string;
  skin_tone_name: string;
  update_mutant_colors: 0 | 1;
  mcolor?: string;
  mcolor2?: string;
  mcolor3?: string;
  voice_color: string;
  highlight_color: string;
  voice_pitch: number;
  char_accent: string;
  body_size_pct: number;
};

type MarkingEntry = {
  name: string;
  color: string;
  index: number;
  can_move_up: 0 | 1;
  can_move_down: 0 | 1;
};

type MarkingZone = {
  key: string;
  label: string;
  markings: MarkingEntry[];
  can_add: 0 | 1;
  available: string[];
};

type MarkingsData = {
  max_per_limb: number;
  has_presets: 0 | 1;
  species_has_no_markings: 0 | 1;
  zones: MarkingZone[];
};

type CulinaryData = {
  fav_food_name: string;
  fav_drink_name: string;
  hated_food_name: string;
  hated_drink_name: string;
};

type Data = {
  identity: IdentityData;
  body: BodyData;
  markings: MarkingsData;
  culinary: CulinaryData;
};

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
        // Skip the row entirely if no zone in this row is present for the species.
        const hasAnyZone = row.some(
          (cell) => cell.key && zoneByKey.has(cell.key),
        );
        if (!hasAnyZone) {
          return null;
        }
        return (
          <Stack.Item key={rowIdx}>
            <Stack>
              {row.map((cell, colIdx) => (
                <Stack.Item
                  key={colIdx}
                  grow={cell.grow}
                  basis={0}
                  // minWidth: 0 stops flex children from refusing to shrink
                  // below their content's intrinsic width — without it,
                  // dropdowns and long marking names push columns wider than
                  // their share, producing the uneven layout where Chest
                  // looked wider than the arm columns. overflow: hidden
                  // backs that up by clipping any non-wrapping descendants.
                  style={{ minWidth: 0, overflow: 'hidden' }}
                >
                  {cell.key && zoneByKey.has(cell.key) ? (
                    <ZoneCard
                      zone={zoneByKey.get(cell.key)!}
                      act={act}
                    />
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
        {/* Per-marking block: name+swatch on top, optional Change Dropdown on
            its own line (so it can claim the full column width without the
            label competing), action buttons on the bottom. Stacks vertically
            so narrow grid cells don't squeeze the dropdown text. */}
        {zone.markings.map((m) => (
          <Box key={m.name} mb={1}>
            <Box>
              <b>{m.name}</b>
              <Box
                inline
                ml={1}
                width="32px"
                height="14px"
                backgroundColor={'#' + (m.color || 'ffffff')}
                title={m.color ? '#' + m.color : '(unset)'}
                style={{
                  cursor: 'pointer',
                  border: '1px solid #000',
                  verticalAlign: 'middle',
                }}
                onClick={() =>
                  act('marking_color', { zone: zone.key, name: m.name })
                }
              />
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

export const IdentityTab = (props) => {
  const { act, data } = useBackend<Data>();
  const id = data.identity;
  const body = data.body;
  const markings = data.markings;
  const culinary = data.culinary;
  if (!id) {
    return <Box color="label">Loading identity…</Box>;
  }

  return (
    <Stack vertical>
      {!!id.appearance_banned && (
        <Stack.Item>
          <Box color="bad" bold>
            You are banned from custom names and appearances. You can still
            adjust your character, but they will be randomised at round start.
          </Box>
        </Stack.Item>
      )}

      {/* Basics — Identity + Family side-by-side when agevetted; Identity
          stretches full-width otherwise. */}
      <Stack.Item>
        <Stack>
          <Stack.Item grow basis={0}>
            <Section title="Identity">
          <LabeledList>
            <LabeledList.Item label="Name">
              {id.name_is_banned ? (
                <Button color="bad" onClick={() => act('set_name')}>
                  NAMEBANNED
                </Button>
              ) : (
                <>
                  <Button onClick={() => act('set_name')}>
                    {id.real_name || '(unset)'}
                  </Button>
                  <Button
                    ml={1}
                    icon="dice"
                    onClick={() => act('randomize_name')}
                    tooltip="Random name"
                  />
                </>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Nickname">
              <Button onClick={() => act('set_nickname')}>
                {id.nickname || '(unset)'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Pronouns">
              <Button onClick={() => act('set_pronouns')}>{id.pronouns}</Button>
            </LabeledList.Item>
            <LabeledList.Item label="Voice Identity">
              <Button onClick={() => act('set_voice_type')}>
                {id.voice_type}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Voice Pack">
              <Button onClick={() => act('set_voice_pack')}>
                {id.voice_pack}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <Button onClick={() => act('set_age')}>{id.age}</Button>
            </LabeledList.Item>
            {!id.agender_species && (
              <LabeledList.Item label="Body Type">
                <Button onClick={() => act('toggle_gender')}>
                  {id.gender === 'male' ? 'Masculine' : 'Feminine'}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Dominance">
              <Button onClick={() => act('toggle_domhand')}>
                {id.domhand === 1 ? 'Left-handed' : 'Right-handed'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Unrevivable">
              <Button
                color={id.dnr_pref ? 'bad' : 'default'}
                onClick={() => act('toggle_dnr')}
              >
                {id.dnr_pref ? 'Yes' : 'No'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
          </Stack.Item>
          {!!id.agevetted && (
            <Stack.Item grow basis={0}>
              <Section title="Family">
                <LabeledList>
                  <LabeledList.Item label="Family">
                    <Button onClick={() => act('set_family')}>
                      {id.family || 'None'}
                    </Button>
                  </LabeledList.Item>
                  {id.family && id.family !== 'None' && (
                    <LabeledList.Item
                      label={
                        id.family === 'Siblings'
                          ? 'Preferred Parent'
                          : 'Preferred Spouse'
                      }
                    >
                      <Button onClick={() => act('set_setspouse')}>
                        {id.setspouse || 'None'}
                      </Button>
                    </LabeledList.Item>
                  )}
                  {(id.family === 'Newlywed' || id.family === 'Parent') && (
                    <>
                      <LabeledList.Item label="Preferred Gender">
                        <Button onClick={() => act('set_gender_choice')}>
                          {id.gender_choice || 'Any Gender'}
                        </Button>
                      </LabeledList.Item>
                      <LabeledList.Item label="Restrict Species">
                        <Button onClick={() => act('cycle_xenophobe')}>
                          {id.xenophobe_pref === 1
                            ? 'Race only'
                            : id.xenophobe_pref === 2
                              ? 'Subrace only'
                              : 'Unrestricted'}
                        </Button>
                      </LabeledList.Item>
                    </>
                  )}
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>

      {/* Race / Origin */}
      <Stack.Item>
        <Section title="Race & Origin">
          <LabeledList>
            <LabeledList.Item label="Race">
              <Button onClick={() => act('set_species')}>
                {id.species_name}
              </Button>
              <Button
                ml={1}
                icon="circle-question"
                tooltip="Race symbol meaning"
                onClick={() => act('show_race_help')}
              >
                <Box
                  inline
                  color={id.species_psydonic ? 'good' : 'bad'}
                  bold
                >
                  {id.species_psydonic ? 'ᛉ' : 'ᛣ'}
                </Box>
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Subrace">
              {id.has_subspecies_options ? (
                <Button onClick={() => act('set_subspecies')}>
                  {id.subspecies_name}
                </Button>
              ) : (
                <Box inline color="label">
                  No subraces for this race
                </Box>
              )}
            </LabeledList.Item>
            {!!id.species_use_titles && (
              <LabeledList.Item label="Race Title">
                <Button onClick={() => act('set_race_title')}>
                  {id.selected_title}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Origin">
              <Button onClick={() => act('set_origin')}>{id.origin_name}</Button>
              <Button
                ml={1}
                icon="circle-question"
                tooltip="Origin description"
                onClick={() => act('show_origin_help')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Statpack">
              <Button onClick={() => act('set_statpack')}>
                {id.statpack_name}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Free Language">
              <Button
                disabled={!id.origin_gives_language}
                tooltip={
                  id.origin_gives_language
                    ? undefined
                    : 'Your current Origin does not grant a free language.'
                }
                onClick={() => act('set_extra_language')}
              >
                {id.extra_language_name}
              </Button>
            </LabeledList.Item>
            {!!id.has_lamian_tail && (
              <>
                <LabeledList.Item label="Tail Type">
                  <Button onClick={() => act('set_tail_type')}>
                    {id.tail_type_name}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Tail Color">
                  <Button
                    onClick={() => act('set_tail_color')}
                    backgroundColor={'#' + (id.tail_color || 'ffffff')}
                  >
                    {' '}
                    Change
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Marking Color">
                  <Button
                    onClick={() => act('set_tail_markings_color')}
                    backgroundColor={'#' + (id.tail_markings_color || 'ffffff')}
                  >
                    {' '}
                    Change
                  </Button>
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>

      {/* Body */}
      {!!body && (
        <Stack.Item>
          <Section title="Body">
            <LabeledList>
              <LabeledList.Item label="Update Colors With Change">
                <Button onClick={() => act('toggle_update_mutant_colors')}>
                  {body.update_mutant_colors ? 'Yes' : 'No'}
                </Button>
              </LabeledList.Item>

              {!!body.use_skintones && !body.has_lamian_tail && (
                <LabeledList.Item label={body.skin_tone_wording || 'Skin tone'}>
                  <Button onClick={() => act('set_skin_tone')}>
                    {body.skin_tone_name}
                  </Button>
                  {body.species_id !== 'lupian' && (
                    <Button
                      ml={1}
                      icon="circle-question"
                      tooltip="Skin color reference list"
                      onClick={() => act('show_skin_color_ref')}
                    />
                  )}
                </LabeledList.Item>
              )}

              {!!body.has_mutcolors &&
                !body.has_lamian_tail &&
                !body.has_harpy && (
                  <>
                    <LabeledList.Item label="Mutant Color #1">
                      <ColorSwatch hex={body.mcolor} />
                      <Button
                        onClick={() => act('set_mutant_color', { index: 1 })}
                      >
                        Change
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Mutant Color #2">
                      <ColorSwatch hex={body.mcolor2} />
                      <Button
                        onClick={() => act('set_mutant_color', { index: 2 })}
                      >
                        Change
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item label="Mutant Color #3">
                      <ColorSwatch hex={body.mcolor3} />
                      <Button
                        onClick={() => act('set_mutant_color', { index: 3 })}
                      >
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
                    <Button
                      onClick={() => act('set_mutant_color', { index: 2 })}
                    >
                      Change
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Feature Color #2">
                    <ColorSwatch hex={body.mcolor3} />
                    <Button
                      onClick={() => act('set_mutant_color', { index: 3 })}
                    >
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
                    <Button
                      onClick={() => act('set_mutant_color', { index: 2 })}
                    >
                      Change
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Feature Color #2">
                    <ColorSwatch hex={body.mcolor3} />
                    <Button
                      onClick={() => act('set_mutant_color', { index: 3 })}
                    >
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
                <Button onClick={() => act('set_highlight_color')}>
                  Change
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Voice Pitch">
                <Button onClick={() => act('set_voice_pitch')}>
                  {body.voice_pitch}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Accent">
                <Button onClick={() => act('set_char_accent')}>
                  {body.char_accent}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Sprite Scale">
                <Button onClick={() => act('set_body_size')}>
                  {body.body_size_pct}%
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      )}

      {/* Palate (Food Preferences) */}
      {!!culinary && (
        <Stack.Item>
          <Section title="Palate">
            <LabeledList>
              <LabeledList.Item label="Favourite Food">
                <Button
                  onClick={() =>
                    act('set_culinary_food', {
                      preference_type: 'Favourite Food',
                    })
                  }
                >
                  {culinary.fav_food_name}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Favourite Drink">
                <Button
                  onClick={() =>
                    act('set_culinary_drink', {
                      preference_type: 'Favourite Drink',
                    })
                  }
                >
                  {culinary.fav_drink_name}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Hated Food">
                <Button
                  onClick={() =>
                    act('set_culinary_food', {
                      preference_type: 'Hated Food',
                    })
                  }
                >
                  {culinary.hated_food_name}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Hated Drink">
                <Button
                  onClick={() =>
                    act('set_culinary_drink', {
                      preference_type: 'Hated Drink',
                    })
                  }
                >
                  {culinary.hated_drink_name}
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      )}

      {/* Markings */}
      {!!markings && (
        <Stack.Item>
          <Section
            title="Markings"
            buttons={
              <>
                <Button
                  disabled={!markings.has_presets}
                  onClick={() => act('markings_use_preset')}
                >
                  Use Preset
                </Button>
                <Button
                  color="bad"
                  onClick={() => act('markings_clear_all')}
                >
                  Clear All
                </Button>
              </>
            }
          >
            {!!markings.species_has_no_markings && (
              <Box color="label">
                Your species has no body markings available.
              </Box>
            )}
            <MarkingsGrid zones={markings.zones} act={act} />

          </Section>
        </Stack.Item>
      )}

      {/* Virtue / Vice / Faith */}
      <Stack.Item>
        <Section title="Virtue & Vice">
          <LabeledList>
            <LabeledList.Item label="Virtue">
              <Button onClick={() => act('set_virtue')}>{id.virtue_name}</Button>
            </LabeledList.Item>
            {!!id.show_virtuetwo && (
              <LabeledList.Item label="Second Virtue">
                <Button onClick={() => act('set_virtuetwo')}>
                  {id.virtuetwo_name}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Vice">
              <Button onClick={() => act('set_charflaw')}>
                {id.charflaw_name}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Faith">
              <Button onClick={() => act('set_faith')}>
                {id.faith_name || '—'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Patron">
              <Button onClick={() => act('set_patron')}>
                {id.patron_name || '—'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Combat Music">
              <Button onClick={() => act('set_combat_music')}>
                {id.combat_music_name || '—'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

    </Stack>
  );
};
