<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { resolveIcon } from '@/utils/icons'
import { getCountryOptions } from '@/utils/countries'
import GlassCalendar from '@/components/creation/fields/GlassCalendar.vue'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { sendNuiCallback } from '@/utils/nui'
import {
  HEIGHT_MAX,
  HEIGHT_MIN,
  countFilledIdentityFields,
  createIdentityDraft,
  isIdentityDraftValid,
  validateIdentity,
} from '@/utils/identity'
import type { IdentityField } from '@/utils/identity'

const { t, locale } = useI18n()

const store = useMulticharacterStore()
const draft = reactive(createIdentityDraft())

const handleSubmit = (): void => {
  if (!isIdentityDraftValid(draft)) {
    return
  }

  const payload = { ...draft }

  store.setIdentity(payload)
  void sendNuiCallback('siku_multicharacter:nui:identitySubmitted', payload)
}

const nationalityOptions = computed(() => getCountryOptions(locale.value))
const isValid = computed(() => isIdentityDraftValid(draft))
const filled = computed(() => countFilledIdentityFields(draft))
const errors = computed(() => validateIdentity(draft))

const errorText = (field: IdentityField): string => {
  const error = errors.value[field]
  return error ? t(error.key, error.params ?? {}) : ''
}

const heroName = computed(() => {
  const name = `${draft.firstName} ${draft.lastName}`.trim()
  return name.length > 0 ? name : t('creation.previewEmpty')
})

const birthDisplay = computed(() => {
  const { birthDay, birthMonth, birthYear } = draft

  if (!birthDay || !birthMonth || !birthYear) {
    return null
  }

  return `${birthDay.padStart(2, '0')}/${birthMonth.padStart(2, '0')}/${birthYear}`
})

const badges = computed(() => {
  const items: { key: string; value: string }[] = []

  items.push({
    key: 'gender',
    value: draft.gender === 'female' ? t('creation.female') : t('creation.male'),
  })

  const country = nationalityOptions.value.find((option) => option.value === draft.nationality)

  if (country) {
    items.push({ key: 'nationality', value: country.label })
  }

  if (birthDisplay.value) {
    items.push({ key: 'birth', value: birthDisplay.value })
  }

  if (draft.birthPlace) {
    items.push({ key: 'place', value: draft.birthPlace })
  }

  items.push({ key: 'height', value: `${draft.height} cm` })

  return items
})

const heightFill = computed(
  () => `${((draft.height - HEIGHT_MIN) / (HEIGHT_MAX - HEIGHT_MIN)) * 100}%`,
)

const digits = ref('')
const showCalendar = ref(false)
const dateField = ref<HTMLElement | null>(null)

