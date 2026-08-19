<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { resolveIcon } from '@/utils/icons'

export interface OptionSelectItem {
  label: string
  mono?: string
}

const props = withDefaults(
  defineProps<{
    modelValue: number
    options: OptionSelectItem[]
    label?: string
    placeholder?: string
    variant?: 'glass' | 'minimal' | 'dark'
  }>(),
  {
    label: '',
    placeholder: '',
    variant: 'glass',
  },
)

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()

const open = ref(false)
const trigger = ref<HTMLElement | null>(null)
const list = ref<HTMLElement | null>(null)
const listStyle = ref<Record<string, string>>({})

const current = computed(() => props.options[props.modelValue])

const toggle = (): void => {
  if (!open.value && trigger.value) {
    const rect = trigger.value.getBoundingClientRect()
    listStyle.value = {
      position: 'fixed',
      left: `${rect.left}px`,
      top: `${rect.bottom + 8}px`,
      width: `${rect.width}px`,
    }
  }
  open.value = !open.value
}

const pick = (index: number): void => {
  emit('update:modelValue', index)
  open.value = false
}

const handleOutsideClick = (event: MouseEvent): void => {
  const target = event.target as Node
  if (open.value && !trigger.value?.contains(target) && !list.value?.contains(target)) {
    open.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleOutsideClick)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleOutsideClick)
})
</script>

<template>
  <div class="optsel" :class="`optsel--${variant}`">
    <span v-if="label" class="ice-field-label mb-2 block">{{ label }}</span>
    <button
      ref="trigger"
      type="button"
      class="optsel__trigger flex w-full items-center gap-3"
      :class="{ 'optsel__trigger--open': open }"
      @click="toggle"
    >
      <span class="optsel__name" :class="{ 'optsel__name--empty': !current }">
        {{ current?.label ?? placeholder }}
      </span>
      <span v-if="current?.mono" class="optsel__mono">{{ current.mono }}</span>
      <v-icon
        class="optsel__chevron ml-auto"
        :class="{ 'optsel__chevron--open': open }"
        size="16"
        :icon="resolveIcon('mdi-chevron-down')"
      />
    </button>

    <Teleport to="body">
      <Transition name="optsel-pop">
        <div
          v-if="open"
          ref="list"
          class="optsel__list ice-scroll z-50"
          :class="`optsel--${variant}`"
          :style="listStyle"
        >
          <button
            v-for="(option, index) in options"
            :key="index"
            type="button"
            class="optsel__row flex w-full items-center gap-2"
            :class="{ 'optsel__row--active': index === modelValue }"
            @click="pick(index)"
          >
            <span class="optsel__row-name">{{ option.label }}</span>
            <span v-if="option.mono" class="optsel__mono ml-auto">{{ option.mono }}</span>
            <v-icon
              v-if="index === modelValue"
              class="optsel__check"
              :class="{ 'ml-auto': !option.mono }"
              size="14"
              :icon="resolveIcon('mdi-check')"
            />
          </button>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<style>
.optsel__trigger {
  transition:
    border-color 0.3s ease,
    background-color 0.3s ease,
    box-shadow 0.3s ease;
}

.optsel__name {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: color 0.3s ease;
}

.optsel__chevron {
  transition: transform 0.3s ease;
}

.optsel__chevron--open {
  transform: rotate(180deg);
}

.optsel__list {
  max-height: 250px;
  overflow-y: auto;
}

.optsel__row {
  transition:
    background-color 0.2s ease,
    color 0.2s ease;
}

.optsel__row-name {
  transition: color 0.2s ease;
}

.optsel-pop-enter-active {
  transition:
    opacity 0.24s cubic-bezier(0.22, 0.6, 0.2, 1),
    transform 0.24s cubic-bezier(0.22, 0.6, 0.2, 1);
}

.optsel-pop-leave-active {
  transition:
    opacity 0.14s ease,
    transform 0.14s ease;
}

