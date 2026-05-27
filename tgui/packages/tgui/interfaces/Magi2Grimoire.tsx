import { Box, Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Aspect = {
  path: string;
  name: string;
  latin_name: string;
  desc: string;
  type: 'Major' | 'Minor';
  color: string;
  spells: string[];
  bound: number;
};

type Data = {
  aspects: Aspect[];
  has_mind: number;
};

export const Magi2Grimoire = (props) => {
  const { act, data } = useBackend<Data>();
  const { aspects = [], has_mind } = data;

  const majors = aspects.filter((a) => a.type === 'Major');
  const minors = aspects.filter((a) => a.type === 'Minor');

  return (
    <Window width={540} height={620}>
      <Window.Content>
        <Stack vertical fill>
          {!has_mind && (
            <Stack.Item>
              <NoticeBox danger>
                This soul has no mind to bind aspects to.
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Section title="Major Aspects" scrollable>
              {majors.length === 0 && (
                <Box color="grey" italic>
                  No major aspects registered.
                </Box>
              )}
              {majors.map((a) => (
                <AspectRow key={a.path} aspect={a} act={act} />
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Minor Aspects" scrollable fill>
              {minors.length === 0 && (
                <Box color="grey" italic>
                  No minor aspects registered.
                </Box>
              )}
              {minors.map((a) => (
                <AspectRow key={a.path} aspect={a} act={act} />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type AspectRowProps = {
  aspect: Aspect;
  act: (action: string, params?: object) => void;
};

const AspectRow = (props: AspectRowProps) => {
  const { aspect, act } = props;
  const borderColor = aspect.color || '#FFFFFF';
  return (
    <Box
      mb={1}
      p={1}
      style={{
        borderLeft: `4px solid ${borderColor}`,
        background: aspect.bound ? 'rgba(80, 80, 0, 0.15)' : 'transparent',
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box bold style={{ color: borderColor, fontSize: '1.05em' }}>
            {aspect.name}
            {aspect.bound ? ' (bound)' : ''}
          </Box>
          {aspect.latin_name && (
            <Box italic color="grey" style={{ fontSize: '0.85em' }}>
              {aspect.latin_name}
            </Box>
          )}
          {aspect.desc && (
            <Box mt={0.5} style={{ fontSize: '0.9em' }}>
              {aspect.desc}
            </Box>
          )}
          {aspect.spells.length > 0 && (
            <Box mt={0.5} color="label" style={{ fontSize: '0.85em' }}>
              Grants: {aspect.spells.join(', ')}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          {aspect.bound ? (
            <Button
              color="bad"
              onClick={() => act('unbind', { path: aspect.path })}
            >
              Unbind
            </Button>
          ) : (
            <Button
              color="good"
              onClick={() => act('bind', { path: aspect.path })}
            >
              Bind
            </Button>
          )}
        </Stack.Item>
      </Stack>
    </Box>
  );
};
