<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import IceModal from '@/components/ui/IceModal.vue'
import IceButton from '@/components/ui/IceButton.vue'
import { resolveIcon } from '@/utils/icons'

withDefaults(
  defineProps<{
    open: boolean
    characterName: string
    variant?: 'glass' | 'minimal' | 'dark'
  }>(),
  {
    variant: 'glass',
  },
)

const emit = defineEmits<{
  cancel: []
  confirm: []
}>()

const { t } = useI18n()
</script>

<template>
  <IceModal :open="open" :variant="variant" @close="emit('cancel')">
    <div class="flex flex-col items-center gap-6 px-9 pb-8 pt-9" :class="`modal--${variant}`">
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

      <div class="modal__actions flex w-full items-center gap-3">
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

/* ── minimal ───────────────────────────────── */

.modal--minimal .modal__title {
  font-size: 17px;
  font-weight: 300;
  letter-spacing: 0.1em;
}

.modal--minimal .modal__message {
  color: rgba(170, 200, 228, 0.6);
}

.modal--minimal .modal__divider {
  background: linear-gradient(
    90deg,
    transparent,
    rgba(160, 200, 235, 0.18) 18%,
    rgba(160, 200, 235, 0.18) 82%,
    transparent
  );
  box-shadow: none;
}

.modal--minimal .modal__badge {
  border-width: 1px;
  box-shadow: none;
}

.modal--minimal .modal__actions :deep(.btn) {
  border-radius: 11px;
  font-size: 12.2px;
  font-weight: 500;
  letter-spacing: 0.16em;
  padding: 12px 24px;
}

.modal--minimal .modal__actions :deep(.btn--ghost) {
  border-color: rgba(160, 200, 235, 0.16);
  background: rgba(16, 30, 50, 0.5);
  color: rgba(196, 220, 242, 0.7);
}

.modal--minimal .modal__actions :deep(.btn--ghost:hover) {
  border-color: rgba(200, 228, 255, 0.3);
  color: rgba(236, 246, 255, 0.92);
}

/* ── dark ──────────────────────────────────── */

.modal--dark .modal__badge {
  width: 3.2rem;
  height: 3.2rem;
  border-radius: 12px;
  border: 1px solid rgba(248, 113, 113, 0.35);
  background: rgba(248, 113, 113, 0.1);
  color: rgba(252, 165, 165, 0.9);
  box-shadow: none;
}

.modal--dark .modal__title {
  font-size: 19px;
  font-weight: 600;
  letter-spacing: -0.015em;
  text-transform: none;
  color: rgba(255, 255, 255, 0.97);
}

.modal--dark .modal__message {
  font-size: 13px;
  font-weight: 400;
  letter-spacing: 0;
  color: rgba(255, 255, 255, 0.44);
}

.modal--dark .modal__divider {
  background: rgba(255, 255, 255, 0.06);
  box-shadow: none;
}

.modal--dark .modal__actions :deep(.btn) {
  border-radius: 9px;
  padding: 11px 26px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.12em;
}

.modal--dark .modal__actions :deep(.btn--ghost) {
  border-color: rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  color: rgba(255, 255, 255, 0.45);
}

.modal--dark .modal__actions :deep(.btn--ghost:hover) {
  border-color: rgba(255, 255, 255, 0.16);
  background: rgba(255, 255, 255, 0.05);
  color: rgba(255, 255, 255, 0.82);
}

.modal--dark .modal__actions :deep(.btn--alert) {
  border-color: rgba(248, 113, 113, 0.45);
  background: rgba(248, 113, 113, 0.14);
  color: rgba(252, 165, 165, 0.95);
  box-shadow: none;
}

.modal--dark .modal__actions :deep(.btn--alert:hover) {
  border-color: rgba(248, 113, 113, 0.65);
  background: rgba(248, 113, 113, 0.2);
  color: rgba(254, 202, 202, 1);
  box-shadow: none;
  transform: none;
}
</style>
