import { onBeforeUnmount, onMounted, type Ref } from 'vue'
import { sendNuiCallback } from '@/utils/nui'

const HANDS_UP_CODE = 'KeyX'
const EDITABLE_TAGS = new Set(['INPUT', 'TEXTAREA', 'SELECT'])

const isTyping = (target: EventTarget | null): boolean => {
  if (!(target instanceof HTMLElement)) {
    return false
  }

  return EDITABLE_TAGS.has(target.tagName) || target.isContentEditable
}

export function useHandsUpKey(active: Ref<boolean>): void {
  const handleKeydown = (event: KeyboardEvent): void => {
    if (!active.value || event.repeat || event.code !== HANDS_UP_CODE || isTyping(event.target)) {
      return
    }

    event.preventDefault()
    void sendNuiCallback('siku_multicharacter:nui:toggleHandsUp')
  }

  onMounted(() => {
    document.addEventListener('keydown', handleKeydown)
  })

  onBeforeUnmount(() => {
    document.removeEventListener('keydown', handleKeydown)
  })
}