.optsel-pop-enter-from,
.optsel-pop-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* ── glass ─────────────────────────────────────────────── */

.optsel--glass .optsel__trigger {
  border-radius: 0.8rem;
  border: 1px solid rgba(212, 231, 247, 0.16);
  background-image:
    var(--ice-noise),
    radial-gradient(150% 100% at 50% -25%, rgba(203, 227, 246, 0.12) 0%, transparent 55%),
    linear-gradient(180deg, rgba(20, 44, 71, 0.74) 0%, rgba(9, 24, 43, 0.82) 100%);
  background-repeat: repeat, no-repeat, no-repeat;
  background-size:
    130px 130px,
    cover,
    cover;
  padding: 0.72rem 1rem;
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.22),
    inset 0 0 0 1px rgba(233, 244, 253, 0.03);
}

.optsel--glass .optsel__trigger:hover {
  border-color: rgba(233, 244, 253, 0.32);
}

.optsel--glass .optsel__trigger--open {
  border-color: rgba(250, 253, 255, 0.45);
  box-shadow:
    inset 0 1px 0 rgba(250, 253, 255, 0.16),
    0 0 20px -6px rgba(226, 240, 250, 0.4);
}

.optsel--glass .optsel__name {
  font-size: 12.5px;
  font-weight: 300;
  letter-spacing: 0.08em;
  color: rgba(250, 253, 255, 0.97);
}

.optsel--glass .optsel__name--empty {
  color: rgba(198, 224, 243, 0.4);
}

.optsel--glass .optsel__mono {
  font-family: ui-monospace, monospace;
  font-size: 9px;
  letter-spacing: 0.1em;
  color: rgba(198, 224, 243, 0.4);
}

.optsel--glass .optsel__chevron {
  color: rgba(198, 224, 243, 0.55);
}

.optsel--glass.optsel__list {
  border-radius: 0.9rem;
  border: 1px solid rgba(212, 231, 247, 0.16);
  background-image:
    var(--ice-noise),
    radial-gradient(150% 100% at 50% -25%, rgba(203, 227, 246, 0.12) 0%, transparent 55%),
    linear-gradient(180deg, rgba(20, 44, 71, 0.94) 0%, rgba(9, 24, 43, 0.96) 100%);
  background-repeat: repeat, no-repeat, no-repeat;
  background-size:
    130px 130px,
    cover,
    cover;
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.22),
    inset 0 0 0 1px rgba(233, 244, 253, 0.03),
    0 24px 48px -20px rgba(3, 8, 16, 0.85);
  padding: 0.35rem;
}

.optsel--glass .optsel__row {
  border-radius: 0.55rem;
  padding: 0.5rem 0.65rem;
}

.optsel--glass .optsel__row:hover {
  background: rgba(240, 248, 255, 0.07);
}

.optsel--glass .optsel__row--active {
  background: rgba(240, 248, 255, 0.1);
}

.optsel--glass .optsel__row-name {
  font-size: 12px;
  font-weight: 300;
  letter-spacing: 0.08em;
  color: rgba(226, 240, 250, 0.85);
}

.optsel--glass .optsel__row--active .optsel__row-name {
  color: rgba(255, 255, 255, 0.98);
  text-shadow: 0 0 10px rgba(226, 240, 250, 0.35);
}

.optsel--glass .optsel__check {
  color: rgba(250, 253, 255, 0.9);
}

/* ── minimal ───────────────────────────────────────────── */

.optsel--minimal .optsel__trigger {
  border-radius: 10px;
  border: 1px solid rgba(150, 190, 225, 0.14);
  background: linear-gradient(180deg, rgba(16, 28, 46, 0.6) 0%, rgba(9, 18, 32, 0.66) 100%);
  padding: 10px 13px;
}

.optsel--minimal .optsel__trigger:hover {
  border-color: rgba(180, 214, 245, 0.24);
}

