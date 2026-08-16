<script setup lang="ts">
export interface GlassSegmentedOption {
  value: string
  label: string
}

defineProps<{
  label?: string
  modelValue: string
  options: GlassSegmentedOption[]
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>

<template>
  <div class="field">
    <span v-if="label" class="field__label">{{ label }}</span>
    <div class="field__track">
      <button
        v-for="option in options"
        :key="option.value"
        type="button"
        class="field__option"
        :class="{ 'field__option--active': option.value === modelValue }"
        @click="emit('update:modelValue', option.value)"
      >
        {{ option.label }}
      </button>
    </div>
  </div>
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
}

.field__track {
  display: flex;
  gap: 0.3rem;
  border-radius: 0.85rem;
  border: 1px solid rgba(233, 244, 253, 0.14);
  background: rgba(233, 244, 253, 0.04);
  padding: 0.28rem;
}

.field__option {
  flex: 1;
  border-radius: 0.6rem;
  padding: 0.5rem 0.6rem;
  font-size: 12.5px;
  font-weight: 300;
  letter-spacing: 0.08em;
  color: rgba(198, 224, 243, 0.55);
  transition:
    color 0.3s ease,
    background-color 0.3s ease,
    box-shadow 0.3s ease;
}

.field__option:hover {
  color: rgba(238, 246, 252, 0.8);
}

.field__option--active {
  background: rgba(240, 248, 255, 0.16);
  color: rgba(255, 255, 255, 0.99);
  text-shadow: 0 0 10px rgba(226, 240, 250, 0.4);
  box-shadow:
    inset 0 0 0 1px rgba(250, 253, 255, 0.24),
    inset 0 1px 0 rgba(255, 255, 255, 0.28),
    0 0 18px -5px rgba(226, 240, 250, 0.45);
}
</style>
