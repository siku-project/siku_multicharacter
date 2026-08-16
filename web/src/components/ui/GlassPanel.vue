<template>
  <div class="glass">
    <span class="glass__sheen" aria-hidden="true"></span>
    <span class="glass__light" aria-hidden="true"></span>
    <div class="glass__body">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.glass {
  position: relative;
  isolation: isolate;
  border-radius: 1.6rem;
  border: 1px solid rgba(233, 244, 253, 0.17);
  background: linear-gradient(
    165deg,
    rgba(214, 232, 246, 0.11) 0%,
    rgba(214, 232, 246, 0.05) 55%,
    rgba(203, 227, 246, 0.08) 100%
  );
  backdrop-filter: blur(22px) saturate(150%);
  -webkit-backdrop-filter: blur(22px) saturate(150%);
  box-shadow:
    inset 0 1px 0 rgba(240, 248, 255, 0.28),
    inset 0 0 0 1px rgba(233, 244, 253, 0.03),
    0 30px 80px -30px rgba(2, 6, 14, 0.85),
    0 8px 30px -12px rgba(2, 6, 14, 0.55);
}

.glass__light {
  position: absolute;
  top: 0;
  left: 9%;
  right: 9%;
  height: 1px;
  z-index: 2;
  border-radius: 9999px;
  pointer-events: none;
  background: linear-gradient(to right, transparent, rgba(250, 253, 255, 0.7) 50%, transparent);
  box-shadow: 0 0 16px 1px rgba(226, 240, 250, 0.4);
}

.glass__sheen {
  position: absolute;
  inset: 0;
  z-index: 0;
  border-radius: inherit;
  pointer-events: none;
  background:
    linear-gradient(
      117deg,
      transparent 32%,
      rgba(233, 244, 253, 0.07) 45%,
      rgba(233, 244, 253, 0.02) 52%,
      transparent 64%
    ),
    radial-gradient(85% 55% at 30% 0%, rgba(233, 244, 253, 0.09) 0%, transparent 60%),
    radial-gradient(52% 120px at 50% 0%, rgba(240, 248, 255, 0.09) 0%, transparent 70%);
}

.glass__body {
  position: relative;
  z-index: 1;
}
</style>
