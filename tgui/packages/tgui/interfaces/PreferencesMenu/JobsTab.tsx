import { useEffect, useRef, useState } from 'react';
import { Box, Button, Section, Stack, Table } from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';

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

// STATIC half of a job entry — round-stable per-pronoun catalog.
type JobEntryStatic = {
  title: string;
  display_name: string;
  tutorial: string;
  slots: number;
  rcp: number;
  required: 0 | 1;
  category: string;
  category_color: string;
  category_order: number;
};

// DYNAMIC half — gating state + priority, changes as user mutates prefs.
type JobEntryDynamic = {
  state: JobState;
  state_text?: string;
  priority?: JobPriority;
};

// Merged shape passed into renderers.
type JobEntry = JobEntryStatic & JobEntryDynamic;

type JobsDynamicData = {
  loaded: 0 | 1;
  joblessrole: string;
  last_class?: string;
  job_change_locked: 0 | 1;
  triumphs: number;
  pq: number;
  // Map keyed by job.title → per-job dynamic state. Spread onto each static
  // catalog entry by title in JobsTab below.
  jobs: Record<string, JobEntryDynamic>;
  class_explain_title?: string | null;
  class_explain_html?: string | null;
};

type JobsStaticData = {
  jobs: JobEntryStatic[];
};

type Data = {
  jobs: JobsDynamicData;
  jobs_static: JobsStaticData;
};

type JobsTabProps = { data: Data; act: ActFunctionType };

// Group the flat job list into categories (Nobles / Courtiers / ... / Other)
// using the backend-supplied category fields, then lay out three columns to
// match the late-join picker's silhouette. Within each category, jobs keep
// their backend display_order ordering.
type JobCategory = {
  name: string;
  color: string;
  order: number;
  jobs: JobEntry[];
};

const groupByCategory = (jobs: JobEntry[]): JobCategory[] => {
  const byName = new Map<string, JobCategory>();
  for (const job of jobs) {
    let cat = byName.get(job.category);
    if (!cat) {
      cat = {
        name: job.category,
        color: job.category_color,
        order: job.category_order,
        jobs: [],
      };
      byName.set(job.category, cat);
    }
    cat.jobs.push(job);
  }
  return [...byName.values()].sort((a, b) => a.order - b.order);
};

// Three columns with explicit order-range partitioning per user spec:
//   Col 1: orders 1-3  (Nobles, Courtiers, Garrison)
//   Col 2: orders 4-6  (Churchmen, Inquisition, Yeomen)
//   Col 3: orders 7-11 (Peasants, Sidefolk, Mercenaries, Other, Wanderers)
// Any category outside those ranges falls into Col 3 as a safety net.
//
// Returned as a row-major matrix so category headers align horizontally
// across columns: matrix[rowIdx][colIdx]. Shorter columns pad with nulls
// so the render can leave blank space for absent cells.
const layoutCategoryRows = (cats: JobCategory[]): (JobCategory | null)[][] => {
  const cols: JobCategory[][] = [[], [], []];
  for (const c of cats) {
    if (c.order >= 1 && c.order <= 3) cols[0].push(c);
    else if (c.order >= 4 && c.order <= 6) cols[1].push(c);
    else cols[2].push(c);
  }
  const maxLen = Math.max(cols[0].length, cols[1].length, cols[2].length);
  const rows: (JobCategory | null)[][] = [];
  for (let i = 0; i < maxLen; i++) {
    rows.push([cols[0][i] || null, cols[1][i] || null, cols[2][i] || null]);
  }
  return rows;
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

// Imperative innerHTML setter that only touches the DOM when the html string
// actually changes. Needed because Inferno's dangerouslySetInnerHTML re-sets
// innerHTML on every render, wiping any browser-managed state (e.g. the
// <details open> attribute set when the user clicks a <summary>). After the
// initial mount, subsequent ui_data polls re-render this component but the
// useEffect guard keeps the DOM untouched as long as html is byte-identical.
const PreservingHtml = ({ html }: { html: string }) => {
  const ref = useRef<HTMLDivElement | null>(null);
  const lastHtml = useRef<string>('');
  useEffect(() => {
    if (ref.current && lastHtml.current !== html) {
      ref.current.innerHTML = html;
      lastHtml.current = html;
    }
  }, [html]);
  return <div ref={ref} />;
};

// Renders job.tutorial as actual HTML. Source is /datum/job.tutorial — server-side
// data, not user input — so the HTML is safe to render directly. Falls back to a
// plain message if the job has no tutorial defined.
const JobTutorialView = ({
  job,
  act,
  explainHtml,
  explainTitle,
  onClose,
}: {
  job: JobEntry;
  act: (action: string, payload?: object) => void;
  explainHtml?: string | null;
  explainTitle?: string | null;
  onClose: () => void;
}) => {
  // Auto-load full details on mount. Backend stashes the HTML for this job
  // and ships it via ui_data; React's next poll picks it up. Clearing on
  // unmount drops the cached payload so a different class's request doesn't
  // see a stale title match.
  useEffect(() => {
    act('show_class_explain', { role: job.title });
    return () => act('clear_class_explain');
  }, [job.title]);
  // Only render the payload when its title matches the open tutorial — the
  // backend ships a single active_class_explain_* pair, so we have to gate
  // on title to avoid showing stale data during the request round-trip.
  const explainReady = !!explainHtml && explainTitle === job.title;
  return (
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
        <PreservingHtml html={job.tutorial} />
      ) : (
        <Box color="label" italic>
          No tutorial is defined for this class.
        </Box>
      )}
      {explainReady && (
        <Box
          mt={1}
          pt={1}
          style={{ borderTop: '1px solid #444' }}
        >
          <PreservingHtml html={explainHtml!} />
        </Box>
      )}
    </Section>
  );
};

