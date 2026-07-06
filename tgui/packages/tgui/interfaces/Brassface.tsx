import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type VaultItem = {
  name: string;
  value: number;
  income: number;
  icon_file: string;
  icon_state: string;
  ref: string;
};

type Pack = {
  name: string;
  category: string;
  base_cost: number;
  count: number;
  type: string;
};

type Data = {
  budget: number;
  locked: BooleanLike;
  next_tick_in: number;
  interest_rate: number;
  multiple_item_penalty: number;
  tax_enabled: BooleanLike;
  tax_rate: number;
  is_nightmaster: BooleanLike;
  categories: string[];
  packs: Pack[];
  appraised_items: VaultItem[];
  total_income: number;
  total_value: number;
};

export const Brassface = () => {
  const { act, data } = useBackend<Data>();
  const {
    budget,
    is_nightmaster,
    categories = [],
    packs = [],
    appraised_items = [],
    total_income,
    total_value,
    next_tick_in,
    tax_enabled,
  } = data;

  const [tab, setTab] = useState<'shop' | 'vault' | 'secrets'>('shop');
  const [shopCategory, setShopCategory] = useState<string>(categories[0] || '');

  return (
    <Window width={560} height={640}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="BRASSFACE — Sweet Dreams for Cheap">
              <Stack align="center">
                <Stack.Item grow>
                  <Box>
                    <b>Mammon loaded:</b> {budget}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="hand-holding-usd"
                    disabled={!budget}
                    onClick={() => act('withdraw')}
                  >
                    Withdraw
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === 'shop'}
                onClick={() => setTab('shop')}
              >
                Shop
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'vault'}
                onClick={() => setTab('vault')}
              >
                Vault
              </Tabs.Tab>
              {!!is_nightmaster && (
                <Tabs.Tab
                  selected={tab === 'secrets'}
                  onClick={() => setTab('secrets')}
                >
                  Secrets
                </Tabs.Tab>
              )}
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            {tab === 'shop' && (
              <ShopTab
                packs={packs}
                categories={categories}
                shopCategory={shopCategory}
                setShopCategory={setShopCategory}
                budget={budget}
                taxEnabled={!!data.tax_enabled}
                taxRate={data.tax_rate || 0}
                onBuy={(type) => act('buy', { type })}
              />
            )}
            {tab === 'vault' && (
              <VaultTab
                items={appraised_items}
                total={total_income}
                totalValue={total_value}
                nextTickIn={next_tick_in}
              />
            )}
            {tab === 'secrets' && !!is_nightmaster && (
              <SecretsTab
                taxEnabled={!!tax_enabled}
                onToggleTax={() => act('toggle_tax')}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ShopTab = (props: {
  packs: Pack[];
  categories: string[];
  shopCategory: string;
  setShopCategory: (cat: string) => void;
  budget: number;
  taxEnabled: boolean;
  taxRate: number;
  onBuy: (type: string) => void;
}) => {
  const {
    packs,
    categories,
    shopCategory,
    setShopCategory,
    budget,
    taxEnabled,
    taxRate,
    onBuy,
  } = props;
  const visible = packs.filter((p) => p.category === shopCategory);

  // Effective post-tax cost. The base cost is shipped via static_data; tax is dynamic so we recompute
  // client-side rather than pushing the whole pack list every poll.
  const effectiveCost = (base: number) =>
    taxEnabled ? Math.round(base + taxRate * base) : base;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack wrap>
          {categories.map((cat) => (
            <Stack.Item key={cat}>
              <Button
                selected={cat === shopCategory}
                onClick={() => setShopCategory(cat)}
              >
                {cat}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section title={shopCategory || 'Select a category'} fill scrollable>
          {visible.length === 0 && (
            <Box color="label" italic>
              No wares in this category.
            </Box>
          )}
          {visible.map((p) => {
            const cost = effectiveCost(p.base_cost);
            return (
              <Stack key={p.type} align="center" mb={1}>
                <Stack.Item grow>
                  <Box bold>
                    {p.name}
                    {p.count > 1 ? ` x${p.count}` : ''}
                  </Box>
                  <Box color="label" fontSize="0.85em">
                    {cost} mammons
                    {cost !== p.base_cost ? ` (${p.base_cost} + tax)` : ''}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button disabled={budget < cost} onClick={() => onBuy(p.type)}>
                    Buy
                  </Button>
                </Stack.Item>
              </Stack>
            );
          })}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const VaultTab = (props: {
  items: VaultItem[];
  total: number;
  totalValue: number;
  nextTickIn: number;
}) => {
  const { items, total, totalValue, nextTickIn } = props;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          <Stack>
            <Stack.Item grow>
              <Box>
                <b>Items in vault:</b> {items.length}
              </Box>
              <Box>
                <b>Total value:</b> {totalValue} mammons
              </Box>
              <Box>
                <b>Estimated income:</b> +{total} mammons/tick
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box color="label">Next tick in</Box>
              <Box bold>{nextTickIn}s</Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title="Vault Items" fill scrollable>
          {items.length === 0 && (
            <Box color="label" italic>
              The vault is bare. Appraise items to mark valuables for profit.
            </Box>
          )}
          {items.map((item) => (
            <Stack key={item.ref} align="center" mb={1}>
              <Stack.Item>
                <DmIcon
                  icon={item.icon_file}
                  icon_state={item.icon_state}
                  width={8}
                  height={8}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Box bold>{item.name}</Box>
                <Box color="label" fontSize="0.85em">
                  Value {item.value} mammons | +{item.income} mammons/tick
                </Box>
              </Stack.Item>
            </Stack>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const SecretsTab = (props: {
  taxEnabled: boolean;
  onToggleTax: () => void;
}) => {
  const { taxEnabled, onToggleTax } = props;
  return (
    <Section title="Secrets" fill>
      <Stack vertical>
        <Stack.Item>
          <Box mb={1}>
            <b>Import Tax:</b> {taxEnabled ? 'Enabled' : 'Evaded'}
          </Box>
          <Box color="label" mb={1} fontSize="0.85em">
            When evaded, BRASSFACE purchases skip the treasury import tax. The
            town will notice if audited.
          </Box>
          <Button
            color={taxEnabled ? 'bad' : 'good'}
            onClick={onToggleTax}
          >
            {taxEnabled ? 'Stop Paying Taxes' : 'Resume Paying Taxes'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
