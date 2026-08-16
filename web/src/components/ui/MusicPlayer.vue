<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import GlassPanel from '@/components/ui/GlassPanel.vue'
import { resolveIcon } from '@/utils/icons'

const TRACK = { title: 'Arctic Drift', artist: 'SIKU', genre: 'Ambient' }
const DURATION = 204
const TICK_MS = 400

const { t } = useI18n()

const playing = ref(false)
const progress = ref(0.32)
const volume = ref(0.6)

const seekBar = ref<HTMLElement | null>(null)
const volumeBar = ref<HTMLElement | null>(null)

let timer: ReturnType<typeof setInterval> | null = null

const stopTimer = (): void => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
}

watch(playing, (active) => {
  stopTimer()
  if (active) {
    timer = setInterval(() => {
      const next = progress.value + TICK_MS / 1000 / DURATION
      progress.value = next > 1 ? 0 : next
    }, TICK_MS)
  }
})

onBeforeUnmount(stopTimer)

const clamp01 = (value: number): number => Math.min(1, Math.max(0, value))

const startDrag = (
  event: PointerEvent,
  bar: HTMLElement | null,
  apply: (ratio: number) => void,
): void => {
  if (!bar) {
    return
  }
  const rect = bar.getBoundingClientRect()
  const update = (moveEvent: PointerEvent): void => {
    apply(clamp01((moveEvent.clientX - rect.left) / rect.width))
  }
  const stop = (): void => {
    window.removeEventListener('pointermove', update)
    window.removeEventListener('pointerup', stop)
  }
  window.addEventListener('pointermove', update)
  window.addEventListener('pointerup', stop)
  update(event)
}

const volumeIcon = computed(() => {
  if (volume.value === 0) {
    return 'mdi-volume-off'
  }
  return volume.value < 0.5 ? 'mdi-volume-medium' : 'mdi-volume-high'
})

const formatTime = (seconds: number): string => {
  const total = Math.floor(seconds)
  const minutes = Math.floor(total / 60)
  const rest = total % 60
  return `${minutes}:${String(rest).padStart(2, '0')}`
}

const currentTime = computed(() => formatTime(progress.value * DURATION))
const totalTime = computed(() => formatTime(DURATION))
</script>

<template>
  <GlassPanel class="player">
    <div class="flex flex-col px-7 py-5">
      <div class="flex items-center">
        <div class="flex min-w-0 flex-1 items-center gap-4">
          <div class="player__cover">
            <v-icon size="19" :icon="resolveIcon('mdi-equalizer')" />
          </div>

          <div class="min-w-0">
            <div class="flex items-center gap-1.5">
              <span class="player__dot" :class="{ 'player__dot--live': playing }"></span>
              <span class="player__live">{{ t('selection.nowPlaying') }}</span>
            </div>
            <p class="player__title">{{ TRACK.title }}</p>
            <p class="player__artist">{{ TRACK.artist }} · {{ TRACK.genre }}</p>
          </div>
        </div>

        <div class="flex shrink-0 items-center gap-3">
          <button type="button" class="player__skip">
            <v-icon size="20" :icon="resolveIcon('mdi-skip-previous')" />
          </button>
          <button type="button" class="player__toggle" @click="playing = !playing">
            <v-icon size="16" :icon="resolveIcon(playing ? 'mdi-pause' : 'mdi-play')" />
          </button>
          <button type="button" class="player__skip">
            <v-icon size="20" :icon="resolveIcon('mdi-skip-next')" />
          </button>
        </div>

        <div class="flex min-w-0 flex-1 items-center justify-end gap-2.5">
          <v-icon
            class="player__volume-icon"
            size="15"
            :icon="resolveIcon(volumeIcon)"
            @click="volume = volume > 0 ? 0 : 0.5"
          />
          <div
            ref="volumeBar"
            class="group relative flex h-5 w-24 cursor-pointer items-center"
            @pointerdown="startDrag($event, volumeBar, (ratio) => (volume = ratio))"
          >
            <div class="player__volume-track">
              <div class="player__volume-fill" :style="{ width: volume * 100 + '%' }"></div>
              <div
                class="player__volume-thumb group-hover:scale-125"
                :style="{ left: volume * 100 + '%' }"
              ></div>
            </div>
          </div>
        </div>
      </div>

      <div class="mt-3 flex items-center gap-3">
        <span class="player__time">{{ currentTime }}</span>
        <div
          ref="seekBar"
          class="group relative flex h-5 min-w-0 flex-1 cursor-pointer items-center"
          @pointerdown="startDrag($event, seekBar, (ratio) => (progress = ratio))"
        >
          <div class="player__seek-track">
            <div class="player__seek-fill" :style="{ width: progress * 100 + '%' }"></div>
            <div
              class="player__seek-thumb group-hover:scale-150"
              :style="{ left: progress * 100 + '%' }"
            ></div>
          </div>
        </div>
        <span class="player__time">{{ totalTime }}</span>
      </div>
    </div>
  </GlassPanel>
