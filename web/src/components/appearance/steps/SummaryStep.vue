<script setup lang="ts">
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import { APPEARANCE_STEPS, PED_MODELS, controlKey } from '@/config/appearance'
import type { AppearanceCategory, AppearanceControl } from '@/config/appearance'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { createIdentityDraft } from '@/utils/identity'

interface SummaryRow {
  key: string
  label: string
  value: string
  color?: string
  mono?: string
}

interface SummaryCategory {
  key: string
  label: string
  rows: SummaryRow[]
}

const props = defineProps<{
  draft: Record<string, number>
  pedModel: string
}>()

const { t, locale } = useI18n()

const { identity: storedIdentity, heritageConfig } = storeToRefs(useMulticharacterStore())

const identity = computed(() => storedIdentity.value ?? createIdentityDraft())

const heroName = computed(() => `${identity.value.firstName} ${identity.value.lastName}`.trim())

const heroMeta = computed(() => {
  const draft = identity.value
  const display = new Intl.DisplayNames([locale.value], { type: 'region' })
  const birth = new Date(
    Number(draft.birthYear),
    Number(draft.birthMonth) - 1,
    Number(draft.birthDay),
  )
  const now = new Date()
  let years = now.getFullYear() - birth.getFullYear()
  const beforeBirthday =
    now.getMonth() < birth.getMonth() ||
    (now.getMonth() === birth.getMonth() && now.getDate() < birth.getDate())
  if (beforeBirthday) {
    years -= 1
  }
  const gender = draft.gender === 'female' ? t('creation.female') : t('creation.male')
  const country = display.of(draft.nationality) ?? draft.nationality
  return [gender, t('selection.age', { age: years }), country].join(' · ')
})

