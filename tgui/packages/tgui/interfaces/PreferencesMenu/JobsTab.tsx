import React, { useState } from 'react';
import { Box, Button, Section, Stack, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';

type JobState =
  | 'banned'
  | 'playtime'
  | 'agedays'
  | 'min_pq'
  | 'max_pq'
  | 'virtue'
  | 'origin'
  | 'vice'
  | 'unavailable'
  | 'available';

type JobPriority = 'high' | 'medium' | 'low' | 'never';

type JobEntry = {
  title: string;
  display_name: string;
  tutorial: string;
  slots: number;
  rcp: number;
  required: 0 | 1;
  state: JobState;
  state_text?: string;
  priority?: JobPriority;
};

type JobsData = {
  loaded: 0 | 1;
  joblessrole: string;
  last_class?: string;
  job_change_locked: 0 | 1;
  triumphs: number;
  pq: number;
  jobs: JobEntry[];
};

type Data = {
  jobs: JobsData;
};

// Matches the classic SetChoices() `splitJobs` list — jobs that mark visual
// section breaks within a column. A horizontal rule renders above each.
const SPLIT_JOBS = new Set([
  'Court Magician',
  'Knight',
  'Priest',
  'Merchant',
  'Town Elder',
  'Adventurer',
  'Grenzelhoft Mercenary',
  'Beggar',
  'Prisoner',
  'Goblin King',
]);

// Classic uses limit=14 rows per column. Higher value = fewer, wider columns.
const COLUMN_LIMIT = 17;

type GridCell = { job: JobEntry; separatorAbove: boolean };

const buildColumns = (jobs: JobEntry[]): GridCell[][] => {
  const cols: GridCell[][] = [];
  let cur: GridCell[] = [];
  for (const job of jobs) {
    if (cur.length >= COLUMN_LIMIT) {
      cols.push(cur);
      cur = [];
    }
    cur.push({
      job,
      separatorAbove: SPLIT_JOBS.has(job.title) && cur.length > 0,
    });
  }
  if (cur.length > 0) {
    cols.push(cur);
  }
  return cols;
};

// Cycle helpers — match classic SetChoices' raise/lower semantics.
const NEXT_LEVEL_UP: Record<JobPriority, JobPriority> = {
  never: 'low',
  low: 'medium',
  medium: 'high',
  high: 'never',
};
const NEXT_LEVEL_DOWN: Record<JobPriority, JobPriority> = {
  high: 'medium',
  medium: 'low',
  low: 'never',
  never: 'high',
};

const PRIORITY_LABEL: Record<JobPriority, string> = {
  high: 'High',
  medium: 'Medium',
  low: 'Low',
  never: 'NEVER',
};

const PRIORITY_COLOR: Record<JobPriority, string> = {
  high: 'blue',
  medium: 'good',
  low: 'orange',
  never: 'bad',
};

// Renders job.tutorial as actual HTML. Source is /datum/job.tutorial — server-side
// data, not user input — so the HTML is safe to render directly. Falls back to a
// plain message if the job has no tutorial defined.
const JobTutorialView = ({
  job,
  onClose,
}: {
  job: JobEntry;
  onClose: () => void;
}) => (
  <Section
    title={job.display_name}
    buttons={
      <Button icon="arrow-left" onClick={onClose}>
        Back to class list
      </Button>
    }
  >
    <Box mb={1} color="label">
      <b>Slots:</b> {job.slots}
      {!!job.rcp && (
        <>
          {' '}
          | <b>RCP:</b> +{job.rcp}
        </>
      )}
    </Box>
    {job.tutorial ? (
      <Box
        // eslint-disable-next-line react/no-danger
        dangerouslySetInnerHTML={{ __html: job.tutorial }}
      />
    ) : (
      <Box color="label" italic>
        No tutorial is defined for this class.
      </Box>
    )}
  </Section>
);

export const JobsTab = (props) => {
  const { act, data } = useBackend<Data>();
  const jobs = data.jobs;
  const [tutorialJob, setTutorialJob] = useState<JobEntry | null>(null);

  if (!jobs || !jobs.loaded) {
    return <Box color="label">Job system not yet initialized.</Box>;
  }

  // If a row's name was clicked, swap the entire tab content for a tutorial
  // view. The list refresh on poll never replaces this state — it sticks until
  // the user hits Back. We do re-resolve from the latest data so slot counts
  // etc. stay live.
  if (tutorialJob) {
    const fresh = jobs.jobs.find((j) => j.title === tutorialJob.title);
    return (
      <JobTutorialView
        job={fresh || tutorialJob}
        onClose={() => setTutorialJob(null)}
      />
    );
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Section
          title="Class Preferences"
          buttons={
            <>
              {jobs.last_class && (
                <Button
                  tooltip={`Spend 2 Triumphs to play as ${jobs.last_class} again`}
                  onClick={() => act('play_lastclass_again')}
                >
                  Play as {jobs.last_class} again (2T)
                </Button>
              )}
              <Button color="bad" onClick={() => act('reset_jobs')}>
                Reset
              </Button>
            </>
          }
        >
          {!!jobs.job_change_locked && (
            <Box color="bad" bold mb={1}>
              Job preferences are locked for this round.
            </Box>
          )}
          <Box mb={1}>
            <b>If Role Unavailable:</b>{' '}
            <Button onClick={() => act('toggle_joblessrole')}>
              {jobs.joblessrole}
            </Button>
          </Box>
          <Box mb={1} color="label" italic>
            Click a class name to read its tutorial. Click an available
            class&apos;s priority to raise it (left-click) or right-click to
            lower it.
          </Box>
          <Stack>
            {buildColumns(jobs.jobs).map((column, colIdx) => (
              <Stack.Item key={colIdx} grow basis={0}>
                <Table>
                  {column.map(({ job, separatorAbove }) => (
                    <React.Fragment key={job.title}>
                      {separatorAbove && (
                        <Table.Row>
                          <Table.Cell colSpan={2}>
                            <hr style={{ borderColor: '#444' }} />
                          </Table.Cell>
                        </Table.Row>
                      )}
                      <JobRow
                        job={job}
                        act={act}
                        onShowTutorial={() => setTutorialJob(job)}
                      />
                    </React.Fragment>
                  ))}
                </Table>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const JobRow = ({
  job,
  act,
  onShowTutorial,
}: {
  job: JobEntry;
  act: (action: string, payload?: object) => void;
  onShowTutorial: () => void;
}) => {
  // Tooltip is a brief one-liner now; the full tutorial opens in a panel.
  const tooltipText = `Slots: ${job.slots}${job.rcp ? ` | RCP: +${job.rcp}` : ''} — click for full tutorial`;
  return (
    <Table.Row>
      <Table.Cell collapsing>
        <Button
          tooltip={tooltipText}
          tooltipPosition="right"
          color="transparent"
          onClick={onShowTutorial}
        >
          {job.display_name}
        </Button>
      </Table.Cell>
      <Table.Cell>
        <JobRightCell job={job} act={act} />
      </Table.Cell>
    </Table.Row>
  );
};

const JobRightCell = ({
  job,
  act,
}: {
  job: JobEntry;
  act: (action: string, payload?: object) => void;
}) => {
  switch (job.state) {
    case 'banned':
      return (
        <Button
          color="bad"
          onClick={() => act('check_job_ban', { role: job.title })}
        >
          BANNED
        </Button>
      );
    case 'playtime':
    case 'agedays':
      return (
        <Box inline color="bad">
          [{job.state_text}]
        </Box>
      );
    case 'min_pq':
    case 'max_pq':
      return (
        <Box inline color="average">
          {job.state_text}
        </Box>
      );
    case 'virtue':
    case 'origin':
      return (
        <Box inline color="average">
          {job.state_text}
        </Box>
      );
    case 'vice':
      return (
        <Box inline color="bad">
          {job.state_text}
        </Box>
      );
    case 'unavailable':
      return (
        <Box inline color="label">
          {job.state_text}
        </Box>
      );
    case 'available': {
      const pr: JobPriority = job.priority || 'never';
      return (
        <Button
          color={PRIORITY_COLOR[pr]}
          tooltip="Left-click: raise · Right-click: lower"
          onClick={() =>
            act('set_job_level', {
              role: job.title,
              level: NEXT_LEVEL_UP[pr],
            })
          }
          onContextMenu={(e) => {
            e.preventDefault();
            act('set_job_level', {
              role: job.title,
              level: NEXT_LEVEL_DOWN[pr],
            });
          }}
        >
          {PRIORITY_LABEL[pr]}
        </Button>
      );
    }
    default:
      return null;
  }
};
