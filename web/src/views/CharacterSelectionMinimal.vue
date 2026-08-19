<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useI18n } from 'vue-i18n'
import DeleteCharacterModal from '@/components/selection/DeleteCharacterModal.vue'
import { resolveIcon } from '@/utils/icons'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { characterInSlot, computeAge, formatPlaytime, daysSince } from '@/utils/multicharacter'
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
  const items: { key: string; value: string }[] = []

  if (character.occupation) {
    items.push({ key: 'job', value: character.occupation.name })
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
    <div class="veil-left" aria-hidden="true"></div>
    <div class="veil-bottom" aria-hidden="true"></div>

    <header class="pointer-events-auto absolute left-12 top-11">
      <div class="flex items-center gap-3.5">
        <span class="brand__bar"></span>
        <div>
          <p class="brand__name">SIKU</p>
          <p class="brand__tag">{{ t('selection.tagline') }}</p>
        </div>
      </div>
    </header>

    <nav class="pointer-events-auto absolute left-12 top-44 w-[366px]">
      <p class="rail__label">{{ t('selection.characters') }}</p>

      <ul class="mt-5 flex flex-col gap-2.5">
        <li v-for="entry in slots" :key="entry.slot">
          <button
            type="button"
            class="slot"
            :class="{
              'slot--active': entry.slot === selectedSlot,
              'slot--empty': !entry.character,
            }"
            @click="select(entry.slot)"
          >
            <span class="slot__accent" aria-hidden="true"></span>

            <span v-if="!entry.character" class="slot__plus">
              <v-icon size="14" :icon="resolveIcon('mdi-plus')" />
            </span>

            <span class="min-w-0 flex-1 text-left">
              <span class="slot__name">
                {{
                  entry.character
                    ? `${entry.character.identity.firstName} ${entry.character.identity.lastName}`
                    : t('selection.emptySlot')
                }}
              </span>
              <span class="slot__meta">
                {{
                  entry.character
                    ? (entry.character.occupation?.name ?? t('selection.unemployed'))
                    : t('selection.create')
                }}
              </span>
            </span>

            <span class="slot__index">{{ entry.slot }}</span>
          </button>
        </li>
      </ul>
    </nav>

    <footer
      class="pointer-events-auto absolute inset-x-12 bottom-10 flex items-end justify-between gap-10"
    >
      <div class="min-w-0">
        <p v-if="lastSeen" class="hero__last">{{ t('selection.lastPlayed') }} · {{ lastSeen }}</p>
        <h1 class="hero__name">{{ fullName }}</h1>

        <div v-if="badges.length" class="mt-4 flex flex-wrap items-center gap-2.5">
          <span v-for="badge in badges" :key="badge.key" class="badge">{{ badge.value }}</span>
        </div>
      </div>

      <div class="flex shrink-0 items-center gap-3">
        <button
          v-if="selected && config.allowCharacterDeletion"
          type="button"
          class="action action--ghost"
          @click="handleRemove"
        >
          {{ t('selection.delete') }}
        </button>

        <button v-if="selected" type="button" class="action action--primary" @click="handleJoin">
          {{ t('selection.joinCity') }}
          <v-icon size="17" :icon="resolveIcon('mdi-chevron-right')" />
        </button>

        <button v-else type="button" class="action action--primary" @click="handleCreate">
          <v-icon size="15" :icon="resolveIcon('mdi-plus')" />
          {{ t('selection.create') }}
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
.veil-left {
  position: absolute;
  inset: 0 auto 0 0;
  width: 42%;
  background: linear-gradient(
    to right,
    rgba(8, 15, 28, 0.92) 0%,
    rgba(8, 15, 28, 0.62) 42%,
    transparent 100%
  );
}

.veil-bottom {
  position: absolute;
  inset: auto 0 0 0;
  height: 34%;
  background: linear-gradient(to top, rgba(8, 15, 28, 0.88) 0%, transparent 100%);
}

.brand__bar {
  width: 2px;
  height: 37px;
  border-radius: 9999px;
  background: linear-gradient(to bottom, rgba(226, 240, 255, 0.95), rgba(120, 170, 220, 0.35));
  box-shadow: 0 0 12px rgba(190, 224, 255, 0.5);
}

.brand__name {
  font-size: 20.5px;
  font-weight: 600;
  letter-spacing: 0.34em;
  color: rgba(244, 250, 255, 0.97);
}

.brand__tag {
  margin-top: 4px;
  font-size: 10.2px;
  font-weight: 300;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.55);
}

.rail__label {
  font-size: 10.2px;
  font-weight: 400;
  letter-spacing: 0.34em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.48);
}

