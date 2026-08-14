<script setup lang="ts">
import { defineAsyncComponent } from 'vue'

const BoilerplateView = import.meta.env.DEV
  ? defineAsyncComponent(() => import('./views/BoilerplateView.vue'))
  : null
</script>

<template>
  <VApp>
    <component :is="BoilerplateView" v-if="BoilerplateView" />
    <RouterView v-else />
  </VApp>
</template>
