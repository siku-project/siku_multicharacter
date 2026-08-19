import { controlKey } from '@/config/appearance'

export const TATTOO_ZONES = [
  'hair',
  'head',
  'neck',
  'torso',
  'back',
  'leftArm',
  'rightArm',
  'leftLeg',
  'rightLeg',
] as const

export type TattooZone = (typeof TATTOO_ZONES)[number]

export const buildTattooPayload = (draft: Record<string, number>): Record<TattooZone, number> => {
  const payload = {} as Record<TattooZone, number>

  for (const zone of TATTOO_ZONES) {
    payload[zone] = draft[controlKey('tattoos', zone, 'tattoo')] ?? 1
  }

  return payload
}
