<script setup lang="ts">
import { resolveIcon } from '@/utils/icons'

withDefaults(
  defineProps<{
    label: string
    icon?: string
    variant?: 'primary' | 'ghost' | 'danger' | 'alert'
    block?: boolean
    disabled?: boolean
  }>(),
  {
    icon: undefined,
    variant: 'primary',
    block: false,
    disabled: false,
  },
)

const emit = defineEmits<{
  click: []
}>()
</script>

<template>
  <button
    type="button"
    class="btn"
    :class="[`btn--${variant}`, { 'btn--block': block, 'btn--disabled': disabled }]"
    :disabled="disabled"
    @click="emit('click')"
  >
    <v-icon v-if="icon" size="15" :icon="resolveIcon(icon)" />
    <span>{{ label }}</span>
  </button>
</template>

<style scoped>
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  border-radius: 0.9rem;
  border: 1px solid transparent;
  padding: 0.72rem 1.4rem;
  font-size: 11px;
  font-weight: 300;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  transition:
    border-color 0.3s ease,
    background-color 0.3s ease,
    box-shadow 0.3s ease,
    color 0.3s ease,
    transform 0.3s ease;
}

.btn--block {
  width: 100%;
}

.btn--disabled {
  opacity: 0.38;
  pointer-events: none;
}

.btn--primary {
  border-color: rgba(198, 224, 243, 0.22);
  background: linear-gradient(180deg, rgba(198, 224, 243, 0.1) 0%, rgba(198, 224, 243, 0.03) 100%);
  color: rgba(242, 248, 253, 0.94);
  box-shadow: inset 0 1px 0 rgba(233, 244, 253, 0.14);
}

.btn--primary:hover {
  border-color: rgba(240, 248, 255, 0.52);
  background: linear-gradient(180deg, rgba(226, 240, 250, 0.18) 0%, rgba(198, 224, 243, 0.06) 100%);
  color: rgba(255, 255, 255, 1);
  box-shadow:
    inset 0 1px 0 rgba(250, 253, 255, 0.32),
    0 0 26px -8px rgba(226, 240, 250, 0.45);
  transform: translateY(-1px);
}

.btn--primary:active {
  transition-duration: 0.08s;
  border-color: rgba(250, 253, 255, 0.72);
  background: linear-gradient(180deg, rgba(240, 248, 255, 0.26) 0%, rgba(214, 236, 252, 0.1) 100%);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.4),
    0 0 30px -6px rgba(240, 248, 255, 0.55);
  transform: translateY(0);
}

.btn--ghost {
  border-color: rgba(233, 244, 253, 0.08);
  background: rgba(233, 244, 253, 0.02);
  color: rgba(198, 224, 243, 0.55);
}

.btn--ghost:hover {
  border-color: rgba(233, 244, 253, 0.18);
  color: rgba(226, 240, 250, 0.85);
  background: rgba(233, 244, 253, 0.045);
}

.btn--alert {
  border-color: rgba(244, 110, 122, 0.4);
  background: linear-gradient(180deg, rgba(244, 110, 122, 0.16) 0%, rgba(244, 110, 122, 0.05) 100%);
  color: rgba(252, 234, 237, 0.96);
  box-shadow: inset 0 1px 0 rgba(252, 234, 237, 0.14);
}

.btn--alert:hover {
  border-color: rgba(244, 130, 141, 0.6);
  background: linear-gradient(180deg, rgba(244, 110, 122, 0.22) 0%, rgba(244, 110, 122, 0.08) 100%);
  box-shadow:
    inset 0 1px 0 rgba(252, 234, 237, 0.2),
    0 0 26px -8px rgba(244, 110, 122, 0.35);
  transform: translateY(-1px);
}

.btn--danger {
  border-color: transparent;
  background: transparent;
  color: rgba(244, 110, 122, 0.5);
}

.btn--danger:hover {
  border-color: rgba(244, 110, 122, 0.22);
  background: rgba(244, 110, 122, 0.05);
  color: rgba(244, 138, 148, 0.85);
}
</style>
