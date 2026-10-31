import { describe, expect, it } from 'vitest'
import {
  HEIGHT_MAX,
  HEIGHT_MIN,
  MAX_AGE,
  MIN_AGE,
  birthYearBounds,
  countFilledIdentityFields,
  createIdentityDraft,
  identityAge,
  isIdentityDraftValid,
  parseIsoDate,
  validateIdentity,
} from './identity'

const today = new Date(2026, 9, 31)

const complete = () => ({
  ...createIdentityDraft(),
  firstName: 'Elena',
  lastName: 'Vasseur',
  nationality: 'FR',
  birthDate: '1992-03-14',
  birthPlace: 'Los Santos',
})

describe('identity', () => {
  it('starts empty with the default height', () => {
    const draft = createIdentityDraft()

    expect(draft.height).toBe(175)
    expect(isIdentityDraftValid(draft, today)).toBe(false)
    expect(countFilledIdentityFields(draft, today)).toBe(2)
  })

  it('accepts a complete identity', () => {
    expect(validateIdentity(complete(), today)).toEqual({})
    expect(isIdentityDraftValid(complete(), today)).toBe(true)
    expect(countFilledIdentityFields(complete(), today)).toBe(7)
  })

  it('requires names of three capitalised characters', () => {
    expect(validateIdentity({ ...complete(), firstName: 'Al' }, today).firstName).toEqual({
      code: 'nameLength',
      min: 3,
    })
    expect(validateIdentity({ ...complete(), lastName: 'vasseur' }, today).lastName).toEqual({
      code: 'nameCapital',
    })
  })

  it('rejects impossible dates and ages outside the bounds', () => {
    expect(parseIsoDate('2001-02-30')).toBeNull()
    expect(validateIdentity({ ...complete(), birthDate: '2001-02-30' }, today).birthDate).toEqual({
      code: 'dateInvalid',
    })
    expect(validateIdentity({ ...complete(), birthDate: '2010-01-01' }, today).birthDate).toEqual({
      code: 'ageMin',
      min: MIN_AGE,
    })
    expect(validateIdentity({ ...complete(), birthDate: '1900-01-01' }, today).birthDate).toEqual({
      code: 'ageMax',
      max: MAX_AGE,
    })
  })

  it('computes the age before and after the birthday', () => {
    expect(identityAge({ ...complete(), birthDate: '2000-10-31' }, today)).toBe(26)
    expect(identityAge({ ...complete(), birthDate: '2000-11-01' }, today)).toBe(25)
  })

  it('keeps the height inside the range', () => {
    expect(validateIdentity({ ...complete(), height: HEIGHT_MIN - 1 }, today).height).toEqual({
      code: 'heightRange',
      min: HEIGHT_MIN,
      max: HEIGHT_MAX,
    })
  })

  it('derives the birth years allowed from the age bounds', () => {
    expect(birthYearBounds(today)).toEqual({ minYear: 2026 - MAX_AGE, maxYear: 2026 - MIN_AGE })
  })
})
