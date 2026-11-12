import type { AppearanceCategory, AppearanceControl } from './catalog'
import { catalogOffset, catalogPhoto, catalogShows, type Catalog } from '../types'

/** The control of a category shown as a grid of photos for this model, if the catalogue has them. */
export const photosControl = (
  category: AppearanceCategory,
  catalog: Catalog,
  model: string,
): AppearanceControl | undefined =>
  category.controls.find(
    (control) =>
      control.type === 'photos' && !!control.photos && catalogShows(catalog, control.photos, model),
  )

/** The controls that move next to the grid when the photos are shown: the swatches, and the variants once the chosen model has more than one. */
export const detailControls = (category: AppearanceCategory): AppearanceControl[] =>
  category.controls.filter(
    (control) => control.detail && (control.type !== 'variants' || (control.max ?? 1) > 1),
  )

/** The controls reset to their first value when the model of a photos control changes. */
export const variantControls = (category: AppearanceCategory): AppearanceControl[] =>
  category.controls.filter((control) => control.type === 'variants')

/** Whether the first slot of a photos control stands for wearing nothing, as it does for a prop. */
export const startsWithNone = (catalog: Catalog, control: AppearanceControl): boolean =>
  catalog.targets[control.photos ?? ''] === 'prop'

/** The photo of the item at a value of a photos control, counted as the editor counts (1 first), on a texture; undefined where the catalogue has none. */
export const photoAt = (
  catalog: Catalog,
  control: AppearanceControl,
  model: string,
  value: number,
  texture = 0,
): string | undefined => {
  const target = control.photos ?? ''

  return catalogPhoto(catalog, target, model, value - catalogOffset(catalog, target), texture)
}
