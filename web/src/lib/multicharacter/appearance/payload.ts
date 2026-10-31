import { ACCESSORY_IDS, CLOTHING_IDS, TATTOO_ZONE_IDS, controlKey } from './catalog'
import type { HeritageConfig } from '../types'

export type AppearanceDraft = Record<string, number>

const read = (
  draft: AppearanceDraft,
  step: string,
  category: string,
  control: string,
  fallback = 0,
): number => draft[controlKey(step, category, control)] ?? fallback

export interface HeritagePayload {
  mother: number
  father: number
  resemblance: number
  skinTone: number
}

export const buildHeritagePayload = (
  draft: AppearanceDraft,
  heritage: HeritageConfig,
): HeritagePayload => ({
  mother: heritage.mothers[read(draft, 'heritage', 'parents', 'mother')]?.id ?? 21,
  father: heritage.fathers[read(draft, 'heritage', 'parents', 'father')]?.id ?? 0,
  resemblance: read(draft, 'heritage', 'resemblance', 'resemblance', 50) / 100,
  skinTone: read(draft, 'heritage', 'resemblance', 'skinTone', 50) / 100,
})

const physical = (
  draft: AppearanceDraft,
  category: string,
  control: string,
  fallback = 0,
): number => read(draft, 'physical', category, control, fallback)

const overlay = (
  draft: AppearanceDraft,
  category: string,
  style: string,
  opacity: string,
  color?: string,
  secondary?: string,
) => ({
  style: physical(draft, category, style, 1),
  opacity: physical(draft, category, opacity, 0.5),
  ...(color ? { color: physical(draft, category, color) } : {}),
  ...(secondary ? { secondary: physical(draft, category, secondary) } : {}),
})

export const buildPhysicalPayload = (draft: AppearanceDraft) => ({
  hair: {
    style: physical(draft, 'hair', 'style', 1),
    color: physical(draft, 'hair', 'color'),
    highlight: physical(draft, 'hair', 'highlights'),
  },
  eyeColor: physical(draft, 'eyes', 'style'),
  overlays: {
    eyebrows: overlay(draft, 'eyebrows', 'shape', 'opacity', 'color'),
    beard: overlay(draft, 'beard', 'style', 'opacity', 'color'),
    chestHair: overlay(draft, 'chestHair', 'style', 'opacity', 'color'),
    ageing: overlay(draft, 'ageing', 'style', 'opacity'),
    lipstick: overlay(draft, 'makeup', 'lipstickStyle', 'lipstickOpacity', 'lipstickColor'),
    makeup: overlay(
      draft,
      'makeup',
      'makeupStyle',
      'makeupOpacity',
      'makeupPrimaryColor',
      'makeupSecondaryColor',
    ),
    blush: overlay(draft, 'makeup', 'blushStyle', 'blushOpacity', 'blushColor'),
    sunDamage: overlay(draft, 'skinDamage', 'sunDamageStyle', 'sunDamageOpacity'),
    moles: overlay(draft, 'skinDamage', 'molesStyle', 'molesOpacity'),
    blemishes: overlay(draft, 'skinDamage', 'blemishesStyle', 'blemishesOpacity'),
  },
  features: {
    browHeight: physical(draft, 'eyebrows', 'height'),
    browDepth: physical(draft, 'eyebrows', 'depth'),
    eyesOpening: physical(draft, 'eyes', 'opening'),
    noseWidth: physical(draft, 'nose', 'width'),
    noseHeight: physical(draft, 'nose', 'height'),
    noseLength: physical(draft, 'nose', 'length'),
    noseBridgeHeight: physical(draft, 'nose', 'bridgeHeight'),
    noseBridgeTwist: physical(draft, 'nose', 'bridgeTwist'),
    noseTipHeight: physical(draft, 'nose', 'tipHeight'),
    cheekboneHeight: physical(draft, 'cheeks', 'boneHeight'),
    cheekboneWidth: physical(draft, 'cheeks', 'boneWidth'),
    cheekWidth: physical(draft, 'cheeks', 'width'),
    lipThickness: physical(draft, 'lips', 'thickness'),
    jawWidth: physical(draft, 'jaw', 'width'),
    jawLength: physical(draft, 'jaw', 'length'),
    chinPosition: physical(draft, 'chin', 'position'),
    chinLength: physical(draft, 'chin', 'length'),
    chinWidth: physical(draft, 'chin', 'width'),
    chinHollow: physical(draft, 'chin', 'hollow'),
    neckThickness: physical(draft, 'neck', 'thickness'),
  },
})

export type ModelVariant = { model: number; variant: number }

const variants = (
  draft: AppearanceDraft,
  step: string,
  ids: readonly string[],
): Record<string, ModelVariant> =>
  Object.fromEntries(
    ids.map((id) => [
      id,
      { model: read(draft, step, id, 'model', 1), variant: read(draft, step, id, 'variant', 1) },
    ]),
  )

export const buildClothingPayload = (draft: AppearanceDraft): Record<string, ModelVariant> =>
  variants(draft, 'clothing', CLOTHING_IDS)

export const buildAccessoryPayload = (draft: AppearanceDraft): Record<string, ModelVariant> =>
  variants(draft, 'accessories', ACCESSORY_IDS)

export const buildTattooPayload = (draft: AppearanceDraft): Record<string, number> =>
  Object.fromEntries(
    TATTOO_ZONE_IDS.map((zone) => [zone, read(draft, 'tattoos', zone, 'tattoo', 1)]),
  )

export const parentPortrait = (id: number): string => {
  if (id >= 42 && id <= 44) {
    return `images/parents/special_male_${id - 42}.webp`
  }

  if (id === 45) {
    return 'images/parents/special_female_0.webp'
  }

  if (id >= 21) {
    return `images/parents/female_${id - 21}.webp`
  }

  return `images/parents/male_${id}.webp`
}
