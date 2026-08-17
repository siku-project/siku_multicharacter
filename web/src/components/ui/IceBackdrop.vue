<template>
  <div class="backdrop" aria-hidden="true">
    <span class="backdrop__emblem"></span>
    <span class="backdrop__aurora backdrop__aurora--one"></span>
    <span class="backdrop__aurora backdrop__aurora--two"></span>
    <span class="backdrop__ice"></span>
    <span class="backdrop__vignette"></span>
  </div>
</template>

<style scoped>
.backdrop {
  position: absolute;
  inset: 0;
  overflow: hidden;
  isolation: isolate;
  background:
    radial-gradient(120% 70% at 50% -20%, rgba(203, 227, 246, 0.1) 0%, transparent 55%),
    radial-gradient(85% 75% at 84% 62%, rgba(37, 68, 104, 0.4) 0%, transparent 60%),
    linear-gradient(215deg, rgba(24, 48, 76, 0.55) 0%, transparent 52%),
    radial-gradient(70% 80% at 8% 95%, rgba(3, 8, 16, 0.75) 0%, transparent 55%),
    linear-gradient(180deg, #0e2036 0%, #091829 46%, #050e1c 100%);
}

.backdrop__emblem {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 1280px;
  height: 1280px;
  transform: translate(-50%, -50%);
  background-image: url('../../assets/siku-emblem.webp');
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
  opacity: 0.06;
  filter: grayscale(1);
  pointer-events: none;
}

.backdrop__aurora {
  position: absolute;
  border-radius: 9999px;
  pointer-events: none;
}

.backdrop__aurora--one {
  top: -38%;
  left: -12%;
  width: 78%;
  height: 74%;
  background: radial-gradient(
    50% 50% at 50% 50%,
    rgba(161, 203, 232, 0.14) 0%,
    rgba(111, 168, 212, 0.06) 45%,
    transparent 70%
  );
  animation: aurora-one 34s ease-in-out infinite alternate;
}

.backdrop__aurora--two {
  top: -30%;
  right: -18%;
  width: 72%;
  height: 68%;
  background: radial-gradient(
    50% 50% at 50% 50%,
    rgba(226, 240, 250, 0.1) 0%,
    rgba(161, 203, 232, 0.045) 48%,
    transparent 72%
  );
  animation: aurora-two 44s ease-in-out infinite alternate;
}

@keyframes aurora-one {
  from {
    transform: translate3d(0, 0, 0) rotate(0deg);
  }
  to {
    transform: translate3d(6%, 4%, 0) rotate(6deg);
  }
}

@keyframes aurora-two {
  from {
    transform: translate3d(0, 0, 0) rotate(0deg);
  }
  to {
    transform: translate3d(-5%, 6%, 0) rotate(-5deg);
  }
}

.backdrop__ice {
  position: absolute;
  inset: auto 0 0 0;
  height: 42%;
  pointer-events: none;
  background:
    radial-gradient(70% 90% at 50% 115%, rgba(161, 203, 232, 0.1) 0%, transparent 60%),
    linear-gradient(to top, rgba(203, 227, 246, 0.05) 0%, transparent 55%);
}

.backdrop__vignette {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background: radial-gradient(115% 100% at 50% 45%, transparent 58%, rgba(3, 8, 16, 0.5) 100%);
}
</style>
