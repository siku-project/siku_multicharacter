import { store } from '../store.svelte'
import {
  NO_CATALOG,
  type Catalog,
  type CatalogKind,
  type CatalogListing,
  type CharacterSummary,
  type HeritageConfig,
  type PedsConfig,
  type SelectionConfig,
} from '../types'
import type { IdentityDraft } from '../identity'

const DAY = 86_400_000

export const DEV_PHOTOS_KEY = 'siku_multicharacter:dev:photos'
export const DEV_CDN_KEY = 'siku_multicharacter:dev:cdnKey'

export type DevPhotos = 'none' | 'files' | 'cdn'

const CATALOG_TARGETS: Record<string, CatalogKind> = {
  hair: 'component',
  eyebrows: 'overlay',
  beard: 'overlay',
  chest_hair: 'overlay',
  lipstick: 'overlay',
  makeup: 'overlay',
  blush: 'overlay',
  top: 'component',
  undershirt: 'component',
  arms: 'component',
  pants: 'component',
  shoes: 'component',
  mask: 'component',
  bag: 'component',
  neck: 'component',
  hat: 'prop',
  glasses: 'prop',
  earrings: 'prop',
  watch: 'prop',
  bracelet: 'prop',
}
const CATALOG_FOLDERS: Record<string, string> = {
  mp_m_freemode_01: 'male',
  mp_f_freemode_01: 'female',
}
const CATALOG_LIMITS: Record<string, string> = {
  hair: 'hairStyles',
  eyebrows: 'eyebrows',
  beard: 'beard',
  chest_hair: 'chestHair',
  lipstick: 'lipstick',
  makeup: 'makeup',
  blush: 'blush',
  top: 'jacketModel',
  undershirt: 'tshirtModel',
  arms: 'armsGlovesModel',
  pants: 'pantsModel',
  shoes: 'shoesModel',
  mask: 'maskModel',
  bag: 'backpackModel',
  neck: 'neckwearModel',
  hat: 'hatModel',
  glasses: 'glassesModel',
  earrings: 'earringsModel',
  watch: 'watchModel',
  bracelet: 'braceletModel',
}

/** The catalogue as config/catalog.lua describes it with source = 'files'. */
export const MOCK_FILES_CATALOG: Catalog = {
  source: 'files',
  targets: CATALOG_TARGETS,
  folders: CATALOG_FOLDERS,
  folder: 'images/catalog',
}

interface CdnItem {
  id: string
  kind: string
  name: string
}

/**
 * Lists the photos the way the server does, through the dev proxy that
 * forwards /cdn to the Siku CDN, and shows them in the editor. Resolves
 * to the number of photos found.
 */
export const listCdnCatalog = async (key: string): Promise<number> => {
  const photos: Record<string, Record<string, CatalogListing>> = {}
  const limits: Record<string, number> = {}
  let count = 0

  for (const [target, kind] of Object.entries(CATALOG_TARGETS)) {
    const pattern = new RegExp(
      kind === 'overlay' ? `^${target}_(\\d+)\\.webp$` : `^${target}_(\\d+)_(\\d+)\\.webp$`,
    )
    const limit = CATALOG_LIMITS[target]
    const offset = kind === 'prop' ? 2 : 1

    for (const [model, folder] of Object.entries(CATALOG_FOLDERS)) {
      const path = encodeURIComponent(`/${target}/${folder}`)
      const response = await fetch(`/cdn/api/v1/files?folder=${path}`, {
        headers: { Authorization: `Bearer ${key}` },
      })

      if (!response.ok) {
        throw new Error(`${target}/${folder}: HTTP ${response.status}`)
      }

      const listing = (await response.json()) as { items?: CdnItem[] }
      const entries: CatalogListing = {}
      let found = 0
      let last = -1

      for (const item of listing.items ?? []) {
        const match = item.kind === 'file' ? pattern.exec(item.name) : null

        if (match) {
          const drawable = Number(match[1])
          const texture = match[2] ? Number(match[2]) : 0
          const ids = (entries[drawable] ??= [])

          while (ids.length < texture) {
            ids.push('')
          }

          ids[texture] = item.id
          found += 1
          last = Math.max(last, drawable)
        }
      }

      if (found > 0) {
        photos[target] = { ...photos[target], [model]: entries }
        count += found

        if (limit) {
          limits[limit] = Math.max(limits[limit] ?? 0, last + offset)
        }
      }
    }
  }

  store.setCatalog(
    count > 0
      ? { source: 'cdn', targets: CATALOG_TARGETS, folders: CATALOG_FOLDERS, url: '/cdn', photos }
      : NO_CATALOG,
  )
  store.setAppearanceLimits(limits)

  return count
}

export const devPhotos = (): DevPhotos => {
  const stored = window.localStorage.getItem(DEV_PHOTOS_KEY)

  return stored === 'none' || stored === 'cdn' ? stored : 'files'
}

export const devCdnKey = (): string => window.localStorage.getItem(DEV_CDN_KEY) ?? ''

