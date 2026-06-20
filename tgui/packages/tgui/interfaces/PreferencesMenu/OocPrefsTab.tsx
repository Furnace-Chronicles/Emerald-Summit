import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type AdminOocData = {
  hear_adminhelps: 0 | 1;
  hear_prayers: 0 | 1;
  announce_login: 0 | 1;
  combohud_lighting: 0 | 1;
  dead_chat_shown: 0 | 1;
  radio_chatter_shown: 0 | 1;
  prayers_shown: 0 | 1;
  asaycolor: string;
  allow_asaycolor: 0 | 1;
  deadmin_always: 0 | 1;
  deadmin_antag: 0 | 1;
  deadmin_head: 0 | 1;
  auto_deadmin_players: 0 | 1;
  auto_deadmin_antagonists: 0 | 1;
  auto_deadmin_heads: 0 | 1;
};

type OocPrefsData = {
  windowflashing: 0 | 1;
  hear_midis: 0 | 1;
  hear_instruments: 0 | 1;
  lobby_music: 0 | 1;
  pull_requests: 0 | 1;
  hear_ooc: 0 | 1;
  unlock_content: 0 | 1;
  byond_publicity: 0 | 1;
  is_admin: 0 | 1;
  admin?: AdminOocData;
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
              <Button
                color={op.windowflashing ? 'good' : 'default'}
                onClick={() => act('toggle_winflash')}
              >
                {op.windowflashing ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Admin MIDIs">
              <Button
                color={op.hear_midis ? 'good' : 'default'}
                onClick={() => act('toggle_hear_midis')}
              >
                {op.hear_midis ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Instrument Songs">
              <Button
                color={op.hear_instruments ? 'good' : 'default'}
                onClick={() => act('toggle_hear_instruments')}
              >
                {op.hear_instruments ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Lobby Music">
              <Button
                color={op.lobby_music ? 'good' : 'default'}
                onClick={() => act('toggle_lobby_music')}
              >
                {op.lobby_music ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="See Pull Requests">
              <Button
                color={op.pull_requests ? 'good' : 'default'}
                onClick={() => act('toggle_pull_requests')}
              >
                {op.pull_requests ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="OOC Chat">
              <Button
                color={op.hear_ooc ? 'good' : 'default'}
                onClick={() => act('toggle_hear_ooc')}
              >
                {op.hear_ooc ? 'Enabled' : 'Disabled'}
              </Button>
            </LabeledList.Item>
            {!!op.unlock_content && (
              <LabeledList.Item label="BYOND Publicity">
                <Button onClick={() => act('toggle_byond_publicity')}>
                  {op.byond_publicity ? 'Public' : 'Hidden'}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Preferences UI">
              <Button
                icon="rotate-left"
                color="bad"
                tooltip="Disable the TGUI character setup window and fall back to the classic HTML preferences. Use this if the TGUI window is broken or unresponsive."
                onClick={() => act('toggle_tgui_pref')}
              >
                Use Classic UI
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {!!op.is_admin && !!op.admin && (
        <Stack.Item>
          <Section title="Admin Settings">
            <LabeledList>
              <LabeledList.Item label="Adminhelp Sounds">
                <Button
                  color={op.admin.hear_adminhelps ? 'good' : 'default'}
                  onClick={() => act('admin_toggle_adminhelps')}
                >
                  {op.admin.hear_adminhelps ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Prayer Sounds">
                <Button
                  color={op.admin.hear_prayers ? 'good' : 'default'}
                  onClick={() => act('admin_toggle_hear_prayers')}
                >
                  {op.admin.hear_prayers ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Announce Login">
                <Button
                  color={op.admin.announce_login ? 'good' : 'default'}
                  onClick={() => act('admin_toggle_announce_login')}
                >
                  {op.admin.announce_login ? 'Enabled' : 'Disabled'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Combo HUD Lighting">
                <Button onClick={() => act('admin_toggle_combohud')}>
                  {op.admin.combohud_lighting ? 'Full-bright' : 'No Change'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Dead Chat">
                <Button
                  color={op.admin.dead_chat_shown ? 'good' : 'default'}
                  onClick={() => act('admin_toggle_dead_chat')}
                >
                  {op.admin.dead_chat_shown ? 'Shown' : 'Hidden'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Radio Messages">
                <Button
                  color={op.admin.radio_chatter_shown ? 'good' : 'default'}
                  onClick={() => act('admin_toggle_radio_chatter')}
                >
                  {op.admin.radio_chatter_shown ? 'Shown' : 'Hidden'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Prayers">
                <Button
                  color={op.admin.prayers_shown ? 'good' : 'default'}
                  onClick={() => act('admin_toggle_prayers')}
                >
                  {op.admin.prayers_shown ? 'Shown' : 'Hidden'}
                </Button>
              </LabeledList.Item>
              {!!op.admin.allow_asaycolor && (
                <LabeledList.Item label="ASAY Color">
                  <Box
                    inline
                    width="32px"
                    height="14px"
                    backgroundColor={op.admin.asaycolor}
                    style={{
                      cursor: 'pointer',
                      border: '1px solid #000',
                      verticalAlign: 'middle',
                    }}
                    onClick={() => act('admin_set_asaycolor')}
                  />
                  <Button
                    ml={1}
                    onClick={() => act('admin_set_asaycolor')}
                  >
                    Change
                  </Button>
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        </Stack.Item>
      )}

      {!!op.is_admin && !!op.admin && (
        <Stack.Item>
          <Section title="Deadmin While Playing">
            <LabeledList>
              <LabeledList.Item label="Always Deadmin">
                {op.admin.auto_deadmin_players ? (
                  <Box color="bad" bold>
                    FORCED
                  </Box>
                ) : (
                  <Button onClick={() => act('admin_toggle_deadmin_always')}>
                    {op.admin.deadmin_always ? 'Enabled' : 'Disabled'}
                  </Button>
                )}
              </LabeledList.Item>
              {!op.admin.auto_deadmin_players && !op.admin.deadmin_always && (
                <>
                  <LabeledList.Item label="As Antag">
                    {op.admin.auto_deadmin_antagonists ? (
                      <Box color="bad" bold>
                        FORCED
                      </Box>
                    ) : (
                      <Button
                        onClick={() => act('admin_toggle_deadmin_antag')}
                      >
                        {op.admin.deadmin_antag ? 'Deadmin' : 'Keep Admin'}
                      </Button>
                    )}
                  </LabeledList.Item>
                  <LabeledList.Item label="As Command">
                    {op.admin.auto_deadmin_heads ? (
                      <Box color="bad" bold>
                        FORCED
                      </Box>
                    ) : (
                      <Button
                        onClick={() => act('admin_toggle_deadmin_head')}
                      >
                        {op.admin.deadmin_head ? 'Deadmin' : 'Keep Admin'}
                      </Button>
                    )}
                  </LabeledList.Item>
                </>
              )}
            </LabeledList>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};
