<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import tipsSprite from '@/assets/tips-mouse.webp'

const { t } = useI18n()

const TIPS = [
  { position: '0% center', labelKey: 'appearance.tipPan', hintKey: 'appearance.tipPanHint' },
  { position: '50% center', labelKey: 'appearance.tipZoom', hintKey: 'appearance.tipZoomHint' },
  {
    position: '100% center',
    labelKey: 'appearance.tipRotate',
    hintKey: 'appearance.tipRotateHint',
  },
]
</script>

<template>
  <div class="pointer-events-none fixed left-1/2 top-7 z-50 -translate-x-1/2">
    <div class="tips flex items-center gap-5 px-5 py-2.5">
      <template v-for="(tip, index) in TIPS" :key="tip.labelKey">
        <div v-if="index > 0" class="tips__sep" aria-hidden="true"></div>
        <div class="flex items-center gap-2.5">
          <div
            class="tips__icon"
            :style="{
              backgroundImage: `url(${tipsSprite})`,
              backgroundSize: '300% auto',
              backgroundPosition: tip.position,
            }"
          />
          <div class="flex flex-col">
            <span class="tips__label">{{ t(tip.labelKey) }}</span>
            <span class="tips__hint">{{ t(tip.hintKey) }}</span>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.tips {
  position: relative;
  border-radius: 14px;
  border: 1px solid rgba(148, 184, 220, 0.16);
  background:
    var(--ice-noise),
    radial-gradient(120% 160% at 50% 0%, rgba(140, 180, 225, 0.1) 0%, rgba(140, 180, 225, 0) 55%),
    linear-gradient(180deg, rgba(15, 23, 42, 0.88) 0%, rgba(15, 23, 42, 0.94) 100%);
  box-shadow:
    inset 0 1px 0 rgba(226, 240, 255, 0.08),
    0 18px 40px rgba(2, 6, 16, 0.45);
}

.tips::before {
  content: '';
  position: absolute;
  inset-inline: 18%;
  top: -1px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(226, 240, 255, 0.5), transparent);
}

.tips__sep {
  width: 1px;
  height: 30px;
  background: linear-gradient(180deg, transparent, rgba(148, 184, 220, 0.28), transparent);
}

.tips__icon {
  width: 26px;
  height: 34px;
  background-repeat: no-repeat;
  opacity: 0.92;
}

.tips__label {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.04em;
  color: rgba(232, 242, 252, 0.95);
}

.tips__hint {
  font-size: 10px;
  color: rgba(160, 185, 210, 0.78);
}
</style>
