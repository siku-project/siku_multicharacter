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

watch(currentIndex, () => {
  activeCategoryId.value = ''
})

const isLast = computed(() => currentIndex.value === totalSteps - 1)

const stepCounter = computed(() => {
  const current = String(currentIndex.value + 1).padStart(2, '0')
  const total = String(totalSteps).padStart(2, '0')
  return `${current} / ${total}`
})

const progressFill = computed(() => `${((currentIndex.value + 1) / totalSteps) * 100}%`)

const selectStep = (index: number): void => {
  if (index !== currentIndex.value && index <= furthestIndex.value) {
    currentIndex.value = index
  }
}

const selectCategory = (id: string): void => {
  activeCategoryId.value = activeCategoryId.value === id ? '' : id
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
    <div class="veil-left" aria-hidden="true"></div>

    <Transition name="head-pop" appear>
      <CameraTips v-if="cameraControlsActive" variant="minimal" />
    </Transition>

    <div class="absolute inset-y-0 left-0 flex w-[920px] flex-col px-12 pb-10 pt-11">
      <Transition name="head-pop" appear>
        <div class="pointer-events-auto shrink-0">
          <div class="flex items-center gap-3.5">
            <span class="brand__bar"></span>
            <div>
              <p class="brand__name">SIKU</p>
              <p class="brand__tag">{{ t('appearance.subtitle') }}</p>
            </div>

            <div class="ml-auto flex items-center gap-3">
              <span class="progress" :style="{ '--fill': progressFill }"></span>
              <span class="counter">{{ stepCounter }}</span>
            </div>
          </div>
        </div>
      </Transition>

      <div class="pointer-events-auto mt-9 w-[680px] shrink-0">
        <p class="rail__label">{{ t('appearance.steps') }}</p>

        <div class="mt-4 flex flex-wrap gap-2">
          <button
            v-for="(step, index) in APPEARANCE_STEPS"
            :key="step.id"
            type="button"
            class="tab"
            :class="{
              'tab--active': index === currentIndex,
              'tab--locked': index > furthestIndex,
            }"
            :disabled="index > furthestIndex"
            @click="selectStep(index)"
          >
            <v-icon size="14" :icon="resolveIcon(step.icon)" />
            <span>{{ t(step.labelKey) }}</span>
            <span class="tab__dot" :class="{ 'tab__dot--lit': index < furthestIndex }"></span>
          </button>
        </div>
      </div>

      <div class="relative mt-9 min-h-0 flex-1">
        <Transition name="step-swap" mode="out-in">
          <div :key="currentStep.id" class="flex h-full min-h-0 gap-5">
            <template v-if="currentStep.id === 'ped'">
              <div class="pointer-events-auto flex w-[392px] flex-col">
                <div class="panel px-7 py-6">
                  <OptionSelect
                    :model-value="pedIndex"
                    :options="pedOptions"
                    :label="t('appearance.stepPed')"
                    :placeholder="t('appearance.pedPlaceholder')"
                    variant="minimal"
                    @update:model-value="handlePedSelect"
                  />
                </div>

                <button
                  type="button"
                  class="action action--primary mt-7"
                  :class="{ 'action--disabled': !pedModel }"
                  :disabled="!pedModel"
                  @click="goNext"
                >
                  {{ t('appearance.continue') }}
                  <v-icon size="17" :icon="resolveIcon('mdi-chevron-right')" />
                </button>
              </div>
            </template>

            <template v-else-if="currentStep.id === 'summary'">
              <div class="pointer-events-auto flex h-full min-h-0 w-[500px] flex-col">
                <div class="panel flex min-h-0 flex-col">
                  <div class="ice-scroll min-h-0 grow overflow-y-auto px-7 py-7">
                    <SummaryStep :draft="draft" :ped-model="pedModel" />
                  </div>
                </div>

                <button type="button" class="action action--primary mt-7" @click="goNext">
                  {{ t('appearance.validate') }}
                  <v-icon size="17" :icon="resolveIcon('mdi-chevron-right')" />
                </button>
              </div>
            </template>

            <template v-else>
              <div class="pointer-events-auto flex w-[336px] shrink-0 flex-col">
                <div class="ice-scroll flex min-h-0 flex-col gap-1.5 overflow-y-auto pb-1 pr-2">
                  <template v-for="(category, index) in categories" :key="category.id">
                    <div
                      v-if="category.group && category.group !== categories[index - 1]?.group"
                      class="flex items-center gap-3"
                      :class="index > 0 ? 'mb-1 mt-4' : 'mb-1'"
                    >
                      <span class="group__label">{{ t(category.group) }}</span>
                      <span class="group__line flex-1"></span>
                    </div>

                    <button
                      type="button"
                      class="row"
                      :class="{ 'row--active': category.id === activeCategoryId }"
                      @click="selectCategory(category.id)"
                    >
                      <span class="row__accent" aria-hidden="true"></span>
                      <span class="row__icon">
                        <v-icon size="16" :icon="resolveIcon(category.icon)" />
                      </span>
                      <span class="row__label">{{ t(category.labelKey) }}</span>
                      <v-icon
                        class="row__chevron ml-auto"
                        size="15"
                        :icon="resolveIcon('mdi-chevron-right')"
                      />
                    </button>
                  </template>
                </div>

                <button type="button" class="action action--primary mt-7" @click="goNext">
                  {{ t('appearance.continue') }}
                  <v-icon size="17" :icon="resolveIcon('mdi-chevron-right')" />
                </button>
              </div>

              <Transition name="detail-pop">
                <div
                  v-if="detailCategory"
                  class="pointer-events-auto flex min-h-0 w-[500px] flex-col"
                >
                  <div class="panel flex min-h-0 flex-col">
                    <div class="panel__head">
                      <span class="detail__icon">
                        <v-icon size="15" :icon="resolveIcon(detailCategory.icon)" />
                      </span>
                      <span class="detail__title">{{ t(detailCategory.labelKey) }}</span>
                    </div>

                    <div class="rule"></div>

                    <div class="ice-scroll min-h-0 grow overflow-y-auto px-7 py-6">
                      <CategoryDetail
                        :step-id="currentStep.id"
                        :category="resolvedDetailCategory ?? detailCategory"
                        :draft="draft"
                        variant="minimal"
                        @update="handleUpdate"
                      />
                    </div>
                  </div>
                </div>
              </Transition>
            </template>
          </div>
        </Transition>
      </div>
    </div>
  </div>
