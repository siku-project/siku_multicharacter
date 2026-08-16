<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import {
  IDENTITY_FIELD_TOTAL,
  countFilledIdentityFields,
  isBirthDateValid,
  isIdentityDraftValid,
} from '@/utils/identity'
import type { IdentityDraft } from '@/utils/identity'

const props = defineProps<{
  draft: IdentityDraft
}>()

const { t, locale } = useI18n()

const fullName = computed(() => {
  const name = `${props.draft.firstName.trim()} ${props.draft.lastName.trim()}`.trim()
  return name.length > 0 ? name : null
})

const genderLabel = computed(() =>
  props.draft.gender === 'female' ? t('creation.female') : t('creation.male'),
)

const age = computed(() => {
  if (!isBirthDateValid(props.draft)) {
    return null
  }
  const birth = new Date(
    Number(props.draft.birthYear),
    Number(props.draft.birthMonth) - 1,
    Number(props.draft.birthDay),
  )
  const now = new Date()
  let years = now.getFullYear() - birth.getFullYear()
  const beforeBirthday =
    now.getMonth() < birth.getMonth() ||
    (now.getMonth() === birth.getMonth() && now.getDate() < birth.getDate())
  if (beforeBirthday) {
    years -= 1
  }
  return years
})

const metaLine = computed(() => {
  const parts = [genderLabel.value]
  if (age.value !== null) {
    parts.push(t('selection.age', { age: age.value }))
  }
  return parts.join(' · ')
})

const nationalityLabel = computed(() => {
  if (!props.draft.nationality) {
    return null
  }
  const display = new Intl.DisplayNames([locale.value], { type: 'region' })
  return display.of(props.draft.nationality) ?? props.draft.nationality
})