</template>

<style scoped>
.player__cover {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.9rem;
  height: 2.9rem;
  flex-shrink: 0;
  border-radius: 0.7rem;
  border: 1px solid rgba(214, 232, 246, 0.18);
  color: rgba(198, 224, 243, 0.6);
  background: radial-gradient(120% 120% at 50% 0%, rgba(214, 236, 252, 0.08) 0%, transparent 70%);
  box-shadow: inset 0 1px 0 rgba(233, 244, 253, 0.1);
}

.player__dot {
  width: 5px;
  height: 5px;
  border-radius: 9999px;
  background: rgba(198, 224, 243, 0.35);
  transition:
    background-color 0.3s ease,
    box-shadow 0.3s ease;
}

.player__dot--live {
  background: rgba(238, 246, 252, 0.95);
  box-shadow: 0 0 8px rgba(214, 236, 252, 0.7);
  animation: player-pulse 1.6s ease-in-out infinite;
}

@keyframes player-pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.45;
  }
}

.player__live {
  font-size: 9px;
  font-weight: 300;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.55);
}

.player__title {
  margin-top: 0.24rem;
  font-size: 13px;
  font-weight: 300;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(244, 250, 255, 0.92);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.player__artist {
  font-size: 11px;
  font-weight: 300;
  letter-spacing: 0.04em;
  color: rgba(198, 224, 243, 0.45);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.player__skip {
  color: rgba(198, 224, 243, 0.5);
  transition: color 0.25s ease;
}

.player__skip:hover {
  color: rgba(238, 246, 252, 0.85);
}

.player__toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.3rem;
  height: 2.3rem;
  border-radius: 9999px;
  border: 1px solid rgba(214, 232, 246, 0.35);
  color: rgba(238, 246, 252, 0.85);
  box-shadow: 0 0 14px -4px rgba(214, 236, 252, 0.3);
  transition:
    border-color 0.3s ease,
    box-shadow 0.3s ease,
    color 0.3s ease;
}

.player__toggle:hover {
  border-color: rgba(250, 253, 255, 0.62);
  color: rgba(255, 255, 255, 1);
  box-shadow: 0 0 22px -4px rgba(226, 240, 250, 0.5);
}

.player__volume-icon {
  cursor: pointer;
  color: rgba(198, 224, 243, 0.5);
  transition: color 0.25s ease;
}

.player__volume-icon:hover {
  color: rgba(238, 246, 252, 0.85);
}

.player__volume-track {
  position: relative;
  width: 100%;
  height: 2px;
  border-radius: 9999px;
  background: rgba(198, 224, 243, 0.18);
}

.player__volume-fill {
  position: absolute;
  inset-block: 0;
  left: 0;
  border-radius: 9999px;
  background: rgba(240, 248, 255, 0.75);
}

.player__volume-thumb {
  position: absolute;
  top: 50%;
  width: 7px;
  height: 7px;
  transform: translate(-50%, -50%);
  border-radius: 9999px;
  background: rgba(250, 253, 255, 0.95);
  box-shadow: 0 0 6px rgba(226, 240, 250, 0.6);
  transition: scale 0.2s ease;
}

.player__seek-track {
  position: relative;
  height: 1px;
  width: 100%;
  background: rgba(198, 224, 243, 0.15);
}

.player__seek-fill {
  position: absolute;
  inset-block: 0;
  left: 0;
  background: rgba(240, 248, 255, 0.7);
  box-shadow: 0 0 8px rgba(226, 240, 250, 0.3);
}

.player__seek-thumb {
  position: absolute;
  top: 50%;
  width: 6px;
  height: 6px;
  transform: translate(-50%, -50%);
  border-radius: 9999px;
  background: rgba(250, 253, 255, 0.95);
  box-shadow: 0 0 6px rgba(226, 240, 250, 0.6);
  transition: scale 0.2s ease;
}

.player__time {
  font-family: ui-monospace, monospace;
  font-size: 9.5px;
  letter-spacing: 0.18em;
  color: rgba(198, 224, 243, 0.4);
  font-variant-numeric: tabular-nums;
}
</style>
