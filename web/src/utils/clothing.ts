import { controlKey } from '@/config/appearance'

export const CLOTHING_CATEGORIES = ['jacket', 'tshirt', 'armsGloves', 'pants', 'shoes'] as const

export type ClothingCategory = (typeof CLOTHING_CATEGORIES)[number]

export const buildClothingPayload = (
  draft: Record<string, number>,
): Record<ClothingCategory, { model: number; variant: number }> => {
  const payload = {} as Record<ClothingCategory, { model: number; variant: number }>

  for (const category of CLOTHING_CATEGORIES) {
    payload[category] = {
      model: draft[controlKey('clothing', category, 'model')] ?? 1,
      variant: draft[controlKey('clothing', category, 'variant')] ?? 1,
    }
  }

  return payload
}