.slot {
  position: relative;
  display: flex;
  width: 100%;
  align-items: center;
  gap: 13px;
  overflow: hidden;
  border-radius: 13px;
  border: 1px solid rgba(150, 190, 225, 0.12);
  background: linear-gradient(180deg, rgba(18, 30, 48, 0.55) 0%, rgba(10, 20, 35, 0.62) 100%);
  padding: 14px 16px;
  transition:
    border-color 0.22s ease,
    background 0.22s ease,
    transform 0.22s ease;
}

.slot:hover {
  border-color: rgba(180, 214, 245, 0.24);
  background: linear-gradient(180deg, rgba(24, 40, 62, 0.62) 0%, rgba(13, 25, 42, 0.68) 100%);
}

.slot--active {
  border-color: rgba(198, 228, 255, 0.42);
  background: linear-gradient(180deg, rgba(34, 58, 88, 0.72) 0%, rgba(16, 30, 50, 0.72) 100%);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.12),
    0 10px 28px -18px rgba(120, 180, 240, 0.7);
}

.slot__accent {
  position: absolute;
  left: 0;
  top: 50%;
  height: 0;
  width: 2px;
  border-radius: 9999px;
  background: linear-gradient(to bottom, rgba(226, 244, 255, 0.95), rgba(140, 190, 240, 0.4));
  box-shadow: 0 0 10px rgba(190, 224, 255, 0.6);
  transform: translateY(-50%);
  transition:
    height 0.24s ease,
    opacity 0.24s ease;
  opacity: 0;
}

.slot--active .slot__accent {
  height: 56%;
  opacity: 1;
}

.slot__plus {
  display: flex;
  height: 24px;
  width: 24px;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  border: 1px solid rgba(180, 214, 245, 0.28);
  color: rgba(214, 234, 252, 0.8);
}

.slot__name {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 14.5px;
  font-weight: 500;
  letter-spacing: 0.01em;
  color: rgba(240, 248, 255, 0.95);
}

.slot--empty .slot__name {
  font-weight: 400;
  color: rgba(206, 226, 245, 0.62);
}

.slot__meta {
  display: block;
  margin-top: 3px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 11px;
  font-weight: 300;
  letter-spacing: 0.11em;
  text-transform: uppercase;
  color: rgba(160, 192, 222, 0.5);
}

.slot__index {
  flex-shrink: 0;
  font-family: ui-monospace, monospace;
  font-size: 10.5px;
  font-variant-numeric: tabular-nums;
  color: rgba(160, 192, 222, 0.4);
}

.hero__last {
  font-size: 10.2px;
  font-weight: 300;
  letter-spacing: 0.24em;
  text-transform: uppercase;
  color: rgba(170, 200, 228, 0.5);
}

.hero__name {
  margin-top: 8px;
  font-size: 45px;
  font-weight: 300;
  letter-spacing: -0.015em;
  line-height: 1.05;
  color: rgba(246, 251, 255, 0.98);
  text-shadow: 0 2px 30px rgba(10, 20, 40, 0.6);
}

.badge {
  border-radius: 9999px;
  border: 1px solid rgba(160, 200, 235, 0.16);
  background: rgba(16, 30, 50, 0.5);
  padding: 6px 13px;
  font-size: 11.2px;
  font-weight: 400;
  letter-spacing: 0.09em;
  color: rgba(214, 234, 252, 0.82);
}

.action {
  display: inline-flex;
  align-items: center;
  gap: 9px;
  border-radius: 11px;
  padding: 12px 24px;
  font-size: 12.2px;
  font-weight: 500;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  transition:
    background 0.2s ease,
    border-color 0.2s ease,
    color 0.2s ease;
}

.action--ghost {
  border: 1px solid rgba(160, 200, 235, 0.16);
  color: rgba(196, 220, 242, 0.7);
}

.action--ghost:hover {
  border-color: rgba(200, 228, 255, 0.3);
  color: rgba(236, 246, 255, 0.92);
}

.action--primary {
  border: 1px solid rgba(214, 238, 255, 0.5);
  background: linear-gradient(180deg, rgba(232, 245, 255, 0.96) 0%, rgba(198, 226, 250, 0.9) 100%);
  color: rgba(10, 24, 42, 0.92);
  box-shadow: 0 12px 30px -16px rgba(150, 200, 250, 0.9);
}

.action--primary:hover {
  background: linear-gradient(180deg, rgba(255, 255, 255, 1) 0%, rgba(214, 236, 255, 0.96) 100%);
}
</style>
