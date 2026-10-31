export const SCREENS = ['hidden', 'selection', 'creation', 'appearance'] as const

export type Screen = (typeof SCREENS)[number]

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
  finances?: CharacterFinances
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

export interface HeritageParent {
  id: number
  name: string
}

export interface HeritageConfig {
  fathers: HeritageParent[]
  mothers: HeritageParent[]
}

export type AppearanceLimits = Record<string, number>

export const isScreen = (value: unknown): value is Screen =>
  typeof value === 'string' && (SCREENS as readonly string[]).includes(value)

export const isLimits = (value: unknown): value is AppearanceLimits =>
  !!value && typeof value === 'object' && !Array.isArray(value)

export const isHeritageConfig = (value: unknown): value is HeritageConfig => {
  if (!value || typeof value !== 'object') {
    return false
  }

  const config = value as Partial<HeritageConfig>

  return Array.isArray(config.fathers) && Array.isArray(config.mothers)
}

export const isPedsConfig = (value: unknown): value is PedsConfig => {
  if (!value || typeof value !== 'object') {
    return false
  }

  const config = value as Partial<PedsConfig>

  return (
    typeof config.authorizeAll === 'boolean' &&
    Array.isArray(config.basics) &&
    Array.isArray(config.peds)
  )
}
