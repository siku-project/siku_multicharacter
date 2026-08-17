import { controlKey } from '@/config/appearance'

const value = (
  draft: Record<string, number>,
  category: string,
  control: string,
  fallback = 0,
): number => draft[controlKey('physical', category, control)] ?? fallback

export const buildPhysicalPayload = (draft: Record<string, number>) => ({
  hair: {
    style: value(draft, 'hair', 'style', 1),
    color: value(draft, 'hair', 'color'),
    highlight: value(draft, 'hair', 'highlights'),
  },
  eyeColor: value(draft, 'eyes', 'style'),
  overlays: {
    eyebrows: {
      style: value(draft, 'eyebrows', 'shape', 1),
      opacity: value(draft, 'eyebrows', 'opacity', 0.5),
      color: value(draft, 'eyebrows', 'color'),
    },
    beard: {
      style: value(draft, 'beard', 'style', 1),
      opacity: value(draft, 'beard', 'opacity', 0.5),
      color: value(draft, 'beard', 'color'),
    },
    chestHair: {
      style: value(draft, 'chestHair', 'style', 1),
      opacity: value(draft, 'chestHair', 'opacity', 0.5),
      color: value(draft, 'chestHair', 'color'),
    },
    ageing: {
      style: value(draft, 'ageing', 'style', 1),
      opacity: value(draft, 'ageing', 'opacity', 0.5),
    },
    lipstick: {
      style: value(draft, 'makeup', 'lipstickStyle', 1),
      opacity: value(draft, 'makeup', 'lipstickOpacity', 0.5),
      color: value(draft, 'makeup', 'lipstickColor'),
    },
    makeup: {
      style: value(draft, 'makeup', 'makeupStyle', 1),
      opacity: value(draft, 'makeup', 'makeupOpacity', 0.5),
      color: value(draft, 'makeup', 'makeupPrimaryColor'),
      secondary: value(draft, 'makeup', 'makeupSecondaryColor'),
    },
    blush: {
      style: value(draft, 'makeup', 'blushStyle', 1),
      opacity: value(draft, 'makeup', 'blushOpacity', 0.5),
      color: value(draft, 'makeup', 'blushColor'),
    },
    sunDamage: {
      style: value(draft, 'skinDamage', 'sunDamageStyle', 1),
      opacity: value(draft, 'skinDamage', 'sunDamageOpacity', 0.5),
    },
    moles: {
      style: value(draft, 'skinDamage', 'molesStyle', 1),
      opacity: value(draft, 'skinDamage', 'molesOpacity', 0.5),
    },
    blemishes: {
      style: value(draft, 'skinDamage', 'blemishesStyle', 1),
      opacity: value(draft, 'skinDamage', 'blemishesOpacity', 0.5),
    },
  },
  features: {
    browHeight: value(draft, 'eyebrows', 'height'),
    browDepth: value(draft, 'eyebrows', 'depth'),
    eyesOpening: value(draft, 'eyes', 'opening'),
    noseWidth: value(draft, 'nose', 'width'),
    noseHeight: value(draft, 'nose', 'height'),
    noseLength: value(draft, 'nose', 'length'),
    noseBridgeHeight: value(draft, 'nose', 'bridgeHeight'),
    noseBridgeTwist: value(draft, 'nose', 'bridgeTwist'),
    noseTipHeight: value(draft, 'nose', 'tipHeight'),
    cheekboneHeight: value(draft, 'cheeks', 'boneHeight'),
    cheekboneWidth: value(draft, 'cheeks', 'boneWidth'),
    cheekWidth: value(draft, 'cheeks', 'width'),
    lipThickness: value(draft, 'lips', 'thickness'),
    jawWidth: value(draft, 'jaw', 'width'),
    jawLength: value(draft, 'jaw', 'length'),
    chinPosition: value(draft, 'chin', 'position'),
    chinLength: value(draft, 'chin', 'length'),
    chinWidth: value(draft, 'chin', 'width'),
    chinHollow: value(draft, 'chin', 'hollow'),
    neckThickness: value(draft, 'neck', 'thickness'),
  },
})
