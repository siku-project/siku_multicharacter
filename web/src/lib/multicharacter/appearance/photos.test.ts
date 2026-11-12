import { describe, expect, it } from 'vitest'
import { stepById, type AppearanceCategory } from './catalog'
import { detailControls, photoAt, photosControl, startsWithNone, variantControls } from './photos'
import { catalogPhoto, type Catalog } from '../types'

const CDN: Catalog = {
  source: 'cdn',
  targets: { hair: 'component', top: 'component', hat: 'prop', beard: 'overlay' },
  folders: { mp_m_freemode_01: 'male' },
  url: 'https://cdn',
  photos: {
    top: { mp_m_freemode_01: { 12: ['a', '', 'c'] } },
    hat: { mp_m_freemode_01: { 0: ['h'] } },
    beard: { mp_m_freemode_01: { 7: ['b'] } },
  },
}

const FILES: Catalog = {
  source: 'files',
  targets: { top: 'component', hat: 'prop' },
  folders: { mp_f_freemode_01: 'female' },
  folder: 'images/catalog',
}

const category = (step: string, id: string): AppearanceCategory => {
  const found = stepById(step)?.categories?.find((entry) => entry.id === id)

  if (!found) {
    throw new Error(`${step}/${id} missing`)
  }

  return found
}

describe('catalogue photos', () => {
  it('names the photos the way siku_studio files them', () => {
    expect(catalogPhoto(CDN, 'top', 'mp_m_freemode_01', 12)).toBe(
      'https://cdn/media/a/top_12_0.webp',
    )
    expect(catalogPhoto(CDN, 'top', 'mp_m_freemode_01', 12, 2)).toBe(
      'https://cdn/media/c/top_12_2.webp',
    )
    expect(catalogPhoto(CDN, 'top', 'mp_m_freemode_01', 12, 1)).toBeUndefined()
    expect(catalogPhoto(CDN, 'beard', 'mp_m_freemode_01', 7)).toBe(
      'https://cdn/media/b/beard_7.webp',
    )
    expect(catalogPhoto(FILES, 'top', 'mp_f_freemode_01', 3, 1)).toBe(
      'images/catalog/top/female/top_3_1.webp',
    )
    expect(catalogPhoto(FILES, 'hat', 'mp_f_freemode_01', -1)).toBeUndefined()
  })

  it('counts the models from 1, and from 2 for a prop whose first slot is none', () => {
    const jacket = category('clothing', 'jacket')
    const hat = category('accessories', 'hat')
    const model = photosControl(jacket, CDN, 'mp_m_freemode_01')
    const prop = photosControl(hat, CDN, 'mp_m_freemode_01')

    expect(model?.id).toBe('model')
    expect(photoAt(CDN, model!, 'mp_m_freemode_01', 13)).toBe('https://cdn/media/a/top_12_0.webp')
    expect(photoAt(CDN, model!, 'mp_m_freemode_01', 13, 2)).toBe(
      'https://cdn/media/c/top_12_2.webp',
    )
    expect(startsWithNone(CDN, model!)).toBe(false)
    expect(startsWithNone(CDN, prop!)).toBe(true)
    expect(photoAt(CDN, prop!, 'mp_m_freemode_01', 1)).toBeUndefined()
    expect(photoAt(CDN, prop!, 'mp_m_freemode_01', 2)).toBe('https://cdn/media/h/hat_0_0.webp')
  })

  it('shows the variants beside the grid only when the model has more than one', () => {
    const jacket = category('clothing', 'jacket')
    const single = {
      ...jacket,
      controls: jacket.controls.map((control) =>
        control.id === 'variant' ? { ...control, max: 1 } : control,
      ),
    }

    expect(detailControls(jacket).map((control) => control.id)).toEqual(['variant'])
    expect(detailControls(single)).toEqual([])
    expect(variantControls(jacket).map((control) => control.id)).toEqual(['variant'])
    expect(detailControls(category('physical', 'hair')).map((control) => control.id)).toEqual([
      'color',
      'highlights',
    ])
  })
})