</template>

<style scoped>
.veil-left {
  position: absolute;
  inset: 0 auto 0 0;
  width: 52%;
  background: linear-gradient(
    to right,
    rgba(8, 15, 28, 0.97) 0%,
    rgba(8, 15, 28, 0.88) 34%,
    rgba(8, 15, 28, 0.55) 62%,
    transparent 100%
  );
}

.brand__bar {
  width: 2px;
  height: 37px;
  border-radius: 9999px;
  background: linear-gradient(to bottom, rgba(226, 240, 255, 0.95), rgba(120, 170, 220, 0.35));
  box-shadow: 0 0 12px rgba(190, 224, 255, 0.5);
}

.brand__name {
  font-size: 20.5px;
  font-weight: 600;
  letter-spacing: 0.34em;
  color: rgba(244, 250, 255, 0.97);
}

.brand__tag {
  margin-top: 4px;
  font-size: 10.2px;
  font-weight: 300;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.55);
}

.progress {
  display: block;
  height: 2px;
  width: 96px;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(226, 240, 255, 0.85) 0%,
    rgba(226, 240, 255, 0.85) var(--fill, 0%),
    rgba(150, 190, 225, 0.18) var(--fill, 0%)
  );
  transition: background 0.35s ease;
}

.counter {
  font-family: ui-monospace, monospace;
  font-size: 10.5px;
  letter-spacing: 0.1em;
  font-variant-numeric: tabular-nums;
  color: rgba(170, 200, 228, 0.55);
}

.rail__label {
  font-size: 10.2px;
  font-weight: 400;
  letter-spacing: 0.34em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.48);
}

.tab {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border-radius: 9999px;
  border: 1px solid rgba(150, 190, 225, 0.12);
  background: linear-gradient(180deg, rgba(18, 30, 48, 0.55) 0%, rgba(10, 20, 35, 0.62) 100%);
  padding: 8px 15px;
  font-size: 10.8px;
  font-weight: 400;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: rgba(206, 226, 245, 0.62);
  transition:
    border-color 0.22s ease,
    background 0.22s ease,
    color 0.22s ease;
}

.tab:hover:not(.tab--locked):not(.tab--active) {
  border-color: rgba(180, 214, 245, 0.24);
  color: rgba(236, 246, 255, 0.9);
}

