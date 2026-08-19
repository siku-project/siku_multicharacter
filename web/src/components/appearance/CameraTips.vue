<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import tipsSprite from '@/assets/tips-mouse.webp'

withDefaults(
  defineProps<{
    variant?: 'glass' | 'minimal' | 'dark'
  }>(),
  {
    variant: 'glass',
  },
)

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
    <div class="tips flex items-center gap-5 px-5 py-2.5" :class="`tips--${variant}`">
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
}

.tips__icon {
  width: 26px;
  height: 34px;
  background-repeat: no-repeat;
  opacity: 0.92;
}

.tips--glass {
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

.tips--glass::before {
  content: '';
  position: absolute;
  inset-inline: 18%;
  top: -1px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(226, 240, 255, 0.5), transparent);
}

.tips--glass .tips__sep {
  width: 1px;
  height: 30px;
  background: linear-gradient(180deg, transparent, rgba(148, 184, 220, 0.28), transparent);
}

.tips--glass .tips__label {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.04em;
  color: rgba(232, 242, 252, 0.95);
}

.tips--glass .tips__hint {
  font-size: 10px;
  color: rgba(160, 185, 210, 0.78);
}

.tips--minimal {
  border-radius: 13px;
  border: 1px solid rgba(150, 190, 225, 0.14);
  background: linear-gradient(180deg, rgba(18, 30, 48, 0.72) 0%, rgba(10, 20, 35, 0.78) 100%);
  box-shadow: 0 20px 44px -24px rgba(4, 10, 22, 0.85);
}

.tips--minimal::before {
  content: '';
  position: absolute;
  inset-inline: 24%;
  top: -1px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(226, 240, 255, 0.45), transparent);
}

.tips--minimal .tips__sep {
  width: 1px;
  height: 28px;
  background: linear-gradient(180deg, transparent, rgba(160, 200, 235, 0.22), transparent);
}

.tips--minimal .tips__label {
  font-size: 10.8px;
  font-weight: 400;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(240, 248, 255, 0.92);
}

.tips--minimal .tips__hint {
  margin-top: 2px;
  font-size: 10px;
  font-weight: 300;
  letter-spacing: 0.02em;
  color: rgba(170, 200, 228, 0.55);
}

.tips--dark {
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(12, 13, 16, 0.94);
  box-shadow: 0 20px 44px -24px rgba(0, 0, 0, 0.9);
}

.tips--dark::before {
  content: '';
  position: absolute;
  inset-inline: 26%;
  top: -1px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(108, 182, 246, 0.65), transparent);
}

.tips--dark .tips__sep {
  width: 1px;
  height: 28px;
  background: rgba(255, 255, 255, 0.08);
}

.tips--dark .tips__label {
  font-size: 11.4px;
  font-weight: 600;
  letter-spacing: 0.01em;
  color: rgba(255, 255, 255, 0.92);
}

.tips--dark .tips__hint {
  margin-top: 1px;
  font-size: 10.2px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.34);
}

.tips--dark .tips__icon {
  opacity: 0.78;
}
</style>
