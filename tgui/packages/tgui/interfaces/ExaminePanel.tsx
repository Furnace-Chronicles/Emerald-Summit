import { useState } from 'react';
import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ExaminePanelData } from './ExaminePanelData';
import {
  FlavorTextPage,
  ImageGalleryPage,
  NsfwImageGalleryPage,
} from './ExaminePanelPages';

enum Page {
  FlavorText,
  ImageGallery,
  NsfwImageGallery,
}

export const ExaminePanel = () => {
  const { act, data } = useBackend<ExaminePanelData>();
  const {
    is_vet,
    is_naked,
    nsfw_examine_always,
    character_name,
    is_playing,
    has_song,
    img_gallery,
    img_gallery_nsfw,
  } = data;
  const [currentPage, setCurrentPage] = useState(Page.FlavorText);

  const showSfwGallery = img_gallery.length > 0;
  const showNsfwGallery =
    img_gallery_nsfw.length > 0 && (is_naked || nsfw_examine_always);
  const showTabs = showSfwGallery || showNsfwGallery;

  let pageContents;
  switch (currentPage) {
    case Page.FlavorText:
      pageContents = <FlavorTextPage data={data} act={act} />;
      break;
    case Page.ImageGallery:
      pageContents = <ImageGalleryPage data={data} act={act} />;
      break;
    case Page.NsfwImageGallery:
      pageContents = <NsfwImageGalleryPage data={data} act={act} />;
      break;
  }

  return (
    <Window
      title={character_name}
      width={1000}
      height={700}
      buttons={
        <>
          {!!is_vet && (
            <Button
              color="gold"
              icon="crown"
              tooltip="This player is age-verified!"
              tooltipPosition="bottom-start"
              onClick={() => act('vet_chat')}
            />
          )}
          <Button
            color="green"
            icon="music"
            tooltip="Music player"
            tooltipPosition="bottom-start"
            onClick={() => act('toggle')}
            disabled={!has_song}
            selected={!is_playing}
          />
        </>
      }
    >
      <Window.Content>
        <Stack vertical fill>
          {showTabs && (
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  textAlign="center"
                  selected={currentPage === Page.FlavorText}
                  onClick={() => setCurrentPage(Page.FlavorText)}
                >
                  Flavor Text
                </Button>
              </Stack.Item>
              {showSfwGallery && (
                <Stack.Item grow>
                  <Button
                    fluid
                    textAlign="center"
                    selected={currentPage === Page.ImageGallery}
                    onClick={() => setCurrentPage(Page.ImageGallery)}
                  >
                    Image Gallery
                  </Button>
                </Stack.Item>
              )}
              {showNsfwGallery && (
                <Stack.Item grow>
                  <Button
                    fluid
                    color="purple"
                    textAlign="center"
                    selected={currentPage === Page.NsfwImageGallery}
                    onClick={() => setCurrentPage(Page.NsfwImageGallery)}
                  >
                    NSFW Gallery
                  </Button>
                </Stack.Item>
              )}
            </Stack>
          )}
          {showTabs && <Stack.Divider />}
          <Stack.Item grow position="relative" overflowX="hidden" overflowY="auto">
            {pageContents}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
