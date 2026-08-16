<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ActionButton from './ActionButton.vue'

defineProps<{
  hasCharacter: boolean
  allowDeletion: boolean
}>()

const emit = defineEmits<{
  join: []
  remove: []
  info: []
  create: []
}>()

const { t } = useI18n()
</script>

<template>
  <Transition name="actions" mode="out-in" :duration="{ enter: 650, leave: 260 }">
    <div v-if="hasCharacter" key="filled" class="flex items-center gap-4">
      <ActionButton
        :label="t('selection.joinCity')"
        icon="mdi-login-variant"
        variant="primary"
        @click="emit('join')"
      />
      <ActionButton
        v-if="allowDeletion"
        :label="t('selection.delete')"
        icon="mdi-trash-can-outline"
        variant="danger"
        @click="emit('remove')"
      />
      <ActionButton
        :label="t('selection.characterInfo')"
        icon="mdi-information-outline"
        variant="neutral"
        @click="emit('info')"
      />
    </div>

    <div v-else key="empty" class="flex items-center gap-4">
      <ActionButton
        :label="t('selection.create')"
        icon="mdi-account-plus-outline"
        variant="primary"
        @click="emit('create')"
      />
    </div>
  </Transition>
</template>

<style scoped>
.actions-enter-active,
.actions-leave-active {
  transition: opacity 0.05s linear;
}

.actions-enter-active .pill {
  transition:
    opacity 0.34s ease,
    transform 0.34s ease;
}

.actions-enter-active .pill:nth-child(2) {
  transition-delay: 0.08s;
}

.actions-enter-active .pill:nth-child(3) {
  transition-delay: 0.16s;
}

.actions-enter-from .pill {
  opacity: 0;
  transform: translateY(-12px);
}

.actions-leave-active .pill {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}

.actions-leave-active .pill:nth-child(2) {
  transition-delay: 0.05s;
}

.actions-leave-active .pill:nth-child(3) {
  transition-delay: 0.1s;
}

.actions-leave-to .pill {
  opacity: 0;
  transform: translateY(-10px);
}
</style>
