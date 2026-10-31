import { RESOURCE } from '@/lib/nui'
import type { IdentityDraft } from './identity'
import {
  isHeritageConfig,
  isLimits,
  isPedsConfig,
  isScreen,
  type AppearanceLimits,
  type CharacterSummary,
  type HeritageConfig,
  type PedsConfig,
  type Screen,
  type SelectionConfig,
} from './types'

let screen = $state<Screen>('hidden')
let characters = $state<CharacterSummary[]>([])
let selectionConfig = $state<SelectionConfig>({
  slots: 1,
  allowCharacterDeletion: false,
  showDirtyMoney: false,
})
let identity = $state<IdentityDraft | null>(null)
let pedsConfig = $state<PedsConfig>({
  authorizeAll: false,
  basics: ['mp_m_freemode_01', 'mp_f_freemode_01'],
  peds: [],
})
let heritageConfig = $state<HeritageConfig>({ fathers: [], mothers: [] })
let appearanceLimits = $state<AppearanceLimits>({})

interface NuiMessage {
  action?: unknown
  screen?: unknown
  characters?: unknown
  config?: unknown
  peds?: unknown
  heritage?: unknown
  limits?: unknown
}

const action = (name: string): string => `${RESOURCE}:nui:${name}`

/** Everything the game sends about the player and the catalogue; the interface only reads it. */
export const store = {
  get screen(): Screen {
    return screen
  },
  get characters(): CharacterSummary[] {
    return characters
  },
  get selectionConfig(): SelectionConfig {
    return selectionConfig
  },
  get identity(): IdentityDraft | null {
    return identity
  },
  get pedsConfig(): PedsConfig {
    return pedsConfig
  },
  get heritageConfig(): HeritageConfig {
    return heritageConfig
  },
  get appearanceLimits(): AppearanceLimits {
    return appearanceLimits
  },

  setScreen(next: Screen): void {
    screen = next
  },
  hide(): void {
    screen = 'hidden'
  },
  setCharacters(next: CharacterSummary[], config?: SelectionConfig): void {
    characters = next
    if (config) {
      selectionConfig = config
    }
  },
  setIdentity(next: IdentityDraft | null): void {
    identity = next
  },
  setPedsConfig(next: PedsConfig): void {
    pedsConfig = next
  },
  setHeritageConfig(next: HeritageConfig): void {
    heritageConfig = next
  },
  setAppearanceLimits(next: AppearanceLimits): void {
    appearanceLimits = { ...appearanceLimits, ...next }
  },

  /** Applies a message from the game. Returns false when the message is not one of ours. */
  applyMessage(data: unknown): boolean {
    const message = (data ?? {}) as NuiMessage

    if (typeof message.action !== 'string') {
      return false
    }

    switch (message.action) {
      case action('setScreen'):
        if (isScreen(message.screen)) {
          screen = message.screen
        }
        return true
      case action('hide'):
        screen = 'hidden'
        return true
      case action('setCharacters'):
        if (Array.isArray(message.characters)) {
          characters = message.characters as CharacterSummary[]
          if (message.config && typeof message.config === 'object') {
            selectionConfig = message.config as SelectionConfig
          }
        }
        return true
      case action('setPeds'):
        if (isPedsConfig(message.peds)) {
          pedsConfig = message.peds
        }
        return true
      case action('setHeritage'):
        if (isHeritageConfig(message.heritage)) {
          heritageConfig = message.heritage
        }
        return true
      case action('setLimits'):
        if (isLimits(message.limits)) {
          appearanceLimits = { ...appearanceLimits, ...message.limits }
        }
        return true
      default:
        return false
    }
  },
}
