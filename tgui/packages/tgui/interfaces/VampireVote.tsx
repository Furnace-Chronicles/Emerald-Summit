import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  TimeDisplay,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Plain records rather than enums: `null` as an enum member name crashes
// eslint's unused-imports rule; indexing behavior is identical (null coerces to "null").
const PrefToColorEnum: Record<string, string> = {
  null: 'red',
  low: 'orange',
  medium: 'green',
  high: 'red',
};

const PrefToTextEnum: Record<string, string> = {
  null: 'NEVER',
  low: '+',
  medium: '++',
  high: '+++',
};

interface Clan {
  clanName: string;
  description: string;
  type: string;
  priority: number;
  icon: string;
}

interface Data {
  clans: Clan[];
  timeLeft: number;
}

export const VampireVote = () => {
  const { data, act } = useBackend<Data>();

  return (
    <Window width={690} height={590}>
      <Window.Content>
        <Section
          fill
          scrollable
          title={'Clan vote'}
          buttons={<TimeDisplay value={data.timeLeft} />}
        >
          <LabeledList>
            {data.clans.map((clan, index) => (
              <LabeledList.Item
                textAlign="Left"
                key={index}
                label={
                  <Stack fill vertical justify="space-around">
                    <Stack.Item grow>
                      <b>{clan.clanName} </b>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Box className={clan.icon} mr={2} inline />
                    </Stack.Item>
                  </Stack>
                }
                buttons={
                  <Button
                    fluid
                    minWidth="6em"
                    maxWidth="6em"
                    textAlign="Center"
                    color={PrefToColorEnum[clan.priority]}
                    onClick={() => {
                      act('select_priority', { selected_clan: clan.type });
                    }}
                  >
                    {PrefToTextEnum[clan.priority]}
                  </Button>
                }
              >
                {clan.description}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
