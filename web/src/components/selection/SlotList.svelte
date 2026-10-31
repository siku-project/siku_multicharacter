<script lang="ts">
  import { PickList, type PickItem } from '@siku/ui'
  import { m } from '@/lib/i18n.svelte'
  import { fullName } from '@/lib/multicharacter/format'
  import type { CharacterSummary } from '@/lib/multicharacter/types'

  interface SlotEntry {
    slot: number
    character?: CharacterSummary
  }

  let {
    slots,
    selected,
    onselect,
    onactivate,
  }: {
    slots: SlotEntry[]
    selected: number
    onselect: (slot: number) => void
    onactivate: () => void
  } = $props()

  const items = $derived<PickItem[]>(
    slots.map((entry) => ({
      value: String(entry.slot),
      label: entry.character ? fullName(entry.character) : m.selection_emptySlot(),
      detail: entry.character
        ? (entry.character.occupation?.name ?? m.selection_unemployed())
        : m.selection_create(),
      icon: entry.character ? 'user' : 'plus',
      meta: String(entry.slot).padStart(2, '0'),
      empty: !entry.character,
    })),
  )
</script>

<nav class="flex flex-col gap-3" aria-label={m.selection_characters()}>
  <div class="flex items-baseline justify-between px-1">
    <span class="t-caption uppercase tracking-wider text-fg-tertiary"
      >{m.selection_characters()}</span
    >
    <span class="t-caption text-fg-tertiary"
      >{m.selection_slotsUsed({
        used: slots.filter((entry) => entry.character).length,
        total: slots.length,
      })}</span
    >
  </div>

  <PickList
    {items}
    value={String(selected)}
    label={m.selection_characters()}
    onchange={(value) => onselect(Number(value))}
    {onactivate}
  />
</nav>
