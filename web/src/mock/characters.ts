import type { CharacterSummary, SelectionConfig } from '@/utils/multicharacter'

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
