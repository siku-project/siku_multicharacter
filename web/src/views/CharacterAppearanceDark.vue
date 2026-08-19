<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import CameraTips from '@/components/appearance/CameraTips.vue'
import CategoryDetail from '@/components/appearance/CategoryDetail.vue'
import OptionSelect from '@/components/appearance/controls/OptionSelect.vue'
import SummaryStep from '@/components/appearance/steps/SummaryStep.vue'
import { storeToRefs } from 'pinia'
import { resolveIcon } from '@/utils/icons'
import { sendNuiCallback } from '@/utils/nui'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { APPEARANCE_STEPS, controlKey, createAppearanceDraft } from '@/config/appearance'
import type { AppearanceCategory, AppearanceStepDefinition, PedModel } from '@/config/appearance'
import { buildPhysicalPayload } from '@/utils/physical'
import { CLOTHING_CATEGORIES, buildClothingPayload } from '@/utils/clothing'
import { ACCESSORY_CATEGORIES, buildAccessoryPayload } from '@/utils/accessories'
import { TATTOO_ZONES, buildTattooPayload } from '@/utils/tattoos'

const { t } = useI18n()

const BASIC_PED_LABELS: Record<string, string> = {
  mp_m_freemode_01: 'appearance.pedMale',
  mp_f_freemode_01: 'appearance.pedFemale',
}

const { pedsConfig, heritageConfig, appearanceLimits } = storeToRefs(useMulticharacterStore())

const LIMIT_BINDINGS: Record<string, string> = {
  ...Object.fromEntries(
    CLOTHING_CATEGORIES.flatMap((category) => [
      [controlKey('clothing', category, 'model'), `${category}Model`],
      [controlKey('clothing', category, 'variant'), `${category}Variant`],
    ]),
  ),
  ...Object.fromEntries(
    ACCESSORY_CATEGORIES.flatMap((category) => [
      [controlKey('accessories', category, 'model'), `${category}Model`],
      [controlKey('accessories', category, 'variant'), `${category}Variant`],
    ]),
  ),
  ...Object.fromEntries(
    TATTOO_ZONES.map((zone) => [controlKey('tattoos', zone, 'tattoo'), `${zone}Tattoo`]),
  ),
  [controlKey('physical', 'hair', 'style')]: 'hairStyles',
  [controlKey('physical', 'eyebrows', 'shape')]: 'eyebrows',
  [controlKey('physical', 'beard', 'style')]: 'beard',
  [controlKey('physical', 'chestHair', 'style')]: 'chestHair',
  [controlKey('physical', 'ageing', 'style')]: 'ageing',
  [controlKey('physical', 'makeup', 'lipstickStyle')]: 'lipstick',
  [controlKey('physical', 'makeup', 'makeupStyle')]: 'makeup',
  [controlKey('physical', 'makeup', 'blushStyle')]: 'blush',
  [controlKey('physical', 'skinDamage', 'sunDamageStyle')]: 'sunDamage',
  [controlKey('physical', 'skinDamage', 'molesStyle')]: 'moles',
  [controlKey('physical', 'skinDamage', 'blemishesStyle')]: 'blemishes',
}

const availablePeds = computed<PedModel[]>(() => {
  const models: PedModel[] = pedsConfig.value.basics.map((id) => ({
    id,
    labelKey: BASIC_PED_LABELS[id],
    name: id,
  }))

  if (pedsConfig.value.authorizeAll) {
    for (const id of pedsConfig.value.peds) {
      models.push({ id, name: id })
    }
  }

  return models
})

const currentIndex = ref(0)
const furthestIndex = ref(0)
const draft = reactive(createAppearanceDraft())
const pedModel = ref('')
const activeCategoryId = ref('')

const totalSteps = APPEARANCE_STEPS.length

const currentStep = computed(
  () => APPEARANCE_STEPS[currentIndex.value] ?? (APPEARANCE_STEPS[0] as AppearanceStepDefinition),
)

const categories = computed(() => currentStep.value.categories ?? [])

