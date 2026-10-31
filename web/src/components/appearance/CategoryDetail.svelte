<script lang="ts">
  import { Divider, Slider, SpritePicker, SwatchPicker } from '@siku/ui'
  import eyeColourSheet from '@/assets/mp-eye-colour.webp'
  import PortraitPicker from '@/components/appearance/PortraitPicker.svelte'
  import { m, tr } from '@/lib/i18n.svelte'
  import {
    controlKey,
    type AppearanceCategory,
    type AppearanceControl,
  } from '@/lib/multicharacter/appearance/catalog'
  import { store } from '@/lib/multicharacter/store.svelte'

  let {
    stepId,
    category,
    draft,
    onupdate,
  }: {
    stepId: string
    category: AppearanceCategory
    draft: Record<string, number>
    onupdate: (key: string, value: number) => void
  } = $props()

  const SPRITES = { eyeColour: eyeColourSheet }

  const keyOf = (control: AppearanceControl): string => controlKey(stepId, category.id, control.id)
  const portraits = $derived(category.controls.filter((control) => control.portrait))
  const controls = $derived(category.controls.filter((control) => !control.portrait))
  const parentsOf = (control: AppearanceControl) =>
    control.id === 'father' ? store.heritageConfig.fathers : store.heritageConfig.mothers

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
        onchange={(value) => onupdate(keyOf(control), value)}
      />
    {/if}
  {/each}

  {#if portraits.length === 0 && controls.length === 0}
    <span class="t-body-sm text-fg-tertiary">{m.appearance_nothingHere()}</span>
  {/if}
</div>
