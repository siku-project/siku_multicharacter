import type { AppearanceCategory, AppearanceControl } from './catalog'
import { catalogShows, type Catalog } from '../types'

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

/** The controls that move next to the photo of the chosen item when the photos are shown. */
export const detailControls = (category: AppearanceCategory): AppearanceControl[] =>
  category.controls.filter((control) => control.detail)
