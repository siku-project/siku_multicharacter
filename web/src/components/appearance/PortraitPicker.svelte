<script lang="ts">
  import { Icon, Select, Surface } from '@siku/ui'
  import { m } from '@/lib/i18n.svelte'
  import { parentPortrait } from '@/lib/multicharacter/appearance/payload'
  import type { HeritageParent } from '@/lib/multicharacter/types'

  let {
    label,
    parents,
    value,
    onchange,
  }: {
    label: string
    parents: HeritageParent[]
    value: number
    onchange: (index: number) => void
  } = $props()

  const parent = $derived(parents[value])
  const options = $derived(
    parents.map((entry, index) => ({
      value: String(index),
      label: entry.name,
      meta: String(entry.id),
    })),
  )
</script>

<div class="flex flex-col items-center gap-3">
  <Surface
    level="sunken"
    padding="none"
    radius="lg"
    class="mc-portrait flex items-center justify-center overflow-hidden"
  >
    {#if parent}
      <img class="h-full w-full object-cover" src={parentPortrait(parent.id)} alt="" />
    {:else}
      <span class="text-fg-disabled"><Icon name="user" size="lg" /></span>
    {/if}
  </Surface>
  <span class="t-caption uppercase tracking-wider text-fg-tertiary">{label}</span>
  <div class="w-full">
    <Select
      value={String(value)}
      {options}
      placeholder={m.appearance_photo()}
      onchange={(next) => onchange(Number(next))}
    />
  </div>
</div>
