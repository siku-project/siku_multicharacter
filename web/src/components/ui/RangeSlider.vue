<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    label: string
    modelValue: number
    min: number
    max: number
    step?: number
    unit?: string
    leftLabel?: string
    rightLabel?: string
    blend?: boolean
  }>(),
  {
    step: 1,
    unit: '',
    leftLabel: '',
    rightLabel: '',
    blend: false,
  },
)

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()

const isDecimal = computed(() => props.step < 1)

const centerFill = computed(() => props.blend || props.min < 0)

const centerValue = computed(() => (props.blend ? (props.min + props.max) / 2 : 0))

const display = computed(() => {
  if (props.blend) {
    const right = Math.round(props.modelValue)
    const left = Math.round(props.max + props.min) - right
    const leftPart = `${left}% ${props.leftLabel}`
    const rightPart = `${right}% ${props.rightLabel}`
    return right >= left ? `${rightPart} • ${leftPart}` : `${leftPart} • ${rightPart}`
  }
  const value = isDecimal.value ? props.modelValue.toFixed(2) : String(props.modelValue)
  return props.unit ? `${value} ${props.unit}` : value
})

const trackStyle = computed(() => {
  const lit = 'rgba(244, 250, 255, 0.85)'
  const faint = 'rgba(214, 236, 252, 0.14)'
  const ratio = ((props.modelValue - props.min) / (props.max - props.min)) * 100
  if (centerFill.value) {
    const center = ((centerValue.value - props.min) / (props.max - props.min)) * 100
    const from = Math.min(ratio, center)
    const to = Math.max(ratio, center)
    return {
      background: `linear-gradient(to right, ${faint} 0%, ${faint} ${from}%, ${lit} ${from}%, ${lit} ${to}%, ${faint} ${to}%, ${faint} 100%)`,
    }
  }
  return {
    background: `linear-gradient(to right, ${lit} ${ratio}%, ${faint} ${ratio}%)`,
  }
})

const dominanceThreshold = computed(() => (props.max - props.min) * 0.02)

const leftDominant = computed(
  () => props.blend && props.modelValue < centerValue.value - dominanceThreshold.value,
)

const rightDominant = computed(
  () => props.blend && props.modelValue > centerValue.value + dominanceThreshold.value,
)
</script>

<template>
  <div class="range">
    <div class="flex items-baseline justify-between">
      <span class="ice-field-label">{{ label }}</span>
      <span class="range__value" :class="{ 'range__value--blend': blend }">{{ display }}</span>
    </div>
    <input
      class="range__input mt-3"
      type="range"
      :min="min"
      :max="max"
      :step="step"
      :value="modelValue"
      :style="trackStyle"
      @input="emit('update:modelValue', Number(($event.target as HTMLInputElement).value))"
    />
    <div v-if="leftLabel || rightLabel" class="mt-1.5 flex items-baseline justify-between">
      <span class="ice-pole range__pole" :class="{ 'range__pole--lit': leftDominant }">
        {{ leftLabel }}
      </span>
      <span class="ice-pole range__pole" :class="{ 'range__pole--lit': rightDominant }">
        {{ rightLabel }}
      </span>
    </div>
  </div>
</template>

<style scoped>
.range__value {
  font-family: ui-monospace, monospace;
  font-size: 11px;
  letter-spacing: 0.08em;
  color: rgba(250, 253, 255, 0.95);
  font-variant-numeric: tabular-nums;
  text-shadow: 0 0 12px rgba(214, 236, 252, 0.35);
}

.range__value--blend {
  font-size: 10px;
  text-transform: uppercase;
}

.range__input {
  appearance: none;
  display: block;
  width: 100%;
  height: 3px;
  border-radius: 9999px;
  outline: none;
  cursor: pointer;
}

.range__input::-webkit-slider-thumb {
  appearance: none;
  width: 15px;
  height: 15px;
  border-radius: 9999px;
  border: 1.5px solid rgba(255, 255, 255, 0.95);
  background: radial-gradient(
    120% 120% at 50% 30%,
    rgba(250, 253, 255, 0.98) 0%,
    rgba(214, 236, 252, 0.85) 100%
  );
  box-shadow: 0 0 14px rgba(214, 236, 252, 0.55);
  transition:
    box-shadow 0.25s ease,
    transform 0.25s ease;
}

.range__input::-webkit-slider-thumb:hover {
  transform: scale(1.15);
  box-shadow: 0 0 20px rgba(214, 236, 252, 0.75);
}

.range__pole {
  transition:
    color 0.3s ease,
    text-shadow 0.3s ease;
}

.range__pole--lit {
  color: rgba(250, 253, 255, 0.92);
  text-shadow: 0 0 10px rgba(226, 240, 250, 0.4);
}
</style>
