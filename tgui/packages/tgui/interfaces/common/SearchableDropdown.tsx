import { type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  Popper,
} from 'tgui-core/components';

type DropdownEntry = { value: any; displayText?: ReactNode; disabled?: boolean };
type Option = string | DropdownEntry;

type Props = {
  options?: Option[];
  selected?: any;
  onSelected?: (value: any) => void;
  displayText?: ReactNode;
  width?: string | number;
  menuWidth?: string | number;
  placeholder?: string;
  disabled?: boolean;
  color?: string;
  over?: boolean;
  fluid?: boolean;
  /** Show the filter box once the option count exceeds this. Default 7. */
  searchThreshold?: number;
  // Any other tgui Dropdown props are passed straight through to the stock
  // Dropdown on the small-list path.
  [key: string]: any;
};

/**
 * Drop-in replacement for tgui-core's Dropdown. Every list renders the same
 * custom trigger + popup so they look identical regardless of size; lists past
 * `searchThreshold` (default 7) additionally get a filter box. (Routing short
 * lists through the stock Dropdown made them render in a different, off-theme
 * color — see the lone short "Height" descriptor.) Wrapped in an inline Box so
 * `width` constrains it, matching the per-tab Dropdown wrappers this replaces.
 */
export function SearchableDropdown(props: Props) {
  const {
    searchThreshold = 7,
    options = [],
    selected,
    onSelected,
    displayText,
    width,
    menuWidth,
    placeholder = 'Select…',
    disabled,
    color,
    over,
    fluid,
    ...rest
  } = props;

  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');

  // Every list renders the same custom trigger so short and long lists look
  // identical; only lists past the threshold also get a search box. Routing
  // short lists through the stock Dropdown made them render in a different
  // (off-theme, bluish) color than the searchable ones — visible on the lone
  // short "Height" descriptor, which stood out from its >7-option neighbours.
  const showSearch = options.length > searchThreshold;

  const entries: DropdownEntry[] = options.map((o) =>
    o && typeof o === 'object' ? o : { value: o, displayText: o },
  );
  const labelOf = (e: DropdownEntry): string =>
    String(e.displayText ?? e.value ?? '');

  const q = query.trim().toLowerCase();
  const filtered = q
    ? entries.filter((e) => labelOf(e).toLowerCase().includes(q))
    : entries;

  const current = entries.find((e) => e.value === selected);
  const buttonLabel = displayText ?? (current ? current.displayText : placeholder);

  const close = () => {
    setOpen(false);
    setQuery('');
  };

  const menuW = menuWidth
    ? typeof menuWidth === 'number'
      ? `${menuWidth}px`
      : menuWidth
    : '240px';

  const menu = (
    <div
      className="Dropdown__menu--wrapper"
      style={{ width: menuW, maxWidth: '90vw' }}
    >
      {showSearch && (
        <Box p={0.5}>
          <Input
            fluid
            autoFocus
            placeholder="Search…"
            value={query}
            onChange={setQuery}
            onEscape={close}
          />
        </Box>
      )}
      <div className="Dropdown__menu">
        {filtered.length === 0 ? (
          <div className="Dropdown__menu--entry" style={{ opacity: 0.6 }}>
            No matches
          </div>
        ) : (
          filtered.map((e, i) => (
            <div
              key={i}
              className={
                'Dropdown__menu--entry' + (e.value === selected ? ' selected' : '')
              }
              style={
                e.disabled
                  ? { opacity: 0.4, cursor: 'not-allowed' }
                  : undefined
              }
              onClick={() => {
                if (e.disabled) {
                  return;
                }
                onSelected?.(e.value);
                close();
              }}
            >
              {e.displayText ?? String(e.value)}
            </div>
          ))
        )}
      </div>
    </div>
  );

  return (
    <Box inline style={{ width: width }}>
      <Popper
        isOpen={open}
        onClickOutside={close}
        placement={over ? 'top-start' : 'bottom-start'}
        content={open ? menu : null}
      >
        <Button
          fluid={fluid ?? true}
          color={color}
          disabled={disabled}
          onClick={() => setOpen(!open)}
        >
          <Box
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              gap: '4px',
            }}
          >
            <Box
              style={{
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                whiteSpace: 'nowrap',
              }}
            >
              {buttonLabel}
            </Box>
            <Icon name="chevron-down" />
          </Box>
        </Button>
      </Popper>
    </Box>
  );
}
