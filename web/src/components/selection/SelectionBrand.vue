<template>
  <div class="flex flex-col gap-3">
    <h1 class="brand__name">SIKU</h1>
    <span class="brand__line"></span>
  </div>
</template>

<style scoped>
.brand__name {
  font-size: 54px;
  line-height: 1;
  font-weight: 100;
  letter-spacing: 0.42em;
  margin-right: -0.42em;
  color: rgba(250, 253, 255, 1);
  text-shadow:
    0 0 34px rgba(214, 236, 252, 0.55),
    0 0 12px rgba(214, 236, 252, 0.3),
    0 1px 3px rgba(4, 11, 22, 0.95),
    0 2px 8px rgba(4, 11, 22, 0.85),
    0 5px 22px rgba(4, 11, 22, 0.75),
    0 10px 40px rgba(4, 11, 22, 0.55);
}

.brand__line {
  width: 100%;
  height: 1px;
  background: linear-gradient(
    to right,
    rgba(226, 240, 250, 0.2),
    rgba(226, 240, 250, 0.85) 20%,
    rgba(226, 240, 250, 0.85) 80%,
    rgba(226, 240, 250, 0.2)
  );
  box-shadow:
    0 0 10px rgba(214, 236, 252, 0.45),
    0 1px 3px rgba(4, 11, 22, 0.9),
    0 3px 10px rgba(4, 11, 22, 0.7);
}
</style>
