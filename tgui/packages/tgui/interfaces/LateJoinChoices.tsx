import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// STATIC half — title, display_name (pronoun-dependent), command_bold (NOBLES
// membership), has_subclass_info. Round-stable; shipped once via ui_static_data.
type JobEntryStatic = {
  title: string;
  display_name: string;
  command_bold: 0 | 1;
  has_subclass_info: 0 | 1;
};

// DYNAMIC half — slot counts + availability. Pushed by notify_late_join_slots_changed()
// when another player takes a slot.
type JobAvailability = {
  current: number;
  total: number;
  prioritized: 0 | 1;
  available: 0 | 1;
  is_cooldown: 0 | 1;
  unavailable_reason?: string | null;
};

// Merged at render time before passing into JobRow.
type JobEntry = JobEntryStatic & JobAvailability;

type CategoryStatic = {
  name: string;
  color: string;
  jobs: JobEntryStatic[];
};

type CategoryMerged = {
  name: string;
  color: string;
  jobs: JobEntry[];
};

type Data = {
  // Dynamic — pushed on slot change and at window open.
  round_duration: string;
  availability: Record<string, JobAvailability>;
  // Static — shipped once at window open.
  siege_skeleton: 0 | 1;
  siege_goblin: 0 | 1;
  categories: CategoryStatic[];
};

const SiegeBanner = ({
  label,
  action,
  act,
}: {
  label: string;
  action: string;
  act: (a: string, p?: object) => void;
}) => (
  <Section>
    <Button
      fluid
      color="bad"
      textAlign="center"
      fontSize="1.4em"
      onClick={() => act(action)}
    >
      {label}
    </Button>
  </Section>
);

