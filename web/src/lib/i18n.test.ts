import { describe, expect, it } from 'vitest'
import { applyTranslations, m, tr } from './i18n.svelte'
import { locale } from './locale.svelte'

describe('i18n', () => {
  it('serves the compiled message when the game sent nothing', () => {
    expect(m.selection_cancel()).toBe('Annuler')
  })

  it('prefers the string the game pushed for the running language', () => {
    applyTranslations(locale.current, { selection_cancel: 'Abandonner' })

    expect(m.selection_cancel()).toBe('Abandonner')
  })

  it('fills placeholders in a pushed string', () => {
    applyTranslations(locale.current, { selection_age: '{age} printemps' })

    expect(m.selection_age({ age: 31 })).toBe('31 printemps')
  })

  it('reads a message by runtime key', () => {
    expect(tr('appearance_catHair')).toBe(m.appearance_catHair())
  })

  it('switches the language along with the strings', () => {
    applyTranslations('en', { selection_cancel: 'Leave' })

    expect(locale.current).toBe('en')
    expect(m.selection_cancel()).toBe('Leave')
    expect(m.selection_tagline()).toBe('Choose your story')
  })
})
