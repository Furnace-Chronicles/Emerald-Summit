import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

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
  age_options: string[];
  species_name: string;
  subspecies_name: string;
  species_psydonic: 0 | 1;
  species_use_titles: 0 | 1;
  selected_title: string;
  has_subspecies_options: 0 | 1;
  origin_name: string;
  origin_gives_language: 0 | 1;
  statpack_name: string;
  statpack_label?: string;
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
  species_options: string[];
  subspecies_options: string[];
  origin_options: string[];
  race_title_options: string[];
  statpack_options: string[];
  extra_language_options: string[];
  virtue_options: string[];
  charflaw_options: string[];
  faith_options: string[];
  patron_options: string[];
  combat_music_options: string[];
  family_options: string[];
  gender_choice_options: string[];
  xenophobe_options: string[];
  xenophobe_label: string;
  tail_type_options: string[];
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
  fav_food_label: string;
  fav_drink_label: string;
  hated_food_label: string;
  hated_drink_label: string;
  food_options: string[];
  drink_options: string[];
};

type Data = {
  identity: IdentityData;
  body: BodyData;
  markings: MarkingsData;
  culinary: CulinaryData;
  // Static option lists shipped via ui_static_data — same for every poll.
  pronoun_options: string[];
  voice_type_options: string[];
  voice_pack_options: string[];
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
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={id.pronouns}
                displayText={id.pronouns}
                options={data.pronoun_options}
                onSelected={(value) =>
                  value !== id.pronouns &&
                  act('set_pronouns_direct', { name: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Voice Identity">
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={id.voice_type}
                displayText={id.voice_type}
                options={data.voice_type_options}
                onSelected={(value) =>
                  value !== id.voice_type &&
                  act('set_voice_type_direct', { name: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Voice Pack">
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={id.voice_pack}
                displayText={id.voice_pack}
                options={data.voice_pack_options}
                onSelected={(value) =>
                  value !== id.voice_pack &&
                  act('set_voice_pack_direct', { name: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={id.age}
                displayText={id.age}
                options={id.age_options}
                onSelected={(value) =>
                  value !== id.age &&
                  act('set_age_direct', { name: value })
                }
              />
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
          {/* Right column: Family stacked vertically above Palate. */}
          <Stack.Item grow basis={0}>
            <Stack vertical>
              {!!id.agevetted && (
                <Stack.Item>
                  <Section title="Family">
                    <LabeledList>
                      <LabeledList.Item label="Family">
                        <Dropdown
                          width="180px"
                          menuWidth="220px"
                          selected={id.family || 'None'}
                          displayText={id.family || 'None'}
                          options={id.family_options}
                          onSelected={(value) =>
                            value !== (id.family || 'None') &&
                            act('set_family_direct', { name: value })
                          }
                        />
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
                            <Dropdown
                              width="180px"
                              menuWidth="220px"
                              selected={id.gender_choice || 'Any Gender'}
                              displayText={id.gender_choice || 'Any Gender'}
                              options={id.gender_choice_options}
                              onSelected={(value) =>
                                value !== id.gender_choice &&
                                act('set_gender_choice_direct', {
                                  name: value,
                                })
                              }
                            />
                          </LabeledList.Item>
                          <LabeledList.Item label="Restrict Species">
                            <Dropdown
                              width="180px"
                              menuWidth="220px"
                              selected={id.xenophobe_label}
                              displayText={id.xenophobe_label}
                              options={id.xenophobe_options}
                              onSelected={(value) =>
                                value !== id.xenophobe_label &&
                                act('set_xenophobe_direct', { name: value })
                              }
                            />
                          </LabeledList.Item>
                        </>
                      )}
                    </LabeledList>
                  </Section>
                </Stack.Item>
              )}
              {!!culinary && (
                <Stack.Item>
                  <Section title="Palate">
                    <LabeledList>
                      <LabeledList.Item label="Favourite Food">
                        <Dropdown
                          width="240px"
                          menuWidth="280px"
                          selected={culinary.fav_food_label}
                          displayText={culinary.fav_food_label}
                          options={culinary.food_options}
                          onSelected={(value) =>
                            value !== culinary.fav_food_label &&
                            act('set_culinary_food_direct', {
                              preference_type: 'Favourite Food',
                              name: value,
                            })
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Favourite Drink">
                        <Dropdown
                          width="240px"
                          menuWidth="280px"
                          selected={culinary.fav_drink_label}
                          displayText={culinary.fav_drink_label}
                          options={culinary.drink_options}
                          onSelected={(value) =>
                            value !== culinary.fav_drink_label &&
                            act('set_culinary_drink_direct', {
                              preference_type: 'Favourite Drink',
                              name: value,
                            })
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Hated Food">
                        <Dropdown
                          width="240px"
                          menuWidth="280px"
                          selected={culinary.hated_food_label}
                          displayText={culinary.hated_food_label}
                          options={culinary.food_options}
                          onSelected={(value) =>
                            value !== culinary.hated_food_label &&
                            act('set_culinary_food_direct', {
                              preference_type: 'Hated Food',
                              name: value,
                            })
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Hated Drink">
                        <Dropdown
                          width="240px"
                          menuWidth="280px"
                          selected={culinary.hated_drink_label}
                          displayText={culinary.hated_drink_label}
                          options={culinary.drink_options}
                          onSelected={(value) =>
                            value !== culinary.hated_drink_label &&
                            act('set_culinary_drink_direct', {
                              preference_type: 'Hated Drink',
                              name: value,
                            })
                          }
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Race & Origin + Virtue & Vice in a single horizontal row. The Stack
          is reversed so Race & Origin renders first (left) without having to
          swap the underlying JSX blocks. */}
      <Stack.Item>
        <Stack reverse>
          <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
            <Section title="Virtue & Vice">
          <LabeledList>
            <LabeledList.Item label="Virtue">
              <Dropdown
                width="160px"
                menuWidth="220px"
                selected={id.virtue_name}
                displayText={id.virtue_name}
                options={[id.virtue_name, ...id.virtue_options]}
                onSelected={(value) =>
                  value !== id.virtue_name &&
                  act('set_virtue_direct', { name: value })
                }
              />
              <Button
                ml={1}
                icon="circle-info"
                tooltip="Print this virtue's description to chat"
                onClick={() => act('show_virtue_desc')}
              />
            </LabeledList.Item>
            {!!id.show_virtuetwo && (
              <LabeledList.Item label="Second Virtue">
                <Dropdown
                  width="220px"
                  menuWidth="260px"
                  selected={id.virtuetwo_name}
                  displayText={id.virtuetwo_name}
                  options={[id.virtuetwo_name, ...id.virtue_options]}
                  onSelected={(value) =>
                    value !== id.virtuetwo_name &&
                    act('set_virtuetwo_direct', { name: value })
                  }
                />
                <Button
                  ml={1}
                  icon="circle-info"
                  tooltip="Print this virtue's description to chat"
                  onClick={() => act('show_virtuetwo_desc')}
                />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Vice">
              <Dropdown
                width="160px"
                menuWidth="220px"
                selected={id.charflaw_name}
                displayText={id.charflaw_name}
                options={[id.charflaw_name, ...id.charflaw_options]}
                onSelected={(value) =>
                  value !== id.charflaw_name &&
                  act('set_charflaw_direct', { name: value })
                }
              />
              <Button
                ml={1}
                icon="circle-info"
                tooltip="Print this vice's description to chat"
                onClick={() => act('show_charflaw_desc')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Faith">
              <Dropdown
                width="160px"
                menuWidth="220px"
                selected={id.faith_name || '—'}
                displayText={id.faith_name || '—'}
                options={id.faith_options}
                onSelected={(value) =>
                  value !== id.faith_name &&
                  act('set_faith_direct', { name: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Patron">
              <Dropdown
                width="160px"
                menuWidth="220px"
                selected={id.patron_name || '—'}
                displayText={id.patron_name || '—'}
                options={id.patron_options}
                onSelected={(value) =>
                  value !== id.patron_name &&
                  act('set_patron_direct', { name: value })
                }
              />
              <Button
                ml={1}
                icon="circle-info"
                tooltip="Print this patron's description to chat"
                onClick={() => act('show_patron_desc')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Combat Music">
              <Dropdown
                width="160px"
                menuWidth="220px"
                selected={id.combat_music_name || '—'}
                displayText={id.combat_music_name || '—'}
                options={id.combat_music_options}
                onSelected={(value) =>
                  value !== id.combat_music_name &&
                  act('set_combat_music_direct', { name: value })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
          </Stack.Item>
          <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
            {/* Race / Origin — right half of the V&V row. */}
            <Section title="Race & Origin">
              <LabeledList>
                <LabeledList.Item label="Race">
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={id.species_name}
                displayText={id.species_name}
                options={[id.species_name, ...id.species_options]}
                onSelected={(value) =>
                  value !== id.species_name &&
                  act('set_species_direct', { name: value })
                }
              />
              <Button
                ml={1}
                icon="circle-info"
                tooltip="Print this race's lore description to chat"
                onClick={() => act('show_species_desc')}
              />
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
                <>
                  <Dropdown
                    width="180px"
                    menuWidth="220px"
                    selected={id.subspecies_name}
                    displayText={id.subspecies_name}
                    options={[id.subspecies_name, ...id.subspecies_options]}
                    onSelected={(value) =>
                      value !== id.subspecies_name &&
                      act('set_subspecies_direct', { name: value })
                    }
                  />
                  <Button
                    ml={1}
                    icon="circle-info"
                    tooltip="Print this subrace's lore description to chat"
                    onClick={() => act('show_subspecies_desc')}
                  />
                </>
              ) : (
                <Box inline color="label">
                  No subraces for this race
                </Box>
              )}
            </LabeledList.Item>
            {!!id.species_use_titles && (
              <LabeledList.Item label="Race Title">
                <Dropdown
                  width="180px"
                  menuWidth="220px"
                  selected={id.selected_title}
                  displayText={id.selected_title}
                  options={id.race_title_options}
                  onSelected={(value) =>
                    value !== id.selected_title &&
                    act('set_race_title_direct', { name: value })
                  }
                />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Origin">
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={id.origin_name}
                displayText={id.origin_name}
                options={[id.origin_name, ...id.origin_options]}
                onSelected={(value) =>
                  value !== id.origin_name &&
                  act('set_origin_direct', { name: value })
                }
              />
              <Button
                ml={1}
                icon="circle-info"
                tooltip="Print this origin's description to chat"
                onClick={() => act('show_origin_help')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Statpack">
              <Dropdown
                width="320px"
                menuWidth="360px"
                selected={id.statpack_label || id.statpack_name}
                displayText={id.statpack_label || id.statpack_name}
                options={[
                  id.statpack_label || id.statpack_name,
                  ...id.statpack_options,
                ]}
                onSelected={(value) =>
                  value !== (id.statpack_label || id.statpack_name) &&
                  act('set_statpack_direct', { name: value })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Free Language">
              {id.origin_gives_language ? (
                <Dropdown
                  width="180px"
                  menuWidth="220px"
                  selected={id.extra_language_name}
                  displayText={id.extra_language_name}
                  options={id.extra_language_options}
                  onSelected={(value) =>
                    value !== id.extra_language_name &&
                    act('set_extra_language_direct', { name: value })
                  }
                />
              ) : (
                <Box inline color="label">
                  Your current Origin does not grant a free language.
                </Box>
              )}
            </LabeledList.Item>
            {!!id.has_lamian_tail && (
              <>
                <LabeledList.Item label="Tail Type">
                  <Dropdown
                    width="200px"
                    menuWidth="240px"
                    selected={id.tail_type_name}
                    displayText={id.tail_type_name}
                    options={id.tail_type_options}
                    onSelected={(value) =>
                      value !== id.tail_type_name &&
                      act('set_tail_type_direct', { name: value })
                    }
                  />
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
        </Stack>
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

    </Stack>
  );
};
