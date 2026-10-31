import { describe, expect, it } from 'vitest'
import { MOCK_CHARACTERS, MOCK_HERITAGE, MOCK_PEDS, MOCK_SELECTION_CONFIG } from './mock'
import { store } from './store.svelte'

const action = (name: string) => `siku_multicharacter:nui:${name}`

describe('store', () => {
  it('ignores messages that are not ours', () => {
    expect(store.applyMessage({ action: 'other:thing' })).toBe(false)
    expect(store.applyMessage(null)).toBe(false)
  })

  it('switches screens only to known ones', () => {
    expect(store.applyMessage({ action: action('setScreen'), screen: 'selection' })).toBe(true)
    expect(store.screen).toBe('selection')
    store.applyMessage({ action: action('setScreen'), screen: 'garage' })
    expect(store.screen).toBe('selection')
    store.applyMessage({ action: action('hide') })
    expect(store.screen).toBe('hidden')
  })

  it('stores the roster with its configuration', () => {
    store.applyMessage({
      action: action('setCharacters'),
      characters: MOCK_CHARACTERS,
      config: MOCK_SELECTION_CONFIG,
    })
    expect(store.characters).toHaveLength(3)
    expect(store.selectionConfig.slots).toBe(5)
  })

  it('validates the catalogue payloads and merges limits', () => {
    store.applyMessage({ action: action('setPeds'), peds: { basics: [] } })
    expect(store.pedsConfig.authorizeAll).toBe(false)
    store.applyMessage({ action: action('setPeds'), peds: MOCK_PEDS })
    expect(store.pedsConfig.authorizeAll).toBe(true)
    store.applyMessage({ action: action('setHeritage'), heritage: MOCK_HERITAGE })
    expect(store.heritageConfig.mothers[0]?.id).toBe(21)
    store.applyMessage({ action: action('setLimits'), limits: { hairStyles: 38 } })
    store.applyMessage({ action: action('setLimits'), limits: { beard: 29 } })
    expect(store.appearanceLimits).toEqual({ hairStyles: 38, beard: 29 })
  })
})
