<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import IcePanel from '@/components/ui/IcePanel.vue'
import IceButton from '@/components/ui/IceButton.vue'
import CameraTips from '@/components/appearance/CameraTips.vue'
import StepTabs from '@/components/appearance/StepTabs.vue'
import CategoryCard from '@/components/appearance/CategoryCard.vue'
import CategoryDetail from '@/components/appearance/CategoryDetail.vue'
import OptionSelect from '@/components/appearance/controls/OptionSelect.vue'
import SummaryStep from '@/components/appearance/steps/SummaryStep.vue'
import { storeToRefs } from 'pinia'
import { resolveIcon } from '@/utils/icons'
import { sendNuiCallback } from '@/utils/nui'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { APPEARANCE_STEPS, controlKey, createAppearanceDraft } from '@/config/appearance'
import type { AppearanceStepDefinition, PedModel } from '@/config/appearance'

const { t } = useI18n()

const BASIC_PED_LABELS: Record<string, string> = {
  mp_m_freemode_01: 'appearance.pedMale',
  mp_f_freemode_01: 'appearance.pedFemale',
}

const { pedsConfig, heritageConfig } = storeToRefs(useMulticharacterStore())

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

watch(currentIndex, () => {
  activeCategoryId.value = ''
})

const isLast = computed(() => currentIndex.value === totalSteps - 1)

const stepCounter = computed(() => {
  const current = String(currentIndex.value + 1).padStart(2, '0')
  const total = String(totalSteps).padStart(2, '0')
  return `${current} / ${total}`
})

const selectCategory = (id: string): void => {
  activeCategoryId.value = id
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
    console.log('[siku_multicharacter] appearance validated', {
      pedModel: pedModel.value,
      draft: { ...draft },
    })
    return
  }
  currentIndex.value += 1
  furthestIndex.value = Math.max(furthestIndex.value, currentIndex.value)
}
</script>

<template>
  <div class="pointer-events-none fixed inset-0">
    <div class="scrim absolute inset-0" aria-hidden="true"></div>

    <Transition name="head-pop" appear>
      <CameraTips v-if="cameraControlsActive" />
    </Transition>

    <div class="absolute inset-y-0 left-0 flex w-[880px] flex-col px-10 pb-8 pt-9">
      <Transition name="head-pop" appear>
        <div class="pointer-events-auto shrink-0">
          <div class="flex items-baseline gap-4">
            <span class="head__brand">SIKU</span>
            <span class="head__subtitle">{{ t('appearance.subtitle') }}</span>
            <span class="head__counter ml-auto">{{ stepCounter }}</span>
          </div>
          <div class="head__line mt-5"></div>
        </div>
      </Transition>

      <StepTabs
        class="pointer-events-auto mt-5 w-[620px] shrink-0"
        :steps="APPEARANCE_STEPS"
        :current-index="currentIndex"
        :furthest-index="furthestIndex"
        @select="currentIndex = $event"
      />

      <div class="relative mt-10 min-h-0 flex-1">
        <Transition name="step-swap" mode="out-in">
          <div :key="currentStep.id" class="flex h-full min-h-0">
            <template v-if="currentStep.id === 'ped'">
              <div class="pointer-events-auto flex w-[400px] flex-col">
                <div>
                  <OptionSelect
                    :model-value="pedIndex"
                    :options="pedOptions"
                    :label="t('appearance.stepPed')"
                    :placeholder="t('appearance.pedPlaceholder')"
                    @update:model-value="handlePedSelect"
                  />
                </div>
                <div class="nav mt-8 flex shrink-0 items-center">
                  <IceButton
                    class="flex-1"
                    :label="t('appearance.continue')"
                    icon="mdi-chevron-right"
                    variant="primary"
                    :disabled="!pedModel"
                    @click="goNext"
                  />
                </div>
              </div>
            </template>

            <template v-else-if="currentStep.id === 'summary'">
              <div class="pointer-events-auto flex h-full min-h-0 w-[470px] flex-col">
                <IcePanel
                  variant="primary"
                  class="detail-flex dense flex min-h-0 flex-col overflow-hidden"
                >
                  <div class="flex min-h-0 flex-col px-7 pb-7 pt-6">
                    <div class="ice-scroll min-h-0 grow overflow-y-auto pr-2.5">
                      <SummaryStep :draft="draft" :ped-model="pedModel" />
                    </div>
                  </div>
                </IcePanel>
                <div class="nav mt-8 flex shrink-0 items-center">
                  <IceButton
                    class="flex-1"
                    :label="t('appearance.validate')"
                    icon="mdi-chevron-right"
                    variant="primary"
                    @click="goNext"
                  />
                </div>
              </div>
            </template>

            <template v-else>
              <div class="pointer-events-auto flex w-[340px] flex-col">
                <div
                  class="ice-scroll grid min-h-0 grid-cols-2 content-start gap-3.5 overflow-y-auto pb-1 pr-1"
                >
                  <template v-for="(category, index) in categories" :key="category.id">
                    <div
                      v-if="category.group && category.group !== categories[index - 1]?.group"
                      class="col-span-2 flex items-center gap-3"
                      :class="{ 'mt-2': index > 0 }"
                    >
                      <span class="group__label">{{ t(category.group) }}</span>
                      <span class="group__line flex-1"></span>
                    </div>
                    <CategoryCard
                      :icon="category.icon"
                      :label="t(category.labelKey)"
                      :active="category.id === activeCategoryId"
                      @select="selectCategory(category.id)"
                    />
                  </template>
                </div>
                <div class="nav mt-8 flex shrink-0 items-center">
                  <IceButton
                    class="flex-1"
                    :label="t('appearance.continue')"
                    icon="mdi-chevron-right"
                    variant="primary"
                    @click="goNext"
                  />
                </div>
              </div>

              <Transition name="detail-pop">
                <div
                  v-if="detailCategory"
                  class="pointer-events-none absolute bottom-0 left-[368px] top-0 flex w-[520px] flex-col items-stretch"
                >
                  <IcePanel
                    variant="primary"
                    class="detail-flex dense pointer-events-auto flex min-h-0 flex-col overflow-hidden"
                  >
                    <div class="flex min-h-0 flex-col px-6 pb-6 pt-5">
                      <div class="flex items-center gap-3.5">
                        <span class="detail__icon">
                          <v-icon size="16" :icon="resolveIcon(detailCategory.icon)" />
                        </span>
                        <span class="detail__title">{{ t(detailCategory.labelKey) }}</span>
                      </div>
                      <div class="detail__line mb-5 mt-4"></div>
                      <div class="ice-scroll min-h-0 grow overflow-y-auto pb-3 pr-2">
                        <CategoryDetail
                          :step-id="currentStep.id"
                          :category="detailCategory"
                          :draft="draft"
                          @update="handleUpdate"
                        />
                      </div>
                    </div>
                  </IcePanel>
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
.scrim {
  background: linear-gradient(
    to right,
    rgba(15, 23, 42, 1) 0%,
    rgba(15, 23, 42, 0.7) 15%,
    rgba(15, 23, 42, 0.4) 33%,
    transparent 100%
  );
}

