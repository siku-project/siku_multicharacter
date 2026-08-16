<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import IcePanel from '@/components/ui/IcePanel.vue'
import IceButton from '@/components/ui/IceButton.vue'
import DetailSection from './DetailSection.vue'
import DetailRow from './DetailRow.vue'
import { resolveIcon } from '@/utils/icons'
import {
  computeAge,
  daysSince,
  formatDate,
  formatMoney,
  formatPlaytime,
} from '@/utils/multicharacter'
import type { CharacterSummary, SelectionConfig } from '@/utils/multicharacter'

const props = withDefaults(
  defineProps<{
    slotNumber: number
    character?: CharacterSummary
    config: SelectionConfig
    showActions?: boolean
  }>(),
  {
    character: undefined,
    showActions: true,
  },
)

const emit = defineEmits<{
  play: [id: number]
  remove: [id: number]
  create: [slot: number]
}>()

const { t, locale } = useI18n()

const age = computed(() => {
  const birthDate = props.character?.identity.birthDate
  return birthDate ? computeAge(birthDate) : null
})

const birthLabel = computed(() => {
  const birthDate = props.character?.identity.birthDate
  if (!birthDate) {
    return null
  }
  const formatted = formatDate(new Date(birthDate).getTime(), locale.value)
  return age.value !== null ? `${formatted} · ${t('selection.age', { age: age.value })}` : formatted
})

const lastPlayedLabel = computed(() => {
  if (!props.character?.lastPlayed) {
    return null
  }
  const days = daysSince(props.character.lastPlayed)
  if (days === 0) {
    return t('selection.today')
  }
  if (days === 1) {
    return t('selection.yesterday')
  }
  return t('selection.daysAgo', { days })
})

const showDirtyMoney = computed(
  () => props.config.showDirtyMoney && props.character?.finances.dirtyMoney !== undefined,
)
</script>

<template>
  <IcePanel variant="primary" class="details">
    <div v-if="character" class="details__scroll flex flex-col px-9 pb-8 pt-9">
      <div class="flex flex-col gap-2">
        <span class="details__slot">{{ t('selection.slot', { number: slotNumber }) }}</span>
        <h2 class="details__name">
          {{ character.identity.firstName }} {{ character.identity.lastName }}
        </h2>
        <span class="details__occupation">
          {{ character.occupation?.name ?? t('selection.unemployed') }}
        </span>
      </div>

      <div class="details__divider my-7 h-px w-full"></div>

      <div class="flex flex-col gap-7">
        <DetailSection :title="t('selection.identity')">
          <DetailRow :label="t('selection.firstName')" :value="character.identity.firstName" />
          <DetailRow :label="t('selection.lastName')" :value="character.identity.lastName" />
          <DetailRow v-if="birthLabel" :label="t('selection.birth')" :value="birthLabel" />
          <DetailRow
            v-if="character.identity.height"
            :label="t('selection.height')"
            :value="`${character.identity.height} cm`"
          />
        </DetailSection>

        <DetailSection :title="t('selection.occupation')">
          <DetailRow
            :label="t('selection.job')"
            :value="character.occupation?.name ?? t('selection.unemployed')"
          />
          <DetailRow
            v-if="character.occupation?.grade"
            :label="t('selection.grade')"
            :value="character.occupation.grade"
          />
        </DetailSection>

        <DetailSection :title="t('selection.finances')">
          <DetailRow :label="t('selection.cash')" :value="formatMoney(character.finances.cash)" />
          <DetailRow :label="t('selection.bank')" :value="formatMoney(character.finances.bank)" />
          <DetailRow
            v-if="showDirtyMoney"
            :label="t('selection.dirtyMoney')"
            :value="formatMoney(character.finances.dirtyMoney ?? 0)"
          />
        </DetailSection>

        <DetailSection :title="t('selection.statistics')">
          <DetailRow :label="t('selection.playtime')" :value="formatPlaytime(character.playtime)" />
          <DetailRow
            v-if="lastPlayedLabel"
            :label="t('selection.lastPlayed')"
            :value="lastPlayedLabel"
          />
          <DetailRow
            :label="t('selection.createdAt')"
            :value="formatDate(character.createdAt, locale)"
          />
        </DetailSection>
      </div>

      <div v-if="showActions" class="mt-6 flex flex-col gap-2.5">
        <IceButton
          :label="t('selection.play')"
          icon="mdi-play"
          variant="primary"
          block
          @click="emit('play', character.id)"
        />
        <IceButton
          v-if="config.allowCharacterDeletion"
          :label="t('selection.delete')"
          icon="mdi-trash-can-outline"
          variant="danger"
          block
          @click="emit('remove', character.id)"
        />
      </div>
    </div>

    <div v-else class="flex h-full flex-col items-center justify-center gap-7 px-8 py-10">
      <span class="details__slot">{{ t('selection.slot', { number: slotNumber }) }}</span>
      <div class="empty__badge">
        <v-icon size="24" :icon="resolveIcon('mdi-plus')" />
      </div>
      <div class="flex flex-col items-center gap-2">
        <span class="empty__title">{{ t('selection.emptySlot') }}</span>
        <span class="empty__hint">{{ t('selection.emptyHint') }}</span>
      </div>
      <IceButton
        :label="t('selection.create')"
        icon="mdi-plus"
        variant="primary"
        @click="emit('create', slotNumber)"
      />
    </div>
  </IcePanel>
</template>

<style scoped>
.details.details {
  --ice-top: 0.8;
  --ice-bottom: 0.9;
  --ice-glow: 0.11;
  width: 100%;
}

.details__scroll {
  max-height: calc(100vh - 140px);
  overflow-y: auto;
}

.details__divider {
  border-radius: 9999px;
  background: linear-gradient(
    to right,
    transparent,
    rgba(214, 236, 252, 0.5) 22%,
    rgba(214, 236, 252, 0.5) 78%,
    transparent
  );
  box-shadow: 0 0 10px rgba(214, 236, 252, 0.3);
}

.details__slot {
  font-family: ui-monospace, monospace;
  font-size: 10.5px;
  letter-spacing: 0.32em;
  text-transform: uppercase;
  color: rgba(198, 224, 243, 0.55);
}

.details__name {
  font-size: 27px;
  line-height: 1.15;
  font-weight: 200;
  letter-spacing: 0.09em;
  color: rgba(250, 253, 255, 1);
  text-shadow: 0 0 22px rgba(214, 236, 252, 0.25);
}

.details__occupation {
  font-size: 12px;
  font-weight: 300;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(214, 232, 246, 0.62);
}

.empty__badge {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 4rem;
  height: 4rem;
  border-radius: 9999px;
  border: 1px solid rgba(214, 236, 252, 0.2);
  color: rgba(226, 240, 250, 0.6);
  background: radial-gradient(120% 120% at 50% 0%, rgba(214, 236, 252, 0.1) 0%, transparent 70%);
  box-shadow:
    inset 0 1px 0 rgba(233, 244, 253, 0.16),
    0 0 30px -12px rgba(214, 236, 252, 0.3);
}

.empty__title {
  font-size: 12px;
  font-weight: 300;
  letter-spacing: 0.26em;
  text-transform: uppercase;
  color: rgba(244, 250, 255, 0.9);
}

.empty__hint {
  font-size: 11.5px;
  font-weight: 300;
  letter-spacing: 0.03em;
  color: rgba(198, 224, 243, 0.45);
  text-align: center;
  max-width: 220px;
}
</style>
