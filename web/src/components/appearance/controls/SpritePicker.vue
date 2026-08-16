<script setup lang="ts">
const props = defineProps<{
  label: string
  modelValue: number
  count: number
  columns: number
  image: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()

const rows = Math.ceil(props.count / props.columns)

const cellStyle = (index: number): Record<string, string> => ({
  backgroundImage: `url(${props.image})`,
  backgroundSize: `${props.columns * 100}% ${rows * 100}%`,
  backgroundPosition: `${((index % props.columns) / (props.columns - 1)) * 100}% ${(Math.floor(index / props.columns) / (rows - 1)) * 100}%`,
  backgroundRepeat: 'no-repeat',
})
</script>

<template>
  <div class="sprite">
    <div class="flex items-baseline justify-between">
      <span class="ice-field-label">{{ label }}</span>
      <span class="ice-field-count">{{ modelValue + 1 }}/{{ count }}</span>
    </div>
    <div class="mt-2 flex flex-wrap gap-2.5 p-1">
      <button
        v-for="index in count"
        :key="index - 1"
        type="button"
        class="sprite__cell"
        :class="{ 'sprite__cell--active': index - 1 === modelValue }"
        @click="emit('update:modelValue', index - 1)"
      >
        <span class="sprite__img" :style="cellStyle(index - 1)"></span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.sprite__cell {
  width: 44px;
  height: 44px;
  border-radius: 9999px;
  border: 1px solid rgba(233, 244, 253, 0.18);
  overflow: hidden;
  box-shadow:
    inset 0 1px 0 rgba(255, 255, 255, 0.1),
    0 6px 14px -8px rgba(3, 8, 16, 0.7);
  transition:
    transform 0.22s ease,
    border-color 0.22s ease,
    box-shadow 0.22s ease;
}

.sprite__cell:hover {
  transform: scale(1.1);
  border-color: rgba(240, 248, 255, 0.45);
}

.sprite__cell--active {
  border-color: rgba(250, 253, 255, 0.9);
  box-shadow:
    0 0 0 2px rgba(250, 253, 255, 0.22),
    0 0 14px rgba(226, 240, 250, 0.5),
    0 6px 14px -8px rgba(3, 8, 16, 0.7);
  transform: scale(1.06);
}

.sprite__img {
  display: block;
  width: 100%;
  height: 100%;
  border-radius: 9999px;
}
</style>