export const JobsTab = ({ data, act }: JobsTabProps) => {
  const jobsDynamic = data.jobs;
  const jobsStatic = data.jobs_static;
  const [tutorialJob, setTutorialJob] = useState<JobEntry | null>(null);

  if (!jobsDynamic || !jobsDynamic.loaded || !jobsStatic) {
    return <Box color="label">Job system not yet initialized.</Box>;
  }

  // Merge the static catalog with the dynamic state map by title. The static
  // catalog drives ordering (it's pre-sorted server-side); the dynamic state
  // contributes per-job state/state_text/priority. Jobs missing a dynamic
  // entry fall through with state undefined, which the renderer treats as
  // "available" with no priority — defensive against transient pushes.
  const mergedJobs: JobEntry[] = jobsStatic.jobs.map((s) => ({
    ...s,
    ...(jobsDynamic.jobs[s.title] || ({ state: 'available' } as JobEntryDynamic)),
  }));

  // If a row's name was clicked, swap the entire tab content for a tutorial
  // view. The list refresh on poll never replaces this state — it sticks until
  // the user hits Back. We do re-resolve from the latest merged data so slot
  // counts etc. stay live.
  if (tutorialJob) {
    const fresh = mergedJobs.find((j) => j.title === tutorialJob.title);
    return (
      <JobTutorialView
        job={fresh || tutorialJob}
        act={act}
        explainHtml={jobsDynamic.class_explain_html}
        explainTitle={jobsDynamic.class_explain_title}
        onClose={() => setTutorialJob(null)}
      />
    );
  }

  // Aliased to keep the rest of the render tree's references stable.
  const jobs = { ...jobsDynamic, jobs: mergedJobs };

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
          <Stack vertical>
            {layoutCategoryRows(groupByCategory(jobs.jobs)).map(
              (row, rowIdx) => (
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
                          /* Wrap in a bordered Box so the section border
                             always reflects the Stack.Item's stretched
                             height, not just the natural height of the
                             Table inside. The Section sits unstyled inside
                             so its title bar still gets the colored bottom
                             rule. */
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
                                <Box inline bold style={{ color: cat.color }}>
                                  {cat.name}
                                </Box>
                              }
                            >
                              <Table>
                                {cat.jobs.map((job) => (
                                  <JobRow
                                    key={job.title}
                                    job={job}
                                    act={act}
                                    onShowTutorial={() =>
                                      setTutorialJob(job)
                                    }
                                  />
                                ))}
                              </Table>
                            </Section>
                          </Box>
                        ) : null}
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
              ),
            )}
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
  // Lead with the circle-info icon so players see at a glance that the class
  // name itself is clickable for the tutorial / subclass description.
  const tooltipText = `Slots: ${job.slots}${job.rcp ? ` | RCP: +${job.rcp}` : ''} — click for full tutorial`;
  return (
    <Table.Row>
      <Table.Cell>
        <Button
          fluid
          icon="circle-info"
          tooltip={tooltipText}
          tooltipPosition="right"
          color="transparent"
          onClick={onShowTutorial}
        >
          {job.display_name}
        </Button>
      </Table.Cell>
      <Table.Cell
        textAlign="right"
        style={{
          width: '180px',
          minWidth: '180px',
          whiteSpace: 'nowrap',
        }}
      >
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
          fluid
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
          fluid
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