const categoryGroups = computed(() => {
  const groups: { key: string; label: string; items: AppearanceCategory[] }[] = []

  for (const category of categories.value) {
    const key = category.group ?? ''
    const last = groups[groups.length - 1]

    if (last && last.key === key) {
      last.items.push(category)
      continue
    }

    groups.push({ key, label: key ? t(key) : '', items: [category] })
  }

  return groups
})

const detailCategory = computed(() =>
  categories.value.find((category) => category.id === activeCategoryId.value),
)

const resolvedDetailCategory = computed<AppearanceCategory | undefined>(() => {
  const category = detailCategory.value

  if (!category) {
    return category
  }

  return {
    ...category,
    controls: category.controls.map((control) => {
      const limitKey = LIMIT_BINDINGS[controlKey(currentStep.value.id, category.id, control.id)]
      const limit = limitKey ? appearanceLimits.value[limitKey] : undefined

      if (!limit || limit <= 0) {
        return control
      }

      return { ...control, max: limit, unit: `/ ${limit}` }
    }),
  }
})

watch(
  categories,
  (list) => {
    activeCategoryId.value = list[0]?.id ?? ''
  },
  { immediate: true },
)

const isLast = computed(() => currentIndex.value === totalSteps - 1)

const stepCounter = computed(() => {
  const current = String(currentIndex.value + 1).padStart(2, '0')
  const total = String(totalSteps).padStart(2, '0')
  return `${current}/${total}`
})

const progressFill = computed(() => `${((currentIndex.value + 1) / totalSteps) * 100}%`)

const selectStep = (index: number): void => {
  if (index !== currentIndex.value && index <= furthestIndex.value) {
    currentIndex.value = index
  }
}

const pedOptions = computed(() =>
  availablePeds.value.map((model) => ({
    label: model.labelKey ? t(model.labelKey) : (model.name ?? model.id),
    mono: model.id,
  })),
)

const pedIndex = computed(() =>
  availablePeds.value.findIndex((model) => model.id === pedModel.value),
)

const handlePedSelect = (index: number): void => {
  pedModel.value = availablePeds.value[index]?.id ?? ''

  if (pedModel.value) {
    void sendNuiCallback('siku_multicharacter:nui:pedSelected', { model: pedModel.value })
  }
}

const handleUpdate = (key: string, value: number): void => {
  draft[key] = value
}

const heritagePayload = computed(() => {
  const mother =
    heritageConfig.value.mothers[draft[controlKey('heritage', 'parents', 'mother')] ?? 0]
  const father =
    heritageConfig.value.fathers[draft[controlKey('heritage', 'parents', 'father')] ?? 0]

  return {
    mother: mother?.id ?? 21,
    father: father?.id ?? 0,
    resemblance: (draft[controlKey('heritage', 'resemblance', 'resemblance')] ?? 50) / 100,
    skinTone: (draft[controlKey('heritage', 'resemblance', 'skinTone')] ?? 50) / 100,
  }
})

watch(heritagePayload, (payload) => {
  void sendNuiCallback('siku_multicharacter:nui:heritageChanged', payload)
})

const physicalPayload = computed(() => buildPhysicalPayload(draft))

watch(physicalPayload, (payload) => {
  void sendNuiCallback('siku_multicharacter:nui:physicalChanged', payload)
})

const clothingPayload = computed(() => buildClothingPayload(draft))

watch(clothingPayload, (payload) => {
  void sendNuiCallback('siku_multicharacter:nui:clothingChanged', payload)
})

const accessoryPayload = computed(() => buildAccessoryPayload(draft))

watch(accessoryPayload, (payload) => {
  void sendNuiCallback('siku_multicharacter:nui:accessoriesChanged', payload)
})

const tattooPayload = computed(() => buildTattooPayload(draft))

watch(tattooPayload, (payload) => {
  void sendNuiCallback('siku_multicharacter:nui:tattoosChanged', payload)
})

const UI_ZONE_RATIO = 0.4

const cameraControlsActive = computed(() => currentStep.value.id !== 'ped')

