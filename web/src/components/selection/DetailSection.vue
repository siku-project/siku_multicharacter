<script setup lang="ts">
defineProps<{
  title: string
}>()
</script>

<template>
  <div class="flex flex-col gap-3.5">
    <div class="flex items-center gap-3.5">
      <span class="section__title">{{ title }}</span>
      <span class="section__line"></span>
    </div>
    <div class="flex flex-col gap-2.5">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.section__title {
  font-size: 10.5px;
  font-weight: 400;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: rgba(174, 210, 236, 0.72);
  white-space: nowrap;
}

.section__line {
  height: 1px;
  flex: 1;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(214, 236, 252, 0.55),
    rgba(214, 236, 252, 0.18) 55%,
    transparent 100%
  );
  box-shadow: 0 0 8px rgba(214, 236, 252, 0.28);
}
</style>
