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

/** The ids of the photos the CDN listed for one target on one model: by drawable, one id per texture, '' where a photo is missing. */
export type CatalogListing = Record<string, string[]>

export type CatalogSource = 'none' | 'cdn' | 'files'

export type CatalogKind = 'component' | 'prop' | 'overlay'

/** How the editor finds the photo of an item: ids listed from the CDN under its url, or files shipped under a folder of the interface. */
export interface Catalog {
  source: CatalogSource
  targets: Record<string, CatalogKind>
  folders: Record<string, string>
  folder?: string
  url?: string
  photos?: Record<string, Record<string, CatalogListing>>
}

export const NO_CATALOG: Catalog = { source: 'none', targets: {}, folders: {} }

/** The file name of a photo, as siku_studio writes it: `top_12_3.webp` for a component or a prop (drawable 12, texture 3), `beard_7.webp` for an overlay. */
export const catalogFileName = (
  target: string,
  kind: CatalogKind,
  drawable: number,
  texture = 0,
): string =>
  kind === 'overlay' ? `${target}_${drawable}.webp` : `${target}_${drawable}_${texture}.webp`

/** The value the first drawable takes in the editor: 1, or 2 for a prop whose value 1 means none. */
export const catalogOffset = (catalog: Catalog, target: string): number =>
  catalog.targets[target] === 'prop' ? 2 : 1

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
    !!catalog.targets &&
    typeof catalog.targets === 'object' &&
    !Array.isArray(catalog.targets) &&
    !!catalog.folders &&
    typeof catalog.folders === 'object'
  )
}

/** The photo of a drawable and texture, as the catalogue knows it; undefined when the editor shows a slider or a bare number instead. */
export const catalogPhoto = (
  catalog: Catalog,
  target: string,
  model: string,
  drawable: number,
  texture = 0,
): string | undefined => {
  const kind = catalog.targets[target]

  if (!kind || drawable < 0 || texture < 0) {
    return undefined
  }

  const name = catalogFileName(target, kind, drawable, texture)

  if (catalog.source === 'files') {
    const folder = catalog.folders[model]

    return folder && catalog.folder ? `${catalog.folder}/${target}/${folder}/${name}` : undefined
  }

  if (catalog.source === 'cdn') {
    const id = catalog.photos?.[target]?.[model]?.[drawable]?.[texture]

    return id && catalog.url ? `${catalog.url}/media/${id}/${name}` : undefined
  }

  return undefined
}

/** Whether the catalogue has photos to show for a target on a model. */
export const catalogShows = (catalog: Catalog, target: string, model: string): boolean => {
  if (!catalog.targets[target]) {
    return false
  }

  if (catalog.source === 'files') {
    return !!catalog.folders[model] && !!catalog.folder
  }

  return (
    catalog.source === 'cdn' &&
    !!catalog.url &&
    Object.keys(catalog.photos?.[target]?.[model] ?? {}).length > 0
  )
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
