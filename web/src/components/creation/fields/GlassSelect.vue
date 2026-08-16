<script setup lang="ts">
import { resolveIcon } from '@/utils/icons'

export interface GlassSelectOption {
  value: string
  label: string
}

withDefaults(
  defineProps<{
    label?: string
    modelValue: string
    options: GlassSelectOption[]
    placeholder?: string
  }>(),
  {
    label: undefined,
    placeholder: '',
  },
)

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>

<template>
  <label class="field">
    <span v-if="label" class="field__label">{{ label }}</span>
    <span class="field__control">
      <select
        class="field__select"
        :class="{ 'field__select--empty': !modelValue }"
        :value="modelValue"
        @change="emit('update:modelValue', ($event.target as HTMLSelectElement).value)"
      >
        <option v-if="placeholder" value="" disabled>{{ placeholder }}</option>
        <option v-for="option in options" :key="option.value" :value="option.value">
          {{ option.label }}
        </option>
      </select>
      <v-icon class="field__chevron" size="16" :icon="resolveIcon('mdi-chevron-down')" />
    </span>
  </label>
</template>

<style scoped>
.field {
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
  min-width: 0;
}

.field__label {
  font-size: 10.5px;
  font-weight: 400;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.6);
  transition: color 0.3s ease;
}

.field:focus-within .field__label {
  color: rgba(240, 248, 255, 0.88);
}

.field__control {
  position: relative;
  display: block;
}

.field__select {
  width: 100%;
  appearance: none;
  border-radius: 0.85rem;
  border: 1px solid rgba(233, 244, 253, 0.14);
  background: rgba(233, 244, 253, 0.055);
  padding: 0.72rem 2.6rem 0.72rem 1rem;
  font-size: 14px;
  font-weight: 300;
  letter-spacing: 0.03em;
  color: rgba(250, 253, 255, 0.97);
  outline: none;
  cursor: pointer;
  transition:
    border-color 0.3s ease,
    background-color 0.3s ease,
    box-shadow 0.3s ease;
}

.field__select--empty {
  color: rgba(198, 224, 243, 0.32);
}

.field__select option {
  background: #0b1a2e;
  color: rgba(244, 250, 255, 0.95);
}

.field__select:hover {
  border-color: rgba(233, 244, 253, 0.26);
  background: rgba(233, 244, 253, 0.07);
}

.field__select:focus {
  border-color: rgba(244, 250, 255, 0.5);
  background: rgba(236, 245, 252, 0.09);
  box-shadow:
    inset 0 1px 0 rgba(250, 253, 255, 0.16),
    0 0 22px -8px rgba(226, 240, 250, 0.4);
}

.field__chevron {
  position: absolute;
  right: 0.9rem;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: rgba(198, 224, 243, 0.55);
}
</style>
