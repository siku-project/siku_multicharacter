export interface CharacterIdentity {
  firstName: string
  lastName: string
  birthDate?: string
  height?: number
}

export interface CharacterOccupation {
  name: string
  grade?: string
}

export interface CharacterFinances {
  cash: number
  bank: number
  dirtyMoney?: number
}

export interface CharacterSummary {
  id: number
  slot: number
  identity: CharacterIdentity
  occupation?: CharacterOccupation
  finances: CharacterFinances
  playtime: number
  lastPlayed?: number
  createdAt: number
  pedModel?: string
}

export interface SelectionConfig {
  slots: number
  allowCharacterDeletion: boolean
  showDirtyMoney: boolean
}

export interface PedsConfig {
  authorizeAll: boolean
  basics: string[]
  peds: string[]
}

const MONEY_FORMAT = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  maximumFractionDigits: 0,
})

export const formatMoney = (amount: number): string => MONEY_FORMAT.format(amount)

export const formatPlaytime = (minutes: number): string => {
  const hours = Math.floor(minutes / 60)
  const rest = minutes % 60
  if (hours === 0) {
    return `${rest} min`
  }
  if (hours >= 100) {
    return `${hours} h`
  }
  return `${hours} h ${String(rest).padStart(2, '0')}`
}

export const daysSince = (timestamp: number): number => {
  const elapsed = Date.now() - timestamp
  return Math.max(0, Math.floor(elapsed / 86_400_000))
}

export const formatDate = (timestamp: number, locale: string): string =>
  new Intl.DateTimeFormat(locale, { day: 'numeric', month: 'short', year: 'numeric' }).format(
    timestamp,
  )

export const computeAge = (birthDate: string): number | null => {
  const birth = new Date(birthDate)
  if (Number.isNaN(birth.getTime())) {
    return null
  }
  const now = new Date()
  let age = now.getFullYear() - birth.getFullYear()
  const beforeBirthday =
    now.getMonth() < birth.getMonth() ||
    (now.getMonth() === birth.getMonth() && now.getDate() < birth.getDate())
  if (beforeBirthday) {
    age -= 1
  }
  return age
}

export const characterInSlot = (
  characters: readonly CharacterSummary[],
  slot: number,
): CharacterSummary | undefined => characters.find((character) => character.slot === slot)
