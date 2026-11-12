<script lang="ts">
  import { Divider, Slider, SpritePicker, SwatchPicker, scaleState } from '@siku/ui'
  import eyeColourSheet from '@/assets/mp-eye-colour.webp'
  import PhotoDetail from '@/components/appearance/PhotoDetail.svelte'
  import PhotoPicker from '@/components/appearance/PhotoPicker.svelte'
  import PortraitPicker from '@/components/appearance/PortraitPicker.svelte'
  import { m, tr } from '@/lib/i18n.svelte'
  import {
    controlKey,
    type AppearanceCategory,
    type AppearanceControl,
  } from '@/lib/multicharacter/appearance/catalog'
  import {
    photoAt,
    photosControl,
    startsWithNone,
    variantControls,
  } from '@/lib/multicharacter/appearance/photos'
  import { store } from '@/lib/multicharacter/store.svelte'
  import { catalogShows } from '@/lib/multicharacter/types'

  let {
    stepId,
    category,
    draft,
    pedModel,
    onupdate,
  }: {
    stepId: string
    category: AppearanceCategory
    draft: Record<string, number>
    pedModel: string
    onupdate: (key: string, value: number) => void
  } = $props()

  const SPRITES = { eyeColour: eyeColourSheet }

  const keyOf = (control: AppearanceControl): string => controlKey(stepId, category.id, control.id)
  const portraits = $derived(category.controls.filter((control) => control.portrait))
  const shown = $derived(photosControl(category, store.catalog, pedModel))
  const controls = $derived(
    category.controls.filter((control) => !control.portrait && !(shown && control.detail)),
  )
  const parentsOf = (control: AppearanceControl) =>
    control.id === 'father' ? store.heritageConfig.fathers : store.heritageConfig.mothers

  const showsPhotos = (control: AppearanceControl): boolean =>
    control.type === 'photos' &&
    !!control.photos &&
    catalogShows(store.catalog, control.photos, pedModel)

  const photoOf = (control: AppearanceControl, index: number): string | undefined =>
    photoAt(store.catalog, control, pedModel, index)

  const change = (control: AppearanceControl, value: number): void => {
    onupdate(keyOf(control), value)

    if (control.type === 'photos') {
      for (const variants of variantControls(category)) {
        onupdate(keyOf(variants), variants.min ?? 1)
      }
    }
  }

  const format = (control: AppearanceControl, value: number): string => {
    if (control.type === 'blend') {
      const right = Math.round(value)
      return `${100 - right} % · ${right} %`
    }

    const text = (control.step ?? 1) < 1 ? value.toFixed(2) : String(value)

    return control.unit ? `${text} ${control.unit}` : text
  }
</script>

<div class="flex flex-col gap-6">
  {#if portraits.length > 0}
    <div class="grid grid-cols-2 gap-5">
      {#each portraits as control (control.id)}
        <PortraitPicker
          label={tr(control.label)}
          parents={parentsOf(control)}
          value={draft[keyOf(control)] ?? 0}
          onchange={(index) => onupdate(keyOf(control), index)}
        />
      {/each}
    </div>
  {/if}

  {#each controls as control (control.id)}
    {#if control.section}
      <Divider label={tr(control.section)} />
    {/if}

    {#if control.type === 'swatches'}
      <SwatchPicker
        label={tr(control.label)}
        colors={control.colors ?? []}
        value={draft[keyOf(control)] ?? 0}
        onchange={(index) => onupdate(keyOf(control), index)}
      />
    {:else if control.type === 'sprite'}
      <SpritePicker
        label={tr(control.label)}
        image={SPRITES[control.sprite ?? 'eyeColour']}
        count={control.max ?? 1}
        columns={control.spriteColumns ?? 8}
        value={draft[keyOf(control)] ?? 0}
        onchange={(index) => onupdate(keyOf(control), index)}
      />
    {:else if showsPhotos(control)}
      <PhotoPicker
        label={tr(control.label)}
        count={control.max ?? 1}
        value={draft[keyOf(control)] ?? control.min ?? 1}
        none={startsWithNone(store.catalog, control) ? m.appearance_none() : undefined}
        photo={(index) => photoOf(control, index)}
        onchange={(index) => change(control, index)}
      />
    {:else}
      <Slider
        label={tr(control.label)}
        value={draft[keyOf(control)] ?? 0}
        min={control.min ?? 0}
        max={control.max ?? 100}
        step={control.step ?? 1}
        centered={control.type === 'blend' || (control.min ?? 0) < 0}
        minLabel={control.minLabel ? tr(control.minLabel) : undefined}
        maxLabel={control.maxLabel ? tr(control.maxLabel) : undefined}
        format={(value) => format(control, value)}
        onchange={(value) => change(control, value)}
      />
    {/if}
  {/each}

  {#if shown && $scaleState.density === 'compact'}
    <PhotoDetail inline {stepId} {category} {draft} {pedModel} {onupdate} />
  {/if}

  {#if portraits.length === 0 && controls.length === 0}
    <span class="t-body-sm text-fg-tertiary">{m.appearance_nothingHere()}</span>
  {/if}
</div>
