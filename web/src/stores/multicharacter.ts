import { ref } from 'vue'
import { defineStore } from 'pinia'
import type {
  CharacterSummary,
  HeritageConfig,
  PedsConfig,
  SelectionConfig,
} from '@/utils/multicharacter'
import type { IdentityDraft } from '@/utils/identity'

export const MULTICHARACTER_SCREENS = ['hidden', 'selection', 'creation', 'appearance'] as const

export type MulticharacterScreen = (typeof MULTICHARACTER_SCREENS)[number]

export const useMulticharacterStore = defineStore('multicharacter', () => {
  const screen = ref<MulticharacterScreen>('hidden')
  const characters = ref<CharacterSummary[]>([])
  const selectionConfig = ref<SelectionConfig>({
    slots: 1,
    allowCharacterDeletion: false,
    showDirtyMoney: false,
  })
  const identity = ref<IdentityDraft | null>(null)
  const pedsConfig = ref<PedsConfig>({
    authorizeAll: false,
    basics: ['mp_m_freemode_01', 'mp_f_freemode_01'],
    peds: [],
  })
  const heritageConfig = ref<HeritageConfig>({
    fathers: [],
    mothers: [],
  })

  const setScreen = (next: MulticharacterScreen): void => {
    if (!MULTICHARACTER_SCREENS.includes(next)) {
      return
    }
    screen.value = next
  }

  const hide = (): void => {
    screen.value = 'hidden'
  }

  const setCharacters = (next: CharacterSummary[]): void => {
    characters.value = next
  }

  const setSelectionConfig = (next: SelectionConfig): void => {
    selectionConfig.value = next
  }

  const setIdentity = (next: IdentityDraft | null): void => {
    identity.value = next
  }

  const setPedsConfig = (next: PedsConfig): void => {
    pedsConfig.value = next
  }

  const setHeritageConfig = (next: HeritageConfig): void => {
    heritageConfig.value = next
  }

  return {
    screen,
    characters,
    selectionConfig,
    identity,
    pedsConfig,
    heritageConfig,
    setScreen,
    hide,
    setCharacters,
    setSelectionConfig,
    setIdentity,
    setPedsConfig,
    setHeritageConfig,
  }
})
