export type Gender = 'male' | 'female'

export interface IdentityDraft {
  firstName: string
  lastName: string
  gender: Gender
  nationality: string
  birthDate: string
  birthPlace: string
  height: number
}

export const HEIGHT_MIN = 120
export const HEIGHT_MAX = 220
export const HEIGHT_DEFAULT = 175
export const MIN_AGE = 18
export const MAX_AGE = 110
export const NAME_MIN_LENGTH = 3
export const NAME_MAX_LENGTH = 24
export const PLACE_MAX_LENGTH = 40
export const IDENTITY_FIELD_TOTAL = 7

export type IdentityField = 'firstName' | 'lastName' | 'birthDate' | 'height'

export type IdentityError =
  | { code: 'nameLength'; min: number }
  | { code: 'nameCapital' }
  | { code: 'dateInvalid' }
  | { code: 'ageMin'; min: number }
  | { code: 'ageMax'; max: number }
  | { code: 'heightRange'; min: number; max: number }

export type IdentityErrors = Partial<Record<IdentityField, IdentityError>>

export const createIdentityDraft = (): IdentityDraft => ({
  firstName: '',
  lastName: '',
  gender: 'male',
  nationality: '',
  birthDate: '',
  birthPlace: '',
  height: HEIGHT_DEFAULT,
})

const startsWithCapital = (value: string): boolean => {
  const first = value.charAt(0)

  return first !== first.toLocaleLowerCase() && first === first.toLocaleUpperCase()
}

const nameError = (value: string): IdentityError | undefined => {
  const name = value.trim()

  if (name.length === 0) {
    return undefined
  }

  if (name.length < NAME_MIN_LENGTH) {
    return { code: 'nameLength', min: NAME_MIN_LENGTH }
  }

  if (!startsWithCapital(name)) {
    return { code: 'nameCapital' }
  }

  return undefined
}

export const parseIsoDate = (value: string): Date | null => {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value)

  if (!match) {
    return null
  }

  const year = Number(match[1])
  const month = Number(match[2])
  const day = Number(match[3])
  const date = new Date(year, month - 1, day)

  if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) {
    return null
  }

  return date
}

export const ageAt = (birth: Date, today = new Date()): number => {
  const monthGap = today.getMonth() - birth.getMonth()
  const beforeBirthday = monthGap < 0 || (monthGap === 0 && today.getDate() < birth.getDate())

  return today.getFullYear() - birth.getFullYear() - (beforeBirthday ? 1 : 0)
}

export const identityAge = (draft: IdentityDraft, today = new Date()): number | null => {
  const date = parseIsoDate(draft.birthDate)

  return date ? ageAt(date, today) : null
}

const birthDateError = (draft: IdentityDraft, today: Date): IdentityError | undefined => {
  if (draft.birthDate.length === 0) {
    return undefined
  }

  const age = identityAge(draft, today)

  if (age === null) {
    return { code: 'dateInvalid' }
  }

  if (age < MIN_AGE) {
    return { code: 'ageMin', min: MIN_AGE }
  }

  if (age > MAX_AGE) {
    return { code: 'ageMax', max: MAX_AGE }
  }

  return undefined
}

const heightError = (draft: IdentityDraft): IdentityError | undefined =>
  draft.height >= HEIGHT_MIN && draft.height <= HEIGHT_MAX
    ? undefined
    : { code: 'heightRange', min: HEIGHT_MIN, max: HEIGHT_MAX }

export const validateIdentity = (draft: IdentityDraft, today = new Date()): IdentityErrors => {
  const errors: IdentityErrors = {}
  const firstName = nameError(draft.firstName)
  const lastName = nameError(draft.lastName)
  const birthDate = birthDateError(draft, today)
  const height = heightError(draft)

  if (firstName) {
    errors.firstName = firstName
  }

  if (lastName) {
    errors.lastName = lastName
  }

  if (birthDate) {
    errors.birthDate = birthDate
  }

  if (height) {
    errors.height = height
  }

  return errors
}

export const isIdentityDraftValid = (draft: IdentityDraft, today = new Date()): boolean =>
  draft.firstName.trim().length > 0 &&
  draft.lastName.trim().length > 0 &&
  draft.nationality.length > 0 &&
  draft.birthDate.length > 0 &&
  Object.keys(validateIdentity(draft, today)).length === 0

export const countFilledIdentityFields = (draft: IdentityDraft, today = new Date()): number => {
  const errors = validateIdentity(draft, today)
  const checks = [
    draft.firstName.trim().length > 0 && !errors.firstName,
    draft.lastName.trim().length > 0 && !errors.lastName,
    true,
    draft.nationality.length > 0,
    draft.birthDate.length > 0 && !errors.birthDate,
    draft.birthPlace.trim().length > 0,
    !errors.height,
  ]

  return checks.filter(Boolean).length
}

export const birthYearBounds = (today = new Date()): { minYear: number; maxYear: number } => ({
  minYear: today.getFullYear() - MAX_AGE,
  maxYear: today.getFullYear() - MIN_AGE,
})
