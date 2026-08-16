<script setup lang="ts">
withDefaults(
  defineProps<{
    label?: string
    modelValue: string
    placeholder?: string
    type?: string
    maxlength?: number
  }>(),
  {
    label: '',
    placeholder: '',
    type: 'text',
    maxlength: 40,
  },
)

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>

<template>
  <label class="field">
    <span v-if="label" class="field__label">{{ label }}</span>
    <input
      class="field__input"
      :value="modelValue"
      :type="type"
      :placeholder="placeholder"
      :maxlength="maxlength"
      spellcheck="false"
      @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    />
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

.field__input {
  width: 100%;
  border-radius: 0.85rem;
  border: 1px solid rgba(233, 244, 253, 0.14);
  background: rgba(233, 244, 253, 0.055);
  padding: 0.85rem 1.15rem;
  font-size: 14.5px;
  font-weight: 300;
  letter-spacing: 0.03em;
  color: rgba(250, 253, 255, 0.97);
  outline: none;
  transition:
    border-color 0.3s ease,
    background-color 0.3s ease,
    box-shadow 0.3s ease;
}

.field__input::placeholder {
  color: rgba(198, 224, 243, 0.32);
}

.field__input:hover {
  border-color: rgba(233, 244, 253, 0.26);
  background: rgba(233, 244, 253, 0.07);
}

.field__input:focus {
  border-color: rgba(244, 250, 255, 0.5);
  background: rgba(236, 245, 252, 0.09);
  box-shadow:
    inset 0 1px 0 rgba(250, 253, 255, 0.16),
    0 0 22px -8px rgba(226, 240, 250, 0.4);
}

.field__input::-webkit-outer-spin-button,
.field__input::-webkit-inner-spin-button {
  appearance: none;
  margin: 0;
}

.field__input[type='number'] {
  appearance: textfield;
  -moz-appearance: textfield;
}
</style>