const identityRows = computed<SummaryRow[]>(() => {
  const draft = identity.value
  const display = new Intl.DisplayNames([locale.value], { type: 'region' })
  const birth = new Date(
    Number(draft.birthYear),
    Number(draft.birthMonth) - 1,
    Number(draft.birthDay),
  )
  const birthLabel = new Intl.DateTimeFormat(locale.value, {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(birth)
  return [
    { key: 'lastName', label: t('creation.lastName'), value: draft.lastName },
    { key: 'firstName', label: t('creation.firstName'), value: draft.firstName },
    {
      key: 'gender',
      label: t('creation.gender'),
      value: draft.gender === 'female' ? t('creation.female') : t('creation.male'),
    },
    { key: 'height', label: t('creation.height'), value: `${draft.height} cm` },
    {
      key: 'nationality',
      label: t('creation.nationality'),
      value: display.of(draft.nationality) ?? draft.nationality,
    },
    { key: 'birthDate', label: t('creation.birthDate'), value: birthLabel },
    { key: 'birthPlace', label: t('creation.birthPlace'), value: draft.birthPlace },
  ]
})

const selectedPed = computed(() => PED_MODELS.find((model) => model.id === props.pedModel))

const pedRow = computed<SummaryRow>(() => {
  const model = selectedPed.value
  const name = model ? (model.labelKey ? t(model.labelKey) : (model.name ?? model.id)) : '—'
  return {
    key: 'ped',
    label: t('appearance.stepPed'),
    value: name,
    mono: model?.id,
  }
})

const valueOf = (stepId: string, categoryId: string, control: AppearanceControl): number =>
  props.draft[controlKey(stepId, categoryId, control.id)] ?? 0

const blendSplit = (value: number): string => {
  const father = Math.round(value)
  const mother = 100 - father
  const motherPart = `${mother}% ${t('appearance.ctrlMother')}`
  const fatherPart = `${father}% ${t('appearance.ctrlFather')}`
  return father >= mother ? `${fatherPart} • ${motherPart}` : `${motherPart} • ${fatherPart}`
}

const heritageRows = computed<SummaryRow[]>(() => {
  const mother =
    heritageConfig.value.mothers[props.draft[controlKey('heritage', 'parents', 'mother')] ?? 0]
      ?.name ?? '—'
  const father =
    heritageConfig.value.fathers[props.draft[controlKey('heritage', 'parents', 'father')] ?? 0]
      ?.name ?? '—'
  const resemblance = props.draft[controlKey('heritage', 'resemblance', 'resemblance')] ?? 50
  const skinTone = props.draft[controlKey('heritage', 'resemblance', 'skinTone')] ?? 50
  return [
    { key: 'mother', label: t('appearance.ctrlMother'), value: mother },
    { key: 'father', label: t('appearance.ctrlFather'), value: father },
    { key: 'resemblance', label: t('appearance.ctrlResemblance'), value: blendSplit(resemblance) },
    { key: 'skinTone', label: t('appearance.ctrlSkinTone'), value: blendSplit(skinTone) },
  ]
})

const controlRow = (
  stepId: string,
  category: AppearanceCategory,
  control: AppearanceControl,
): SummaryRow => {
  const value = valueOf(stepId, category.id, control)
  const row: SummaryRow = {
    key: `${category.id}.${control.id}`,
    label: t(control.labelKey),
    value: '',
  }
  if (control.type === 'swatches') {
    row.color = control.colors?.[value]
    row.value = String(value + 1)
  } else if (control.type === 'sprite') {
    row.value = `${value + 1} / ${control.max ?? 1}`
  } else {
    const decimal = (control.step ?? 1) < 1
    row.value = decimal
      ? value.toFixed(2)
      : control.unit
        ? `${value} ${control.unit}`
        : String(value)
  }
  return row
}

const stepCategories = (stepId: string): AppearanceCategory[] =>
  APPEARANCE_STEPS.find((step) => step.id === stepId)?.categories ?? []

const buildSection = (stepId: string): SummaryCategory[] =>
  stepCategories(stepId).map((category) => ({
    key: category.id,
    label: t(category.labelKey),
    rows: category.controls
      .filter((control) => control.type !== 'blend')
      .map((control) => controlRow(stepId, category, control)),
  }))

const detailSections = computed(() => [
  { key: 'physical', titleKey: 'appearance.stepPhysical', categories: buildSection('physical') },
  { key: 'clothing', titleKey: 'appearance.stepClothing', categories: buildSection('clothing') },
  {
    key: 'accessories',
    titleKey: 'appearance.stepAccessories',
    categories: buildSection('accessories'),
  },
  { key: 'tattoos', titleKey: 'appearance.stepTattoos', categories: buildSection('tattoos') },
])
</script>

<template>
  <div class="flex flex-col gap-7">
    <div class="flex flex-col gap-2">
      <h2 class="sum-hero">{{ heroName }}</h2>
      <p class="sum-hero__meta">{{ heroMeta }}</p>
      <div class="sum-hero__divider mt-3"></div>
    </div>

    <div class="flex flex-col gap-3">
      <div class="sum-sec flex items-center gap-3.5">
        <span class="sum-sec__label">{{ t('appearance.sumIdentity') }}</span>
        <span class="sum-sec__line flex-1"></span>
      </div>
      <div class="flex flex-col gap-2">
        <div
          v-for="row in identityRows"
          :key="row.key"
          class="flex items-baseline justify-between gap-4"
        >
          <span class="sum-row__label">{{ row.label }}</span>
          <span class="sum-row__value">{{ row.value }}</span>
        </div>
      </div>
    </div>

    <div class="flex flex-col gap-3">
      <div class="sum-sec flex items-center gap-3.5">
        <span class="sum-sec__label">{{ t('appearance.sumCharacter') }}</span>
        <span class="sum-sec__line flex-1"></span>
      </div>
      <div class="flex items-baseline justify-between gap-4">
        <span class="sum-row__label">{{ pedRow.label }}</span>
        <span class="flex flex-col items-end gap-0.5">
          <span class="sum-row__value">{{ pedRow.value }}</span>
          <span v-if="pedRow.mono" class="sum-row__mono">{{ pedRow.mono }}</span>
        </span>
      </div>
    </div>

    <div class="flex flex-col gap-3">
      <div class="sum-sec flex items-center gap-3.5">
        <span class="sum-sec__label">{{ t('appearance.stepHeritage') }}</span>
        <span class="sum-sec__line flex-1"></span>
      </div>
      <div class="flex flex-col gap-2">
        <div
          v-for="row in heritageRows"
          :key="row.key"
          class="flex items-baseline justify-between gap-4"
        >
          <span class="sum-row__label">{{ row.label }}</span>
          <span class="sum-row__value">{{ row.value }}</span>
        </div>
      </div>
    </div>

    <div v-for="section in detailSections" :key="section.key" class="flex flex-col gap-3">
      <div class="sum-sec flex items-center gap-3.5">
        <span class="sum-sec__label">{{ t(section.titleKey) }}</span>
        <span class="sum-sec__line flex-1"></span>
      </div>
      <div class="flex flex-col gap-3.5">
        <div
          v-for="category in section.categories"
          :key="category.key"
          class="flex flex-col gap-1.5"
        >
          <span class="sum-cat">{{ category.label }}</span>
          <div class="flex flex-col gap-1.5 pl-3">
            <div
              v-for="row in category.rows"
              :key="row.key"
              class="flex items-baseline justify-between gap-4"
            >
              <span class="sum-row__label">{{ row.label }}</span>
              <span class="flex items-center gap-2">
                <span
                  v-if="row.color"
                  class="sum-row__dot"
                  :style="{ background: row.color }"
                ></span>
                <span class="sum-row__value">{{ row.value }}</span>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sum-hero {
  font-size: 23px;
  line-height: 1.2;
  font-weight: 200;
  letter-spacing: 0.06em;
  color: rgba(252, 254, 255, 0.99);
  text-shadow: 0 0 22px rgba(226, 240, 250, 0.35);
  overflow-wrap: anywhere;
}

.sum-hero__meta {
  font-size: 10.5px;
  font-weight: 300;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.55);
}

.sum-hero__divider {
  height: 1px;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(250, 253, 255, 0.55),
    rgba(214, 236, 252, 0.16) 60%,
    transparent
  );
  box-shadow: 0 0 9px rgba(240, 248, 255, 0.28);
}

