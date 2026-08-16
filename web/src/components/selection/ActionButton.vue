<script setup lang="ts">
import { resolveIcon } from '@/utils/icons'

withDefaults(
  defineProps<{
    label: string
    icon: string
    variant?: 'primary' | 'neutral' | 'danger'
  }>(),
  {
    variant: 'neutral',
  },
)

const emit = defineEmits<{
  click: []
}>()
</script>

<template>
  <button type="button" class="pill" :class="`pill--${variant}`" @click="emit('click')">
    <span class="pill__bloom" aria-hidden="true"></span>
    <span class="pill__icon">
      <v-icon size="17" :icon="resolveIcon(icon)" />
    </span>
    <span class="pill__label">{{ label }}</span>
  </button>
</template>

<style scoped>
.pill {
  position: relative;
  overflow: hidden;
  isolation: isolate;
  display: inline-flex;
  align-items: center;
  gap: 1rem;
  border-radius: 9999px;
  border: 1px solid rgba(214, 232, 246, 0.38);
  padding: 0.5rem 2rem 0.5rem 0.55rem;
  background:
    radial-gradient(140% 120% at 50% -40%, rgba(203, 227, 246, 0.09) 0%, transparent 60%),
    linear-gradient(180deg, rgba(17, 38, 62, 0.76) 0%, rgba(9, 23, 42, 0.85) 100%);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.15),
    0 4px 10px rgba(4, 11, 22, 0.45),
    0 14px 32px -8px rgba(4, 11, 22, 0.6),
    0 28px 60px -18px rgba(4, 11, 22, 0.55);
  transition:
    border-color 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    box-shadow 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.45s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.pill__bloom {
  position: absolute;
  inset: 0;
  z-index: 0;
  border-radius: inherit;
  pointer-events: none;
  background: radial-gradient(
    120% 170% at 1.9rem 50%,
    rgba(214, 236, 252, 0.11) 0%,
    rgba(214, 236, 252, 0.04) 38%,
    transparent 65%
  );
  opacity: 0;
  transition: opacity 0.55s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.pill:hover {
  border-color: rgba(230, 244, 253, 0.62);
  transform: scale(1.015);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.2),
    0 0 26px -10px rgba(214, 236, 252, 0.24),
    0 4px 10px rgba(4, 11, 22, 0.45),
    0 14px 32px -8px rgba(4, 11, 22, 0.6),
    0 28px 60px -18px rgba(4, 11, 22, 0.55);
}

.pill:hover .pill__bloom {
  opacity: 1;
}

.pill:hover .pill__icon {
  border-color: rgba(240, 248, 254, 0.72);
  color: rgba(252, 254, 255, 0.98);
  box-shadow:
    0 0 18px -6px rgba(214, 236, 252, 0.42),
    inset 0 0 10px -6px rgba(214, 236, 252, 0.28);
}

.pill:hover .pill__label {
  color: rgba(252, 254, 255, 0.99);
}

.pill__icon {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.7rem;
  height: 2.7rem;
  border-radius: 9999px;
  border: 1.5px solid rgba(214, 236, 252, 0.5);
  color: rgba(242, 248, 253, 0.92);
  background: radial-gradient(120% 120% at 50% 0%, rgba(214, 236, 252, 0.12) 0%, transparent 70%);
  box-shadow: 0 0 14px -5px rgba(214, 236, 252, 0.35);
  transition:
    border-color 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    color 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    box-shadow 0.45s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.pill__label {
  position: relative;
  z-index: 1;
  font-size: 13px;
  font-weight: 400;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: rgba(242, 248, 253, 0.94);
  white-space: nowrap;
  transition:
    color 0.45s cubic-bezier(0.22, 0.6, 0.2, 1),
    text-shadow 0.45s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.pill--primary {
  border-color: rgba(222, 240, 252, 0.52);
}

.pill--primary .pill__icon {
  border-color: rgba(238, 246, 252, 0.72);
  color: rgba(250, 253, 255, 1);
  box-shadow: 0 0 20px -5px rgba(214, 236, 252, 0.6);
}

.pill--danger .pill__bloom {
  background: radial-gradient(
    120% 170% at 1.9rem 50%,
    rgba(244, 110, 122, 0.14) 0%,
    rgba(244, 110, 122, 0.05) 38%,
    transparent 65%
  );
}

.pill--danger .pill__icon {
  border-color: rgba(244, 110, 122, 0.3);
  color: rgba(244, 138, 148, 0.75);
}

.pill--danger .pill__label {
  color: rgba(226, 240, 250, 0.6);
}

.pill--danger:hover {
  border-color: rgba(244, 110, 122, 0.3);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.14),
    0 0 24px -10px rgba(244, 110, 122, 0.2),
    0 4px 10px rgba(4, 11, 22, 0.45),
    0 14px 32px -8px rgba(4, 11, 22, 0.6),
    0 28px 60px -18px rgba(4, 11, 22, 0.55);
}

.pill--danger:hover .pill__icon {
  border-color: rgba(244, 138, 148, 0.5);
  color: rgba(248, 170, 178, 0.9);
  box-shadow:
    0 0 16px -6px rgba(244, 110, 122, 0.35),
    inset 0 0 10px -6px rgba(244, 110, 122, 0.25);
}

.pill--danger:hover .pill__label {
  color: rgba(248, 190, 196, 0.92);
}
</style>