const dateDisplay = computed(() => {
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

const handleDateKeydown = (event: KeyboardEvent): void => {
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

const handleDatePaste = (event: ClipboardEvent): void => {
  event.preventDefault()

  for (const char of (event.clipboardData?.getData('text') ?? '').replace(/\D/g, '')) {
    appendDigit(char)
  }
}

const datePopover = ref<HTMLElement | null>(null)
const popoverStyle = ref<Record<string, string>>({})

const placePopover = (): void => {
  const field = dateField.value

  if (!field) {
    return
  }

  const rect = field.getBoundingClientRect()

  popoverStyle.value = {
    position: 'fixed',
    left: `${rect.left}px`,
    top: `${rect.bottom + 9}px`,
  }
}

const openCalendar = async (): Promise<void> => {
  if (showCalendar.value) {
    return
  }

  showCalendar.value = true
  placePopover()

  await nextTick()

  const field = dateField.value
  const popover = datePopover.value

  if (!field || !popover) {
    return
  }

  const rect = field.getBoundingClientRect()
  const height = popover.offsetHeight

  if (rect.bottom + 9 + height > window.innerHeight - 12) {
    popoverStyle.value = {
      position: 'fixed',
      left: `${rect.left}px`,
      top: `${Math.max(12, rect.top - 9 - height)}px`,
    }
  }
}

const pickDate = (day: number, month: number, year: number): void => {
  digits.value = `${String(day).padStart(2, '0')}${String(month).padStart(2, '0')}${year}`
  showCalendar.value = false
}

const handleOutsideClick = (event: MouseEvent): void => {
  if (!showCalendar.value) {
    return
  }

  const target = event.target as Node

  if (!dateField.value?.contains(target) && !datePopover.value?.contains(target)) {
    showCalendar.value = false
  }
}

watch(digits, (value) => {
  draft.birthDay = value.slice(0, 2)
  draft.birthMonth = value.slice(2, 4)
  draft.birthYear = value.slice(4, 8)
})

onMounted(() => document.addEventListener('mousedown', handleOutsideClick))
onBeforeUnmount(() => document.removeEventListener('mousedown', handleOutsideClick))
</script>

<template>
  <div class="fixed inset-0 flex items-center justify-center select-none">
    <div class="scrim" aria-hidden="true"></div>

    <div class="modal">
      <div class="modal__head">
        <div class="flex items-center gap-3">
          <span class="brand__bar"></span>
          <div>
            <p class="brand__name">SIKU</p>
            <p class="brand__tag">{{ t('creation.civilStatus') }}</p>
          </div>
        </div>

        <span class="counter">{{ filled }} / 7</span>
      </div>

      <div class="modal__hero">
        <h1
          class="hero__name"
          :class="{ 'hero__name--empty': !draft.firstName && !draft.lastName }"
        >
          {{ heroName }}
        </h1>

        <div class="mt-3.5 flex flex-wrap items-center gap-2">
          <span v-for="badge in badges" :key="badge.key" class="badge">{{ badge.value }}</span>
        </div>
      </div>

      <div class="rule"></div>

      <div class="modal__body">
        <div class="grid grid-cols-2 gap-4">
          <label class="field">
            <span class="field__label">{{ t('creation.firstName') }}</span>
            <input
              v-model.trim="draft.firstName"
              class="field__input"
              :class="{ 'field__input--invalid': errorText('firstName') }"
              type="text"
              maxlength="24"
              :placeholder="t('creation.firstNamePlaceholder')"
            />
            <Transition name="field-error">
              <span v-if="errorText('firstName')" class="field__error">
                {{ errorText('firstName') }}
              </span>
            </Transition>
          </label>

          <label class="field">
            <span class="field__label">{{ t('creation.lastName') }}</span>
            <input
              v-model.trim="draft.lastName"
              class="field__input"
              :class="{ 'field__input--invalid': errorText('lastName') }"
              type="text"
              maxlength="24"
              :placeholder="t('creation.lastNamePlaceholder')"
            />
            <Transition name="field-error">
              <span v-if="errorText('lastName')" class="field__error">
                {{ errorText('lastName') }}
              </span>
            </Transition>
          </label>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div class="field">
            <span class="field__label">{{ t('creation.gender') }}</span>
            <div class="segmented">
              <button
                type="button"
                class="segmented__item"
                :class="{ 'segmented__item--active': draft.gender === 'male' }"
                @click="draft.gender = 'male'"
              >
                {{ t('creation.male') }}
              </button>
              <button
                type="button"
                class="segmented__item"
                :class="{ 'segmented__item--active': draft.gender === 'female' }"
                @click="draft.gender = 'female'"
              >
                {{ t('creation.female') }}
              </button>
            </div>
          </div>

          <label class="field">
            <span class="field__label">{{ t('creation.nationality') }}</span>
            <div class="select">
              <select v-model="draft.nationality" class="field__input select__native">
                <option value="" disabled>{{ t('creation.nationalityPlaceholder') }}</option>
                <option
                  v-for="option in nationalityOptions"
                  :key="option.value"
                  :value="option.value"
                >
                  {{ option.label }}
                </option>
              </select>
              <v-icon class="select__chevron" size="16" :icon="resolveIcon('mdi-chevron-down')" />
            </div>
          </label>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div ref="dateField" class="field date-field">
            <span class="field__label">{{ t('creation.birthDate') }}</span>
            <div class="date">
              <input
                :value="dateDisplay"
                class="field__input date__input"
                :class="{ 'field__input--invalid': errorText('birthDate') }"
                inputmode="numeric"
                :placeholder="t('creation.datePlaceholder')"
                @keydown="handleDateKeydown"
                @paste="handleDatePaste"
                @focus="openCalendar"
                @click="openCalendar"
              />
              <v-icon
                class="date__icon"
                size="16"
                :icon="resolveIcon('mdi-calendar-blank-outline')"
              />
            </div>

            <Transition name="field-error">
              <span v-if="errorText('birthDate')" class="field__error">
                {{ errorText('birthDate') }}
              </span>
            </Transition>

            <Teleport to="body">
              <Transition name="cal-pop">
                <div
                  v-if="showCalendar"
                  ref="datePopover"
                  class="date__popover"
                  :style="popoverStyle"
                >
                  <GlassCalendar
                    :day="draft.birthDay"
                    :month="draft.birthMonth"
                    :year="draft.birthYear"
                    @pick="pickDate"
                  />
                </div>
              </Transition>
            </Teleport>
          </div>

          <label class="field">
            <span class="field__label">{{ t('creation.birthPlace') }}</span>
            <input
              v-model.trim="draft.birthPlace"
              class="field__input"
              type="text"
              maxlength="40"
              :placeholder="t('creation.birthPlacePlaceholder')"
            />
          </label>
        </div>

        <div class="field">
          <div class="flex items-baseline justify-between">
            <span class="field__label">{{ t('creation.height') }}</span>
            <span class="field__value">{{ draft.height }} cm</span>
          </div>
          <input
            v-model.number="draft.height"
            class="range"
            type="range"
            :min="HEIGHT_MIN"
            :max="HEIGHT_MAX"
            :style="{ '--fill': heightFill }"
          />
        </div>
      </div>

      <div class="rule"></div>

      <div class="modal__foot">
        <p class="foot__hint">
          {{ isValid ? t('creation.ready') : t('creation.fillAll') }}
        </p>

        <button
          type="button"
          class="action action--primary"
          :class="{ 'action--disabled': !isValid }"
          :disabled="!isValid"
          @click="handleSubmit"
        >
          {{ t('creation.continue') }}
          <v-icon size="17" :icon="resolveIcon('mdi-chevron-right')" />
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.scrim {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(70% 60% at 50% 45%, rgba(28, 52, 84, 0.5) 0%, transparent 70%),
    linear-gradient(180deg, rgba(6, 12, 22, 0.9) 0%, rgba(6, 12, 22, 0.94) 100%);
}

.modal {
  position: relative;
  width: 640px;
  max-height: 88vh;
  overflow: hidden auto;
  border-radius: 20px;
  border: 1px solid rgba(160, 200, 235, 0.16);
  background:
    var(--ice-noise),
    radial-gradient(120% 90% at 50% -10%, rgba(120, 170, 220, 0.14) 0%, transparent 60%),
    linear-gradient(180deg, rgba(19, 32, 51, 0.97) 0%, rgba(11, 21, 36, 0.98) 100%);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.1),
    0 40px 90px -40px rgba(4, 10, 22, 0.9);
  scrollbar-width: none;
}

.modal::-webkit-scrollbar {
  width: 0;
}

.modal::before {
  content: '';
  position: absolute;
  inset-inline: 22%;
  top: -1px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(226, 240, 255, 0.55), transparent);
}

.modal__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 26px 32px 0;
}

