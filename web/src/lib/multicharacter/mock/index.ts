import { store } from '../store.svelte'
import type { CharacterSummary, HeritageConfig, PedsConfig, SelectionConfig } from '../types'
import type { IdentityDraft } from '../identity'

const DAY = 86_400_000

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
}
