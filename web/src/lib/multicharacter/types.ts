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

export interface CatalogPhoto {
  drawable: number
  url: string
}

export type CatalogSource = 'none' | 'cdn' | 'files'

/** How the editor finds the photo of an item: links listed from the CDN, or files shipped under a folder of the interface. */
export interface Catalog {
  source: CatalogSource
  targets: string[]
  folders: Record<string, string>
  folder?: string
  photos?: Record<string, Record<string, CatalogPhoto[]>>
}

export const NO_CATALOG: Catalog = { source: 'none', targets: [], folders: {} }

export const isScreen = (value: unknown): value is Screen =>
  typeof value === 'string' && (SCREENS as readonly string[]).includes(value)

export const isLimits = (value: unknown): value is AppearanceLimits =>
  !!value && typeof value === 'object' && !Array.isArray(value)

export const isCatalog = (value: unknown): value is Catalog => {
  if (!value || typeof value !== 'object') {
    return false
  }

  const catalog = value as Partial<Catalog>

  return (
    (catalog.source === 'cdn' || catalog.source === 'files') &&
    Array.isArray(catalog.targets) &&
    !!catalog.folders &&
    typeof catalog.folders === 'object'
  )
}

/** The photo of a drawable, as the catalogue knows it; undefined when the editor shows a slider or a bare number instead. */
export const catalogPhoto = (
  catalog: Catalog,
  target: string,
  model: string,
  drawable: number,
): string | undefined => {
  if (!catalog.targets.includes(target)) {
    return undefined
  }

  if (catalog.source === 'files') {
    const folder = catalog.folders[model]

    return folder && catalog.folder
      ? `${catalog.folder}/${target}/${folder}/${target}_${drawable}_0.webp`
      : undefined
  }

  if (catalog.source === 'cdn') {
    return catalog.photos?.[target]?.[model]?.find((photo) => photo.drawable === drawable)?.url
  }

  return undefined
}

/** Whether the catalogue has photos to show for a target on a model. */
export const catalogShows = (catalog: Catalog, target: string, model: string): boolean => {
  if (!catalog.targets.includes(target)) {
    return false
  }

  if (catalog.source === 'files') {
    return !!catalog.folders[model] && !!catalog.folder
  }

  return catalog.source === 'cdn' && (catalog.photos?.[target]?.[model]?.length ?? 0) > 0
}

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