.sum-sec__label {
  font-size: 11.5px;
  font-weight: 300;
  letter-spacing: 0.26em;
  text-transform: uppercase;
  color: rgba(250, 253, 255, 0.95);
  text-shadow:
    0 0 14px rgba(226, 240, 250, 0.35),
    0 1px 8px rgba(3, 8, 16, 0.6);
}

.sum-sec__line {
  height: 1px;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(240, 248, 255, 0.45),
    rgba(214, 236, 252, 0.14) 60%,
    transparent
  );
  box-shadow: 0 0 8px rgba(226, 240, 250, 0.25);
}

.sum-cat {
  font-size: 10.5px;
  font-weight: 400;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: rgba(226, 240, 250, 0.78);
  text-shadow: 0 1px 8px rgba(3, 8, 16, 0.6);
}

.sum-row__label {
  font-size: 10.5px;
  font-weight: 300;
  letter-spacing: 0.08em;
  color: rgba(198, 224, 243, 0.55);
  white-space: nowrap;
}

.sum-row__value {
  font-size: 12.5px;
  font-weight: 300;
  letter-spacing: 0.03em;
  text-align: right;
  color: rgba(246, 251, 255, 0.96);
  font-variant-numeric: tabular-nums;
  text-shadow: 0 1px 8px rgba(3, 8, 16, 0.55);
}

.sum-row__mono {
  font-family: ui-monospace, monospace;
  font-size: 9px;
  letter-spacing: 0.1em;
  color: rgba(198, 224, 243, 0.4);
}

.sum-row__dot {
  width: 13px;
  height: 13px;
  border-radius: 9999px;
  border: 1px solid rgba(233, 244, 253, 0.3);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15);
}
</style>