.tab--active {
  border-color: rgba(198, 228, 255, 0.42);
  background: linear-gradient(180deg, rgba(34, 58, 88, 0.72) 0%, rgba(16, 30, 50, 0.72) 100%);
  color: rgba(244, 250, 255, 0.97);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.12),
    0 10px 28px -18px rgba(120, 180, 240, 0.7);
}

.tab--locked {
  cursor: default;
  opacity: 0.34;
}

.tab__dot {
  width: 4px;
  height: 4px;
  border-radius: 9999px;
  border: 1px solid rgba(160, 192, 222, 0.3);
  transition:
    background 0.3s ease,
    border-color 0.3s ease;
}

.tab__dot--lit {
  background: rgba(226, 244, 255, 0.9);
  border-color: rgba(226, 244, 255, 0.5);
  box-shadow: 0 0 7px rgba(190, 224, 255, 0.6);
}

.group__label {
  font-size: 9.4px;
  font-weight: 400;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.48);
}

.group__line {
  height: 1px;
  background: linear-gradient(to right, rgba(160, 200, 235, 0.16), transparent 85%);
}

.row {
  position: relative;
  display: flex;
  width: 100%;
  align-items: center;
  gap: 12px;
  overflow: hidden;
  border-radius: 13px;
  border: 1px solid rgba(150, 190, 225, 0.12);
  background: linear-gradient(180deg, rgba(18, 30, 48, 0.55) 0%, rgba(10, 20, 35, 0.62) 100%);
  padding: 11px 14px;
  transition:
    border-color 0.22s ease,
    background 0.22s ease;
}

.row:hover:not(.row--active) {
  border-color: rgba(180, 214, 245, 0.24);
  background: linear-gradient(180deg, rgba(24, 40, 62, 0.62) 0%, rgba(13, 25, 42, 0.68) 100%);
}

.row--active {
  border-color: rgba(198, 228, 255, 0.42);
  background: linear-gradient(180deg, rgba(34, 58, 88, 0.72) 0%, rgba(16, 30, 50, 0.72) 100%);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.12),
    0 10px 28px -18px rgba(120, 180, 240, 0.7);
}

.row__accent {
  position: absolute;
  left: 0;
  top: 50%;
  height: 0;
  width: 2px;
  border-radius: 9999px;
  background: linear-gradient(to bottom, rgba(226, 244, 255, 0.95), rgba(140, 190, 240, 0.4));
  box-shadow: 0 0 10px rgba(190, 224, 255, 0.6);
  transform: translateY(-50%);
  opacity: 0;
  transition:
    height 0.24s ease,
    opacity 0.24s ease;
}

.row--active .row__accent {
  height: 56%;
  opacity: 1;
}

.row__icon {
  display: flex;
  height: 30px;
  width: 30px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  border: 1px solid rgba(160, 200, 235, 0.2);
  color: rgba(198, 224, 243, 0.68);
  transition:
    color 0.22s ease,
    border-color 0.22s ease;
}

.row--active .row__icon {
  border-color: rgba(214, 238, 255, 0.5);
  color: rgba(244, 250, 255, 0.97);
}

.row__label {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 12.4px;
  font-weight: 400;
  letter-spacing: 0.06em;
  color: rgba(224, 238, 252, 0.82);
}

.row--active .row__label {
  font-weight: 500;
  color: rgba(244, 250, 255, 0.97);
}

.row__chevron {
  flex-shrink: 0;
  color: rgba(160, 192, 222, 0.35);
  transition:
    color 0.22s ease,
    transform 0.22s ease;
}

.row--active .row__chevron {
  color: rgba(214, 238, 255, 0.7);
  transform: translateX(2px);
}

.panel {
  position: relative;
  overflow: hidden;
  border-radius: 20px;
  border: 1px solid rgba(160, 200, 235, 0.16);
  background:
    var(--ice-noise),
    radial-gradient(120% 90% at 50% -10%, rgba(120, 170, 220, 0.14) 0%, transparent 60%),
    linear-gradient(180deg, rgba(19, 32, 51, 0.97) 0%, rgba(11, 21, 36, 0.98) 100%);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.1),
    0 40px 90px -40px rgba(4, 10, 22, 0.9);
}

.panel::before {
  content: '';
  position: absolute;
  inset-inline: 22%;
  top: -1px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(226, 240, 255, 0.55), transparent);
}

