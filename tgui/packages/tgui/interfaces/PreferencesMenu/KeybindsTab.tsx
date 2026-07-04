import { useEffect, useState } from 'react';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';

// STATIC half — name + full_name + default_keys per keybind. Default_keys
// depend on hotkeys_mode, so refresh_static_data fires on toggle_hotkeys
// to ship the matching defaults.
type KeybindEntryStatic = {
  name: string;
  full_name: string;
  default_keys: string[];
};

// DYNAMIC half — only the user's currently-bound keys per keybind name.
type KeybindEntry = KeybindEntryStatic & {
  bindings: string[];
};

type KeybindCategory = {
  name: string;
  keybinds: KeybindEntryStatic[];
};

type KeybindsDynamicData = {
  hotkeys_mode: 0 | 1;
  // keybind name → list of currently-bound keys.
  user_bindings: Record<string, string[]>;
};

type KeybindsStaticData = {
  max_keys_per_keybind: number;
  categories: KeybindCategory[];
};

type Data = {
  keybinds: KeybindsDynamicData;
  keybinds_static: KeybindsStaticData;
};

// (kbName, oldKey) — oldKey may be empty string when binding a new secondary slot.
type CaptureTarget = { kbName: string; fullName: string; oldKey: string };

type KeybindsTabProps = { data: Data; act: ActFunctionType };

export const KeybindsTab = ({ data, act }: KeybindsTabProps) => {
  // Merge static catalog (max_keys_per_keybind, categories) with dynamic
  // (hotkeys_mode, user_bindings). Per-keybind shape used by KeybindRow gets
  // assembled inline at render time by joining the catalog's default_keys
  // with the user's currently-bound keys from user_bindings.
  const kbDynamic = data.keybinds;
  const kbStatic = data.keybinds_static;
  const userBindings = kbDynamic?.user_bindings || {};
  const kb = kbStatic ? { ...kbStatic, ...kbDynamic } : null;
  const [capture, setCapture] = useState<CaptureTarget | null>(null);

  // While the capture modal is open, swallow keydown events and send the result
  // to the backend. Escape cancels.
  useEffect(() => {
    if (!capture) return;
    const handler = (e: KeyboardEvent) => {
      e.preventDefault();
      e.stopPropagation();
      if (e.key === 'Escape') {
        setCapture(null);
        return;
      }
      act('set_keybind', {
        keybinding: capture.kbName,
        old_key: capture.oldKey,
        key: e.key,
        alt: e.altKey ? 1 : 0,
        ctrl: e.ctrlKey ? 1 : 0,
        shift: e.shiftKey ? 1 : 0,
        numpad: e.location === 3 ? 1 : 0,
        key_code: e.keyCode,
        clear_key: 0,
      });
      setCapture(null);
    };
    window.addEventListener('keydown', handler, true);
    return () => window.removeEventListener('keydown', handler, true);
  }, [capture]);

  if (!kb) {
    return <Box color="label">Loading keybinds…</Box>;
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Section
          title="Keybinds"
          buttons={
            <Button
              icon="rotate-left"
              onClick={() => act('reset_keybinds')}
              tooltip="Pick Hotkeys or Classic layout"
            >
              Reset to Default
            </Button>
          }
        >
          <Box color="label" mb={1} italic>
            Click any binding to rebind it. Press <b>Esc</b> to cancel,
            <b> Delete</b> or <b>Backspace</b> to clear (you&apos;ll be asked).
          </Box>

          {kb.categories.map((category) => (
            <Section key={category.name} title={category.name}>
              <LabeledList>
                {category.keybinds.map((staticEntry) => {
                  // Build the merged entry inline per row — no per-poll
                  // allocation of a parallel array, and dynamic bindings join
                  // the static catalog by name lookup.
                  const entry: KeybindEntry = {
                    ...staticEntry,
                    bindings: userBindings[staticEntry.name] || [],
                  };
                  return (
                    <LabeledList.Item key={entry.name} label={entry.full_name}>
                      <KeybindRow
                        entry={entry}
                        maxKeys={kb.max_keys_per_keybind}
                        onRebind={(oldKey) =>
                          setCapture({
                            kbName: entry.name,
                            fullName: entry.full_name,
                            oldKey,
                          })
                        }
                        onClear={(oldKey) =>
                          act('set_keybind', {
                            keybinding: entry.name,
                            old_key: oldKey,
                            clear_key: 1,
                          })
                        }
                      />
                    </LabeledList.Item>
                  );
                })}
              </LabeledList>
            </Section>
          ))}
        </Section>
      </Stack.Item>

      {!!capture && (
        <CaptureOverlay
          target={capture}
          onCancel={() => setCapture(null)}
        />
      )}
    </Stack>
  );
};

const KeybindRow = ({
  entry,
  maxKeys,
  onRebind,
  onClear,
}: {
  entry: KeybindEntry;
  maxKeys: number;
  onRebind: (oldKey: string) => void;
  onClear: (oldKey: string) => void;
}) => {
  if (entry.bindings.length === 0) {
    return (
      <>
        <Button onClick={() => onRebind('Unbound')}>Unbound</Button>
        {entry.default_keys.length > 0 && (
          <Box inline ml={1} color="label" italic>
            Default: {entry.default_keys.join(', ')}
          </Box>
        )}
      </>
    );
  }

  return (
    <>
      {entry.bindings.map((bound) => (
        <Button
          key={bound}
          ml={0}
          mr={1}
          tooltip="Click to rebind · Right-click to clear"
          onClick={() => onRebind(bound)}
          onContextMenu={(e) => {
            e.preventDefault();
            onClear(bound);
          }}
        >
          {bound}
        </Button>
      ))}
      {entry.bindings.length < maxKeys && (
        <Button onClick={() => onRebind('')}>+ Add</Button>
      )}
      {entry.default_keys.length > 0 && (
        <Box inline ml={1} color="label" italic>
          Default: {entry.default_keys.join(', ')}
        </Box>
      )}
    </>
  );
};

const CaptureOverlay = ({
  target,
  onCancel,
}: {
  target: CaptureTarget;
  onCancel: () => void;
}) => (
  <Box
    style={{
      position: 'fixed',
      top: 0,
      left: 0,
      width: '100%',
      height: '100%',
      backgroundColor: 'rgba(0, 0, 0, 0.6)',
      zIndex: 1000,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    }}
    onClick={onCancel}
  >
    <Section title="Press a key…" style={{ minWidth: '320px' }}>
      <Box mb={1}>
        Binding: <b>{target.fullName}</b>
      </Box>
      {target.oldKey && target.oldKey !== 'Unbound' && (
        <Box mb={1} color="label">
          Replacing: <b>{target.oldKey}</b>
        </Box>
      )}
      <Box color="label" italic>
        Press any key (modifiers supported). <b>Esc</b> to cancel.
      </Box>
      <Box mt={1}>
        <Button onClick={onCancel}>Cancel</Button>
      </Box>
    </Section>
  </Box>
);
