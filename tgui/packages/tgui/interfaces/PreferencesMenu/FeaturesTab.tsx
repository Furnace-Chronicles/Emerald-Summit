import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type DescriptorEntry = {
  choice_type: string;
  choice_name: string;
  current_name: string;
};

type CustomDescriptor = {
  index: number;
  prefix_text: string;
  content_text: string;
};

type DescriptorsData = {
  entries: DescriptorEntry[];
  custom_entries: CustomDescriptor[];
  max_content_length: number;
};

type CustomizerPicker = {
  type: 'rotate' | 'chooser' | 'reset_colors' | 'color' | 'list_value' | 'toggle';
  label?: string;
  text?: string;
  color?: string;
  task?: string;
  extra?: Record<string, string>;
};

type CustomizerEntry = {
  customizer_type: string;
  name: string;
  allows_disabling: 0 | 1;
  disabled: 0 | 1;
  choice_name: string;
  has_multiple_choices: 0 | 1;
  pref_data: CustomizerPicker[];
};

type CustomizersData = {
  entries: CustomizerEntry[];
};

type Data = {
  descriptors: DescriptorsData;
  customizers: CustomizersData;
};

// Renders the structured per-choice picker list emitted by each
// /datum/customizer_choice/get_pref_data(). Every action routes through the
// generic 'customizer_action' ui_act, which calls back into the classic
// handle_customizer_topic so we reuse all existing validation/behavior.
const CustomizerPickerList = ({
  customizerType,
  pickers,
  act,
}: {
  customizerType: string;
  pickers: CustomizerPicker[];
  act: (action: string, payload?: object) => void;
}) => {
  const send = (task: string | undefined, extra: Record<string, string> = {}) =>
    act('customizer_action', {
      customizer_type: customizerType,
      customizer_task: task,
      ...extra,
    });

  // Split standalone "reset_colors" pickers out of the labeled list — they have no label.
  const labeledPickers = pickers.filter((p) => p.type !== 'reset_colors');
  const resetPicker = pickers.find((p) => p.type === 'reset_colors');

  return (
    <>
      <LabeledList>
        {labeledPickers.map((p, i) => {
          switch (p.type) {
            case 'rotate':
              return (
                <LabeledList.Item key={i} label="Style">
                  <Button
                    icon="chevron-left"
                    tooltip="Previous"
                    onClick={() => send('rotate', { rotate: 'prev' })}
                  />
                  <Button
                    ml={1}
                    width="160px"
                    textAlign="center"
                    onClick={() => send(p.task)}
                  >
                    {p.text}
                  </Button>
                  <Button
                    ml={1}
                    icon="chevron-right"
                    tooltip="Next"
                    onClick={() => send('rotate', { rotate: 'next' })}
                  />
                </LabeledList.Item>
              );
            case 'color':
              return (
                <LabeledList.Item key={i} label={p.label}>
                  <Box
                    inline
                    width="32px"
                    height="14px"
                    backgroundColor={p.color || '#ffffff'}
                    title={p.color || '(unset)'}
                    style={{
                      cursor: 'pointer',
                      border: '1px solid #000',
                      verticalAlign: 'middle',
                    }}
                    onClick={() => send(p.task, p.extra || {})}
                  />
                </LabeledList.Item>
              );
            case 'toggle':
            case 'list_value':
              return (
                <LabeledList.Item key={i} label={p.label}>
                  <Button
                    width="160px"
                    textAlign="center"
                    onClick={() => send(p.task, p.extra || {})}
                  >
                    {p.text}
                  </Button>
                </LabeledList.Item>
              );
            default:
              return null;
          }
        })}
      </LabeledList>
      {resetPicker && (
        <Box mt={1}>
          <Button onClick={() => send(resetPicker.task)}>Reset colors</Button>
        </Box>
      )}
    </>
  );
};