let leftHeld = false
let rightHeld = false

const isInsideUiZone = (event: MouseEvent): boolean =>
  event.clientX < window.innerWidth * UI_ZONE_RATIO

const handleMouseDown = (event: MouseEvent): void => {
  if (!cameraControlsActive.value || isInsideUiZone(event)) {
    return
  }

  if (event.button === 0) {
    leftHeld = true
    void sendNuiCallback('siku_multicharacter:nui:cameraControlStart', { type: 'pan' })
  } else if (event.button === 2) {
    rightHeld = true
    void sendNuiCallback('siku_multicharacter:nui:cameraControlStart', { type: 'rotate' })
  }
}

const handleMouseUp = (event: MouseEvent): void => {
  if (event.button === 0 && leftHeld) {
    leftHeld = false
    void sendNuiCallback('siku_multicharacter:nui:cameraControlStop', { type: 'pan' })
  } else if (event.button === 2 && rightHeld) {
    rightHeld = false
    void sendNuiCallback('siku_multicharacter:nui:cameraControlStop', { type: 'rotate' })
  }
}

const handleMouseMove = (event: MouseEvent): void => {
  if (!leftHeld && !rightHeld) {
    return
  }

  void sendNuiCallback('siku_multicharacter:nui:cameraControlMove', {
    type: leftHeld ? 'pan' : 'rotate',
    movementX: event.movementX,
    movementY: event.movementY,
  })
}

const handleWheel = (event: WheelEvent): void => {
  if (!cameraControlsActive.value || isInsideUiZone(event)) {
    return
  }

  event.preventDefault()

  void sendNuiCallback('siku_multicharacter:nui:cameraZoom', {
    zoomIn: event.deltaY < 0,
    mouseX: event.clientX / window.innerWidth,
    mouseY: event.clientY / window.innerHeight,
  })
}

const handleContextMenu = (event: MouseEvent): void => {
  if (!isInsideUiZone(event)) {
    event.preventDefault()
  }
}

onMounted(() => {
  document.addEventListener('mousedown', handleMouseDown)
  document.addEventListener('mouseup', handleMouseUp)
  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('wheel', handleWheel, { passive: false })
  document.addEventListener('contextmenu', handleContextMenu)
})

onBeforeUnmount(() => {
  document.removeEventListener('mousedown', handleMouseDown)
  document.removeEventListener('mouseup', handleMouseUp)
  document.removeEventListener('mousemove', handleMouseMove)
  document.removeEventListener('wheel', handleWheel)
  document.removeEventListener('contextmenu', handleContextMenu)
})

const goBack = (): void => {
  if (currentIndex.value > 0) {
    currentIndex.value -= 1
  }
}

const goNext = (): void => {
  if (isLast.value) {
    void sendNuiCallback('siku_multicharacter:nui:appearanceValidated', {
      pedModel: pedModel.value,
      appearance: {
        heritage: heritagePayload.value,
        physical: physicalPayload.value,
        clothing: clothingPayload.value,
        accessories: accessoryPayload.value,
        tattoos: tattooPayload.value,
      },
    })
    return
  }

  currentIndex.value += 1
  furthestIndex.value = Math.max(furthestIndex.value, currentIndex.value)
}
</script>

