<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import GlassPanel from '@/components/ui/GlassPanel.vue'
import IceButton from '@/components/ui/IceButton.vue'
import GlassInput from './fields/GlassInput.vue'
import GlassSelect from './fields/GlassSelect.vue'
import GlassSegmented from './fields/GlassSegmented.vue'
import RangeSlider from '@/components/ui/RangeSlider.vue'
import GlassCalendar from './fields/GlassCalendar.vue'
import GlassDateInput from './fields/GlassDateInput.vue'
import IdentityPreview from './IdentityPreview.vue'
import {
  HEIGHT_MAX,
  HEIGHT_MIN,
  createIdentityDraft,
  isIdentityDraftValid,
  validateIdentity,
} from '@/utils/identity'
import { getCountryOptions } from '@/utils/countries'
import type { IdentityDraft } from '@/utils/identity'

const emit = defineEmits<{
  submit: [draft: IdentityDraft]
}>()

const { t, locale } = useI18n()

const draft = reactive(createIdentityDraft())

const showCalendar = ref(false)
const dateGroup = ref<HTMLElement | null>(null)

const genderOptions = computed(() => [
  { value: 'male', label: t('creation.male') },
  { value: 'female', label: t('creation.female') },
])

const nationalityOptions = computed(() => getCountryOptions(locale.value))

const isValid = computed(() => isIdentityDraftValid(draft))

const errors = computed(() => validateIdentity(draft))

const errorText = (field: 'firstName' | 'lastName' | 'birthDate' | 'height'): string => {
  const error = errors.value[field]
  return error ? t(error.key, error.params ?? {}) : ''
}

const applyPickedDate = (day: number, month: number, year: number): void => {
  draft.birthDay = String(day)
  draft.birthMonth = String(month)
  draft.birthYear = String(year)
  showCalendar.value = false
}

const applyTypedDate = (value: { day: string; month: string; year: string }): void => {
  draft.birthDay = value.day
  draft.birthMonth = value.month
  draft.birthYear = value.year
}

const handleOutsideClick = (event: MouseEvent): void => {
  if (showCalendar.value && dateGroup.value && !dateGroup.value.contains(event.target as Node)) {
    showCalendar.value = false
  }
}

const handleKeydown = (event: KeyboardEvent): void => {
  if (event.key === 'Escape') {
    showCalendar.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleOutsideClick)
  window.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleOutsideClick)
  window.removeEventListener('keydown', handleKeydown)
})

const handleSubmit = (): void => {
  if (isValid.value) {
    emit('submit', { ...draft })
  }
}
</script>

<template>
  <GlassPanel class="form">
    <div class="flex items-stretch">
      <aside class="form__aside flex w-[360px] shrink-0 flex-col px-10 pb-12 pt-14">
        <h1 class="form__title">{{ t('creation.title') }}</h1>
        <p class="form__subtitle mt-2.5">{{ t('creation.subtitle') }}</p>

        <div class="form__divider mb-9 mt-8 h-px w-full"></div>

        <IdentityPreview :draft="draft" />
      </aside>

      <div class="form__separator" aria-hidden="true"></div>

      <div class="form__pane relative flex flex-1 flex-col overflow-hidden px-12 pb-9 pt-10">
        <div class="relative">
          <div class="flex items-center gap-4">
            <span class="form__section-label">{{ t('creation.sectionIdentity') }}</span>
            <span class="form__section-line flex-1"></span>
          </div>
          <div class="mt-4 grid grid-cols-2 gap-x-9 gap-y-6">
            <GlassInput
              v-model="draft.firstName"
              :label="t('creation.firstName')"
              :placeholder="t('creation.firstNamePlaceholder')"
              :error="errorText('firstName')"
            />
            <GlassInput
              v-model="draft.lastName"
              :label="t('creation.lastName')"
              :placeholder="t('creation.lastNamePlaceholder')"
              :error="errorText('lastName')"
            />

            <GlassSegmented
              v-model="draft.gender"
              :label="t('creation.gender')"
              :options="genderOptions"
            />
            <GlassSelect
              v-model="draft.nationality"
              :label="t('creation.nationality')"
              :options="nationalityOptions"
              :placeholder="t('creation.nationalityPlaceholder')"
            />
          </div>
        </div>

        <div class="relative mt-8">
          <div class="flex items-center gap-4">
            <span class="form__section-label">{{ t('creation.sectionBirth') }}</span>
            <span class="form__section-line flex-1"></span>
          </div>
          <div class="mt-4 grid grid-cols-2 gap-x-9">
            <div ref="dateGroup" class="relative">
              <GlassDateInput
                :label="t('creation.date')"
                :day="draft.birthDay"
                :month="draft.birthMonth"
                :year="draft.birthYear"
                :placeholder="t('creation.datePlaceholder')"
                :error="errorText('birthDate')"
                @update="applyTypedDate"
                @open="showCalendar = true"
              />

              <Transition name="calendar-pop">
                <GlassCalendar
                  v-if="showCalendar"
                  class="absolute left-0 top-full z-30 mt-2.5"
                  :day="draft.birthDay"
                  :month="draft.birthMonth"
                  :year="draft.birthYear"
                  @pick="applyPickedDate"
                />
              </Transition>
            </div>
            <GlassInput
              v-model="draft.birthPlace"
              :label="t('creation.place')"
              :placeholder="t('creation.birthPlacePlaceholder')"
            />
          </div>
        </div>

        <div class="relative mt-8">
          <div class="flex items-center gap-4">
            <span class="form__section-label">{{ t('creation.sectionTraits') }}</span>
            <span class="form__section-line flex-1"></span>
          </div>
          <div class="mt-4">
            <RangeSlider
              v-model="draft.height"
              :label="t('creation.height')"
              :min="HEIGHT_MIN"
              :max="HEIGHT_MAX"
              unit="cm"
            />
          </div>
        </div>

        <div class="relative mt-auto pt-9">
          <div class="form__footer-line" :class="{ 'form__footer-line--lit': isValid }"></div>
          <div class="mt-6 flex justify-center">
            <IceButton
              class="form__submit"
              :label="t('creation.continue')"
              icon="mdi-chevron-right"
              variant="primary"
              :disabled="!isValid"
              @click="handleSubmit"
            />
          </div>
        </div>
      </div>
    </div>
  </GlassPanel>
