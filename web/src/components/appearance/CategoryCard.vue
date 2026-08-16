<script setup lang="ts">
import { resolveIcon } from '@/utils/icons'

defineProps<{
  icon: string
  label: string
  active: boolean
}>()

const emit = defineEmits<{
  select: []
}>()
</script>

<template>
  <button type="button" class="card" :class="{ 'card--active': active }" @click="emit('select')">
    <span class="card__icon">
      <v-icon size="22" :icon="resolveIcon(icon)" />
    </span>
    <span class="card__label">{{ label }}</span>
  </button>
</template>

<style scoped>
.card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.7rem;
  min-height: 118px;
  border-radius: 1.25rem;
  border: 1px solid rgba(212, 231, 247, 0.16);
  background:
    var(--ice-noise),
    radial-gradient(150% 100% at 50% -25%, rgba(203, 227, 246, 0.13) 0%, transparent 55%),
    linear-gradient(180deg, rgba(20, 44, 71, 0.82) 0%, rgba(9, 24, 43, 0.88) 100%);
  background-repeat: repeat, no-repeat, no-repeat;
  background-size:
    130px 130px,
    cover,
    cover;
  padding: 1.1rem 0.7rem 1rem;
  box-shadow:
    0 0 0 1px rgba(233, 244, 253, 0.04),
    0 26px 54px -30px rgba(5, 14, 30, 0.62),
    0 3px 10px -6px rgba(5, 14, 30, 0.5),
    inset 0 1px 0 rgba(233, 244, 253, 0.22),
    inset 0 0 0 1px rgba(233, 244, 253, 0.03),
    inset 0 -24px 46px -34px rgba(5, 14, 30, 0.4);
  transition:
    border-color 0.3s ease,
    box-shadow 0.3s ease;
}

.card:hover:not(.card--active) {
  border-color: rgba(212, 231, 247, 0.26);
  box-shadow:
    0 0 0 1px rgba(233, 244, 253, 0.06),
    0 30px 60px -30px rgba(5, 14, 30, 0.62),
    0 0 46px -10px rgba(170, 208, 236, 0.18),
    inset 0 1px 0 rgba(233, 244, 253, 0.3),
    inset 0 0 0 1px rgba(233, 244, 253, 0.05),
    inset 0 -24px 46px -34px rgba(5, 14, 30, 0.4);
}

.card--active {
  border-color: rgba(250, 253, 255, 0.5);
  box-shadow:
    0 0 0 1px rgba(233, 244, 253, 0.06),
    0 0 24px -6px rgba(226, 240, 250, 0.45),
    0 26px 54px -30px rgba(5, 14, 30, 0.62),
    inset 0 1px 0 rgba(255, 255, 255, 0.26),
    inset 0 0 0 1px rgba(233, 244, 253, 0.05),
    inset 0 -24px 46px -34px rgba(5, 14, 30, 0.4);
}

.card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.7rem;
  height: 2.7rem;
  border-radius: 9999px;
  border: 1px solid rgba(214, 232, 246, 0.22);
  color: rgba(198, 224, 243, 0.7);
  transition:
    color 0.3s ease,
    border-color 0.3s ease,
    box-shadow 0.3s ease;
}

.card--active .card__icon {
  color: rgba(255, 255, 255, 0.98);
  border-color: rgba(250, 253, 255, 0.55);
  box-shadow: 0 0 16px -3px rgba(226, 240, 250, 0.55);
}

.card__label {
  max-width: 100%;
  font-size: 10.5px;
  font-weight: 300;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  text-align: center;
  color: rgba(226, 240, 250, 0.8);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: color 0.3s ease;
}

.card--active .card__label {
  color: rgba(255, 255, 255, 0.98);
  text-shadow: 0 0 10px rgba(226, 240, 250, 0.35);
}
</style>
