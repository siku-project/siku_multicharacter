<script setup lang="ts">
defineProps<{
  label: string
  modelValue: number
  colors: string[]
}>()

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()
</script>

<template>
  <div class="swatches">
    <span class="ice-field-label">{{ label }}</span>
    <div class="mt-2 flex flex-wrap gap-2.5 p-1">
      <button
        v-for="(color, index) in colors"
        :key="index"
        type="button"
        class="swatches__dot"
        :class="{ 'swatches__dot--active': index === modelValue }"
        :style="{ background: color }"
        @click="emit('update:modelValue', index)"
      ></button>
    </div>
  </div>
</template>

<style scoped>
.swatches__dot {
  width: 27px;
  height: 27px;
  border-radius: 9999px;
  border: 1px solid rgba(233, 244, 253, 0.18);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.14);
  transition:
    transform 0.22s ease,
    border-color 0.22s ease,
    box-shadow 0.22s ease;
}

.swatches__dot:hover {
  transform: scale(1.12);
  border-color: rgba(240, 248, 255, 0.45);
}

.swatches__dot--active {
  border-color: rgba(250, 253, 255, 0.9);
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.18),
    0 0 0 2px rgba(250, 253, 255, 0.22),
    0 0 12px rgba(226, 240, 250, 0.45);
  transform: scale(1.08);
}
</style>
