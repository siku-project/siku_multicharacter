<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import DeleteCharacterModal from '@/components/selection/DeleteCharacterModal.vue'
import { resolveIcon } from '@/utils/icons'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { characterInSlot, computeAge, daysSince, formatPlaytime } from '@/utils/multicharacter'
import { sendNuiCallback } from '@/utils/nui'
import type { CharacterSummary } from '@/utils/multicharacter'

const { t } = useI18n()
const { characters, selectionConfig: config } = storeToRefs(useMulticharacterStore())

const selectedSlot = ref(characters.value[0]?.slot ?? 1)
const showDeleteModal = ref(false)

const slots = computed(() =>
  Array.from({ length: config.value.slots }, (_, index) => {
    const slot = index + 1
    return { slot, character: characterInSlot(characters.value, slot) }
  }),
)

const selected = computed<CharacterSummary | undefined>(() =>
  characterInSlot(characters.value, selectedSlot.value),
)

const fullName = computed(() =>
  selected.value
    ? `${selected.value.identity.firstName} ${selected.value.identity.lastName}`
    : t('selection.emptySlot'),
)

const badges = computed(() => {
  const character = selected.value

  if (!character) {
    return []
  }

  const age = character.identity.birthDate ? computeAge(character.identity.birthDate) : null
  const items: { key: string; value: string; accent?: boolean }[] = []

  if (character.occupation) {
    items.push({ key: 'job', value: character.occupation.name, accent: true })
  }

  if (age !== null) {
    items.push({ key: 'age', value: t('selection.age', { age }) })
  }

  if (character.identity.height) {
    items.push({ key: 'height', value: `${character.identity.height} cm` })
  }

  items.push({ key: 'playtime', value: formatPlaytime(character.playtime) })

  return items
})

const lastSeen = computed(() => {
  const character = selected.value

  if (!character?.lastPlayed) {
    return null
  }

  const days = daysSince(character.lastPlayed)

  if (days === 0) {
    return t('selection.today')
  }

  if (days === 1) {
    return t('selection.yesterday')
  }

  return t('selection.daysAgo', { days })
})

watch(selectedSlot, (slot) => {
  void sendNuiCallback('siku_multicharacter:nui:slotChanged', { slot })
})

watch(characters, (next) => {
  if (!next.some((character) => character.slot === selectedSlot.value)) {
    selectedSlot.value = next[0]?.slot ?? 1
  }
})

const select = (slot: number): void => {
  selectedSlot.value = slot
}

const handleJoin = (): void => {
  if (!selected.value) {
    return
  }

  void sendNuiCallback('siku_multicharacter:nui:playCharacter', { id: selected.value.id })
}

const handleCreate = (): void => {
  void sendNuiCallback('siku_multicharacter:nui:startCreation', { slot: selectedSlot.value })
}

const handleRemove = (): void => {
  if (selected.value) {
    showDeleteModal.value = true
  }
}

const handleDeleteConfirm = (): void => {
  console.log('[siku_multicharacter] delete confirmed for character', selected.value?.id)
  showDeleteModal.value = false
}
</script>

<template>
  <div class="pointer-events-none fixed inset-0 select-none">
    <div class="veil-top" aria-hidden="true"></div>
    <div class="veil-bottom" aria-hidden="true"></div>

    <header class="pointer-events-auto absolute left-14 top-12">
      <div class="flex items-center gap-3.5">
        <span class="brand__bar"></span>
        <div>
          <p class="brand__name">SIKU</p>
          <p class="brand__tag">{{ t('selection.tagline') }}</p>
        </div>
      </div>
    </header>

    <nav class="pointer-events-auto absolute left-14 top-44 w-[352px]">
      <p class="rail__label">{{ t('selection.characters') }}</p>

      <ul class="mt-4 flex flex-col gap-2">
        <li v-for="entry in slots" :key="entry.slot">
          <button
            type="button"
            class="row"
            :class="{ 'row--active': entry.slot === selectedSlot }"
            @click="select(entry.slot)"
          >
            <span class="row__bar" aria-hidden="true"></span>

            <span v-if="!entry.character" class="row__plus">
              <v-icon size="13" :icon="resolveIcon('mdi-plus')" />
            </span>

            <span class="min-w-0 flex-1 text-left">
              <span class="row__name">
                {{
                  entry.character
                    ? `${entry.character.identity.firstName} ${entry.character.identity.lastName}`
                    : t('selection.emptySlot')
                }}
              </span>
              <span class="row__meta">
                {{
                  entry.character
                    ? (entry.character.occupation?.name ?? t('selection.unemployed'))
                    : t('selection.create')
                }}
              </span>
            </span>

            <span class="row__slot">{{ entry.slot }}</span>
          </button>
        </li>
      </ul>
    </nav>

    <footer
      class="pointer-events-auto absolute inset-x-14 bottom-11 flex items-end justify-between gap-10"
    >
      <div class="min-w-0">
        <p v-if="lastSeen" class="hero__last">{{ t('selection.lastPlayed') }} · {{ lastSeen }}</p>
        <h1 class="hero__name">{{ fullName }}</h1>

        <div v-if="badges.length" class="mt-3 flex flex-wrap items-center gap-2">
          <span
            v-for="badge in badges"
            :key="badge.key"
            class="chip"
            :class="{ 'chip--accent': badge.accent }"
          >
            {{ badge.value }}
          </span>
        </div>
      </div>

      <div class="flex shrink-0 items-center gap-2.5">
        <button
          v-if="selected && config.allowCharacterDeletion"
          type="button"
          class="btn btn--ghost"
          @click="handleRemove"
        >
          {{ t('selection.delete') }}
        </button>

        <button
          type="button"
          class="btn btn--primary"
          @click="selected ? handleJoin() : handleCreate()"
        >
          {{ selected ? t('selection.play') : t('selection.create') }}
        </button>
      </div>
    </footer>

    <DeleteCharacterModal
      class="pointer-events-auto"
      :open="showDeleteModal"
      :character-name="selected ? fullName : ''"
      @cancel="showDeleteModal = false"
      @confirm="handleDeleteConfirm"
    />
  </div>