<template>
  <div class="pointer-events-none fixed inset-0 select-none">
    <Transition name="head-pop" appear>
      <CameraTips v-if="cameraControlsActive" variant="dark" />
    </Transition>

    <div class="shell pointer-events-auto">
      <header class="shell__head">
        <span class="brand__bar"></span>
        <div class="min-w-0">
          <p class="brand__name">SIKU</p>
          <p class="brand__tag">{{ t('appearance.subtitle') }}</p>
        </div>

        <div class="ml-auto flex items-center gap-3">
          <span class="progress" :style="{ '--fill': progressFill }"></span>
          <span class="counter">{{ stepCounter }}</span>
        </div>
      </header>

      <div class="rule"></div>

      <div class="flex min-h-0 flex-1">
        <nav class="rail">
          <button
            v-for="(step, index) in APPEARANCE_STEPS"
            :key="step.id"
            type="button"
            class="step"
            :class="{
              'step--active': index === currentIndex,
              'step--done': index < furthestIndex,
              'step--locked': index > furthestIndex,
            }"
            :title="t(step.labelKey)"
            :disabled="index > furthestIndex"
            @click="selectStep(index)"
          >
            <v-icon size="17" :icon="resolveIcon(step.icon)" />
            <span class="step__dot"></span>
          </button>
        </nav>

        <section class="flex min-h-0 flex-1 flex-col">
          <div class="pane__head">
            <h1 class="pane__title">{{ t(currentStep.labelKey) }}</h1>
            <span v-if="detailCategory" class="pane__crumb">
              {{ t(detailCategory.labelKey) }}
            </span>
          </div>

          <template v-if="categoryGroups.length > 0">
            <div class="pane__filters">
              <div
                v-for="group in categoryGroups"
                :key="group.key || 'root'"
                class="flex flex-col gap-2.5"
              >
                <span v-if="group.label" class="filters__label">{{ group.label }}</span>
                <div class="flex flex-wrap gap-2">
                  <button
                    v-for="category in group.items"
                    :key="category.id"
                    type="button"
                    class="chip"
                    :class="{ 'chip--active': category.id === activeCategoryId }"
                    @click="activeCategoryId = category.id"
                  >
                    <v-icon size="13" :icon="resolveIcon(category.icon)" />
                    {{ t(category.labelKey) }}
                  </button>
                </div>
              </div>
            </div>

            <div class="rule"></div>
          </template>

          <div class="ice-scroll min-h-0 flex-1 overflow-y-auto px-6 py-6">
            <Transition name="pane-swap" mode="out-in">
              <div v-if="currentStep.id === 'ped'" key="ped">
                <OptionSelect
                  :model-value="pedIndex"
                  :options="pedOptions"
                  :label="t('appearance.stepPed')"
                  :placeholder="t('appearance.pedPlaceholder')"
                  variant="dark"
                  @update:model-value="handlePedSelect"
                />
              </div>

              <div v-else-if="currentStep.id === 'summary'" key="summary">
                <SummaryStep :draft="draft" :ped-model="pedModel" />
              </div>

              <CategoryDetail
                v-else-if="detailCategory"
                :key="`${currentStep.id}-${detailCategory.id}`"
                :step-id="currentStep.id"
                :category="resolvedDetailCategory ?? detailCategory"
                :draft="draft"
                variant="dark"
                @update="handleUpdate"
              />
            </Transition>
          </div>

          <div class="rule"></div>

          <footer class="shell__foot">
            <button v-if="currentIndex > 0" type="button" class="btn btn--ghost" @click="goBack">
              {{ t('appearance.back') }}
            </button>

            <button
              type="button"
              class="btn btn--primary ml-auto"
              :class="{ 'btn--disabled': currentStep.id === 'ped' && !pedModel }"
              :disabled="currentStep.id === 'ped' && !pedModel"
              @click="goNext"
            >
              {{ isLast ? t('appearance.validate') : t('appearance.continue') }}
            </button>
          </footer>
        </section>
      </div>
    </div>
  </div>
</template>

<style scoped>
.shell {
  position: absolute;
  left: 52px;
  top: 50%;
  display: flex;
  height: min(880px, calc(100vh - 76px));
  width: 580px;
  flex-direction: column;
  overflow: hidden;
  transform: translateY(-50%);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(11, 12, 14, 0.97);
  box-shadow: 0 44px 100px -44px rgba(0, 0, 0, 0.95);
}

.shell__head {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  gap: 13px;
  padding: 18px 22px;
}

.shell__foot {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  gap: 10px;
  padding: 16px 22px;
}

.rule {
  height: 1px;
  flex-shrink: 0;
  background: rgba(255, 255, 255, 0.06);
}

.brand__bar {
  width: 3px;
  height: 32px;
  flex-shrink: 0;
  border-radius: 9999px;
  background: #6cb6f6;
  box-shadow: 0 0 14px rgba(108, 182, 246, 0.7);
}

