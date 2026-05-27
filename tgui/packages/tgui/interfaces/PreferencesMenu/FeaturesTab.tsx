import { Fragment } from 'react';
import {
  Box,
  Button,
  Dropdown as RawDropdown,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { BodySection } from './BodySection';
import { CustomizerCard, CustomizerEntry } from './CustomizerCard';
import { MarkingsSection } from './MarkingsSection';

// Wraps RawDropdown in an inline-Box constraint so the width prop actually
// limits the dropdown — without this, the dropdown stretches to fill its
// LabeledList.Item content cell instead of honoring its declared width.
const Dropdown = (props: any) => (
  <Box inline style={{ width: props.width }}>
    <RawDropdown {...props} />
  </Box>
);

type DescriptorEntry = {
  choice_type: string;
  choice_name: string;
  current_name: string;
  options: string[];
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

type CustomizersData = {
  entries: CustomizerEntry[];
};

type Data = {
  descriptors: DescriptorsData;
  customizers: CustomizersData;
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