export const FeaturesTab = (props) => {
  const { act, data } = useBackend<Data>();
  const descriptors = data.descriptors;
  const customizers = data.customizers;

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="Describe Myself">
          {!descriptors || descriptors.entries.length === 0 ? (
            <Box color="label">
              Your species has no descriptor choices.
            </Box>
          ) : (
            <LabeledList>
              {descriptors.entries.map((entry) => (
                <LabeledList.Item
                  key={entry.choice_type}
                  label={entry.choice_name}
                >
                  <Button
                    onClick={() =>
                      act('set_descriptor', {
                        choice_type: entry.choice_type,
                      })
                    }
                  >
                    {entry.current_name || '—'}
                  </Button>
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
          {!!descriptors?.custom_entries.length && (
            <Box mt={1}>
              <LabeledList>
                {descriptors.custom_entries.map((c) => (
                  <LabeledList.Item key={c.index} label={`Custom #${c.index}`}>
                    <Button
                      onClick={() =>
                        act('set_custom_descriptor_prefix', { index: c.index })
                      }
                    >
                      {c.prefix_text}
                    </Button>
                    <Button
                      ml={1}
                      onClick={() =>
                        act('set_custom_descriptor_content', { index: c.index })
                      }
                    >
                      {c.content_text || '(empty)'}
                    </Button>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Box>
          )}
          <Box mt={1} textAlign="center" color="label" italic>
            Descriptors can vary based on gender.
            <br />
            Some don&apos;t appear if you don&apos;t match a requirement.
          </Box>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section
          title="Customizers"
          buttons={
            <>
              <Button onClick={() => act('customizers_randomize_all')}>
                Randomize All
              </Button>
              <Button onClick={() => act('customizers_reset_all_colors')}>
                Reset Colors
              </Button>
            </>
          }
        >
          {!customizers || customizers.entries.length === 0 ? (
            <Box color="label">
              Your species has no customizers available.
            </Box>
          ) : (
            <Stack vertical>
              {(() => {
                // Group specific customizers into one row each; everything else
                // stays full-width. If a species only has some of a group (e.g.
                // Hair but no Facial Hair), the lone entry/entries still render
                // together with the available group members.
                const GROUPS: string[][] = [
                  ['Hair', 'Facial Hair'],
                  ['Eyes', 'Horns'],
                  ['Penis', 'Testicles'],
                  ['Breasts', 'Vagina'],
                  ['Tail', 'Tail Feature'],
                  ['Legwear', 'Underwear'],
                  ['Accessory', 'Face Detail'],
                  ['Snout', 'Hood', 'Frills'],
                ];
                const groupOf: Record<string, string[]> = {};
                for (const group of GROUPS) {
                  for (const name of group) {
                    groupOf[name] = group;
                  }
                }
                const rows: CustomizerEntry[][] = [];
                const consumed = new Set<string>();
                for (const c of customizers.entries) {
                  if (consumed.has(c.customizer_type)) continue;
                  const group = groupOf[c.name];
                  if (group) {
                    // Pull every available member of the group together, in the
                    // order declared by GROUPS — keeps Snout/Hood/Frills stable
                    // regardless of how the backend orders its entries list.
                    const row: CustomizerEntry[] = [];
                    for (const memberName of group) {
                      const member = customizers.entries.find(
                        (other) =>
                          other.name === memberName &&
                          !consumed.has(other.customizer_type),
                      );
                      if (member) {
                        row.push(member);
                        consumed.add(member.customizer_type);
                      }
                    }
                    if (row.length > 0) rows.push(row);
                  } else {
                    rows.push([c]);
                    consumed.add(c.customizer_type);
                  }
                }
                return rows.map((row, idx) => (
                  <Stack.Item key={idx}>
                    <Stack>
                      {row.map((c) => (
                        <Stack.Item key={c.customizer_type} grow>
                          <Section title={c.name}>
                            <Stack align="center" mb={1}>
                              {!!c.allows_disabling && (
                                <Stack.Item>
                                  <Button
                                    color={c.disabled ? 'bad' : 'good'}
                                    tooltip={c.disabled ? 'Disabled' : 'Enabled'}
                                    onClick={() =>
                                      act('customizer_toggle', {
                                        customizer_type: c.customizer_type,
                                      })
                                    }
                                  >
                                    {c.disabled ? 'Off' : 'On'}
                                  </Button>
                                </Stack.Item>
                              )}
                              {!c.disabled &&
                                !!c.has_multiple_choices &&
                                c.choice_name !== c.name && (
                                  <Stack.Item>
                                    <Button
                                      width="160px"
                                      textAlign="center"
                                      onClick={() =>
                                        act('customizer_change_choice', {
                                          customizer_type: c.customizer_type,
                                        })
                                      }
                                    >
                                      {c.choice_name}
                                    </Button>
                                  </Stack.Item>
                                )}
                            </Stack>
                            {!c.disabled && c.pref_data.length > 0 && (
                              <CustomizerPickerList
                                customizerType={c.customizer_type}
                                pickers={c.pref_data}
                                act={act}
                              />
                            )}
                          </Section>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                ));
              })()}
            </Stack>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
