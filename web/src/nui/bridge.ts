import {
  MULTICHARACTER_SCREENS,
  useMulticharacterStore,
  type MulticharacterScreen,
} from '@/stores/multicharacter'
import { applyLocale, isLocalePayload } from '@/utils/locale'
import { sendNuiCallback } from '@/utils/nui'
import type {
  CharacterSummary,
  HeritageConfig,
  PedsConfig,
  SelectionConfig,
} from '@/utils/multicharacter'

interface NuiMessage {
  action?: unknown
  screen?: unknown
  locale?: unknown
  peds?: unknown
  heritage?: unknown
  limits?: unknown
  characters?: unknown
  config?: unknown
}

const isLimits = (value: unknown): value is Record<string, number> =>
  !!value && typeof value === 'object' && !Array.isArray(value)

const isHeritageConfig = (value: unknown): value is HeritageConfig => {
  if (!value || typeof value !== 'object') {
    return false
  }
  const config = value as Partial<HeritageConfig>
  return Array.isArray(config.fathers) && Array.isArray(config.mothers)
}

const isPedsConfig = (value: unknown): value is PedsConfig => {
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

const isScreen = (value: unknown): value is MulticharacterScreen =>
  typeof value === 'string' && MULTICHARACTER_SCREENS.includes(value as MulticharacterScreen)

export const initNuiBridge = (): void => {
  window.addEventListener('message', (event: MessageEvent<NuiMessage>) => {
    const data = event.data
    if (!data || typeof data.action !== 'string') {
      return
    }

    const store = useMulticharacterStore()

    if (data.action === 'siku_multicharacter:nui:setScreen' && isScreen(data.screen)) {
      store.setScreen(data.screen)
      return
    }

    if (data.action === 'siku_multicharacter:nui:hide') {
      store.hide()
      return
    }

    if (data.action === 'siku_multicharacter:nui:setLocale' && isLocalePayload(data.locale)) {
      applyLocale(data.locale)
      return
    }

    if (data.action === 'siku_multicharacter:nui:setPeds' && isPedsConfig(data.peds)) {
      store.setPedsConfig(data.peds)
      return
    }

    if (data.action === 'siku_multicharacter:nui:setHeritage' && isHeritageConfig(data.heritage)) {
      store.setHeritageConfig(data.heritage)
      return
    }

    if (data.action === 'siku_multicharacter:nui:setLimits' && isLimits(data.limits)) {
      store.setAppearanceLimits(data.limits)
      return
    }

    if (data.action === 'siku_multicharacter:nui:setCharacters' && Array.isArray(data.characters)) {
      store.setCharacters(data.characters as CharacterSummary[])

      if (data.config && typeof data.config === 'object') {
        store.setSelectionConfig(data.config as SelectionConfig)
      }
    }
  })

  void sendNuiCallback('siku_multicharacter:nui:ready')
}
