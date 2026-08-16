<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { resolveIcon } from '@/utils/icons'
import { formatDate } from '@/utils/multicharacter'
import type { CharacterSummary } from '@/utils/multicharacter'

const props = defineProps<{
  slotNumber: number
  character?: CharacterSummary
  selected: boolean
}>()

const emit = defineEmits<{
  select: [slot: number]
}>()

const { t, locale } = useI18n()

const createdLabel = computed(() =>
  props.character ? formatDate(props.character.createdAt, locale.value) : null,
)
</script>

<template>
  <button
    type="button"
    class="card"
    :class="{ 'card--selected': selected, 'card--empty': !character }"
    @click="emit('select', slotNumber)"
  >
    <span class="card__number">{{ String(slotNumber).padStart(2, '0') }}</span>

    <span class="card__icon">
      <v-icon
        size="30"
        :icon="resolveIcon(character ? 'mdi-account-outline' : 'mdi-account-plus-outline')"
      />
    </span>

    <span v-if="character" class="card__body">
      <span class="card__name">
        {{ character.identity.firstName }} {{ character.identity.lastName }}
      </span>
      <span class="card__date">{{ createdLabel }}</span>
    </span>

    <span v-else class="card__body">
      <span class="card__empty">{{ t('selection.emptySlot') }}</span>
    </span>

    <span class="card__bar" aria-hidden="true"></span>
  </button>
</template>

<style scoped>
.card {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1.15rem;
  width: 200px;
  height: 200px;
  padding: 1.4rem 1.1rem 1.7rem;
  border-radius: 1.25rem;
  border: 1px solid rgba(214, 232, 246, 0.15);
  overflow: hidden;
  isolation: isolate;
  background-image:
    var(--ice-noise),
    radial-gradient(140% 90% at 50% -30%, rgba(203, 227, 246, 0.09) 0%, transparent 55%),
    linear-gradient(180deg, rgba(17, 38, 62, 0.7) 0%, rgba(9, 23, 42, 0.8) 100%);
  background-repeat: repeat, no-repeat, no-repeat;
  background-size:
    130px 130px,
    cover,
    cover;
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.14),
    0 4px 12px rgba(4, 11, 22, 0.45),
    0 16px 36px -8px rgba(4, 11, 22, 0.6),
    0 34px 70px -20px rgba(4, 11, 22, 0.55);
  transition:
    border-color 0.4s ease,
    background-color 0.4s ease,
    box-shadow 0.4s ease,
    transform 0.4s ease;
}

.card:hover {
  border-color: rgba(214, 232, 246, 0.32);
  transform: translateY(-4px);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.18),
    0 6px 14px rgba(4, 11, 22, 0.5),
    0 20px 42px -8px rgba(4, 11, 22, 0.65),
    0 0 30px -8px rgba(214, 236, 252, 0.22),
    0 38px 76px -20px rgba(4, 11, 22, 0.55);
}

.card--selected,
.card--selected:hover {
  border-color: rgba(233, 244, 253, 0.5);
  background-image:
    var(--ice-noise),
    radial-gradient(140% 90% at 50% -30%, rgba(203, 227, 246, 0.17) 0%, transparent 55%),
    linear-gradient(180deg, rgba(24, 51, 80, 0.78) 0%, rgba(12, 29, 51, 0.86) 100%);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.26),
    0 0 44px -9px rgba(214, 236, 252, 0.45),
    0 6px 14px rgba(4, 11, 22, 0.5),
    0 20px 44px -10px rgba(4, 11, 22, 0.65);
  transform: translateY(-6px);
}

.card--empty {
  border-style: dashed;
}

.card--empty:hover {
  border-color: rgba(214, 232, 246, 0.36);
}

.card--empty.card--selected,
.card--empty.card--selected:hover {
  border-color: rgba(233, 244, 253, 0.5);
}

.card__number {
  position: absolute;
  top: 0.85rem;
  left: 1.05rem;
  font-family: ui-monospace, monospace;
  font-size: 11px;
  letter-spacing: 0.16em;
  color: rgba(161, 203, 232, 0.5);
  transition:
    color 0.4s ease,
    text-shadow 0.4s ease;
}

.card:hover .card__number {
  color: rgba(214, 232, 246, 0.75);
}

.card--selected .card__number {
  color: rgba(244, 250, 255, 0.95);
  text-shadow: 0 0 10px rgba(214, 236, 252, 0.5);
}

.card__icon {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 4rem;
  height: 4rem;
  border-radius: 9999px;
  border: 1.5px solid rgba(214, 232, 246, 0.32);
  color: rgba(232, 243, 251, 0.88);
  background: radial-gradient(120% 120% at 50% 0%, rgba(214, 236, 252, 0.11) 0%, transparent 70%);
  box-shadow: 0 0 16px -7px rgba(214, 236, 252, 0.3);
  transition:
    border-color 0.4s ease,
    color 0.4s ease,
    box-shadow 0.4s ease,
    transform 0.4s ease;
}

.card:hover .card__icon {
  border-color: rgba(226, 240, 250, 0.5);
  color: rgba(244, 250, 255, 0.96);
  box-shadow: 0 0 22px -6px rgba(214, 236, 252, 0.5);
}

.card--selected .card__icon {
  border-color: rgba(238, 246, 252, 0.72);
  color: rgba(250, 253, 255, 1);
  box-shadow:
    0 0 26px -6px rgba(214, 236, 252, 0.65),
    inset 0 0 12px -6px rgba(214, 236, 252, 0.4);
  transform: scale(1.04);
}

.card--empty .card__icon {
  border-style: dashed;
  color: rgba(232, 243, 251, 0.85);
}

.card__body {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.3rem;
  min-width: 0;
  width: 100%;
}

.card__name {
  max-width: 100%;
  font-size: 14.5px;
  font-weight: 400;
  letter-spacing: 0.07em;
  color: rgba(248, 252, 255, 0.97);
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: text-shadow 0.4s ease;
}

.card--selected .card__name {
  text-shadow: 0 0 14px rgba(214, 236, 252, 0.45);
}

.card__date {
  font-size: 11px;
  font-weight: 300;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: rgba(174, 210, 236, 0.68);
  font-variant-numeric: tabular-nums;
}

.card__empty {
  font-size: 11px;
  font-weight: 400;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: rgba(238, 246, 252, 0.85);
  white-space: nowrap;
  transition: color 0.3s ease;
}

.card__bar {
  position: absolute;
  bottom: 0.7rem;
  left: 2rem;
  right: 2rem;
  height: 2px;
  z-index: 1;
  border-radius: 9999px;
  background: rgba(238, 246, 252, 0.92);
  transform: scaleX(0);
  transform-origin: center;
  transition: transform 0.45s ease;
}

.card--selected .card__bar {
  transform: scaleX(1);
  animation: bar-breathe 3.2s ease-in-out infinite;
}

@keyframes bar-breathe {
  0%,
  100% {
    box-shadow: 0 0 10px rgba(214, 236, 252, 0.5);
    opacity: 0.85;
  }
  50% {
    box-shadow: 0 0 18px rgba(214, 236, 252, 0.85);
    opacity: 1;
  }
}
</style>