/** Picks where the editor reads its photos from in the browser, and remembers it. */
export const applyDevPhotos = async (mode: DevPhotos, key = devCdnKey()): Promise<number> => {
  window.localStorage.setItem(DEV_PHOTOS_KEY, mode)
  window.localStorage.setItem(DEV_CDN_KEY, key)

  if (mode === 'files') {
    store.setCatalog(MOCK_FILES_CATALOG)
    return 0
  }

  if (mode === 'cdn' && key) {
    return listCdnCatalog(key)
  }

  store.setCatalog(NO_CATALOG)
  return 0
}

export const MOCK_SELECTION_CONFIG: SelectionConfig = {
  slots: 5,
  allowCharacterDeletion: true,
  showDirtyMoney: true,
}

export const MOCK_CHARACTERS: CharacterSummary[] = [
  {
    id: 1042,
    slot: 1,
    identity: { firstName: 'Elena', lastName: 'Vasseur', birthDate: '1992-03-14', height: 168 },
    occupation: { name: 'Mécanicienne', grade: 'Cheffe d’atelier' },
    finances: { cash: 1240, bank: 48_960 },
    playtime: 9_312,
    lastPlayed: Date.now() - 2 * DAY,
    createdAt: Date.now() - 210 * DAY,
    pedModel: 'mp_f_freemode_01',
  },
  {
    id: 1187,
    slot: 2,
    identity: { firstName: 'Marcus', lastName: 'Delacroix', birthDate: '1985-11-02', height: 184 },
    occupation: { name: 'Ambulancier', grade: 'Titulaire' },
    finances: { cash: 320, bank: 12_780, dirtyMoney: 4_500 },
    playtime: 3_845,
    lastPlayed: Date.now() - 12 * 3_600_000,
    createdAt: Date.now() - 96 * DAY,
    pedModel: 'mp_m_freemode_01',
  },
  {
    id: 1301,
    slot: 3,
    identity: { firstName: 'Naomi', lastName: 'Okafor', birthDate: '2001-07-28', height: 171 },
    finances: { cash: 85, bank: 1_150 },
    playtime: 214,
    lastPlayed: Date.now() - 26 * DAY,
    createdAt: Date.now() - 31 * DAY,
    pedModel: 'mp_f_freemode_01',
  },
]

export const MOCK_IDENTITY: IdentityDraft = {
  firstName: 'Nora',
  lastName: 'Lindqvist',
  gender: 'female',
  nationality: 'SE',
  birthDate: '2001-03-12',
  birthPlace: 'Los Santos',
  height: 171,
}

export const MOCK_PEDS: PedsConfig = {
  authorizeAll: true,
  basics: ['mp_m_freemode_01', 'mp_f_freemode_01'],
  peds: [
    'a_m_y_skater_01',
    'a_m_y_hipster_02',
    'a_f_y_tourist_01',
    'a_m_m_business_01',
    'a_f_y_business_02',
    's_m_y_cop_01',
  ],
}

const FATHERS = [
  'Benjamin',
  'Daniel',
  'Joshua',
  'Noah',
  'Andrew',
  'Joan',
  'Alex',
  'Isaac',
  'Evan',
  'Ethan',
  'Vincent',
  'Angel',
  'Diego',
  'Adrian',
  'Gabriel',
  'Michael',
  'Santiago',
  'Kevin',
  'Louis',
  'Samuel',
  'Anthony',
]
const MOTHERS = [
  'Hannah',
  'Audrey',
  'Jasmine',
  'Giselle',
  'Amelia',
  'Isabella',
  'Zoe',
  'Ava',
  'Camila',
  'Violet',
  'Sophia',
  'Evelyn',
  'Nicole',
  'Ashley',
  'Grace',
  'Brianna',
  'Natalie',
  'Olivia',
  'Elizabeth',
  'Charlotte',
  'Emma',
]

export const MOCK_HERITAGE: HeritageConfig = {
  fathers: [
    ...FATHERS.map((name, id) => ({ id, name })),
    { id: 42, name: 'John' },
    { id: 43, name: 'Niko' },
    { id: 44, name: 'Claude' },
  ],
  mothers: [...MOTHERS.map((name, index) => ({ id: 21 + index, name })), { id: 45, name: 'Misty' }],
}

/** What the game would have sent before each screen, for the browser playground. */
export const loadMocks = (): void => {
  store.setCharacters(MOCK_CHARACTERS, MOCK_SELECTION_CONFIG)
  store.setIdentity(MOCK_IDENTITY)
  store.setPedsConfig(MOCK_PEDS)
  store.setHeritageConfig(MOCK_HERITAGE)
  store.setAppearanceLimits({ hairStyles: 38, eyebrows: 34, beard: 29, jacketModel: 61 })

  void applyDevPhotos(devPhotos()).catch((error: unknown) => {
    console.warn('[dev] catalogue photos:', (error as Error).message)
  })
}
