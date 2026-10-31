import type { CharacterSummary } from './types'

const DAY = 86_400_000

export const formatMoney = (amount: number, locale: string): string =>
  new Intl.NumberFormat(locale, {
    style: 'currency',
    currency: 'USD',
    maximumFractionDigits: 0,
  }).format(amount)

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

export const daysSince = (timestamp: number, now = Date.now()): number =>
  Math.max(0, Math.floor((now - timestamp) / DAY))

export const formatDate = (value: Date | number, locale: string): string =>
  new Intl.DateTimeFormat(locale, { day: 'numeric', month: 'long', year: 'numeric' }).format(value)

export const regionName = (code: string, locale: string): string => {
  try {
    return new Intl.DisplayNames([locale], { type: 'region' }).of(code) ?? code
  } catch {
    return code
  }
}

export const characterInSlot = (
  characters: readonly CharacterSummary[],
  slot: number,
): CharacterSummary | undefined => characters.find((character) => character.slot === slot)

export const fullName = (character: Pick<CharacterSummary, 'identity'>): string =>
  `${character.identity.firstName} ${character.identity.lastName}`.trim()