.brand__name {
  font-size: 15px;
  font-weight: 600;
  letter-spacing: 0.03em;
  color: rgba(255, 255, 255, 0.96);
}

.brand__tag {
  margin-top: 3px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.34);
}

.progress {
  display: block;
  height: 2px;
  width: 74px;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    #6cb6f6 0%,
    #6cb6f6 var(--fill, 0%),
    rgba(255, 255, 255, 0.1) var(--fill, 0%)
  );
  transition: background 0.3s ease;
}

.counter {
  font-family: ui-monospace, monospace;
  font-size: 11px;
  font-variant-numeric: tabular-nums;
  color: rgba(255, 255, 255, 0.34);
}

.rail {
  display: flex;
  width: 62px;
  flex-shrink: 0;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  border-right: 1px solid rgba(255, 255, 255, 0.06);
  padding: 14px 0;
}

.step {
  position: relative;
  display: flex;
  height: 42px;
  width: 42px;
  align-items: center;
  justify-content: center;
  border-radius: 11px;
  color: rgba(255, 255, 255, 0.34);
  transition:
    background 0.16s ease,
    color 0.16s ease,
    box-shadow 0.16s ease;
}

.step:hover:not(.step--locked):not(.step--active) {
  background: rgba(255, 255, 255, 0.04);
  color: rgba(255, 255, 255, 0.72);
}

.step--active {
  background: rgba(108, 182, 246, 0.13);
  box-shadow: inset 0 0 0 1px rgba(108, 182, 246, 0.32);
  color: #9ed0fb;
}

.step--locked {
  cursor: default;
  opacity: 0.26;
}

.step__dot {
  position: absolute;
  bottom: 7px;
  left: 50%;
  height: 3px;
  width: 3px;
  border-radius: 9999px;
  background: transparent;
  transform: translateX(-50%);
  transition: background 0.3s ease;
}

.step--done .step__dot {
  background: rgba(108, 182, 246, 0.75);
}

.step--active .step__dot {
  background: transparent;
}

.pane__head {
  display: flex;
  flex-shrink: 0;
  align-items: baseline;
  gap: 10px;
  padding: 18px 22px 14px;
}

.pane__title {
  font-size: 17px;
  font-weight: 600;
  letter-spacing: -0.01em;
  color: rgba(255, 255, 255, 0.96);
}

.pane__crumb {
  font-size: 11.5px;
  font-weight: 500;
  color: rgba(158, 208, 251, 0.75);
}

.pane__crumb::before {
  content: '/';
  margin-right: 8px;
  color: rgba(255, 255, 255, 0.18);
}

.pane__filters {
  display: flex;
  flex-shrink: 0;
  flex-direction: column;
  gap: 14px;
  padding: 2px 22px 20px;
}

.filters__label {
  font-size: 9.6px;
  font-weight: 500;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.3);
}

.chip {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border-radius: 9px;
  border: 1px solid rgba(255, 255, 255, 0.07);
  background: rgba(255, 255, 255, 0.028);
  padding: 9px 14px;
  font-size: 12.2px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.55);
  transition:
    border-color 0.16s ease,
    background 0.16s ease,
    color 0.16s ease;
}

.chip:hover:not(.chip--active) {
  border-color: rgba(255, 255, 255, 0.14);
  color: rgba(255, 255, 255, 0.82);
}

.chip--active {
  border-color: rgba(108, 182, 246, 0.42);
  background: rgba(108, 182, 246, 0.13);
  color: #9ed0fb;
}

.btn {
  border-radius: 9px;
  padding: 10px 22px;
  font-size: 11.6px;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  transition:
    background 0.16s ease,
    border-color 0.16s ease,
    color 0.16s ease;
}

.btn--ghost {
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  color: rgba(255, 255, 255, 0.45);
}

.btn--ghost:hover {
  border-color: rgba(255, 255, 255, 0.16);
  color: rgba(255, 255, 255, 0.82);
}

