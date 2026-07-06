import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';

type RoleEntry = {
  name: string;
  state: 'banned' | 'days' | 'ok';
  days_remaining?: number;
  enabled?: 0 | 1;
};

type GamePrefsData = {
  stat_simple: 0 | 1;
  tgui_lock: 0 | 1;
  hotkeys: 0 | 1;
  clientfps: number;
  ambientocclusion: 0 | 1;
  schizo_voice: 0 | 1;
  roles: RoleEntry[];
  banned_from_antag: 0 | 1;
};

type Data = {
  game_prefs: GamePrefsData;
};

type GamePrefsTabProps = { data: Data; act: ActFunctionType };

const capitalize = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

export const GamePrefsTab = ({ data, act }: GamePrefsTabProps) => {
  const gp = data.game_prefs;
  if (!gp) {
    return <Box color="label">Loading…</Box>;
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="General Settings">
          <LabeledList>
            <LabeledList.Item label="Statpane Style">
              <Button onClick={() => act('toggle_stat_simple')}>
                {gp.stat_simple ? 'Classic' : 'Medieval'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="TGUI Monitors">
              <Button onClick={() => act('toggle_tgui_lock')}>
                {gp.tgui_lock ? 'Primary' : 'All'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Hotkey mode">
              <Button onClick={() => act('toggle_hotkeys')}>
                {gp.hotkeys ? 'Hotkeys' : 'Classic'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Client FPS">
              <Button onClick={() => act('set_clientfps')}>{gp.clientfps}</Button>
            </LabeledList.Item>
            <LabeledList.Item label="Ambient Occlusion">
              <Button
                color={gp.ambientocclusion ? 'good' : 'default'}
                onClick={() => act('toggle_ambientocclusion')}
              >
                {gp.ambientocclusion ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Be a Voice">
              <Button
                color={gp.schizo_voice ? 'good' : 'default'}
                onClick={() => act('toggle_schizo_voice')}
              >
                {gp.schizo_voice ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Special Role Settings">
          {!!gp.banned_from_antag && (
            <Box color="bad" bold mb={1}>
              You are banned from antagonist roles.
            </Box>
          )}
          <LabeledList>
            {gp.roles.map((role) => (
              <LabeledList.Item key={role.name} label={capitalize(role.name)}>
                {role.state === 'banned' && (
                  <Box inline color="bad">
                    BANNED
                  </Box>
                )}
                {role.state === 'days' && (
                  <Box inline color="bad">
                    [IN {role.days_remaining} DAYS]
                  </Box>
                )}
                {role.state === 'ok' && (
                  <Button
                    color={role.enabled ? 'good' : 'default'}
                    onClick={() =>
                      act('toggle_special_role', { role: role.name })
                    }
                  >
                    {role.enabled ? 'Enabled' : 'Disabled'}
                  </Button>
                )}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
