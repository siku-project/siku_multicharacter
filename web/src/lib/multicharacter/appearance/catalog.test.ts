import { describe, expect, it } from 'vitest'
import {
  APPEARANCE_STEPS,
  controlKey,
  createAppearanceDraft,
  limitKeyFor,
  stepById,
} from './catalog'

describe('appearance catalogue', () => {
  it('walks from the model to the summary', () => {
    expect(APPEARANCE_STEPS.map((step) => step.id)).toEqual([
      'ped',
      'heritage',
      'physical',
      'clothing',
      'accessories',
      'tattoos',
      'summary',
    ])
    expect(stepById('physical')?.categories?.length).toBe(14)
  })

  it('seeds every control with its default or its midpoint', () => {
    const draft = createAppearanceDraft()

    expect(draft[controlKey('physical', 'hair', 'style')]).toBe(1)
    expect(draft[controlKey('heritage', 'resemblance', 'resemblance')]).toBe(50)
    expect(draft[controlKey('physical', 'nose', 'width')]).toBe(0)
    expect(draft[controlKey('physical', 'hair', 'color')]).toBe(0)
  })

  it('binds controls to the limits the game reports', () => {
    expect(limitKeyFor('physical', 'hair', 'style')).toBe('hairStyles')
    expect(limitKeyFor('clothing', 'jacket', 'model')).toBe('jacketModel')
    expect(limitKeyFor('accessories', 'hat', 'variant')).toBe('hatVariant')
    expect(limitKeyFor('tattoos', 'torso', 'tattoo')).toBe('torsoTattoo')
    expect(limitKeyFor('physical', 'nose', 'width')).toBeUndefined()
    expect(limitKeyFor('heritage', 'parents', 'mother')).toBeUndefined()
  })
})
