export interface IdentityDraft {
  firstName: string
  lastName: string
  gender: 'male' | 'female'
  nationality: string
  birthDay: string
  birthMonth: string
  birthYear: string
  birthPlace: string
  height: number
}

export const HEIGHT_MIN = 120
export const HEIGHT_MAX = 220
export const HEIGHT_DEFAULT = 175

export const MIN_AGE = 18
export const MAX_AGE = 110

export const NAME_MIN_LENGTH = 3

export type IdentityField = 'firstName' | 'lastName' | 'birthDate' | 'height'

export interface IdentityFieldError {
  key: string
  params?: Record<string, string | number>
}

export type IdentityErrors = Partial<Record<IdentityField, IdentityFieldError>>

export const createIdentityDraft = (): IdentityDraft => ({
  firstName: '',
  lastName: '',
  gender: 'male',
  nationality: '',
  birthDay: '',
  birthMonth: '',
  birthYear: '',
  birthPlace: '',
  height: HEIGHT_DEFAULT,
})

const startsWithCapital = (value: string): boolean => {
  const first = value.charAt(0)
  return first !== first.toLocaleLowerCase() && first === first.toLocaleUpperCase()
}

const nameError = (value: string): IdentityFieldError | undefined => {
  const name = value.trim()

  if (name.length === 0) {
    return undefined
  }

  if (name.length < NAME_MIN_LENGTH) {
    return { key: 'creation.errorNameLength', params: { min: NAME_MIN_LENGTH } }
  }

  if (!startsWithCapital(name)) {
    return { key: 'creation.errorNameCapital' }
  }

  return undefined
}

export const isBirthDateFilled = (draft: IdentityDraft): boolean =>
  draft.birthDay.length > 0 && draft.birthMonth.length > 0 && draft.birthYear.length === 4

const birthDate = (draft: IdentityDraft): Date | null => {
  const day = Number(draft.birthDay)
  const month = Number(draft.birthMonth)
  const year = Number(draft.birthYear)

  if (!Number.isInteger(day) || !Number.isInteger(month) || !Number.isInteger(year)) {
    return null
  }

  const date = new Date(year, month - 1, day)

  if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) {
    return null
  }

  return date
}

export const identityAge = (draft: IdentityDraft): number | null => {
  const date = birthDate(draft)

  if (!date) {
    return null
  }

  const today = new Date()
  const monthGap = today.getMonth() - date.getMonth()
  const isBeforeBirthday = monthGap < 0 || (monthGap === 0 && today.getDate() < date.getDate())

  return today.getFullYear() - date.getFullYear() - (isBeforeBirthday ? 1 : 0)
}

const birthDateError = (draft: IdentityDraft): IdentityFieldError | undefined => {
  if (!isBirthDateFilled(draft)) {
    return undefined
  }

  const age = identityAge(draft)

  if (age === null) {
    return { key: 'creation.errorDateInvalid' }
  }

  if (age < MIN_AGE) {
    return { key: 'creation.errorAgeMin', params: { min: MIN_AGE } }
  }

  if (age > MAX_AGE) {
    return { key: 'creation.errorAgeMax', params: { max: MAX_AGE } }
  }

  return undefined
}

const heightError = (draft: IdentityDraft): IdentityFieldError | undefined => {
  if (draft.height >= HEIGHT_MIN && draft.height <= HEIGHT_MAX) {
    return undefined
  }

  return { key: 'creation.errorHeightRange', params: { min: HEIGHT_MIN, max: HEIGHT_MAX } }
}

export const validateIdentity = (draft: IdentityDraft): IdentityErrors => {
  const errors: IdentityErrors = {}

  const firstName = nameError(draft.firstName)
  const lastName = nameError(draft.lastName)
  const birth = birthDateError(draft)
  const height = heightError(draft)

  if (firstName) {
    errors.firstName = firstName
  }

  if (lastName) {
    errors.lastName = lastName
  }

  if (birth) {
    errors.birthDate = birth
  }

  if (height) {
    errors.height = height
  }

  return errors
}

export const isBirthDateValid = (draft: IdentityDraft): boolean =>
  isBirthDateFilled(draft) && birthDateError(draft) === undefined

export const isIdentityDraftValid = (draft: IdentityDraft): boolean =>
  draft.firstName.trim().length > 0 &&
  draft.lastName.trim().length > 0 &&
  draft.nationality.length > 0 &&
  isBirthDateFilled(draft) &&
  Object.keys(validateIdentity(draft)).length === 0

export const IDENTITY_FIELD_TOTAL = 7

export const countFilledIdentityFields = (draft: IdentityDraft): number => {
  const checks = [
    draft.firstName.trim().length > 0,
    draft.lastName.trim().length > 0,
    true,
    draft.nationality.length > 0,
    isBirthDateValid(draft),
    draft.birthPlace.trim().length > 0,
    true,
  ]
  return checks.filter(Boolean).length
}
