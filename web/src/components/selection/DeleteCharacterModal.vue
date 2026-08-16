<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import IceModal from '@/components/ui/IceModal.vue'
import IceButton from '@/components/ui/IceButton.vue'
import { resolveIcon } from '@/utils/icons'

defineProps<{
  open: boolean
  characterName: string
}>()

const emit = defineEmits<{
  cancel: []
  confirm: []
}>()

const { t } = useI18n()
</script>

<template>
  <IceModal :open="open" @close="emit('cancel')">
    <div class="flex flex-col items-center gap-6 px-9 pb-8 pt-9">
      <span class="modal__badge">
        <v-icon size="22" :icon="resolveIcon('mdi-trash-can-outline')" />
      </span>

      <div class="flex flex-col items-center gap-2.5">
        <h2 class="modal__title">{{ t('selection.deleteTitle') }}</h2>
        <p class="modal__message">
          {{ t('selection.deleteWarning', { name: characterName }) }}
        </p>
      </div>

      <div class="modal__divider h-px w-full"></div>

      <div class="flex w-full items-center gap-3">
        <IceButton :label="t('selection.cancel')" variant="ghost" block @click="emit('cancel')" />
        <IceButton
          :label="t('selection.deleteConfirm')"
          variant="alert"
          block
          @click="emit('confirm')"
        />
      </div>
    </div>
  </IceModal>
</template>

<style scoped>
.modal__badge {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 3.8rem;
  height: 3.8rem;
  border-radius: 9999px;
  border: 1.5px solid rgba(244, 110, 122, 0.38);
  color: rgba(246, 158, 167, 0.9);
  background: radial-gradient(120% 120% at 50% 0%, rgba(244, 110, 122, 0.12) 0%, transparent 70%);
  box-shadow:
    0 0 26px -8px rgba(244, 110, 122, 0.35),
    inset 0 1px 0 rgba(252, 234, 237, 0.14);
}

.modal__title {
  font-size: 18px;
  font-weight: 300;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  text-align: center;
  color: rgba(250, 253, 255, 0.98);
}

.modal__message {
  max-width: 330px;
  font-size: 13.5px;
  font-weight: 300;
  line-height: 1.6;
  letter-spacing: 0.02em;
  text-align: center;
  color: rgba(198, 224, 243, 0.62);
}

.modal__divider {
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    transparent,
    rgba(214, 236, 252, 0.35) 25%,
    rgba(214, 236, 252, 0.35) 75%,
    transparent
  );
  box-shadow: 0 0 8px rgba(214, 236, 252, 0.2);
}
</style>
