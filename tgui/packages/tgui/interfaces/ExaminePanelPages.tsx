import { useMemo, useState } from 'react';
import { Box, Button, Image, Section, Stack } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { ExaminePanelData } from './ExaminePanelData';

export const FlavorTextPage = ({ data }: { data: ExaminePanelData }) => {
  const {
    flavor_text,
    flavor_text_nsfw,
    ooc_notes,
    ooc_notes_nsfw,
    headshot,
    is_naked,
    nsfw_examine_always,
  } = data;
  const [oocNotesIndex, setOocNotesIndex] = useState('SFW');
  const [flavorTextIndex, setFlavorTextIndex] = useState('SFW');

  const flavorHTML = useMemo(
    () => ({
      __html: `<span className='Chat'>${flavor_text}</span>`,
    }),
    [flavor_text],
  );

  const nsfwHTML = useMemo(
    () => ({
      __html: `<span className='Chat'>${flavor_text_nsfw}</span>`,
    }),
    [flavor_text_nsfw],
  );

  const oocHTML = useMemo(
    () => ({
      __html: `<span className='Chat'>${ooc_notes}</span>`,
    }),
    [ooc_notes],
  );

  const oocnsfwHTML = useMemo(
    () => ({
      __html: `<span className='Chat'>${ooc_notes_nsfw}</span>`,
    }),
    [ooc_notes_nsfw],
  );

  return (
    <Stack fill>
      <Stack fill vertical>
        <Stack.Item align="center">
          <img src={resolveAsset(headshot)} width="350px" height="350px" />
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item grow width="300px">
              <Section
                scrollable
                fill
                title="OOC Notes"
                preserveWhitespace
                buttons={
                  <>
                    <Button
                      selected={oocNotesIndex === 'SFW'}
                      bold={oocNotesIndex === 'SFW'}
                      onClick={() => setOocNotesIndex('SFW')}
                      textAlign="center"
                      minWidth="60px"
                    >
                      SFW
                    </Button>
                    <Button
                      selected={oocNotesIndex === 'NSFW'}
                      disabled={!ooc_notes_nsfw}
                      bold={oocNotesIndex === 'NSFW'}
                      onClick={() => setOocNotesIndex('NSFW')}
                      textAlign="center"
                      minWidth="60px"
                    >
                      NSFW
                    </Button>
                  </>
                }
              >
                {oocNotesIndex === 'SFW' && <Box dangerouslySetInnerHTML={oocHTML} />}
                {oocNotesIndex === 'NSFW' && (
                  <Box dangerouslySetInnerHTML={oocnsfwHTML} />
                )}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <Stack.Item grow>
        <Section
          scrollable
          fill
          preserveWhitespace
          title="Flavor Text"
          buttons={
            <>
              <Button
                selected={flavorTextIndex === 'SFW'}
                bold={flavorTextIndex === 'SFW'}
                onClick={() => setFlavorTextIndex('SFW')}
                textAlign="center"
                width="60px"
              >
                SFW
              </Button>
              <Button
                selected={flavorTextIndex === 'NSFW'}
                disabled={!flavor_text_nsfw || (!is_naked && !nsfw_examine_always)}
                bold={flavorTextIndex === 'NSFW'}
                onClick={() => setFlavorTextIndex('NSFW')}
                textAlign="center"
                width="60px"
              >
                NSFW
              </Button>
            </>
          }
        >
          {flavorTextIndex === 'SFW' && <Box dangerouslySetInnerHTML={flavorHTML} />}
          {flavorTextIndex === 'NSFW' && (
            <Box dangerouslySetInnerHTML={nsfwHTML} />
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// One-at-a-time viewer: shows the selected image at full panel size and lets the
// user page through the gallery, instead of squishing every image into one row.
const ImageCarousel = (props: { images: string[] }) => {
  const { images } = props;
  const [index, setIndex] = useState(0);

  if (!images.length) {
    return <Box color="label">No images.</Box>;
  }

  // Clamp in case the backing list ever shrinks while mounted.
  const current = Math.min(index, images.length - 1);
  const step = (delta: number) =>
    setIndex((current + delta + images.length) % images.length);

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill align="center">
          <Image
            maxHeight="100%"
            maxWidth="100%"
            src={resolveAsset(images[current])}
          />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack align="center" justify="center">
          <Stack.Item>
            <Button
              icon="chevron-left"
              tooltip="Previous"
              disabled={images.length < 2}
              onClick={() => step(-1)}
            />
          </Stack.Item>
          <Stack.Item>
            <Box textAlign="center" width="60px">
              {current + 1} / {images.length}
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="chevron-right"
              tooltip="Next"
              disabled={images.length < 2}
              onClick={() => step(1)}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const ImageGalleryPage = ({ data }: { data: ExaminePanelData }) => {
  const { img_gallery } = data;

  return <ImageCarousel images={img_gallery} />;
};

export const NsfwImageGalleryPage = ({ data }: { data: ExaminePanelData }) => {
  const { img_gallery_nsfw } = data;

  return <ImageCarousel images={img_gallery_nsfw} />;
};