.modal__hero {
  padding: 22px 32px 24px;
}

.modal__body {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 26px 32px;
}

.modal__foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding: 20px 32px 26px;
}

.rule {
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(160, 200, 235, 0.18) 18%,
    rgba(160, 200, 235, 0.18) 82%,
    transparent
  );
}

.brand__bar {
  width: 2px;
  height: 32px;
  border-radius: 9999px;
  background: linear-gradient(to bottom, rgba(226, 240, 255, 0.95), rgba(120, 170, 220, 0.35));
  box-shadow: 0 0 12px rgba(190, 224, 255, 0.5);
}

.brand__name {
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.3em;
  color: rgba(244, 250, 255, 0.96);
}

.brand__tag {
  margin-top: 3px;
  font-size: 9.6px;
  font-weight: 300;
  letter-spacing: 0.26em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.52);
}

.counter {
  font-family: ui-monospace, monospace;
  font-size: 11px;
  letter-spacing: 0.08em;
  font-variant-numeric: tabular-nums;
  color: rgba(170, 200, 228, 0.45);
}

.hero__name {
  font-size: 34px;
  font-weight: 300;
  letter-spacing: -0.015em;
  line-height: 1.1;
  color: rgba(246, 251, 255, 0.98);
}

.hero__name--empty {
  color: rgba(198, 224, 243, 0.35);
}

.badge {
  border-radius: 9999px;
  border: 1px solid rgba(160, 200, 235, 0.16);
  background: rgba(10, 20, 35, 0.5);
  padding: 5px 12px;
  font-size: 10.8px;
  font-weight: 400;
  letter-spacing: 0.08em;
  color: rgba(214, 234, 252, 0.8);
}

.field {
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.field__label {
  font-size: 9.8px;
  font-weight: 400;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.55);
}

.field__value {
  font-family: ui-monospace, monospace;
  font-size: 11px;
  font-variant-numeric: tabular-nums;
  color: rgba(214, 234, 252, 0.75);
}

.field__input {
  width: 100%;
  border-radius: 10px;
  border: 1px solid rgba(150, 190, 225, 0.14);
  background: linear-gradient(180deg, rgba(16, 28, 46, 0.6) 0%, rgba(9, 18, 32, 0.66) 100%);
  padding: 10px 13px;
  font-size: 13.2px;
  font-weight: 400;
  color: rgba(240, 248, 255, 0.95);
  transition:
    border-color 0.2s ease,
    background 0.2s ease,
    box-shadow 0.2s ease;
}

