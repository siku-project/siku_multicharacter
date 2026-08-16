<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import OptionSelect from './controls/OptionSelect.vue'
import SwatchRow from './controls/SwatchRow.vue'
import RangeSlider from '@/components/ui/RangeSlider.vue'
import SpritePicker from './controls/SpritePicker.vue'
import { resolveIcon } from '@/utils/icons'
import { controlKey } from '@/config/appearance'
import type { AppearanceCategory, AppearanceControl } from '@/config/appearance'
import eyeColourSprite from '@/assets/mp-eye-colour.png'

const SPRITE_IMAGES: Record<string, string> = {
  eyeColour: eyeColourSprite,
}

const props = defineProps<{
  stepId: string
  category: AppearanceCategory
  draft: Record<string, number>
}>()

const emit = defineEmits<{
  update: [key: string, value: number]
}>()

const { t } = useI18n()

const portraitControls = computed(() =>
  props.category.controls.filter((control) => control.portrait),
)

const standardControls = computed(() =>
  props.category.controls.filter((control) => !control.portrait),
)

const keyOf = (controlId: string): string => controlKey(props.stepId, props.category.id, controlId)

const selectItems = (control: AppearanceControl): { label: string }[] =>
  (control.labels ?? []).map((label) => ({ label }))
</script>

<template>
  <div class="flex flex-col gap-6">
    <div v-if="portraitControls.length > 0" class="grid grid-cols-2 gap-5">
      <div v-for="control in portraitControls" :key="control.id" class="flex flex-col gap-3">
        <div class="portrait mx-auto">
          <v-icon size="26" :icon="resolveIcon('mdi-account-outline')" />
          <span class="portrait__tag">{{ t('appearance.photo') }}</span>
        </div>
        <div class="flex justify-center">
          <span class="portrait__name">{{ t(control.labelKey) }}</span>
        </div>
        <OptionSelect
          :model-value="draft[keyOf(control.id)] ?? 0"
          :options="selectItems(control)"
          @update:model-value="emit('update', keyOf(control.id), $event)"
        />
      </div>
    </div>

    <template v-for="control in standardControls" :key="control.id">
      <div v-if="control.section" class="detail-sec -mb-1 mt-1 flex items-center gap-3.5">
        <span class="detail-sec__label">{{ t(control.section) }}</span>
        <span class="detail-sec__line flex-1"></span>
      </div>
      <SwatchRow
        v-if="control.type === 'swatches'"
        :label="t(control.labelKey)"
        :model-value="draft[keyOf(control.id)] ?? 0"
        :colors="control.colors ?? []"
        @update:model-value="emit('update', keyOf(control.id), $event)"
      />
      <SpritePicker
        v-else-if="control.type === 'sprite'"
        :label="t(control.labelKey)"
        :model-value="draft[keyOf(control.id)] ?? 0"
        :count="control.max ?? 1"
        :columns="control.spriteColumns ?? 8"
        :image="SPRITE_IMAGES[control.sprite ?? ''] ?? ''"
        @update:model-value="emit('update', keyOf(control.id), $event)"
      />
      <RangeSlider
        v-else
        :label="t(control.labelKey)"
        :model-value="draft[keyOf(control.id)] ?? 0"
        :min="control.min ?? 0"
        :max="control.max ?? 100"
        :step="control.step ?? 1"
        :unit="control.unit ?? ''"
        :left-label="control.leftKey ? t(control.leftKey) : ''"
        :right-label="control.rightKey ? t(control.rightKey) : ''"
        :blend="control.type === 'blend'"
        @update:model-value="emit('update', keyOf(control.id), $event)"
      />
    </template>
  </div>
</template>

<style scoped>
.portrait {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.45rem;
  width: 7.5rem;
  aspect-ratio: 3 / 3.4;
  border-radius: 0.85rem;
  border: 1px solid rgba(212, 231, 247, 0.16);
  background:
    radial-gradient(120% 90% at 50% -15%, rgba(203, 227, 246, 0.1) 0%, transparent 60%),
    linear-gradient(180deg, rgba(20, 44, 71, 0.45) 0%, rgba(9, 24, 43, 0.55) 100%);
  color: rgba(198, 224, 243, 0.35);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.14),
    inset 0 -18px 34px -26px rgba(5, 14, 30, 0.5);
}

.portrait__tag {
  font-size: 8.5px;
  font-weight: 300;
  letter-spacing: 0.32em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.32);
}

.detail-sec__label {
  font-size: 11.5px;
  font-weight: 300;
  letter-spacing: 0.26em;
  text-transform: uppercase;
  color: rgba(250, 253, 255, 0.95);
  text-shadow: 0 0 14px rgba(226, 240, 250, 0.35);
}

.detail-sec__line {
  height: 1px;
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    rgba(240, 248, 255, 0.45),
    rgba(214, 236, 252, 0.14) 60%,
    transparent
  );
  box-shadow: 0 0 8px rgba(226, 240, 250, 0.25);
}

.portrait__name {
  font-size: 10.5px;
  font-weight: 400;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(226, 240, 250, 0.8);
}
</style>
