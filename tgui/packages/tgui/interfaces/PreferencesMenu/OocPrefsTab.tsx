import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type OocPrefsData = {
  windowflashing: 0 | 1;
  hear_midis: 0 | 1;
  lobby_music: 0 | 1;
  pull_requests: 0 | 1;
  unlock_content: 0 | 1;
  byond_publicity: 0 | 1;
  is_admin: 0 | 1;
};

type Data = {
  ooc_prefs: OocPrefsData;
};

export const OocPrefsTab = (props) => {
  const { act, data } = useBackend<Data>();
  const op = data.ooc_prefs;
  if (!op) {
    return <Box color="label">Loading…</Box>;
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="OOC Settings">
          <LabeledList>
            <LabeledList.Item label="Window Flashing">
              <Button onClick={() => act('toggle_winflash')}>
                {op.windowflashing ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Admin MIDIs">
              <Button onClick={() => act('toggle_hear_midis')}>
                {op.hear_midis ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Lobby Music">
              <Button onClick={() => act('toggle_lobby_music')}>
                {op.lobby_music ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="See Pull Requests">
              <Button onClick={() => act('toggle_pull_requests')}>
                {op.pull_requests ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            {!!op.unlock_content && (
              <LabeledList.Item label="BYOND Publicity">
                <Button onClick={() => act('toggle_byond_publicity')}>
                  {op.byond_publicity ? 'Public' : 'Hidden'}
                </Button>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>

      {!!op.is_admin && (
        <Stack.Item>
          <Section title="Admin Settings">
            <Box color="label" italic>
              Admin-only toggles (Adminhelp Sounds, Prayer Sounds, Hide Dead
              Chat, etc.) still live in the classic OOC Preferences tab. Open
              the classic Game Preferences window to access them.
            </Box>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};
