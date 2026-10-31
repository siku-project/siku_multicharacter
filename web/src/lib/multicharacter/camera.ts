import { game, type CameraControl } from './bridge'

const UI_ZONE_RATIO = 0.4
const HANDS_UP_CODE = 'KeyX'
const EDITABLE = new Set(['INPUT', 'TEXTAREA', 'SELECT'])

const isTyping = (target: EventTarget | null): boolean =>
  target instanceof HTMLElement && (EDITABLE.has(target.tagName) || target.isContentEditable)

const insideUi = (event: MouseEvent): boolean => event.clientX < window.innerWidth * UI_ZONE_RATIO

/**
 * Drives the free camera of the appearance editor from the part of the screen
 * the interface does not cover: left drag pans, right drag rotates, the wheel
 * zooms, X raises the arms. Returns the function that detaches everything.
 */
export const attachCameraControls = (active: () => boolean): (() => void) => {
  let held: CameraControl | null = null

  const down = (event: MouseEvent): void => {
    if (!active() || insideUi(event)) {
      return
    }

    if (event.button === 0 || event.button === 2) {
      held = event.button === 0 ? 'pan' : 'rotate'
      void game.cameraControlStart(held)
    }
  }

  const up = (event: MouseEvent): void => {
    if (!held || (event.button !== 0 && event.button !== 2)) {
      return
    }

    void game.cameraControlStop(held)
    held = null
  }

  const move = (event: MouseEvent): void => {
    if (held) {
      void game.cameraControlMove(held, event.movementX, event.movementY)
    }
  }

  const wheel = (event: WheelEvent): void => {
    if (!active() || insideUi(event)) {
      return
    }

    event.preventDefault()
    void game.cameraZoom(
      event.deltaY < 0,
      event.clientX / window.innerWidth,
      event.clientY / window.innerHeight,
    )
  }

  const contextMenu = (event: MouseEvent): void => {
    if (!insideUi(event)) {
      event.preventDefault()
    }
  }

  const keydown = (event: KeyboardEvent): void => {
    if (!active() || event.repeat || event.code !== HANDS_UP_CODE || isTyping(event.target)) {
      return
    }

    event.preventDefault()
    void game.toggleHandsUp()
  }

  document.addEventListener('mousedown', down)
  document.addEventListener('mouseup', up)
  document.addEventListener('mousemove', move)
  document.addEventListener('wheel', wheel, { passive: false })
  document.addEventListener('contextmenu', contextMenu)
  document.addEventListener('keydown', keydown)

  return () => {
    document.removeEventListener('mousedown', down)
    document.removeEventListener('mouseup', up)
    document.removeEventListener('mousemove', move)
    document.removeEventListener('wheel', wheel)
    document.removeEventListener('contextmenu', contextMenu)
    document.removeEventListener('keydown', keydown)
  }
}
