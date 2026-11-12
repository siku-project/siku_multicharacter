<script lang="ts">
  import { Surface, SwatchPicker } from '@siku/ui'
  import { tr } from '@/lib/i18n.svelte'
  import {
    controlKey,
    type AppearanceCategory,
    type AppearanceControl,
  } from '@/lib/multicharacter/appearance/catalog'
  import { detailControls, photosControl } from '@/lib/multicharacter/appearance/photos'
  import { store } from '@/lib/multicharacter/store.svelte'
  import { catalogPhoto } from '@/lib/multicharacter/types'

  let {
    stepId,
    category,
    draft,
    pedModel,
    inline = false,
    onupdate,
  }: {
    stepId: string
    category: AppearanceCategory
    draft: Record<string, number>
    pedModel: string
    inline?: boolean
    onupdate: (key: string, value: number) => void
  } = $props()

  let broken = $state<string | null>(null)

  const keyOf = (control: AppearanceControl): string => controlKey(stepId, category.id, control.id)
  const control = $derived(photosControl(category, store.catalog, pedModel))
  const details = $derived(detailControls(category))
  const value = $derived(control ? (draft[keyOf(control)] ?? control.min ?? 1) : 1)
  const src = $derived(
    control ? catalogPhoto(store.catalog, control.photos ?? '', pedModel, value - 1) : undefined,
  )
</script>

{#if control}
  <Surface
    elevated={!inline}
    level={inline ? 'raised' : 'base'}
    padding="md"
    class={inline ? 'mc-detail--inline' : 'mc-detail pointer-events-auto'}
  >
    <div class="flex flex-col gap-4">
      <div class="flex items-baseline justify-between gap-3">
        <span class="t-subheading">{tr(control.label)}</span>
        <span class="t-caption text-fg-tertiary">{value} / {control.max ?? 1}</span>
      </div>

      <Surface
        level="sunken"
        padding="none"
        radius="lg"
        class="mc-detail__photo flex items-center justify-center self-center overflow-hidden"
      >
        {#if src && broken !== src}
          <img
            class="h-full w-full object-contain"
            {src}
            alt=""
            draggable="false"
            onerror={() => (broken = src)}
          />
        {:else}
          <span class="t-figure-sm text-fg-disabled">{value}</span>
        {/if}
      </Surface>

      {#each details as detail (detail.id)}
        {#if detail.type === 'swatches'}
          <SwatchPicker
            size="sm"
            label={tr(detail.label)}
            colors={detail.colors ?? []}
            value={draft[keyOf(detail)] ?? 0}
            onchange={(index) => onupdate(keyOf(detail), index)}
          />
        {/if}
      {/each}
    </div>
  </Surface>
{/if}