.btn--primary {
  border: 1px solid rgba(108, 182, 246, 0.55);
  background: #6cb6f6;
  color: rgba(5, 10, 16, 0.94);
  box-shadow: 0 10px 26px -14px rgba(108, 182, 246, 0.95);
}

.btn--primary:hover:not(.btn--disabled) {
  background: #8ac8fb;
}

.btn--disabled {
  cursor: not-allowed;
  border-color: rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.045);
  color: rgba(255, 255, 255, 0.3);
  box-shadow: none;
}

.shell :deep(.ice-field-label) {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.14em;
  color: rgba(255, 255, 255, 0.34);
}

.shell :deep(.ice-field-count),
.shell :deep(.range__value) {
  font-size: 11px;
  letter-spacing: 0.02em;
  color: rgba(255, 255, 255, 0.62);
  text-shadow: none;
}

.shell :deep(.range__value--blend) {
  font-size: 10px;
}

.shell :deep(.ice-pole) {
  font-size: 9.6px;
  font-weight: 400;
  letter-spacing: 0.06em;
  color: rgba(255, 255, 255, 0.26);
}

.shell :deep(.range__pole--lit) {
  color: #9ed0fb;
  text-shadow: none;
}

.shell :deep(.range__input::-webkit-slider-thumb) {
  width: 13px;
  height: 13px;
  border: none;
  background: #6cb6f6;
  box-shadow: 0 0 10px rgba(108, 182, 246, 0.7);
}

.shell :deep(.swatches__dot--active) {
  border-color: rgba(108, 182, 246, 0.9);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.18),
    0 0 0 2px rgba(108, 182, 246, 0.35);
}

.shell :deep(.sprite__cell--active) {
  border-color: rgba(108, 182, 246, 0.9);
  box-shadow:
    0 0 0 2px rgba(108, 182, 246, 0.35),
    0 6px 14px -8px rgba(0, 0, 0, 0.8);
}

.shell :deep(.detail-sec__label) {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.14em;
  color: rgba(255, 255, 255, 0.5);
  text-shadow: none;
}

.shell :deep(.detail-sec__line),
.shell :deep(.sum-sec__line),
.shell :deep(.sum-hero__divider) {
  background: rgba(255, 255, 255, 0.06);
  box-shadow: none;
}

.shell :deep(.portrait) {
  border-radius: 10px;
  border-color: rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  box-shadow: none;
}

.shell :deep(.portrait__name) {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.12em;
  color: rgba(255, 255, 255, 0.5);
}

.shell :deep(.sum-hero) {
  font-size: 26px;
  font-weight: 600;
  letter-spacing: -0.015em;
  color: rgba(255, 255, 255, 0.97);
  text-shadow: none;
}

.shell :deep(.sum-hero__meta) {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.16em;
  color: rgba(255, 255, 255, 0.34);
}

.shell :deep(.sum-sec__label) {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.14em;
  color: rgba(255, 255, 255, 0.5);
  text-shadow: none;
}

.shell :deep(.sum-cat) {
  font-size: 10.2px;
  font-weight: 500;
  letter-spacing: 0.08em;
  color: rgba(158, 208, 251, 0.75);
  text-shadow: none;
}

.shell :deep(.sum-row__label) {
  font-size: 11px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.34);
}

.shell :deep(.sum-row__value) {
  font-size: 12.4px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.9);
  text-shadow: none;
}

.shell :deep(.sum-row__mono) {
  color: rgba(255, 255, 255, 0.26);
}

.shell :deep(.sum-row__dot) {
  border-color: rgba(255, 255, 255, 0.16);
}

.pane-swap-enter-active {
  transition:
    opacity 0.2s ease,
    transform 0.2s ease;
}

.pane-swap-leave-active {
  transition:
    opacity 0.12s ease,
    transform 0.12s ease;
}

.pane-swap-enter-from {
  opacity: 0;
  transform: translateY(6px);
}

.pane-swap-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

.head-pop-enter-active {
  transition:
    opacity 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.45s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.head-pop-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}
</style>
