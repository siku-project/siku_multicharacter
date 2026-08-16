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
  }>(),
  {
    label: '',
    placeholder: '',
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
  <div class="optsel">
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
        <div v-if="open" ref="list" class="optsel__list ice-scroll z-50" :style="listStyle">
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
  transition:
    border-color 0.3s ease,
    box-shadow 0.3s ease;
}

.optsel__trigger:hover {
  border-color: rgba(233, 244, 253, 0.32);
}

.optsel__trigger--open {
  border-color: rgba(250, 253, 255, 0.45);
  box-shadow:
    inset 0 1px 0 rgba(250, 253, 255, 0.16),
    0 0 20px -6px rgba(226, 240, 250, 0.4);
}

.optsel__name {
  font-size: 12.5px;
  font-weight: 300;
  letter-spacing: 0.08em;
  color: rgba(250, 253, 255, 0.97);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  transition: color 0.3s ease;
}

.optsel__name--empty {
  color: rgba(198, 224, 243, 0.4);
}

.optsel__mono {
  font-family: ui-monospace, monospace;
  font-size: 9px;
  letter-spacing: 0.1em;
  color: rgba(198, 224, 243, 0.4);
}

.optsel__chevron {
  color: rgba(198, 224, 243, 0.55);
  transition: transform 0.3s ease;
}

.optsel__chevron--open {
  transform: rotate(180deg);
}

.optsel__list {
  max-height: 250px;
  overflow-y: auto;
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

.optsel__row {
  border-radius: 0.55rem;
  padding: 0.5rem 0.65rem;
  transition:
    background-color 0.2s ease,
    color 0.2s ease;
}

.optsel__row:hover {
  background: rgba(240, 248, 255, 0.07);
}

.optsel__row--active {
  background: rgba(240, 248, 255, 0.1);
}

.optsel__row-name {
  font-size: 12px;
  font-weight: 300;
  letter-spacing: 0.08em;
  color: rgba(226, 240, 250, 0.85);
  transition: color 0.2s ease;
}

.optsel__row--active .optsel__row-name {
  color: rgba(255, 255, 255, 0.98);
  text-shadow: 0 0 10px rgba(226, 240, 250, 0.35);
}

.optsel__check {
  color: rgba(250, 253, 255, 0.9);
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
</style>
