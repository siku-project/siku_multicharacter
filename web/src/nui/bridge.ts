import {
  MULTICHARACTER_SCREENS,
  useMulticharacterStore,
  type MulticharacterScreen,
} from '@/stores/multicharacter'
import { applyLocale, isLocalePayload } from '@/utils/locale'
import { sendNuiCallback } from '@/utils/nui'

interface NuiMessage {
  action?: unknown
  screen?: unknown
  locale?: unknown
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
    }
  })

  void sendNuiCallback('siku_multicharacter:nui:ready')
}
