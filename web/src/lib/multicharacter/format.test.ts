import { describe, expect, it } from 'vitest'
import { characterInSlot, daysSince, formatPlaytime, fullName, regionName } from './format'
import { MOCK_CHARACTERS } from './mock'

describe('format', () => {
  it('formats playtime in minutes, hours and whole hours', () => {
    expect(formatPlaytime(45)).toBe('45 min')
    expect(formatPlaytime(125)).toBe('2 h 05')
    expect(formatPlaytime(6_000)).toBe('100 h')
  })

  it('counts whole days since a timestamp', () => {
    const now = Date.UTC(2026, 9, 31, 12)

    expect(daysSince(now - 3_600_000, now)).toBe(0)
    expect(daysSince(now - 2 * 86_400_000 - 1, now)).toBe(2)
    expect(daysSince(now + 10, now)).toBe(0)
  })

  it('names a region in the given language', () => {
    expect(regionName('FR', 'en')).toBe('France')
    expect(regionName('XX', 'en')).toBe('XX')
  })

  it('finds a character by slot and prints its full name', () => {
    const character = characterInSlot(MOCK_CHARACTERS, 2)

    expect(character?.id).toBe(1187)
    expect(fullName(character!)).toBe('Marcus Delacroix')
    expect(characterInSlot(MOCK_CHARACTERS, 4)).toBeUndefined()
  })
})