</template>

<style scoped>
.veil-top {
  position: absolute;
  inset: 0 auto 0 0;
  width: 38%;
  background: linear-gradient(
    to right,
    rgba(6, 7, 9, 0.88) 0%,
    rgba(6, 7, 9, 0.55) 45%,
    rgba(6, 7, 9, 0) 100%
  );
}

.veil-bottom {
  position: absolute;
  inset: auto 0 0 0;
  height: 30%;
  background: linear-gradient(to top, rgba(6, 7, 9, 0.86) 0%, rgba(6, 7, 9, 0) 100%);
}

.brand__bar {
  width: 3px;
  height: 36px;
  border-radius: 9999px;
  background: #6cb6f6;
  box-shadow: 0 0 14px rgba(108, 182, 246, 0.7);
}

.brand__name {
  font-size: 21px;
  font-weight: 600;
  letter-spacing: 0.02em;
  color: rgba(255, 255, 255, 0.96);
}

.brand__tag {
  margin-top: 4px;
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.48);
}

.rail__label {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.44);
}

.row {
  position: relative;
  display: flex;
  width: 100%;
  align-items: center;
  gap: 12px;
  overflow: hidden;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.07);
  background: rgba(14, 15, 18, 0.72);
  padding: 13px 15px;
  transition:
    background 0.16s ease,
    border-color 0.16s ease;
}

.row:hover {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(22, 24, 28, 0.82);
}

.row--active {
  border-color: rgba(108, 182, 246, 0.4);
  background: rgba(18, 32, 46, 0.86);
}

.row__bar {
  position: absolute;
  left: 0;
  top: 50%;
  height: 0;
  width: 2px;
  background: #6cb6f6;
  box-shadow: 0 0 10px rgba(108, 182, 246, 0.7);
  transform: translateY(-50%);
  transition: height 0.18s ease;
}

.row--active .row__bar {
  height: 62%;
}

.row__plus {
  display: flex;
  height: 22px;
  width: 22px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  border: 1px solid rgba(108, 182, 246, 0.45);
  color: #6cb6f6;
}

.row__name {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 13.6px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.93);
}

.row__meta {
  display: block;
  margin-top: 2px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 11.4px;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.34);
}

.row__slot {
  flex-shrink: 0;
  font-family: ui-monospace, monospace;
  font-size: 10.5px;
  font-variant-numeric: tabular-nums;
  color: rgba(255, 255, 255, 0.24);
}

.row--active .row__slot {
  color: rgba(108, 182, 246, 0.7);
}

.hero__last {
  font-size: 10px;
  font-weight: 500;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.44);
}

.hero__name {
  margin-top: 8px;
  font-size: 34px;
  font-weight: 600;
  letter-spacing: -0.015em;
  line-height: 1.1;
  color: rgba(255, 255, 255, 0.97);
}

.chip {
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(14, 15, 18, 0.72);
  padding: 6px 12px;
  font-size: 11.5px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.7);
}

.chip--accent {
  border-color: rgba(108, 182, 246, 0.32);
  background: rgba(20, 38, 55, 0.8);
  color: #9ed0fb;
}

.btn {
  border-radius: 9px;
  padding: 11px 26px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  transition:
    background 0.16s ease,
    border-color 0.16s ease,
    color 0.16s ease;
}

.btn--ghost {
  border: 1px solid rgba(255, 255, 255, 0.09);
  background: rgba(14, 15, 18, 0.72);
  color: rgba(255, 255, 255, 0.45);
}

.btn--ghost:hover {
  border-color: rgba(248, 113, 113, 0.35);
  color: rgba(252, 165, 165, 0.92);
}

.btn--primary {
  border: 1px solid rgba(108, 182, 246, 0.55);
  background: #6cb6f6;
  color: rgba(5, 10, 16, 0.94);
  box-shadow: 0 10px 26px -14px rgba(108, 182, 246, 0.95);
}

.btn--primary:hover {
  background: #8ac8fb;
}
</style>