.head__brand {
  font-size: 30px;
  font-weight: 100;
  letter-spacing: 0.42em;
  text-transform: uppercase;
  color: rgba(252, 254, 255, 0.99);
  text-shadow:
    0 0 22px rgba(226, 240, 250, 0.45),
    0 2px 12px rgba(3, 8, 16, 0.7),
    0 6px 24px rgba(3, 8, 16, 0.5);
}

.head__subtitle {
  font-size: 12.5px;
  font-weight: 300;
  letter-spacing: 0.05em;
  color: rgba(198, 224, 243, 0.6);
}

.head__counter {
  font-family: ui-monospace, monospace;
  font-size: 10.5px;
  letter-spacing: 0.16em;
  color: rgba(226, 240, 250, 0.6);
  font-variant-numeric: tabular-nums;
}

.head__line {
  height: 1px;
  background: linear-gradient(
    to right,
    rgba(250, 253, 255, 0.5),
    rgba(214, 236, 252, 0.16) 55%,
    transparent
  );
  box-shadow: 0 0 10px rgba(240, 248, 255, 0.25);
}

.dense.ice {
  --ice-top: 0.9;
  --ice-bottom: 0.95;
  --ice-glow: 0.15;
}

.detail-flex :deep(.ice__body) {
  display: flex;
  min-height: 0;
  flex-direction: column;
  height: auto;
}

.group__label {
  font-size: 9px;
  font-weight: 400;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.45);
  text-shadow: 0 1px 8px rgba(3, 8, 16, 0.6);
}

.group__line {
  height: 1px;
  background: linear-gradient(
    to right,
    rgba(226, 240, 250, 0.24),
    rgba(226, 240, 250, 0.07) 55%,
    transparent
  );
}

.detail__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  border-radius: 9999px;
  border: 1px solid rgba(250, 253, 255, 0.4);
  color: rgba(255, 255, 255, 0.96);
  box-shadow: 0 0 14px -4px rgba(226, 240, 250, 0.45);
}

.detail__title {
  font-size: 14.5px;
  font-weight: 200;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: rgba(252, 254, 255, 0.98);
  text-shadow: 0 0 16px rgba(226, 240, 250, 0.3);
}

.detail__line {
  height: 1px;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(240, 248, 255, 0.4),
    rgba(214, 236, 252, 0.12) 55%,
    transparent
  );
}

.nav :deep(.btn--primary) {
  background:
    linear-gradient(180deg, rgba(198, 224, 243, 0.14) 0%, rgba(198, 224, 243, 0.04) 100%),
    linear-gradient(180deg, rgba(18, 40, 66, 0.66) 0%, rgba(8, 22, 40, 0.7) 100%);
  box-shadow: inset 0 1px 0 rgba(233, 244, 253, 0.18);
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
    opacity 0.32s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.32s cubic-bezier(0.22, 0.6, 0.2, 1);
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
