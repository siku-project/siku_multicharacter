<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { resolveIcon } from '@/utils/icons'

const props = withDefaults(
  defineProps<{
    label?: string
    day: string
    month: string
    year: string
    placeholder?: string
    error?: string
  }>(),
  {
    label: '',
    placeholder: '',
    error: '',
  },
)

const emit = defineEmits<{
  update: [value: { day: string; month: string; year: string }]
  open: []
}>()

const digits = ref('')

const display = computed(() => {
  const value = digits.value
  if (value.length === 0) {
    return ''
  }
  let out = value.slice(0, 2)
  if (value.length >= 2) {
    out += '/'
  }
  if (value.length > 2) {
    out += value.slice(2, 4)
  }
  if (value.length >= 4) {
    out += '/'
  }
  if (value.length > 4) {
    out += value.slice(4, 8)
  }
  return out
})

const appendDigit = (digit: string): void => {
  const current = digits.value
  if (current.length >= 8) {
    return
  }
  if (current.length === 0 && Number(digit) > 3) {
    digits.value = `0${digit}`
    return
  }
  if (current.length === 2 && Number(digit) > 1) {
    digits.value = `${current}0${digit}`
    return
  }
  digits.value = current + digit
}

const handleKeydown = (event: KeyboardEvent): void => {
  if (event.key === 'Backspace' || event.key === 'Delete') {
    event.preventDefault()
    digits.value = digits.value.slice(0, -1)
    return
  }
  if (/^\d$/.test(event.key)) {
    event.preventDefault()
    appendDigit(event.key)
    return
  }
  if (event.key.length === 1 && !event.metaKey && !event.ctrlKey) {
    event.preventDefault()
  }
}

const handlePaste = (event: ClipboardEvent): void => {
  const text = event.clipboardData?.getData('text') ?? ''
  for (const char of text.replace(/\D/g, '')) {
    appendDigit(char)
  }
}

watch(digits, (value) => {
  emit('update', {
    day: value.slice(0, 2),
    month: value.slice(2, 4),
    year: value.slice(4, 8),
  })
})

watch(
  () => [props.day, props.month, props.year],
  () => {
    if (!props.day || !props.month || props.year.length !== 4) {
      return
    }
    const complete = props.day.padStart(2, '0') + props.month.padStart(2, '0') + props.year
    if (complete.length === 8 && complete !== digits.value) {
      digits.value = complete
    }
  },
  { immediate: true },
)
</script>

<template>
  <label class="field">
    <span v-if="label" class="field__label">{{ label }}</span>
    <span class="field__control">
      <input
        class="field__input"
        :class="{ 'field__input--invalid': error }"
        type="text"
        inputmode="numeric"
        :value="display"
        :placeholder="placeholder"
        :maxlength="10"
        spellcheck="false"
        autocomplete="off"
        @keydown="handleKeydown"
        @paste.prevent="handlePaste"
        @focus="emit('open')"
        @click="emit('open')"
      />
      <v-icon class="field__icon" size="16" :icon="resolveIcon('mdi-calendar-blank-outline')" />
    </span>
    <Transition name="field-error">
      <span v-if="error" class="field__error">{{ error }}</span>
    </Transition>
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

.field__input {
  width: 100%;
  border-radius: 0.85rem;
  border: 1px solid rgba(233, 244, 253, 0.14);
  background: rgba(233, 244, 253, 0.055);
  padding: 0.85rem 2.7rem 0.85rem 1.15rem;
  font-size: 14.5px;
  font-weight: 300;
  letter-spacing: 0.06em;
  font-variant-numeric: tabular-nums;
  color: rgba(250, 253, 255, 0.97);
  outline: none;
  cursor: text;
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

.field__icon {
  position: absolute;
  right: 0.95rem;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: rgba(198, 224, 243, 0.5);
  transition: color 0.3s ease;
}

.field:focus-within .field__icon {
  color: rgba(240, 248, 255, 0.85);
}

.field__input--invalid,
.field__input--invalid:hover,
.field__input--invalid:focus {
  border-color: rgba(244, 110, 122, 0.55);
  box-shadow: 0 0 20px -10px rgba(244, 110, 122, 0.7);
}

.field__error {
  font-size: 11.5px;
  font-weight: 300;
  letter-spacing: 0.03em;
  color: rgba(246, 158, 167, 0.9);
}

.field-error-enter-active,
.field-error-leave-active {
  transition:
    opacity 0.2s ease,
    transform 0.2s ease;
}

.field-error-enter-from,
.field-error-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}
</style>
