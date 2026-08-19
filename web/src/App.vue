<script setup lang="ts">
import { computed, defineAsyncComponent } from 'vue'
import type { Component } from 'vue'
import { storeToRefs } from 'pinia'
import CharacterSelection from './views/CharacterSelection.vue'
import CharacterSelectionMinimal from './views/CharacterSelectionMinimal.vue'
import CharacterSelectionDark from './views/CharacterSelectionDark.vue'
import CharacterCreation from './views/CharacterCreation.vue'
import CharacterCreationMinimal from './views/CharacterCreationMinimal.vue'
import CharacterCreationDark from './views/CharacterCreationDark.vue'
import CharacterAppearance from './views/CharacterAppearance.vue'
import CharacterAppearanceMinimal from './views/CharacterAppearanceMinimal.vue'
import CharacterAppearanceDark from './views/CharacterAppearanceDark.vue'
import { useMulticharacterStore } from './stores/multicharacter'
import type { MulticharacterScreen, MulticharacterTheme } from './stores/multicharacter'

const BoilerplateView = import.meta.env.DEV
  ? defineAsyncComponent(() => import('./views/BoilerplateView.vue'))
  : null

const { screen, theme } = storeToRefs(useMulticharacterStore())

const THEMES: Record<MulticharacterTheme, Partial<Record<MulticharacterScreen, Component>>> = {
  glass: {
    selection: CharacterSelection,
    creation: CharacterCreation,
    appearance: CharacterAppearance,
  },
  minimal: {
    selection: CharacterSelectionMinimal,
    creation: CharacterCreationMinimal,
    appearance: CharacterAppearanceMinimal,
  },
  dark: {
    selection: CharacterSelectionDark,
    creation: CharacterCreationDark,
    appearance: CharacterAppearanceDark,
  },
}

const activeView = computed<Component | null>(
  () => THEMES[theme.value]?.[screen.value] ?? THEMES.glass[screen.value] ?? null,
)
</script>

<template>
  <VApp>
    <component :is="BoilerplateView" v-if="BoilerplateView" />
    <Transition v-else name="screen-fade" mode="out-in">
      <component :is="activeView" v-if="activeView" :key="`${theme}-${screen}`" />
    </Transition>
  </VApp>
</template>

<style scoped>
.screen-fade-enter-active,
.screen-fade-leave-active {
  transition: opacity 0.25s ease;
}

.screen-fade-enter-from,
.screen-fade-leave-to {
  opacity: 0;
}
</style>
