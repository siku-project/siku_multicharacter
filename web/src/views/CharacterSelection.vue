<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { storeToRefs } from 'pinia'
import SelectionBrand from '@/components/selection/SelectionBrand.vue'
import SelectionActions from '@/components/selection/SelectionActions.vue'
import SlotList from '@/components/selection/SlotList.vue'
import CharacterDetails from '@/components/selection/CharacterDetails.vue'
import DeleteCharacterModal from '@/components/selection/DeleteCharacterModal.vue'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { characterInSlot } from '@/utils/multicharacter'
import { sendNuiCallback } from '@/utils/nui'

const { characters, selectionConfig: config } = storeToRefs(useMulticharacterStore())

const selectedSlot = ref(characters.value[0]?.slot ?? 1)
const showInfo = ref(false)
const showDeleteModal = ref(false)

const actionsTop = import.meta.env.DEV ? 'top-24' : 'top-8'

const selectedCharacter = computed(() => characterInSlot(characters.value, selectedSlot.value))

watch(selectedSlot, (slot) => {
  if (!selectedCharacter.value) {
    showInfo.value = false
  }

  void sendNuiCallback('siku_multicharacter:nui:slotChanged', { slot })
})

watch(characters, (next) => {
  if (!next.some((character) => character.slot === selectedSlot.value)) {
    selectedSlot.value = next[0]?.slot ?? 1
  }
})

const handleSelect = (slot: number): void => {
  selectedSlot.value = slot
}

const handleJoin = (): void => {
  if (!selectedCharacter.value) {
    return
  }

  void sendNuiCallback('siku_multicharacter:nui:playCharacter', { id: selectedCharacter.value.id })
}

const handleRemove = (): void => {
  if (selectedCharacter.value) {
    showDeleteModal.value = true
  }
}

const handleDeleteCancel = (): void => {
  showDeleteModal.value = false
}

const handleDeleteConfirm = (): void => {
  console.log('[siku_multicharacter] delete confirmed for character', selectedCharacter.value?.id)
  showDeleteModal.value = false
}

const handleCreate = (): void => {
  void sendNuiCallback('siku_multicharacter:nui:startCreation', { slot: selectedSlot.value })
}

const handleInfo = (): void => {
  showInfo.value = !showInfo.value
}
</script>

<template>
  <div class="pointer-events-none fixed inset-0">
    <div class="pointer-events-auto absolute left-12 top-10">
      <SelectionBrand />
    </div>

    <div class="pointer-events-auto absolute left-1/2 -translate-x-1/2" :class="actionsTop">
      <SelectionActions
        :has-character="Boolean(selectedCharacter)"
        :allow-deletion="config.allowCharacterDeletion"
        @join="handleJoin"
        @remove="handleRemove"
        @info="handleInfo"
        @create="handleCreate"
      />
    </div>

    <div
      class="pointer-events-auto absolute bottom-10 left-1/2 w-full max-w-[1400px] -translate-x-1/2 px-6"
    >
      <SlotList
        :total-slots="config.slots"
        :characters="characters"
        :selected-slot="selectedSlot"
        @select="handleSelect"
      />
    </div>

    <DeleteCharacterModal
      :open="showDeleteModal"
      :character-name="
        selectedCharacter
          ? `${selectedCharacter.identity.firstName} ${selectedCharacter.identity.lastName}`
          : ''
      "
      @cancel="handleDeleteCancel"
      @confirm="handleDeleteConfirm"
    />

    <div class="pointer-events-auto absolute right-10 top-1/2 w-[380px] -translate-y-1/2">
      <Transition name="details" mode="out-in">
        <CharacterDetails
          v-if="showInfo && selectedCharacter"
          :key="selectedSlot"
          :slot-number="selectedSlot"
          :character="selectedCharacter"
          :config="config"
          :show-actions="false"
        />
      </Transition>
    </div>
  </div>
</template>

<style scoped>
.details-enter-active {
  transition:
    opacity 0.28s ease,
    transform 0.28s ease;
}

.details-leave-active {
  transition:
    opacity 0.18s ease,
    transform 0.18s ease;
}

.details-enter-from {
  opacity: 0;
  transform: translateX(14px);
}

.details-leave-to {
  opacity: 0;
  transform: translateX(10px);
}
</style>
