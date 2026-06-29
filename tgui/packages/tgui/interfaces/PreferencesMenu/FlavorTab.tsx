import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import type { ActFunctionType } from '../../backend';

type FlavorData = {
  agevetted: 0 | 1;
  is_legacy: 0 | 1;
  min_flavortext: number;
  min_ooc_notes: number;
  flavortext_len: number;
  ooc_notes_len: number;
  rumour_len: number;
  gossip_len: number;
  ooc_extra_set: 0 | 1;
  headshot_link?: string;
  nsfw_headshot_link?: string;
  nsfwflavortext_len: number;
  erpprefs_len: number;
  nsfw_ooc_extra_set: 0 | 1;
  song_url_set: 0 | 1;
  song_title?: string;
  song_artist?: string;
  img_gallery_count: number;
  nsfw_img_gallery_count: number;
};

type Data = {
  flavor: FlavorData;
};

type FlavorTabProps = { data: Data; act: ActFunctionType };

const lenStatus = (current: number, minimum: number) => {
  if (current === 0) {
    return { text: '(unset)', color: 'bad' as const };
  }
  if (current < minimum) {
    return { text: `${current} / ${minimum}`, color: 'bad' as const };
  }
  return { text: `${current} chars`, color: 'good' as const };
};

// Accepted-upload rules, surfaced as tooltips on the image/link prompts below.
// Hosts are shared across every field; only the allowed extensions differ.
const UPLOAD_HOSTS = 'Gyazo, Lensdump, Imgbox, or Catbox';
const TIP_IMAGE = `Direct https image link ending in .jpg, .png, or .jpeg, hosted on ${UPLOAD_HOSTS}.`;
const TIP_GALLERY = `Direct https image link ending in .jpg, .png, .jpeg, or .gif, hosted on ${UPLOAD_HOSTS}.`;
const TIP_EXTRA = `Direct https link ending in .jpg, .png, .jpeg, .gif, .mp4, or .mp3, hosted on ${UPLOAD_HOSTS}.`;

export const FlavorTab = ({ data, act }: FlavorTabProps) => {
  const flavor = data.flavor;

  if (!flavor) {
    return <Box color="label">Loading flavor data…</Box>;
  }

  const ftStatus = lenStatus(flavor.flavortext_len, flavor.min_flavortext);
  const oocStatus = lenStatus(flavor.ooc_notes_len, flavor.min_ooc_notes);

  return (
    <Stack vertical>
      <Stack.Item>
        <Section
          title="Profile"
          buttons={
            <Button
              icon="eye"
              onClick={() => act('preview_examine')}
              tooltip="Open the in-character profile preview window"
            >
              Preview Examine
            </Button>
          }
        >
          {!!flavor.is_legacy && (
            <Box mb={1} italic color="label">
              This profile is a LEGACY slot from before the Flavortext/OOC
              changes — editing any field will modernize it.
            </Box>
          )}
          <LabeledList>
            <LabeledList.Item label="Flavortext">
              <Button onClick={() => act('edit_flavortext')}>Edit</Button>
              <Box inline ml={1} color={ftStatus.color}>
                {ftStatus.text}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="OOC Notes">
              <Button onClick={() => act('edit_ooc_notes')}>Edit</Button>
              <Box inline ml={1} color={oocStatus.color}>
                {oocStatus.text}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="NSFW Flavortext">
              <Button onClick={() => act('edit_nsfwflavortext')}>Edit</Button>
              <Box
                inline
                ml={1}
                color={flavor.nsfwflavortext_len ? 'good' : 'label'}
              >
                {flavor.nsfwflavortext_len
                  ? `${flavor.nsfwflavortext_len} chars`
                  : '(unset)'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="ERP Preferences">
              <Button onClick={() => act('edit_erpprefs')}>Edit</Button>
              <Box inline ml={1} color={flavor.erpprefs_len ? 'good' : 'label'}>
                {flavor.erpprefs_len
                  ? `${flavor.erpprefs_len} chars`
                  : '(unset)'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Rumours">
              <Button onClick={() => act('edit_rumour')}>Edit</Button>
              <Box inline ml={1} color="label">
                {flavor.rumour_len === 0
                  ? '(unset)'
                  : `${flavor.rumour_len} / 400`}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Noble Gossip">
              <Button onClick={() => act('edit_gossip')}>Edit</Button>
              <Box inline ml={1} color="label">
                {flavor.gossip_len === 0
                  ? '(unset)'
                  : `${flavor.gossip_len} / 400`}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Images & Age-Vetted Extras">
          {!flavor.agevetted ? (
            <Box color="bad">
              You must be Age Vetted to use Headshot, NSFW Bodyshot, and OOC
              Extra features. Open a ticket in Discord to verify.
            </Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Headshot">
                <Button tooltip={TIP_IMAGE} onClick={() => act('edit_headshot')}>
                  Edit URL
                </Button>
                <Box inline ml={1} color="label">
                  {flavor.headshot_link ? '(set)' : '(unset)'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="NSFW Bodyshot">
                <Button
                  tooltip={TIP_IMAGE}
                  onClick={() => act('edit_nsfw_headshot')}
                >
                  Edit URL
                </Button>
                <Box inline ml={1} color="label">
                  {flavor.nsfw_headshot_link ? '(set)' : '(unset)'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="OOC Extra Image/Video/Gif (Flavor Text)">
                <Button tooltip={TIP_EXTRA} onClick={() => act('edit_ooc_extra')}>
                  Edit URL
                </Button>
                <Box inline ml={1} color="label">
                  {flavor.ooc_extra_set ? '(set)' : '(unset)'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="NSFW OOC Extra Image/Video/Gif (Flavor Text)">
                <Button
                  tooltip={TIP_EXTRA}
                  onClick={() => act('edit_nsfw_ooc_extra')}
                >
                  Edit URL
                </Button>
                <Box inline ml={1} color="label">
                  {flavor.nsfw_ooc_extra_set ? '(set)' : '(unset)'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Song">
                <Button onClick={() => act('edit_song_url')}>Change URL</Button>
                <Button onClick={() => act('edit_song_title')}>
                  Change Title
                </Button>
                <Button onClick={() => act('edit_song_artist')}>
                  Change Artist
                </Button>
                <Box inline ml={1} color="label">
                  {flavor.song_url_set
                    ? flavor.song_title || '(set)'
                    : '(unset)'}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Image Gallery">
                <Button tooltip={TIP_GALLERY} onClick={() => act('img_gallery_add')}>
                  Add
                </Button>
                <Button onClick={() => act('img_gallery_clear')}>
                  Clear Gallery
                </Button>
                <Box inline ml={1} color="label">
                  {flavor.img_gallery_count} / 6
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Nsfw Image Gallery">
                <Button
                  tooltip={TIP_GALLERY}
                  onClick={() => act('nsfw_img_gallery_add')}
                >
                  Add
                </Button>
                <Button onClick={() => act('nsfw_img_gallery_clear')}>
                  Clear Nsfw Gallery
                </Button>
                <Box inline ml={1} color="label">
                  {flavor.nsfw_img_gallery_count} / 6
                </Box>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