const JobRow = ({
  job,
  act,
}: {
  job: JobEntry;
  act: (a: string, p?: object) => void;
}) => {
  // Priority jobs get the green highlight just like classic ('priority' CSS).
  // Command-bold jobs (nobles) render their name in bold.
  const slotText = job.prioritized
    ? ` (${job.current})`
    : ` (${job.current}/${job.total})`;
  const nameText = job.command_bold ? (
    <b>
      {job.display_name}
      {slotText}
    </b>
  ) : (
    <>
      {job.display_name}
      {slotText}
    </>
  );
  const unavailable = !job.available;
  // Cooldown is the exception: keep the row clickable so the player can
  // print the live "X seconds remaining" chat message via AttemptLateSpawn.
  // Visually still flagged as restricted (yellow), but not hard-disabled.
  const onCooldown = !!job.is_cooldown;
  const hardDisabled = unavailable && !onCooldown;
  return (
    <Stack mt={0.5} align="center">
      {!!job.has_subclass_info && (
        <Stack.Item>
          <Button
            tooltip="Subclass info"
            color="transparent"
            onClick={() =>
              act('subclass_info', { job: job.title })
            }
          >
            <Box inline bold style={{ color: '#6b6743' }}>
              (!)
            </Box>
          </Button>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Button
          fluid
          disabled={hardDisabled}
          color={
            hardDisabled
              ? undefined
              : onCooldown
                ? 'average'
                : job.prioritized
                  ? 'good'
                  : undefined
          }
          tooltip={
            unavailable ? job.unavailable_reason || 'Unavailable' : undefined
          }
          onClick={
            hardDisabled
              ? undefined
              : () => act('select_job', { job: job.title })
          }
        >
          {unavailable ? (
            <Box inline color={onCooldown ? undefined : 'label'}>
              {job.display_name}
              {' '}
              <Box
                inline
                italic
                /* Cooldown rows have an orange ("average") button background;
                   inheriting the default button text reads cleanly. Locked
                   restrictions (race/age/etc) stay red on the dark disabled
                   button. */
                color={onCooldown ? undefined : 'bad'}
                style={onCooldown ? { color: '#1a1a1a' } : undefined}
              >
                — {job.unavailable_reason || 'Unavailable'}
              </Box>
            </Box>
          ) : (
            nameText
          )}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

const CategoryColumn = ({
  category,
  act,
}: {
  category: CategoryMerged;
  act: (a: string, p?: object) => void;
}) => (
  // Box wrap with fixed border + height: 100% so the bordered cell stretches
  // to the row's max height (set by align="stretch" on the parent Stack).
  // Section sits unstyled inside; its title bar still gets the colored rule.
  <Box
    style={{
      border: '1px solid #1d1d1d',
      backgroundColor: '#0e0e0e',
      height: '100%',
      boxSizing: 'border-box',
    }}
  >
    <Section
      title={
        <Box inline bold style={{ color: category.color }}>
          {category.name}
        </Box>
      }
    >
      {category.jobs.map((job) => (
        <JobRow key={job.title} job={job} act={act} />
      ))}
    </Section>
  </Box>
);

export const LateJoinChoices = () => {
  const { act, data } = useBackend<Data>();

  // Skeleton / goblin siege: the classic UI suppresses the normal category
  // list and just shows the lone "BECOME X" affordance, so we mirror that.
  if (data.siege_skeleton) {
    return (
      <Window width={500} height={220} title="Choose Class">
        <Window.Content>
          <Section title="Skeleton Siege">
            <Box mb={1} color="label">
              Round Duration: {data.round_duration}
            </Box>
            <SiegeBanner
              label="BECOME AN EVIL SKELETON"
              action="select_skeleton"
              act={act}
            />
          </Section>
        </Window.Content>
      </Window>
    );
  }

  if (data.siege_goblin) {
    return (
      <Window width={500} height={220} title="Choose Class">
        <Window.Content>
          <Section title="Goblin Siege">
            <Box mb={1} color="label">
              Round Duration: {data.round_duration}
            </Box>
            <SiegeBanner
              label="BECOME A GOBLIN"
              action="select_goblin"
              act={act}
            />
          </Section>
        </Window.Content>
      </Window>
    );
  }

  // Merge the static catalog (categories) with the per-job availability map
  // by title. Static drives ordering, names, command_bold; dynamic supplies
  // slot counts + availability + cooldown state. Jobs missing a dynamic
  // entry fall through with sane defaults so a brief push-gap doesn't
  // suppress the catalog.
  const availability = data.availability || {};
  const mergedCategories: CategoryMerged[] = (data.categories || []).map(
    (cat) => ({
      ...cat,
      jobs: cat.jobs.map((j) => ({
        ...j,
        ...(availability[j.title] || {
          current: 0,
          total: 0,
          prioritized: 0,
          available: 0,
          is_cooldown: 0,
          unavailable_reason: 'Unavailable',
        }),
      })),
    }),
  );

  // Partition matches Class Selection's columns. Backend ships categories in
  // configured display order (Nobles, Courtiers, Garrison, Churchmen,
  // Inquisition, Yeomen, Peasants, Sidefolk, Mercenaries), so index ranges
  // align with the Class Selection order ranges 1-3 / 4-6 / 7+.
  //   Col 1: indices 0-2  (Nobles, Courtiers, Garrison)
  //   Col 2: indices 3-5  (Churchmen, Inquisition, Yeomen)
  //   Col 3: indices 6+   (Peasants, Sidefolk, Mercenaries)
  // Returned row-major so category headers align horizontally across columns.
  const cols: CategoryMerged[][] = [[], [], []];
  mergedCategories.forEach((cat, i) => {
    if (i <= 2) cols[0].push(cat);
    else if (i <= 5) cols[1].push(cat);
    else cols[2].push(cat);
  });
  const maxLen = Math.max(cols[0].length, cols[1].length, cols[2].length);
  const rows: (CategoryMerged | null)[][] = [];
  for (let i = 0; i < maxLen; i++) {
    rows.push([cols[0][i] || null, cols[1][i] || null, cols[2][i] || null]);
  }

  return (
    <Window width={900} height={620} title="Choose Class">
      <Window.Content scrollable>
        <Box mb={1} bold>
          Round Duration: {data.round_duration}
        </Box>
        {mergedCategories.length === 0 ? (
          <Box color="label" italic>
            No classes are currently available for late-join.
          </Box>
        ) : (
          <Stack vertical>
            {rows.map((row, rowIdx) => (
              <Stack.Item key={rowIdx}>
                <Stack align="stretch">
                  {row.map((cat, colIdx) => (
                    <Stack.Item
                      key={colIdx}
                      grow
                      basis={0}
                      style={{ minWidth: 0 }}
                    >
                      {cat ? (
                        <CategoryColumn category={cat} act={act} />
                      ) : null}
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