.panel__head {
  display: flex;
  align-items: center;
  gap: 13px;
  padding: 18px 22px 16px;
}

.rule {
  height: 1px;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(160, 200, 235, 0.18) 12%,
    rgba(160, 200, 235, 0.18) 88%,
    transparent
  );
}

.detail__icon {
  display: flex;
  height: 30px;
  width: 30px;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  border: 1px solid rgba(214, 238, 255, 0.42);
  color: rgba(244, 250, 255, 0.96);
  box-shadow: 0 0 14px -4px rgba(190, 224, 255, 0.5);
}

.detail__title {
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(244, 250, 255, 0.96);
}

.action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
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
    color 0.2s ease;
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

.panel :deep(.ice-field-label) {
  font-size: 9.8px;
  font-weight: 400;
  letter-spacing: 0.2em;
  color: rgba(170, 200, 228, 0.55);
}

.panel :deep(.ice-field-count),
.panel :deep(.range__value) {
  font-size: 11px;
  letter-spacing: 0.05em;
  color: rgba(214, 234, 252, 0.75);
  text-shadow: none;
}

.panel :deep(.range__value--blend) {
  font-size: 10px;
}

.panel :deep(.ice-pole) {
  font-size: 9.6px;
  font-weight: 300;
  letter-spacing: 0.1em;
  color: rgba(160, 192, 222, 0.42);
}

.panel :deep(.range__pole--lit) {
  color: rgba(226, 244, 255, 0.9);
  text-shadow: none;
}

.panel :deep(.detail-sec__label) {
  font-size: 9.8px;
  font-weight: 400;
  letter-spacing: 0.2em;
  color: rgba(198, 224, 243, 0.72);
  text-shadow: none;
}

.panel :deep(.detail-sec__line),
.panel :deep(.sum-sec__line),
.panel :deep(.sum-hero__divider) {
  background: linear-gradient(to right, rgba(160, 200, 235, 0.18), transparent 88%);
  box-shadow: none;
}

.panel :deep(.portrait) {
  border-radius: 12px;
  border-color: rgba(160, 200, 235, 0.16);
  background: linear-gradient(180deg, rgba(18, 30, 48, 0.55) 0%, rgba(10, 20, 35, 0.62) 100%);
  box-shadow: none;
}

.panel :deep(.portrait__name) {
  font-size: 10.2px;
  font-weight: 400;
  letter-spacing: 0.16em;
  color: rgba(214, 234, 252, 0.78);
}

.panel :deep(.sum-hero) {
  font-size: 30px;
  font-weight: 300;
  letter-spacing: -0.01em;
  text-shadow: none;
}

.panel :deep(.sum-hero__meta) {
  font-size: 10.2px;
  letter-spacing: 0.2em;
  color: rgba(170, 200, 228, 0.5);
}

.panel :deep(.sum-sec__label) {
  font-size: 9.8px;
  font-weight: 400;
  letter-spacing: 0.2em;
  color: rgba(198, 224, 243, 0.72);
  text-shadow: none;
}

.panel :deep(.sum-cat) {
  font-size: 10.2px;
  letter-spacing: 0.14em;
  color: rgba(214, 234, 252, 0.72);
  text-shadow: none;
}

.panel :deep(.sum-row__label) {
  font-size: 11px;
  color: rgba(170, 200, 228, 0.55);
}

.panel :deep(.sum-row__value) {
  font-size: 12.4px;
  font-weight: 400;
  color: rgba(240, 248, 255, 0.94);
  text-shadow: none;
}

.step-swap-enter-active {
  transition:
    opacity 0.28s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.28s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.step-swap-leave-active {
  transition:
    opacity 0.15s ease,
    transform 0.15s ease;
}

.step-swap-enter-from {
  opacity: 0;
  transform: translateY(8px);
}

.step-swap-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

.detail-pop-enter-active {
  transition:
    opacity 0.3s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.3s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.detail-pop-leave-active {
  transition:
    opacity 0.16s ease,
    transform 0.16s ease;
}

.detail-pop-enter-from {
  opacity: 0;
  transform: translateX(-14px);
}

.detail-pop-leave-to {
  opacity: 0;
  transform: translateX(-8px);
}

.head-pop-enter-active {
  transition:
    opacity 0.5s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.5s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.head-pop-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}
</style>
