import { Box, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  threat_regions: {
    region_name: string;
    danger_level: string;
    danger_color: string;
  }[];
};

export const ThreatBoard = () => {
  const { data } = useBackend<Data>();

  return (
    <Window>
      <Window.Content scrollable>
        <Box>
          Test
          {data.threat_regions.map((region) => (
            <Section key={region.region_name}>
              <h3>{region.region_name}</h3>
              <p>Danger Level: {region.danger_level}</p>
            </Section>
          ))}
        </Box>
      </Window.Content>
    </Window>
  );
};
