import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type JobEntry = {
  title: string;
  display_name: string;
  current: number;
  total: number;
  prioritized: 0 | 1;
  command_bold: 0 | 1;
  has_subclass_info: 0 | 1;
};

type Category = {
  name: string;
  color: string;
  jobs: JobEntry[];
};

type Data = {
  round_duration: string;
  siege_skeleton: 0 | 1;
  siege_goblin: 0 | 1;
  categories: Category[];
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
          color={job.prioritized ? 'good' : undefined}
          onClick={() => act('select_job', { job: job.title })}
        >
          {nameText}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

const CategoryColumn = ({
  category,
  act,
}: {
  category: Category;
  act: (a: string, p?: object) => void;
}) => (
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
);

export const LateJoinChoices = (props) => {
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

  // Lay out categories in a responsive 3-column grid. Classic LateChoices used
  // 4 columns at 185px each (~740px); 3 here gives wider buttons that show the
  // full job name at our font scale.
  const cols: Category[][] = [[], [], []];
  data.categories.forEach((cat, i) => cols[i % 3].push(cat));

  return (
    <Window width={780} height={620} title="Choose Class">
      <Window.Content scrollable>
        <Box mb={1} bold>
          Round Duration: {data.round_duration}
        </Box>
        {data.categories.length === 0 ? (
          <Box color="label" italic>
            No classes are currently available for late-join.
          </Box>
        ) : (
          <Stack>
            {cols.map((col, idx) => (
              <Stack.Item key={idx} grow basis={0}>
                <Stack vertical>
                  {col.map((cat) => (
                    <Stack.Item key={cat.name}>
                      <CategoryColumn category={cat} act={act} />
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
