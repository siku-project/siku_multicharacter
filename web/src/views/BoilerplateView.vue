<script setup lang="ts">
import { ref, computed } from 'vue'
import type { Component } from 'vue'
import backgroundUrl from '@/assets/boilerplate-background.jpg'
import DevTopBar from '@/components/boilerplate/DevTopBar.vue'
import DevFab from '@/components/boilerplate/DevFab.vue'
import DevViewSelector from '@/components/boilerplate/DevViewSelector.vue'
import CharacterSelection from '@/views/CharacterSelection.vue'
import CharacterCreation from '@/views/CharacterCreation.vue'
import CharacterAppearance from '@/views/CharacterAppearance.vue'
import { useMulticharacterStore } from '@/stores/multicharacter'
import { MOCK_CHARACTERS, MOCK_SELECTION_CONFIG } from '@/mock/characters'
import { MOCK_IDENTITY } from '@/mock/identity'

const store = useMulticharacterStore()
store.setCharacters(MOCK_CHARACTERS)
store.setSelectionConfig(MOCK_SELECTION_CONFIG)
store.setIdentity(MOCK_IDENTITY)

const viewComponents: Record<string, Component> = {
  'Sélection de personnage': CharacterSelection,
  "Création d'identité": CharacterCreation,
  'Apparence du personnage': CharacterAppearance,
}

const views: string[] = Object.keys(viewComponents)
const currentView = ref('none')

const activeComponent = computed<Component | null>(() =>
  currentView.value !== 'none' ? (viewComponents[currentView.value] ?? null) : null,
)

const handleSelectView = (view: string) => {
  currentView.value = view
}
</script>

<template>
  <div
    class="fixed inset-0 w-full h-full bg-contain bg-center bg-no-repeat bg-gray-900 sm:bg-contain md:bg-cover lg:bg-cover xl:bg-cover 2xl:bg-cover transition-all duration-300"
    :style="{ backgroundImage: `url(${backgroundUrl})` }"
  >
    <component :is="activeComponent" v-if="activeComponent" />

    <DevTopBar />
    <DevFab :current-view="currentView" />
    <DevViewSelector :views="views" :current-view="currentView" @select-view="handleSelectView" />
  </div>
</template>
