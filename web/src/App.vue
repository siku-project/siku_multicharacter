<script setup lang="ts">
import { defineAsyncComponent } from 'vue'
import { storeToRefs } from 'pinia'
import CharacterSelection from './views/CharacterSelection.vue'
import CharacterCreation from './views/CharacterCreation.vue'
import CharacterAppearance from './views/CharacterAppearance.vue'
import { useMulticharacterStore } from './stores/multicharacter'

const BoilerplateView = import.meta.env.DEV
  ? defineAsyncComponent(() => import('./views/BoilerplateView.vue'))
  : null

const { screen } = storeToRefs(useMulticharacterStore())
</script>

<template>
  <VApp>
    <component :is="BoilerplateView" v-if="BoilerplateView" />
    <Transition v-else name="screen-fade" mode="out-in">
      <CharacterSelection v-if="screen === 'selection'" />
      <CharacterCreation v-else-if="screen === 'creation'" />
      <CharacterAppearance v-else-if="screen === 'appearance'" />
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
