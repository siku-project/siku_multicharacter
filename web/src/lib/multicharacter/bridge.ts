import { sendNuiCallback, sendNuiEvent } from '@/lib/nui'
import type { IdentityDraft } from './identity'
import type { HeritagePayload } from './appearance/payload'

export interface AppearancePayload {
  pedModel: string
  appearance: {
    heritage: HeritagePayload
    physical: ReturnType<typeof import('./appearance/payload').buildPhysicalPayload>
    clothing: Record<string, { model: number; variant: number }>
    accessories: Record<string, { model: number; variant: number }>
    tattoos: Record<string, number>
  }
}

export type CameraControl = 'pan' | 'rotate'

/** Every call the interface makes to the game, by name. */
export const game = {
  ready: () => sendNuiCallback('ready'),
  slotChanged: (slot: number) => sendNuiEvent('slotChanged', { slot }),
  playCharacter: (id: number) => sendNuiEvent('playCharacter', { id }),
  startCreation: (slot: number) => sendNuiEvent('startCreation', { slot }),
  deleteCharacter: (id: number) => sendNuiEvent('deleteCharacter', { id }),
  identitySubmitted: (identity: IdentityDraft) => sendNuiEvent('identitySubmitted', identity),
  pedSelected: (model: string) => sendNuiEvent('pedSelected', { model }),
  heritageChanged: (payload: HeritagePayload) => sendNuiEvent('heritageChanged', payload),
  physicalChanged: (payload: unknown) => sendNuiEvent('physicalChanged', payload),
  clothingChanged: (payload: unknown) => sendNuiEvent('clothingChanged', payload),
  accessoriesChanged: (payload: unknown) => sendNuiEvent('accessoriesChanged', payload),
  tattoosChanged: (payload: unknown) => sendNuiEvent('tattoosChanged', payload),
  appearanceValidated: (payload: AppearancePayload) => sendNuiEvent('appearanceValidated', payload),
  cameraControlStart: (type: CameraControl) => sendNuiEvent('cameraControlStart', { type }),
  cameraControlStop: (type: CameraControl) => sendNuiEvent('cameraControlStop', { type }),
  cameraControlMove: (type: CameraControl, movementX: number, movementY: number) =>
    sendNuiEvent('cameraControlMove', { type, movementX, movementY }),
  cameraZoom: (zoomIn: boolean, mouseX: number, mouseY: number) =>
    sendNuiEvent('cameraZoom', { zoomIn, mouseX, mouseY }),
  toggleHandsUp: () => sendNuiEvent('toggleHandsUp'),
}
