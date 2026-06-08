import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

// Searchable drop-in: identical to the stock Dropdown for short lists, but grows
// a filter box once a list passes 7 options. Replaces the old per-tab RawDropdown
// + inline-Box width wrapper (SearchableDropdown handles the width constraint).
import { SearchableDropdown as Dropdown } from '../common/SearchableDropdown';

export type CustomizerPicker = {
  type:
    | 'rotate'
    | 'chooser'
    | 'reset_colors'
    | 'color'
    | 'list_value'
    | 'toggle';
  label?: string;
  text?: string;
  color?: string;
  task?: string;
  extra?: Record<string, string>;
  options?: string[];
};

export type CustomizerEntry = {
  customizer_type: string;
  name: string;
  allows_disabling: 0 | 1;
  disabled: 0 | 1;
  choice_name: string;
  has_multiple_choices: 0 | 1;
  choice_options: string[];
  pref_data: CustomizerPicker[];
};

// Renders the structured per-choice picker list emitted by each
// /datum/customizer_choice/get_pref_data(). Every action routes through the
// generic 'customizer_action' ui_act, which calls back into the classic
// handle_customizer_topic so we reuse all existing validation/behavior.
export const CustomizerPickerList = ({
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
                  {p.options && p.options.length > 0 ? (
                    <Box inline ml={1}>
                      <Dropdown
                        width="200px"
                        menuWidth="240px"
                        selected={p.text || ''}
                        displayText={p.text || ''}
                        options={p.options}
                        onSelected={(value) =>
                          value !== p.text &&
                          send(p.task, { picked_name: value })
                        }
                      />
                    </Box>
                  ) : (
                    <Button
                      ml={1}
                      width="200px"
                      textAlign="center"
                      onClick={() => send(p.task)}
                    >
                      {p.text}
                    </Button>
                  )}
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
                  {/* Native span carries the HTML title attribute (tgui's
                      Box doesn't whitelist it); Box keeps the swatch
                      styling. Same pattern in LoadoutTab / MarkingsSection. */}
                  <span title={p.color || '(unset)'}>
                    <Box
                      inline
                      width="32px"
                      height="14px"
                      backgroundColor={p.color || '#ffffff'}
                      style={{
                        cursor: 'pointer',
                        border: '1px solid #000',
                        verticalAlign: 'middle',
                      }}
                      onClick={() => send(p.task, p.extra || {})}
                    />
                  </span>
                </LabeledList.Item>
              );
            case 'list_value':
              return (
                <LabeledList.Item key={i} label={p.label}>
                  {p.options && p.options.length > 0 ? (
                    <Dropdown
                      width="200px"
                      menuWidth="240px"
                      selected={p.text || ''}
                      displayText={p.text || ''}
                      options={p.options}
                      onSelected={(value) =>
                        value !== p.text &&
                        send(p.task, { picked_name: value })
                      }
                    />
                  ) : (
                    <Button
                      width="200px"
                      textAlign="center"
                      onClick={() => send(p.task, p.extra || {})}
                    >
                      {p.text}
                    </Button>
                  )}
                </LabeledList.Item>
              );
            case 'toggle':
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

// Renders a single customizer entry as a labeled Section: title bar, optional
// On/Off toggle and variant dropdown row, then the picker list. Shared by
// FeaturesTab's customizer grid and BodySection's inline Ears render.
export const CustomizerCard = ({
  customizer,
  act,
}: {
  customizer: CustomizerEntry;
  act: (action: string, payload?: object) => void;
}) => {
  const c = customizer;
  return (
    <Section title={c.name}>
      {/* Reserve a fixed-height top row so the picker list below lines up
          across cards regardless of whether this customizer has an On/Off
          toggle or a variant dropdown. */}
      <Stack
        align="center"
        mb={1}
        style={{ minHeight: '24px' }}
      >
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
        {/* Show the choice selector whenever there are multiple choices. Do NOT also gate on
            choice_name !== name: the testicles customizer is named "Testicles" and its default
            choice is also "Testicles", so that extra check hid the dropdown and made the second
            choice ("Internal testicles") unreachable. */}
        {!c.disabled &&
          !!c.has_multiple_choices && (
            <Stack.Item>
              <Dropdown
                width="180px"
                menuWidth="220px"
                selected={c.choice_name}
                displayText={c.choice_name}
                options={c.choice_options}
                onSelected={(value) =>
                  value !== c.choice_name &&
                  act('customizer_change_choice_direct', {
                    customizer_type: c.customizer_type,
                    name: value,
                  })
                }
              />
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
  );
};
