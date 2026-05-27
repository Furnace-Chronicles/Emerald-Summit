import { useEffect, useState } from 'react';
import { Box, Button, ByondUi, Dropdown, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { IdentityTab } from './PreferencesMenu/IdentityTab';
import { FeaturesTab } from './PreferencesMenu/FeaturesTab';
import { LoadoutTab } from './PreferencesMenu/LoadoutTab';
import { JobsTab } from './PreferencesMenu/JobsTab';
import { FlavorTab } from './PreferencesMenu/FlavorTab';
import { GamePrefsTab } from './PreferencesMenu/GamePrefsTab';
import { OocPrefsTab } from './PreferencesMenu/OocPrefsTab';
import { KeybindsTab } from './PreferencesMenu/KeybindsTab';
import { FamiliarTab } from './PreferencesMenu/FamiliarTab';
import { GnollTab } from './PreferencesMenu/GnollTab';

type HeaderData = {
  real_name: string;
  triumphs: number;
  triumphs_roman: string;
  pq_text: string;
  pq_color: string | null;
  agevetted: 0 | 1;
  triumph_buys_enabled: 0 | 1;
  is_new_player: 0 | 1;
  is_pregame: 0 | 1;
  is_round_in_progress: 0 | 1;
  player_ready: 0 | 1;
  is_active_migrant: 0 | 1;
  job_change_locked: 0 | 1;
  is_guest: 0 | 1;
  current_slot: number;
  max_save_slots: number;
};

type SlotEntry = { id: number; name: string };

type LobbyJobEntry = { job: string; players: string[] };

type LobbyData = {
  is_pregame: 0 | 1;
  round_in_progress: 0 | 1;
  timeleft_ds: number;
  total_ready: number;
  ready_by_job: LobbyJobEntry[];
};

type Data = {
  active_tab: TabId;
  header?: HeaderData;
  identity?: { real_name: string };
  slots?: SlotEntry[];
  lobby?: LobbyData;
};

type TabId =
  | 'identity'
  | 'features'
  | 'loadout'
  | 'jobs'
  | 'flavor'
  | 'gamepref'
  | 'oocpref'
  | 'keybinds'
  | 'familiar'
  | 'gnoll';

// Keybinds is intentionally absent — it's reached via the header button and
// rendered as a full-screen view with its own Back control.
const TAB_LABELS: Partial<Record<TabId, string>> = {
  identity: 'Identity',
  features: 'Features',
  loadout: 'Loadout',
  jobs: 'Class Selection',
  flavor: 'Flavor Text',
  gamepref: 'Game Prefs',
  familiar: 'Familiar',
  gnoll: 'Gnoll',
};

const renderTab = (tab: TabId) => {
  switch (tab) {
    case 'identity':
      return <IdentityTab />;
    case 'features':
      return <FeaturesTab />;
    case 'loadout':
      return <LoadoutTab />;
    case 'jobs':
      return <JobsTab />;
    case 'flavor':
      return <FlavorTab />;
    case 'gamepref':
      // Combined view — Game Prefs sections stacked above OOC Prefs sections.
      return (
        <>
          <GamePrefsTab />
          <OocPrefsTab />
        </>
      );
    case 'oocpref':
      // Legacy tab id kept as a no-op so any stored active_tab references
      // resolve cleanly; oocpref content now lives under the gamepref tab.
      return <OocPrefsTab />;
    case 'keybinds':
      return <KeybindsTab />;
    case 'familiar':
      return <FamiliarTab />;
    case 'gnoll':
      return <GnollTab />;
    default:
      return (
        <Box color="label">
          Phase 0 skeleton — controls for this tab will land in a later phase.
          The classic Character Sheet is still available for everything not yet
          ported.
        </Box>
      );
  }
};

const FooterBar = ({
  header,
  slots,
  act,
}: {
  header: HeaderData;
  slots: SlotEntry[];
  act: (action: string, payload?: object) => void;
}) => {
  // Lobby + pregame: Ready / Unready toggle. Else (round in progress): JoinLate +
  // Migration / Actors / Observe. Save / Load always shown when not a guest key.
  return (
    <Section>
      <Stack>
        <Stack.Item>
          {!!header.is_new_player && !!header.is_pregame && (
            <Button
              icon={header.player_ready ? 'check-double' : 'check'}
              color={header.player_ready ? 'good' : 'default'}
              disabled={!!header.job_change_locked && !!header.player_ready}
              tooltip={
                header.player_ready
                  ? 'You are READY. Click to unready.'
                  : 'Click to ready up for round start.'
              }
              onClick={() => act('toggle_ready')}
            >
              {header.player_ready ? 'READY' : 'UNREADY'}
            </Button>
          )}
          {!!header.is_new_player && !header.is_pregame && (
            <>
              <Button
                icon="right-to-bracket"
                color="good"
                disabled={!!header.is_active_migrant}
                tooltip={
                  header.is_active_migrant
                    ? 'A migration application blocks late-join.'
                    : 'Spawn into the round.'
                }
                onClick={() => act('late_join')}
              >
                Join Late
              </Button>
              <Button
                ml={1}
                icon="people-arrows"
                onClick={() => act('open_migration')}
              >
                Migration
              </Button>
              <Button
                ml={1}
                icon="users"
                onClick={() => act('open_manifest')}
              >
                Actors
              </Button>
              <Button
                ml={1}
                icon="ghost"
                onClick={() => act('become_observer')}
              >
                Observe
              </Button>
            </>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="floppy-disk"
            color="good"
            tooltip="Save preferences and character to disk"
            onClick={() => act('save_character')}
          >
            Save
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            width="200px"
            menuWidth="240px"
            over
            selected={String(header.current_slot)}
            displayText={
              slots.find((s) => s.id === header.current_slot)?.name ||
              `Slot ${header.current_slot}`
            }
            options={slots.map((s) => ({
              displayText: s.name,
              value: String(s.id),
            }))}
            onSelected={(value) => act('change_slot', { slot: value })}
          />
        </Stack.Item>
        <Stack.Item grow />
        <Stack.Item>
          <Button
            icon="rotate-left"
            tooltip="Reload from disk — discards unsaved changes"
            onClick={() => act('load_character')}
          >
            Undo
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PreviewPane = () => {
  const { act } = useBackend();
  // Trigger an initial preview render when the pane mounts so the BYOND
  // character_preview_map populates with the current character dummy.
  useEffect(() => {
    act('refresh_preview');
  }, []);

  return (
    <Section
      fill
      title="Preview"
      buttons={
        <Button
          icon="rotate"
          tooltip="Re-render the dummy"
          onClick={() => act('refresh_preview')}
        >
          Refresh
        </Button>
      }
    >
      <ByondUi
        params={{
          id: 'tgui_preview_map',
          type: 'map',
          'background-color': '#000000',
          'icon-size': 64,
          'zoom-mode': 'distort',
        }}
        style={{
          width: '100%',
          height: '256px',
        }}
      />
      <Box mt={1} color="label" italic textAlign="center">
        Click <b>Refresh</b> after changing body fields if the dummy doesn&apos;t
        update on its own.
      </Box>
    </Section>
  );
};

const formatCountdown = (ds: number) => {
  if (ds === -10) return 'DELAYED';
  if (ds <= 0) return 'SOON';
  const totalSec = Math.ceil(ds / 10);
  const m = Math.floor(totalSec / 60);
  const s = totalSec % 60;
  return m > 0 ? `${m}:${s.toString().padStart(2, '0')}` : `${s}s`;
};

const LobbySection = ({ lobby }: { lobby: LobbyData }) => {
  // Server pushes a fresh timeleft_ds on every poll (~2s). Between polls we tick
  // locally so the countdown looks live. Each new poll snaps to the authoritative
  // value, correcting any drift.
  const [displayDs, setDisplayDs] = useState(lobby.timeleft_ds);
  useEffect(() => {
    setDisplayDs(lobby.timeleft_ds);
    if (!lobby.is_pregame || lobby.timeleft_ds <= 0) return;
    const interval = setInterval(() => {
      setDisplayDs((d) => Math.max(0, d - 10));
    }, 1000);
    return () => clearInterval(interval);
  }, [lobby.timeleft_ds, !!lobby.is_pregame]);

  let statusLine: string;
  let statusColor: string | undefined;
  if (lobby.round_in_progress) {
    statusLine = 'Round in progress';
    statusColor = '#888';
  } else if (lobby.is_pregame) {
    statusLine = `Round starts in: ${formatCountdown(displayDs)}`;
    statusColor = displayDs <= 100 ? '#ff6347' : undefined;
  } else {
    statusLine = 'Waiting…';
    statusColor = '#888';
  }

  return (
    <Section title="Lobby" fill scrollable>
      <Box bold fontSize="1.1em" style={statusColor ? { color: statusColor } : undefined}>
        {statusLine}
      </Box>
      {!lobby.round_in_progress && (
        <>
          <Box mt={1} color="label">
            Players ready: <b>{lobby.total_ready}</b>
          </Box>
          {lobby.ready_by_job.length > 0 && (
            <Box mt={1}>
              {lobby.ready_by_job.map((entry) => (
                <Box key={entry.job} mb={0.5}>
                  <b>{entry.job}</b>{' '}
                  <Box inline color="label">
                    ({entry.players.length})
                  </Box>
                  <Box color="label" fontSize="0.9em">
                    {entry.players.join(', ')}
                  </Box>
                </Box>
              ))}
            </Box>
          )}
        </>
      )}
    </Section>
  );
};

export const PreferencesMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const header = data.header;
  const realName = header?.real_name || data.identity?.real_name;
  const [tab, setTab] = useState<TabId>(data.active_tab || 'identity');

  const handleTabChange = (nextTab: TabId) => {
    setTab(nextTab);
    act('set_tab', { tab: nextTab });
  };

  // Hide the title-bar close (X) button during pregame and any pre-round state.
  // Players can only dismiss the window once the round is actually in progress —
  // a latejoiner can close it then if they want, but otherwise this is the only
  // lobby UI so closing it would strand them with no way back in.
  const canClose = !!header?.is_round_in_progress;

  return (
    <Window width={1400} height={820} canClose={canClose}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="280px">
            <Stack vertical fill>
              <Stack.Item>
                <PreviewPane />
              </Stack.Item>
              {data.lobby && (
                <Stack.Item grow>
                  <LobbySection lobby={data.lobby} />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical fill>
              <Stack.Item>
                <Section title="Emerald Summit">
                  <Stack>
                    <Stack.Item grow>
                      <b>Name:</b> {realName || '(unset)'}
                    </Stack.Item>
                    {!!header && (
                      <>
                        <Stack.Item>
                          <Button
                            tooltip="Open the PQ details menu"
                            onClick={() => act('open_pq_menu')}
                          >
                            <b>PQ:</b>{' '}
                            <Box
                              inline
                              style={
                                header.pq_color
                                  ? { color: header.pq_color }
                                  : undefined
                              }
                            >
                              {header.pq_text}
                            </Box>
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            tooltip="Open Triumphs list"
                            onClick={() => act('open_triumphs_list')}
                          >
                            <b>Triumphs:</b> {header.triumphs_roman}
                          </Button>
                        </Stack.Item>
                        {!!header.triumph_buys_enabled && (
                          <Stack.Item>
                            <Button
                              icon="cart-shopping"
                              tooltip="Buy with Triumphs"
                              onClick={() => act('open_triumph_buy_menu')}
                            >
                              Triumph Buy
                            </Button>
                          </Stack.Item>
                        )}
                        <Stack.Item>
                          <Button
                            color={header.agevetted ? 'good' : 'bad'}
                            tooltip={
                              header.agevetted
                                ? 'You are Age Verified.'
                                : 'Not Age Verified. Open a Discord ticket to verify.'
                            }
                            onClick={() => act('agevet_info')}
                          >
                            {header.agevetted ? 'Age Vetted' : 'Not Vetted'}
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="keyboard"
                            tooltip="Configure keybinds"
                            onClick={() => handleTabChange('keybinds')}
                          >
                            Keybinds
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="rotate-left"
                            color="bad"
                            tooltip="Switch back to the classic HTML preferences window. Useful if the TGUI window is broken or you prefer the old layout."
                            onClick={() => act('toggle_tgui_pref')}
                          >
                            Classic UI
                          </Button>
                        </Stack.Item>
                      </>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>
              {tab === 'keybinds' ? (
                <Stack.Item>
                  <Button
                    icon="arrow-left"
                    onClick={() => handleTabChange('identity')}
                  >
                    Back
                  </Button>
                </Stack.Item>
              ) : (
                <Stack.Item>
                  <Tabs>
                    {(Object.keys(TAB_LABELS) as TabId[]).map((id) => (
                      <Tabs.Tab
                        key={id}
                        selected={tab === id}
                        onClick={() => handleTabChange(id)}
                      >
                        {TAB_LABELS[id]}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Stack.Item>
              )}
              <Stack.Item grow>
                <Section fill scrollable>
                  {renderTab(tab)}
                </Section>
              </Stack.Item>
              {!!header && (
                <Stack.Item>
                  <FooterBar
                    header={header}
                    slots={data.slots || []}
                    act={act}
                  />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
