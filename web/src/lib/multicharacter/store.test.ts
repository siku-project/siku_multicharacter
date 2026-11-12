import { describe, expect, it } from 'vitest'
import { MOCK_CHARACTERS, MOCK_HERITAGE, MOCK_PEDS, MOCK_SELECTION_CONFIG } from './mock'
import { store } from './store.svelte'
import { catalogPhoto, catalogShows } from './types'

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

  it('keeps the catalogue the game describes, sliders otherwise', () => {
    expect(
      store.applyMessage({
        action: action('setCatalog'),
        catalog: {
          source: 'cdn',
          targets: { hair: 'component' },
          folders: { mp_m_freemode_01: 'male' },
          url: 'https://cdn',
          photos: { hair: { mp_m_freemode_01: { 3: ['x'] } } },
        },
      }),
    ).toBe(true)
    expect(store.catalog.source).toBe('cdn')
    expect(catalogShows(store.catalog, 'hair', 'mp_m_freemode_01')).toBe(true)
    expect(catalogShows(store.catalog, 'hair', 'mp_f_freemode_01')).toBe(false)
    expect(catalogPhoto(store.catalog, 'hair', 'mp_m_freemode_01', 3)).toBe(
      'https://cdn/media/x/hair_3_0.webp',
    )
    expect(catalogPhoto(store.catalog, 'hair', 'mp_m_freemode_01', 4)).toBeUndefined()

    store.applyMessage({
      action: action('setCatalog'),
      catalog: {
        source: 'files',
        targets: { hair: 'component', beard: 'overlay' },
        folders: { mp_f_freemode_01: 'female' },
        folder: 'images/catalog',
      },
    })
    expect(catalogPhoto(store.catalog, 'hair', 'mp_f_freemode_01', 12)).toBe(
      'images/catalog/hair/female/hair_12_0.webp',
    )
    expect(catalogPhoto(store.catalog, 'beard', 'mp_f_freemode_01', 7)).toBe(
      'images/catalog/beard/female/beard_7.webp',
    )
    expect(catalogShows(store.catalog, 'eyebrows', 'mp_f_freemode_01')).toBe(false)

    store.applyMessage({
      action: action('setCatalog'),
      catalog: { source: 'files', targets: ['hair'], folders: {}, folder: 'images/catalog' },
    })
    expect(store.catalog.source).toBe('none')

    store.applyMessage({ action: action('setCatalog'), catalog: { source: 'elsewhere' } })
    expect(store.catalog.source).toBe('none')
    expect(catalogShows(store.catalog, 'hair', 'mp_f_freemode_01')).toBe(false)
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
