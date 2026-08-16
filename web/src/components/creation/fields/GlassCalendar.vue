<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { resolveIcon } from '@/utils/icons'
import { MAX_AGE, MIN_AGE } from '@/utils/identity'

interface CalendarCell {
  day: number
  month: number
  year: number
  inMonth: boolean
}

const props = defineProps<{
  day: string
  month: string
  year: string
}>()

const emit = defineEmits<{
  pick: [day: number, month: number, year: number]
}>()

const { locale } = useI18n()

const currentYear = new Date().getFullYear()
const minYear = currentYear - MAX_AGE
const maxYear = currentYear - MIN_AGE

const initialYear = (): number => {
  const year = Number(props.year)
  if (Number.isInteger(year) && year >= minYear && year <= maxYear) {
    return year
  }
  return currentYear - 25
}

const initialMonth = (): number => {
  const month = Number(props.month)
  return Number.isInteger(month) && month >= 1 && month <= 12 ? month - 1 : 0
}

const viewYear = ref(initialYear())
const viewMonth = ref(initialMonth())

watch(
  () => [props.day, props.month, props.year],
  () => {
    const year = Number(props.year)
    const month = Number(props.month)
    if (Number.isInteger(year) && year >= minYear && year <= maxYear) {
      viewYear.value = year
    }
    if (Number.isInteger(month) && month >= 1 && month <= 12) {
      viewMonth.value = month - 1
    }
  },
)

const monthLabel = computed(() => {
  const label = new Intl.DateTimeFormat(locale.value, { month: 'long' }).format(
    new Date(viewYear.value, viewMonth.value, 1),
  )
  return label.charAt(0).toUpperCase() + label.slice(1)
})

const weekdayLabels = computed(() => {
  const format = new Intl.DateTimeFormat(locale.value, { weekday: 'narrow' })
  return Array.from({ length: 7 }, (_, index) => format.format(new Date(2024, 0, index + 1)))
})

const cells = computed<CalendarCell[]>(() => {
  const first = new Date(viewYear.value, viewMonth.value, 1)
  const offset = (first.getDay() + 6) % 7
  return Array.from({ length: 42 }, (_, index) => {
    const date = new Date(viewYear.value, viewMonth.value, index + 1 - offset)
    return {
      day: date.getDate(),
      month: date.getMonth() + 1,
      year: date.getFullYear(),
      inMonth: date.getMonth() === viewMonth.value,
    }
  })
})

const isSelected = (cell: CalendarCell): boolean =>
  Number(props.day) === cell.day &&
  Number(props.month) === cell.month &&
  Number(props.year) === cell.year

const shiftMonth = (step: number): void => {
  const next = new Date(viewYear.value, viewMonth.value + step, 1)
  const year = Math.min(maxYear, Math.max(minYear, next.getFullYear()))
  viewYear.value = year
  viewMonth.value = year === next.getFullYear() ? next.getMonth() : viewMonth.value
}

const shiftYear = (step: number): void => {
  viewYear.value = Math.min(maxYear, Math.max(minYear, viewYear.value + step))
}

const pick = (cell: CalendarCell): void => {
  if (cell.year < minYear || cell.year > maxYear) {
    return
  }
  emit('pick', cell.day, cell.month, cell.year)
}
</script>

<template>
  <div class="calendar">
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-1">
        <button type="button" class="calendar__nav" @click="shiftYear(-1)">
          <v-icon size="15" :icon="resolveIcon('mdi-chevron-double-left')" />
        </button>
        <button type="button" class="calendar__nav" @click="shiftMonth(-1)">
          <v-icon size="15" :icon="resolveIcon('mdi-chevron-left')" />
        </button>
      </div>

      <span class="calendar__label">{{ monthLabel }} {{ viewYear }}</span>

      <div class="flex items-center gap-1">
        <button type="button" class="calendar__nav" @click="shiftMonth(1)">
          <v-icon size="15" :icon="resolveIcon('mdi-chevron-right')" />
        </button>
        <button type="button" class="calendar__nav" @click="shiftYear(1)">
          <v-icon size="15" :icon="resolveIcon('mdi-chevron-double-right')" />
        </button>
      </div>
    </div>

    <div class="calendar__grid mt-4">
      <span v-for="(label, index) in weekdayLabels" :key="`w-${index}`" class="calendar__weekday">
        {{ label }}
      </span>
    </div>

    <div class="calendar__grid mt-1.5">
      <button
        v-for="(cell, index) in cells"
        :key="index"
        type="button"
        class="calendar__day"
        :class="{
          'calendar__day--out': !cell.inMonth,
          'calendar__day--selected': isSelected(cell),
        }"
        @click="pick(cell)"
      >
        {{ cell.day }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.calendar {
  width: 320px;
  border-radius: 1.1rem;
  border: 1px solid rgba(233, 244, 253, 0.18);
  background: linear-gradient(180deg, rgba(13, 28, 48, 0.96) 0%, rgba(8, 19, 34, 0.98) 100%);
  backdrop-filter: blur(18px) saturate(140%);
  -webkit-backdrop-filter: blur(18px) saturate(140%);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.18),
    0 26px 60px -22px rgba(2, 6, 14, 0.9);
  padding: 1.1rem 1.15rem 1.2rem;
}

.calendar__nav {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 1.9rem;
  height: 1.9rem;
  border-radius: 0.6rem;
  color: rgba(198, 224, 243, 0.55);
  transition:
    color 0.25s ease,
    background-color 0.25s ease;
}

.calendar__nav:hover {
  color: rgba(250, 253, 255, 0.95);
  background: rgba(214, 236, 252, 0.08);
}

.calendar__label {
  font-size: 12.5px;
  font-weight: 400;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: rgba(244, 250, 255, 0.95);
}

.calendar__grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 0.15rem;
}

.calendar__weekday {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  font-weight: 400;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: rgba(161, 203, 232, 0.45);
  padding: 0.2rem 0;
}

.calendar__day {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 2.15rem;
  border-radius: 0.6rem;
  font-size: 12.5px;
  font-weight: 300;
  font-variant-numeric: tabular-nums;
  color: rgba(238, 246, 252, 0.85);
  transition:
    background-color 0.2s ease,
    color 0.2s ease,
    box-shadow 0.2s ease;
}

.calendar__day:hover {
  background: rgba(214, 236, 252, 0.1);
  color: rgba(255, 255, 255, 1);
}

.calendar__day--out {
  color: rgba(161, 203, 232, 0.28);
}

.calendar__day--selected,
.calendar__day--selected:hover {
  background: rgba(214, 236, 252, 0.18);
  color: rgba(255, 255, 255, 1);
  box-shadow:
    inset 0 0 0 1px rgba(238, 246, 252, 0.55),
    0 0 16px -4px rgba(214, 236, 252, 0.5);
}
</style>