const birthLabel = computed(() => {
  if (!isBirthDateValid(props.draft)) {
    return null
  }
  const date = new Date(
    Number(props.draft.birthYear),
    Number(props.draft.birthMonth) - 1,
    Number(props.draft.birthDay),
  )
  return new Intl.DateTimeFormat(locale.value, {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(date)
})

const rows = computed(() => [
  {
    key: 'nationality',
    label: t('creation.nationality'),
    value: nationalityLabel.value,
    swap: true,
  },
  {
    key: 'birth',
    label: t('creation.birthDate'),
    value: birthLabel.value,
    swap: true,
  },
  {
    key: 'birthPlace',
    label: t('creation.birthPlace'),
    value: props.draft.birthPlace.trim() || null,
    swap: false,
  },
  {
    key: 'height',
    label: t('creation.height'),
    value: `${props.draft.height} cm`,
    swap: false,
  },
])

const filledCount = computed(() => countFilledIdentityFields(props.draft))

const totalFields = IDENTITY_FIELD_TOTAL

const isComplete = computed(() => isIdentityDraftValid(props.draft))

const fillRatio = computed(() => (filledCount.value / totalFields) * 100)
</script>

<template>
  <div class="flex min-h-0 flex-1 flex-col">
    <div class="flex flex-col gap-3">
      <h2
        class="preview__name"
        :class="{ 'preview__name--empty': !fullName, 'preview__name--complete': isComplete }"
      >
        {{ fullName ?? t('creation.previewEmpty') }}
      </h2>
      <p class="preview__meta">{{ metaLine }}</p>
    </div>

    <div class="mt-8 flex items-center gap-3.5">
      <div class="preview__track flex-1" :class="{ 'preview__track--complete': isComplete }">
        <span class="preview__fill" :style="{ width: `${fillRatio}%` }"></span>
      </div>
      <span class="preview__count" :class="{ 'preview__count--complete': isComplete }">
        {{ filledCount }}/{{ totalFields }}
      </span>
    </div>

    <div class="mt-6 flex flex-col">
      <template v-for="(row, index) in rows" :key="row.key">
        <div v-if="index > 0" class="preview__line"></div>
        <div class="preview__row" :class="{ 'preview__row--filled': row.value !== null }">
          <div class="flex items-center justify-between gap-4">
            <span class="preview__label">{{ row.label }}</span>
            <span class="preview__dot"></span>
          </div>
          <Transition v-if="row.swap" name="value-swap" mode="out-in">
            <span :key="row.value ?? 'empty'" class="preview__value">
              {{ row.value ?? '—' }}
            </span>
          </Transition>
          <span v-else class="preview__value">{{ row.value ?? '—' }}</span>
        </div>
      </template>
    </div>

    <div class="mt-auto pt-9">
      <div class="preview__footer-line mb-4"></div>
      <div class="flex items-baseline justify-between">
        <span class="preview__stamp">SIKU</span>
        <span class="preview__stamp-sub">{{ t('creation.civilStatus') }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.preview__name {
  font-size: 29px;
  line-height: 1.18;
  font-weight: 200;
  letter-spacing: 0.05em;
  color: rgba(252, 254, 255, 0.99);
  text-shadow: 0 0 24px rgba(226, 240, 250, 0.32);
  overflow-wrap: anywhere;
  transition:
    color 0.35s ease,
    text-shadow 0.35s ease;
}

.preview__name--empty {
  color: rgba(198, 224, 243, 0.32);
  text-shadow: none;
}

.preview__name--complete {
  text-shadow:
    0 0 18px rgba(240, 248, 255, 0.45),
    0 0 46px rgba(214, 236, 252, 0.25);
}

.preview__meta {
  font-size: 11px;
  font-weight: 300;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.55);
}

.preview__track {
  position: relative;
  height: 1px;
  border-radius: 9999px;
  background: rgba(198, 224, 243, 0.14);
}

.preview__fill {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  border-radius: inherit;
  background: linear-gradient(to right, rgba(250, 253, 255, 0.9), rgba(214, 236, 252, 0.5));
  box-shadow: 0 0 10px rgba(226, 240, 250, 0.35);
  transition: width 0.6s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.preview__track--complete .preview__fill {
  background: linear-gradient(to right, rgba(255, 255, 255, 0.95), rgba(226, 240, 250, 0.7));
  box-shadow: 0 0 14px rgba(240, 248, 255, 0.55);
}

.preview__count {
  font-family: ui-monospace, monospace;
  font-size: 10px;
  letter-spacing: 0.14em;
  color: rgba(198, 224, 243, 0.42);
  font-variant-numeric: tabular-nums;
  transition:
    color 0.4s ease,
    text-shadow 0.4s ease;
}

.preview__count--complete {
  color: rgba(250, 253, 255, 0.9);
  text-shadow: 0 0 10px rgba(226, 240, 250, 0.4);
}

.preview__row {
  display: flex;
  flex-direction: column;
  gap: 0.42rem;
  padding: 0.85rem 0;
}

.preview__row:first-of-type {
  padding-top: 0;
}

.preview__row:last-of-type {
  padding-bottom: 0;
}

.preview__label {
  font-size: 10px;
  font-weight: 400;
  letter-spacing: 0.24em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.44);
  transition: color 0.35s ease;
}

.preview__row--filled .preview__label {
  color: rgba(198, 224, 243, 0.62);
}

.preview__dot {
  width: 5px;
  height: 5px;
  flex-shrink: 0;
  border-radius: 9999px;
  border: 1px solid rgba(198, 224, 243, 0.32);
  transition:
    background-color 0.45s ease,
    border-color 0.45s ease,
    box-shadow 0.45s ease;
}

.preview__row--filled .preview__dot {
  background: rgba(250, 253, 255, 0.95);
  border-color: rgba(250, 253, 255, 0.55);
  box-shadow: 0 0 9px rgba(226, 240, 250, 0.55);
}

.preview__value {
  font-size: 15px;
  font-weight: 300;
  letter-spacing: 0.03em;
  color: rgba(246, 251, 255, 0.96);
  font-variant-numeric: tabular-nums;
  overflow-wrap: anywhere;
  transition: color 0.35s ease;
}

.preview__row:not(.preview__row--filled) .preview__value {
  color: rgba(198, 224, 243, 0.26);
}

.preview__line {
  height: 1px;
  flex-shrink: 0;
  background: linear-gradient(
    to right,
    rgba(226, 240, 250, 0.2),
    rgba(226, 240, 250, 0.06) 55%,
    transparent
  );
}

.preview__footer-line {
  height: 1px;
  background: linear-gradient(to right, transparent, rgba(240, 248, 255, 0.28) 50%, transparent);
  box-shadow: 0 0 8px rgba(226, 240, 250, 0.18);
}

.preview__stamp {
  font-size: 10px;
  font-weight: 300;
  letter-spacing: 0.42em;
  text-transform: uppercase;
  color: rgba(226, 240, 250, 0.45);
  text-shadow: 0 0 12px rgba(226, 240, 250, 0.25);
}

.preview__stamp-sub {
  font-size: 9px;
  font-weight: 300;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.3);
}

.value-swap-enter-active {
  transition:
    opacity 0.3s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.3s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.value-swap-leave-active {
  transition:
    opacity 0.16s ease,
    transform 0.16s ease;
}

.value-swap-enter-from {
  opacity: 0;
  transform: translateY(6px);
}

.value-swap-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}
</style>
