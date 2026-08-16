<script setup lang="ts">
withDefaults(
  defineProps<{
    label: string
    value: string
    muted?: boolean
  }>(),
  {
    muted: false,
  },
)
</script>

<template>
  <div class="flex items-baseline justify-between gap-6">
    <span class="row__label">{{ label }}</span>
    <span class="row__value" :class="{ 'row__value--muted': muted }">{{ value }}</span>
  </div>
</template>

<style scoped>
.row__label {
  font-size: 12.5px;
  font-weight: 300;
  letter-spacing: 0.06em;
  color: rgba(198, 224, 243, 0.58);
  white-space: nowrap;
}

.row__value {
  font-size: 14.5px;
  font-weight: 400;
  letter-spacing: 0.03em;
  color: rgba(250, 253, 255, 0.98);
  text-align: right;
  font-variant-numeric: tabular-nums;
}

.row__value--muted {
  color: rgba(198, 224, 243, 0.45);
  font-family: ui-monospace, monospace;
  font-size: 12px;
}
</style>