.optsel--minimal .optsel__trigger--open {
  border-color: rgba(198, 228, 255, 0.45);
  box-shadow: 0 10px 26px -18px rgba(120, 180, 240, 0.8);
}

.optsel--minimal .optsel__name {
  font-size: 13.2px;
  font-weight: 400;
  letter-spacing: 0.01em;
  color: rgba(240, 248, 255, 0.95);
}

.optsel--minimal .optsel__name--empty {
  color: rgba(160, 192, 222, 0.4);
}

.optsel--minimal .optsel__mono {
  font-family: ui-monospace, monospace;
  font-size: 9.5px;
  letter-spacing: 0.06em;
  color: rgba(160, 192, 222, 0.42);
}

.optsel--minimal .optsel__chevron {
  color: rgba(170, 200, 228, 0.5);
}

.optsel--minimal.optsel__list {
  border-radius: 12px;
  border: 1px solid rgba(160, 200, 235, 0.16);
  background: linear-gradient(180deg, rgba(19, 32, 51, 0.98) 0%, rgba(11, 21, 36, 0.99) 100%);
  box-shadow: 0 28px 60px -28px rgba(4, 10, 22, 0.9);
  padding: 5px;
}

.optsel--minimal .optsel__row {
  border-radius: 8px;
  padding: 8px 11px;
}

.optsel--minimal .optsel__row:hover {
  background: rgba(226, 240, 255, 0.06);
}

.optsel--minimal .optsel__row--active {
  background: linear-gradient(180deg, rgba(34, 58, 88, 0.72) 0%, rgba(16, 30, 50, 0.72) 100%);
}

.optsel--minimal .optsel__row-name {
  font-size: 12.4px;
  font-weight: 400;
  letter-spacing: 0.02em;
  color: rgba(224, 238, 252, 0.82);
}

.optsel--minimal .optsel__row--active .optsel__row-name {
  font-weight: 500;
  color: rgba(244, 250, 255, 0.97);
}

.optsel--minimal .optsel__check {
  color: rgba(214, 238, 255, 0.85);
}

/* ── dark ──────────────────────────────────────────────── */

.optsel--dark .optsel__trigger {
  border-radius: 9px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  padding: 10px 13px;
}

.optsel--dark .optsel__trigger:hover {
  border-color: rgba(255, 255, 255, 0.14);
}

.optsel--dark .optsel__trigger--open {
  border-color: rgba(108, 182, 246, 0.55);
  background: rgba(108, 182, 246, 0.07);
  box-shadow: 0 0 0 3px rgba(108, 182, 246, 0.12);
}

.optsel--dark .optsel__name {
  font-size: 13px;
  font-weight: 450;
  color: rgba(255, 255, 255, 0.92);
}

.optsel--dark .optsel__name--empty {
  color: rgba(255, 255, 255, 0.26);
}

.optsel--dark .optsel__mono {
  font-family: ui-monospace, monospace;
  font-size: 9.5px;
  color: rgba(255, 255, 255, 0.26);
}

.optsel--dark .optsel__chevron {
  color: rgba(255, 255, 255, 0.32);
}

.optsel--dark.optsel__list {
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(16, 17, 20, 0.99);
  box-shadow: 0 28px 60px -28px rgba(0, 0, 0, 0.95);
  padding: 5px;
}

.optsel--dark .optsel__row {
  border-radius: 7px;
  padding: 8px 11px;
}

.optsel--dark .optsel__row:hover {
  background: rgba(255, 255, 255, 0.05);
}

.optsel--dark .optsel__row--active {
  background: rgba(108, 182, 246, 0.13);
  box-shadow: inset 0 0 0 1px rgba(108, 182, 246, 0.28);
}

.optsel--dark .optsel__row-name {
  font-size: 12.6px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.8);
}

.optsel--dark .optsel__row--active .optsel__row-name {
  color: #9ed0fb;
}

.optsel--dark .optsel__check {
  color: #6cb6f6;
}
</style>
