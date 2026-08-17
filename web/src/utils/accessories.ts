import { controlKey } from '@/config/appearance'

export const ACCESSORY_CATEGORIES = [
  'mask',
  'backpack',
  'hat',
  'glasses',
  'earrings',
  'watch',
  'bracelet',
  'neckwear',
] as const

export type AccessoryCategory = (typeof ACCESSORY_CATEGORIES)[number]

export const buildAccessoryPayload = (
  draft: Record<string, number>,
): Record<AccessoryCategory, { model: number; variant: number }> => {
  const payload = {} as Record<AccessoryCategory, { model: number; variant: number }>

  for (const category of ACCESSORY_CATEGORIES) {
    payload[category] = {
      model: draft[controlKey('accessories', category, 'model')] ?? 1,
      variant: draft[controlKey('accessories', category, 'variant')] ?? 1,
    }
  }

  return payload
}
