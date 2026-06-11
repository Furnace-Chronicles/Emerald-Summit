import { Fragment } from 'react';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { BodySection } from './BodySection';
import { CustomizerCard, CustomizerEntry } from './CustomizerCard';
import { MarkingsSection } from './MarkingsSection';
// Searchable drop-in: stock Dropdown for short lists, adds a filter box once a
// list passes 7 options. (Replaces the per-tab RawDropdown + inline-Box wrapper.)
import { SearchableDropdown as Dropdown } from '../common/SearchableDropdown';

type DescriptorEntryStatic = {
  choice_type: string;
  choice_name: string;
  options: string[];
};

type DescriptorEntryDynamic = {
  choice_type: string;
  current_name: string;
};

type DescriptorEntry = DescriptorEntryStatic & DescriptorEntryDynamic;

type CustomDescriptor = {
  index: number;
  prefix_text: string;
  content_text: string;
};

type DescriptorsDynamicData = {
  entries: DescriptorEntryDynamic[];
  custom_entries: CustomDescriptor[];
};

type DescriptorsStaticData = {
  entries: DescriptorEntryStatic[];
  max_content_length: number;
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

type CustomizersDynamicData = {
  entries: CustomizerEntryDynamic[];
};

type CustomizersStaticData = {
  entries: CustomizerEntryStatic[];
};

type Data = {
  descriptors: DescriptorsDynamicData;
  descriptors_static: DescriptorsStaticData;
  customizers: CustomizersDynamicData;
  customizers_static: CustomizersStaticData;
};


export const FeaturesTab = (props) => {
  const { act, data } = useBackend<Data>();

  // Merge each descriptor entry's static (name + options) with its dynamic
  // (current_name) half by choice_type, so the rendering loop sees the
  // existing unified shape.
  const descriptorsStatic = data.descriptors_static;
  const descriptorsDynamic = data.descriptors;
  const descriptors = descriptorsStatic
    ? {
        ...descriptorsStatic,
        ...descriptorsDynamic,
        entries: descriptorsStatic.entries.map((s) => {
          const d = descriptorsDynamic?.entries.find(
            (e) => e.choice_type === s.choice_type,
          );
          return { ...s, ...d } as DescriptorEntry;
        }),
        custom_entries: descriptorsDynamic?.custom_entries || [],
      }
    : null;

  // Same merge for customizers — static catalog (name, allows_disabling,
  // choice_options) joined to dynamic state (disabled, choice_name,
  // pref_data) by customizer_type. Defaults are baked in between the
  // spreads so a brief gap between static and dynamic pushes (e.g. when
  // switching tabs before the server's set_tab reply lands) doesn't leave
  // pref_data undefined — CustomizerCard reads pref_data.length and would
  // crash on the optimistic render otherwise.
  const customizersStatic = data.customizers_static;
  const customizersDynamic = data.customizers;
  const customizers = customizersStatic
    ? {
        entries: customizersStatic.entries.map((s) => {
          const d = customizersDynamic?.entries.find(
            (e) => e.customizer_type === s.customizer_type,
          );
          return {
            ...s,
            disabled: 0,
            choice_name: s.name,
            pref_data: [],
            ...d,
          } as CustomizerEntry;
        }),
      }
    : null;

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
                  <Dropdown
                    width="200px"
                    menuWidth="240px"
                    selected={entry.current_name || '—'}
                    displayText={entry.current_name || '—'}
                    options={entry.options}
                    onSelected={(value) =>
                      value !== entry.current_name &&
                      act('set_descriptor_direct', {
                        choice_type: entry.choice_type,
                        name: value,
                      })
                    }
                  />
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
                // Ears is rendered inside BodySection's right column instead
                // of the customizer grid; mark it consumed so the iteration
                // skips it.
                for (const c of customizers.entries) {
                  if (c.name === 'Ears') consumed.add(c.customizer_type);
                }
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
                // Find the row containing the Hair customizer so we can
                // slot the Body section right below it. Falls back to
                // not injecting if the species has no Hair customizer.
                const hairRowIdx = rows.findIndex((row) =>
                  row.some((c) => c.name === 'Hair'),
                );
                return rows.map((row, idx) => (
                  <Fragment key={idx}>
                  <Stack.Item>
                    <Stack>
                      {row.map((c) => (
                        <Stack.Item key={c.customizer_type} grow>
                          <CustomizerCard customizer={c} act={act} />
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                  {idx === hairRowIdx && (
                    <Stack.Item>
                      <BodySection />
                    </Stack.Item>
                  )}
                  </Fragment>
                ));
              })()}
            </Stack>
          )}
        </Section>
      </Stack.Item>

      {/* Markings section moved from the Identity tab — at the bottom of
          Features per user request. */}
      <Stack.Item>
        <MarkingsSection />
      </Stack.Item>
    </Stack>
  );
};
