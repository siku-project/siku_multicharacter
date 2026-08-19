<script setup lang="ts">
import { onBeforeUnmount, onMounted } from 'vue'
import IcePanel from './IcePanel.vue'

withDefaults(
  defineProps<{
    open: boolean
    variant?: 'glass' | 'minimal' | 'dark'
  }>(),
  {
    variant: 'glass',
  },
)

const emit = defineEmits<{
  close: []
}>()

const handleKeydown = (event: KeyboardEvent): void => {
  if (event.key === 'Escape') {
    emit('close')
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="open" class="overlay" :class="`overlay--${variant}`" @click.self="emit('close')">
        <IcePanel v-if="variant === 'glass'" variant="primary" class="panel">
          <slot />
        </IcePanel>
        <div v-else class="panel panel--flat">
          <slot />
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  z-index: 60;
  display: flex;
  align-items: center;
  justify-content: center;
}

.overlay--glass {
  background: radial-gradient(
    90% 90% at 50% 45%,
    rgba(6, 15, 29, 0.35) 0%,
    rgba(4, 11, 22, 0.68) 100%
  );
}

.overlay--minimal {
  background: linear-gradient(180deg, rgba(8, 15, 28, 0.86) 0%, rgba(6, 12, 22, 0.92) 100%);
}

.overlay--dark {
  background: rgba(5, 6, 8, 0.86);
}

.panel.panel {
  --ice-top: 0.85;
  --ice-bottom: 0.94;
  --ice-glow: 0.13;
  width: min(460px, 90vw);
}

.panel--flat {
  position: relative;
  overflow: hidden;
}

.overlay--minimal .panel--flat {
  border-radius: 20px;
  border: 1px solid rgba(160, 200, 235, 0.16);
  background:
    var(--ice-noise),
    radial-gradient(120% 90% at 50% -10%, rgba(120, 170, 220, 0.14) 0%, transparent 60%),
    linear-gradient(180deg, rgba(19, 32, 51, 0.97) 0%, rgba(11, 21, 36, 0.98) 100%);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.1),
    0 40px 90px -40px rgba(4, 10, 22, 0.9);
}

.overlay--minimal .panel--flat::before {
  content: '';
  position: absolute;
  inset-inline: 22%;
  top: -1px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(226, 240, 255, 0.55), transparent);
}

.overlay--dark .panel--flat {
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(12, 13, 16, 0.98);
  box-shadow: 0 40px 90px -40px rgba(0, 0, 0, 0.95);
}

.modal-enter-active {
  transition: opacity 0.32s ease;
}

.modal-leave-active {
  transition: opacity 0.22s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .panel {
  transition: transform 0.44s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.modal-leave-active .panel {
  transition: transform 0.22s ease;
}

.modal-enter-from .panel {
  transform: translateY(16px) scale(0.95);
}

.modal-leave-to .panel {
  transform: translateY(8px) scale(0.97);
}
</style>
