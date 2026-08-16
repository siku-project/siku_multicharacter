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

export const HEIGHT_MIN = 140
export const HEIGHT_MAX = 210
export const HEIGHT_DEFAULT = 175

export const MIN_AGE = 18
export const MAX_AGE = 90

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

export const isBirthDateValid = (draft: IdentityDraft): boolean => {
  const day = Number(draft.birthDay)
  const month = Number(draft.birthMonth)
  const year = Number(draft.birthYear)
  if (!Number.isInteger(day) || !Number.isInteger(month) || !Number.isInteger(year)) {
    return false
  }
  const currentYear = new Date().getFullYear()
  if (year < currentYear - MAX_AGE || year > currentYear - MIN_AGE) {
    return false
  }
  const date = new Date(year, month - 1, day)
  return date.getFullYear() === year && date.getMonth() === month - 1 && date.getDate() === day
}

export const isIdentityDraftValid = (draft: IdentityDraft): boolean =>
  draft.firstName.trim().length > 1 &&
  draft.lastName.trim().length > 1 &&
  draft.nationality.length > 0 &&
  isBirthDateValid(draft)

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