.field__input::placeholder {
  color: rgba(160, 192, 222, 0.36);
}

.field__input:hover {
  border-color: rgba(180, 214, 245, 0.24);
}

.field__input--invalid,
.field__input--invalid:hover,
.field__input--invalid:focus {
  border-color: rgba(244, 110, 122, 0.5);
  box-shadow: 0 0 20px -12px rgba(244, 110, 122, 0.75);
}

.field__error {
  font-size: 11px;
  font-weight: 300;
  letter-spacing: 0.02em;
  color: rgba(246, 158, 167, 0.88);
}

.field-error-enter-active,
.field-error-leave-active {
  transition:
    opacity 0.18s ease,
    transform 0.18s ease;
}

.field-error-enter-from,
.field-error-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

.field__input:focus {
  outline: none;
  border-color: rgba(198, 228, 255, 0.45);
  background: linear-gradient(180deg, rgba(26, 45, 70, 0.72) 0%, rgba(13, 25, 42, 0.74) 100%);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.12),
    0 10px 26px -18px rgba(120, 180, 240, 0.8);
}

.segmented {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 5px;
  border-radius: 10px;
  border: 1px solid rgba(150, 190, 225, 0.14);
  background: rgba(9, 18, 32, 0.55);
  padding: 4px;
}

.segmented__item {
  border-radius: 8px;
  padding: 7px 0;
  font-size: 12px;
  font-weight: 400;
  color: rgba(190, 216, 240, 0.6);
  transition:
    background 0.2s ease,
    color 0.2s ease;
}

.segmented__item:hover {
  color: rgba(232, 244, 255, 0.9);
}

.segmented__item--active {
  background: linear-gradient(180deg, rgba(40, 68, 102, 0.85) 0%, rgba(22, 40, 64, 0.85) 100%);
  color: rgba(244, 250, 255, 0.97);
  box-shadow: inset 0 1px 0 rgba(226, 240, 255, 0.14);
}

.select {
  position: relative;
}

.select__native {
  appearance: none;
  padding-right: 36px;
}

.select__native option {
  background: #0d1a2c;
  color: rgba(240, 248, 255, 0.95);
}

.select__chevron {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: rgba(170, 200, 228, 0.5);
}

.date-field {
  position: relative;
}

.date {
  position: relative;
  display: block;
}

.date__input {
  padding-right: 38px;
  font-variant-numeric: tabular-nums;
  letter-spacing: 0.05em;
  cursor: pointer;
}

.date__icon {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  color: rgba(170, 200, 228, 0.5);
}

.date__popover {
  z-index: 60;
}

.cal-pop-enter-active,
.cal-pop-leave-active {
  transition:
    opacity 0.18s ease,
    transform 0.18s ease;
}

.cal-pop-enter-from,
.cal-pop-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

.range {
  width: 100%;
  height: 3px;
  appearance: none;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(214, 238, 255, 0.8) 0%,
    rgba(214, 238, 255, 0.8) var(--fill, 50%),
    rgba(150, 190, 225, 0.18) var(--fill, 50%)
  );
  cursor: pointer;
}

.range::-webkit-slider-thumb {
  appearance: none;
  height: 14px;
  width: 14px;
  border-radius: 9999px;
  background: rgba(244, 251, 255, 0.98);
  box-shadow: 0 0 12px rgba(190, 224, 255, 0.6);
}

.foot__hint {
  font-size: 10.6px;
  font-weight: 300;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.45);
}

.action {
  display: inline-flex;
  align-items: center;
  gap: 9px;
  border-radius: 11px;
  padding: 12px 24px;
  font-size: 12.2px;
  font-weight: 500;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  transition:
    background 0.2s ease,
    border-color 0.2s ease,
    color 0.2s ease,
    opacity 0.2s ease;
}

.action--primary {
  border: 1px solid rgba(214, 238, 255, 0.5);
  background: linear-gradient(180deg, rgba(232, 245, 255, 0.96) 0%, rgba(198, 226, 250, 0.9) 100%);
  color: rgba(10, 24, 42, 0.92);
  box-shadow: 0 12px 30px -16px rgba(150, 200, 250, 0.9);
}

.action--primary:hover:not(.action--disabled) {
  background: linear-gradient(180deg, rgba(255, 255, 255, 1) 0%, rgba(214, 236, 255, 0.96) 100%);
}

.action--disabled {
  cursor: not-allowed;
  border-color: rgba(160, 200, 235, 0.2);
  background: rgba(30, 48, 72, 0.55);
  color: rgba(196, 220, 242, 0.42);
  box-shadow: none;
}
</style>
