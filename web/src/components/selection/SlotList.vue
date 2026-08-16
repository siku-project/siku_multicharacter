<script setup lang="ts">
import { computed, ref } from 'vue'
import SlotCard from './SlotCard.vue'
import { resolveIcon } from '@/utils/icons'
import { characterInSlot } from '@/utils/multicharacter'
import type { CharacterSummary } from '@/utils/multicharacter'

const VISIBLE_SLOTS = 5

const props = defineProps<{
  totalSlots: number
  characters: CharacterSummary[]
  selectedSlot: number
}>()

const emit = defineEmits<{
  select: [slot: number]
}>()

const start = ref(0)
const direction = ref<1 | -1>(1)

const isCarousel = computed(() => props.totalSlots > VISIBLE_SLOTS)

const visibleSlots = computed(() => {
  if (!isCarousel.value) {
    return Array.from({ length: props.totalSlots }, (_, index) => index + 1)
  }
  return Array.from(
    { length: VISIBLE_SLOTS + 2 },
    (_, index) => ((start.value - 1 + index + props.totalSlots) % props.totalSlots) + 1,
  )
})

const shift = (step: 1 | -1): void => {
  direction.value = step
  start.value = (start.value + step + props.totalSlots) % props.totalSlots
}
</script>

<template>
  <div class="flex items-center justify-center gap-5">
    <button v-if="isCarousel" type="button" class="nav" aria-label="previous" @click="shift(-1)">
      <v-icon size="20" :icon="resolveIcon('mdi-chevron-left')" />
    </button>

    <div class="rail pointer-events-none -mx-16 -my-10 overflow-hidden px-16 py-10">
      <TransitionGroup
        name="slots"
        tag="div"
        class="track pointer-events-auto relative flex items-end gap-8"
        :class="[
          direction === 1 ? 'slots--next' : 'slots--prev',
          { 'track--carousel': isCarousel },
        ]"
      >
        <SlotCard
          v-for="slot in visibleSlots"
          :key="slot"
          :slot-number="slot"
          :character="characterInSlot(characters, slot)"
          :selected="slot === selectedSlot"
          @select="emit('select', $event)"
        />
      </TransitionGroup>
    </div>

    <button v-if="isCarousel" type="button" class="nav" aria-label="next" @click="shift(1)">
      <v-icon size="20" :icon="resolveIcon('mdi-chevron-right')" />
    </button>
  </div>
</template>

<style scoped>
.track--carousel {
  margin-left: -202px;
  margin-right: -202px;
}

.rail {
  mask-image: linear-gradient(
    to right,
    transparent 0,
    rgba(0, 0, 0, 0.35) 36px,
    black 64px,
    black calc(100% - 64px),
    rgba(0, 0, 0, 0.35) calc(100% - 36px),
    transparent 100%
  );
  -webkit-mask-image: linear-gradient(
    to right,
    transparent 0,
    rgba(0, 0, 0, 0.35) 36px,
    black 64px,
    black calc(100% - 64px),
    rgba(0, 0, 0, 0.35) calc(100% - 36px),
    transparent 100%
  );
}

.nav {
  position: relative;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 3rem;
  height: 3rem;
  flex-shrink: 0;
  border-radius: 9999px;
  border: 1px solid rgba(214, 232, 246, 0.38);
  color: rgba(232, 243, 251, 0.85);
  background:
    radial-gradient(140% 120% at 50% -40%, rgba(203, 227, 246, 0.09) 0%, transparent 60%),
    linear-gradient(180deg, rgba(17, 38, 62, 0.76) 0%, rgba(9, 23, 42, 0.85) 100%);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.15),
    0 4px 10px rgba(4, 11, 22, 0.45),
    0 14px 32px -8px rgba(4, 11, 22, 0.6);
  transition:
    border-color 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    color 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    box-shadow 0.45s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.nav:hover {
  border-color: rgba(230, 244, 253, 0.62);
  color: rgba(255, 255, 255, 1);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.22),
    0 0 24px -9px rgba(214, 236, 252, 0.3),
    0 4px 10px rgba(4, 11, 22, 0.45),
    0 14px 32px -8px rgba(4, 11, 22, 0.6);
}

.slots-move,
.slots-enter-active,
.slots-leave-active {
  transition: transform 0.45s cubic-bezier(0.3, 0.7, 0.2, 1);
}

.slots-leave-active {
  position: absolute;
  top: 0;
}

.slots--next .slots-leave-active {
  left: 0;
}

.slots--prev .slots-leave-active {
  right: 0;
}

.slots--next .slots-enter-from {
  transform: translateX(232px);
}

.slots--next .slots-leave-to {
  transform: translateX(-232px);
}

.slots--prev .slots-enter-from {
  transform: translateX(-232px);
}

.slots--prev .slots-leave-to {
  transform: translateX(232px);
}
</style>
