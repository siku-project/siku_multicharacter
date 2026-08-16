<script setup lang="ts">
import IceBackdrop from '@/components/ui/IceBackdrop.vue'
import MusicPlayer from '@/components/ui/MusicPlayer.vue'
import IdentityForm from '@/components/creation/IdentityForm.vue'
import { useMulticharacterStore } from '@/stores/multicharacter'
import type { IdentityDraft } from '@/utils/identity'

const store = useMulticharacterStore()

const handleSubmit = (draft: IdentityDraft): void => {
  store.setIdentity(draft)
  console.log('[siku_multicharacter] identity submitted', draft)
}
</script>

<template>
  <div class="fixed inset-0">
    <IceBackdrop />
    <div class="relative flex h-full flex-col items-center justify-center gap-6 pb-6">
      <Transition name="form-pop" appear>
        <IdentityForm @submit="handleSubmit" />
      </Transition>
      <Transition name="player-pop" appear>
        <MusicPlayer class="creation__player" />
      </Transition>
    </div>
  </div>
</template>

<style scoped>
.creation__player {
  width: 620px;
}

.form-pop-enter-active {
  transition:
    opacity 0.5s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.5s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.form-pop-enter-from {
  opacity: 0;
  transform: translateY(18px) scale(0.97);
}

.player-pop-enter-active {
  transition:
    opacity 0.55s cubic-bezier(0.22, 0.6, 0.2, 1) 0.14s,
    transform 0.55s cubic-bezier(0.22, 0.6, 0.2, 1) 0.14s;
}

.player-pop-enter-from {
  opacity: 0;
  transform: translateY(14px) scale(0.985);
}
</style>
