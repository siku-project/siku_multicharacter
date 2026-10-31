<script lang="ts">
  import { Badge, Divider } from '@siku/ui'
  import { m } from '@/lib/i18n.svelte'
  import { daysSince, formatPlaytime, fullName } from '@/lib/multicharacter/format'
  import { ageAt, parseIsoDate } from '@/lib/multicharacter/identity'
  import type { CharacterSummary } from '@/lib/multicharacter/types'

  let { character, slot }: { character: CharacterSummary | undefined; slot: number } = $props()

  const lastSeen = $derived.by(() => {
    if (!character?.lastPlayed) {
      return null
    }

    const days = daysSince(character.lastPlayed)

    return days === 0
      ? m.selection_today()
      : days === 1
        ? m.selection_yesterday()
        : m.selection_daysAgo({ days })
  })

  const facts = $derived.by(() => {
    if (!character) {
      return []
    }

    const items: { key: string; label: string }[] = []
    const birth = character.identity.birthDate ? parseIsoDate(character.identity.birthDate) : null

    if (birth) {
      items.push({ key: 'age', label: m.selection_age({ age: ageAt(birth) }) })
    }

    if (character.identity.height) {
      items.push({ key: 'height', label: `${character.identity.height} cm` })
    }

    items.push({ key: 'playtime', label: formatPlaytime(character.playtime) })

    return items
  })
</script>

<div class="flex min-w-0 flex-col gap-3">
  <div class="flex items-center gap-3">
    <span class="t-code text-fg-tertiary">{String(slot).padStart(2, '0')}</span>
    <Divider vertical />
    <span class="t-caption uppercase tracking-wider text-fg-tertiary">
      {#if character && lastSeen}
        {m.selection_lastPlayed()} · {lastSeen}
      {:else if character}
        {m.selection_lastPlayed()}
      {:else}
        {m.selection_emptySlot()}
      {/if}
    </span>
  </div>

  <h1 class="t-title-lg truncate" class:text-fg-tertiary={!character}>
    {character ? fullName(character) : m.selection_emptySlot()}
  </h1>

  {#if character}
    <div class="flex flex-wrap items-center gap-2">
      <Badge tone="live" label={character.occupation?.name ?? m.selection_unemployed()} />
      {#each facts as fact (fact.key)}
        <Badge tone="neutral" label={fact.label} />
      {/each}
    </div>
  {:else}
    <p class="t-body text-fg-secondary">{m.selection_emptyHint()}</p>
  {/if}
</div>
