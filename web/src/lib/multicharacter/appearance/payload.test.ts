import { describe, expect, it } from 'vitest'
import { controlKey, createAppearanceDraft } from './catalog'
import {
  buildAccessoryPayload,
  buildClothingPayload,
  buildHeritagePayload,
  buildPhysicalPayload,
  buildTattooPayload,
  parentPortrait,
} from './payload'
import { MOCK_HERITAGE } from '../mock'

describe('appearance payloads', () => {
  const draft = createAppearanceDraft()

  it('resolves parents by index and blends as fractions', () => {
    draft[controlKey('heritage', 'parents', 'mother')] = 2
    draft[controlKey('heritage', 'parents', 'father')] = 21
    draft[controlKey('heritage', 'resemblance', 'resemblance')] = 25

    expect(buildHeritagePayload(draft, MOCK_HERITAGE)).toEqual({
      mother: 23,
      father: 42,
      resemblance: 0.25,
      skinTone: 0.5,
    })
  })

  it('groups the physical controls the way the game expects', () => {
    draft[controlKey('physical', 'hair', 'style')] = 7
    draft[controlKey('physical', 'nose', 'width')] = -0.4

    const physical = buildPhysicalPayload(draft)

    expect(physical.hair.style).toBe(7)
    expect(physical.features.noseWidth).toBe(-0.4)
    expect(physical.overlays.makeup).toEqual({ style: 1, opacity: 0.5, color: 0, secondary: 0 })
    expect(physical.overlays.ageing).toEqual({ style: 1, opacity: 0.5 })
  })

  it('lists every clothing, accessory and tattoo slot', () => {
    expect(Object.keys(buildClothingPayload(draft))).toEqual([
      'jacket',
      'tshirt',
      'armsGloves',
      'pants',
      'shoes',
    ])
    expect(buildAccessoryPayload(draft).hat).toEqual({ model: 1, variant: 1 })
    expect(Object.keys(buildTattooPayload(draft))).toHaveLength(9)
  })

  it('maps parent ids to their portrait', () => {
    expect(parentPortrait(0)).toBe('images/parents/male_0.webp')
    expect(parentPortrait(21)).toBe('images/parents/female_0.webp')
    expect(parentPortrait(43)).toBe('images/parents/special_male_1.webp')
    expect(parentPortrait(45)).toBe('images/parents/special_female_0.webp')
  })
})
