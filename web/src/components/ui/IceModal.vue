<script setup lang="ts">
import { onBeforeUnmount, onMounted } from 'vue'
import IcePanel from './IcePanel.vue'

defineProps<{
  open: boolean
}>()

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
      <div v-if="open" class="overlay" @click.self="emit('close')">
        <IcePanel variant="primary" class="panel">
          <slot />
        </IcePanel>
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
  background: radial-gradient(
    90% 90% at 50% 45%,
    rgba(6, 15, 29, 0.35) 0%,
    rgba(4, 11, 22, 0.68) 100%
  );
}

.panel.panel {
  --ice-top: 0.85;
  --ice-bottom: 0.94;
  --ice-glow: 0.13;
  width: min(460px, 90vw);
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