</template>

<style scoped>
.form {
  width: min(1100px, 94vw);
}

.form__aside {
  background: linear-gradient(180deg, rgba(6, 14, 26, 0.32) 0%, rgba(6, 14, 26, 0.18) 100%);
  border-radius: 1.6rem 0 0 1.6rem;
}

.form__pane {
  background: radial-gradient(75% 50% at 50% 0%, rgba(226, 240, 250, 0.045) 0%, transparent 65%);
  border-radius: 0 1.6rem 1.6rem 0;
}

.form__separator {
  width: 1px;
  align-self: stretch;
  background: linear-gradient(
    to bottom,
    rgba(240, 248, 255, 0.3) 0%,
    rgba(214, 236, 252, 0.2) 32%,
    rgba(214, 236, 252, 0.2) 70%,
    transparent 96%
  );
  box-shadow: 0 0 10px rgba(226, 240, 250, 0.14);
}

.form__title {
  font-size: 17.5px;
  line-height: 1.35;
  font-weight: 200;
  letter-spacing: 0.17em;
  text-transform: uppercase;
  white-space: nowrap;
  color: rgba(250, 253, 255, 0.98);
  text-shadow: 0 0 26px rgba(214, 236, 252, 0.3);
}

.form__subtitle {
  font-size: 13px;
  font-weight: 300;
  letter-spacing: 0.04em;
  color: rgba(198, 224, 243, 0.55);
}

.form__divider {
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(250, 253, 255, 0.55),
    rgba(214, 236, 252, 0.16) 60%,
    transparent
  );
  box-shadow: 0 0 9px rgba(240, 248, 255, 0.28);
}

.form__section-label {
  font-size: 9.5px;
  font-weight: 400;
  letter-spacing: 0.32em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.4);
}

.form__section-line {
  height: 1px;
  background: linear-gradient(to right, rgba(226, 240, 250, 0.14), transparent 85%);
}

.form__footer-line {
  height: 1px;
  background: linear-gradient(
    to right,
    transparent,
    rgba(214, 236, 252, 0.18) 18%,
    rgba(214, 236, 252, 0.18) 82%,
    transparent
  );
  transition:
    box-shadow 0.5s ease,
    opacity 0.5s ease;
}

.form__footer-line--lit {
  background: linear-gradient(to right, transparent, rgba(240, 248, 255, 0.42) 50%, transparent);
  box-shadow: 0 0 12px rgba(226, 240, 250, 0.28);
}

.form__submit.btn {
  min-width: 280px;
  padding: 0.85rem 1.7rem;
  font-size: 12px;
}

.form__submit.btn--disabled {
  opacity: 0.68;
  filter: grayscale(0.55) brightness(0.94);
  border-color: rgba(198, 224, 243, 0.3);
  box-shadow: inset 0 1px 0 rgba(233, 244, 253, 0.12);
}

.form__submit :deep(.v-icon) {
  transition: transform 0.3s ease;
}

.form__submit:hover :deep(.v-icon) {
  transform: translateX(3px);
}

.calendar-pop-enter-active {
  transition:
    opacity 0.28s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.28s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.calendar-pop-leave-active {
  transition:
    opacity 0.18s ease,
    transform 0.18s ease;
}

.calendar-pop-enter-from,
.calendar-pop-leave-to {
  opacity: 0;
  transform: translateY(-8px) scale(0.98);
}
</style>
