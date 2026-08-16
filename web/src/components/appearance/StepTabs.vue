<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { resolveIcon } from '@/utils/icons'
import type { AppearanceStepDefinition } from '@/config/appearance'

const props = defineProps<{
  steps: AppearanceStepDefinition[]
  currentIndex: number
  furthestIndex: number
}>()

const emit = defineEmits<{
  select: [index: number]
}>()

const { t } = useI18n()

const handleSelect = (index: number): void => {
  if (index !== props.currentIndex && index <= props.furthestIndex) {
    emit('select', index)
  }
}
</script>

<template>
  <div class="flex flex-wrap gap-2">
    <button
      v-for="(step, index) in steps"
      :key="step.id"
      type="button"
      class="tab"
      :class="{
        'tab--active': index === currentIndex,
        'tab--locked': index > furthestIndex,
      }"
      :disabled="index > furthestIndex"
      @click="handleSelect(index)"
    >
      <v-icon size="15" :icon="resolveIcon(step.icon)" />
      <span>{{ t(step.labelKey) }}</span>
      <span class="tab__dot" :class="{ 'tab__dot--lit': index < furthestIndex }"></span>
    </button>
  </div>
</template>

<style scoped>
.tab {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  border-radius: 9999px;
  border: 1px solid rgba(212, 231, 247, 0.16);
  background-image:
    var(--ice-noise),
    radial-gradient(150% 100% at 50% -25%, rgba(203, 227, 246, 0.13) 0%, transparent 55%),
    linear-gradient(180deg, rgba(20, 44, 71, 0.78) 0%, rgba(9, 24, 43, 0.85) 100%);
  background-repeat: repeat, no-repeat, no-repeat;
  background-size:
    130px 130px,
    cover,
    cover;
  padding: 0.46rem 1rem;
  font-size: 10.5px;
  font-weight: 300;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.65);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.22),
    inset 0 0 0 1px rgba(233, 244, 253, 0.03),
    0 14px 30px -16px rgba(3, 8, 16, 0.75),
    0 3px 10px -6px rgba(3, 8, 16, 0.55);
  transition:
    color 0.25s ease,
    border-color 0.25s ease,
    box-shadow 0.25s ease;
}

.tab:hover:not(.tab--locked):not(.tab--active) {
  color: rgba(238, 246, 252, 0.92);
  border-color: rgba(233, 244, 253, 0.34);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.28),
    inset 0 0 0 1px rgba(233, 244, 253, 0.05),
    0 14px 30px -16px rgba(3, 8, 16, 0.75),
    0 0 26px -10px rgba(170, 208, 236, 0.22);
}

.tab--active {
  background-image:
    var(--ice-noise),
    linear-gradient(180deg, rgba(240, 248, 255, 0.2) 0%, rgba(240, 248, 255, 0.06) 100%),
    linear-gradient(180deg, rgba(20, 44, 71, 0.88) 0%, rgba(9, 24, 43, 0.92) 100%);
  border-color: rgba(250, 253, 255, 0.42);
  color: rgba(255, 255, 255, 0.99);
  text-shadow: 0 0 10px rgba(226, 240, 250, 0.4);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.26),
    0 0 20px -6px rgba(226, 240, 250, 0.4),
    0 14px 30px -16px rgba(3, 8, 16, 0.75);
}

.tab--locked {
  opacity: 0.38;
  cursor: default;
}

.tab__dot {
  width: 4px;
  height: 4px;
  border-radius: 9999px;
  border: 1px solid rgba(198, 224, 243, 0.3);
  transition:
    background-color 0.4s ease,
    border-color 0.4s ease,
    box-shadow 0.4s ease;
}

.tab__dot--lit {
  background: rgba(250, 253, 255, 0.92);
  border-color: rgba(250, 253, 255, 0.5);
  box-shadow: 0 0 7px rgba(226, 240, 250, 0.6);
}
</style>
