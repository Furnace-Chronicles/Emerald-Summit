import { BooleanLike } from 'tgui-core/react';

export type ExaminePanelData = {
  // Identity
  character_name: string;
  headshot: string;
  obscured: BooleanLike;
  // Descriptions
  flavor_text: string;
  ooc_notes: string;
  // Descriptions, but requiring manual input to see
  flavor_text_nsfw: string;
  ooc_notes_nsfw: string;
  img_gallery: string[];
  img_gallery_nsfw: string[];
  is_playing: BooleanLike;
  has_song: BooleanLike;
  is_vet: BooleanLike;
  is_naked: BooleanLike;
  nsfw_examine_always: BooleanLike;
};
