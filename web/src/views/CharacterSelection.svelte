<script lang="ts">
  import { Button, Hint, Veil } from '@siku/ui'
  import Brand from '@/components/shared/Brand.svelte'
  import CharacterHero from '@/components/selection/CharacterHero.svelte'
  import DeleteCharacterDialog from '@/components/selection/DeleteCharacterDialog.svelte'
  import SlotList from '@/components/selection/SlotList.svelte'
  import { m } from '@/lib/i18n.svelte'
  import { game } from '@/lib/multicharacter/bridge'
  import { characterInSlot, fullName } from '@/lib/multicharacter/format'
  import { store } from '@/lib/multicharacter/store.svelte'

  let selectedSlot = $state(store.characters[0]?.slot ?? 1)
  let confirmDelete = $state(false)

  const slots = $derived(
    Array.from({ length: store.selectionConfig.slots }, (_, index) => ({
      slot: index + 1,
      character: characterInSlot(store.characters, index + 1),
    })),
  )

  const selected = $derived(characterInSlot(store.characters, selectedSlot))

  $effect(() => {
    if (!slots.some((entry) => entry.slot === selectedSlot)) {
      selectedSlot = store.characters[0]?.slot ?? 1
    }
  })

  const select = (slot: number): void => {
    if (slot === selectedSlot) {
      return
    }

    selectedSlot = slot
    void game.slotChanged(slot)
  }

  const proceed = (): void => {
    if (selected) {
      void game.playCharacter(selected.id)
    } else {
      void game.startCreation(selectedSlot)
    }
  }

  const remove = (): void => {
    if (!selected) {
      return
    }

    confirmDelete = false
    void game.deleteCharacter(selected.id)
  }

  const canDelete = $derived(!!selected && store.selectionConfig.allowCharacterDeletion)

  const onkeydown = (event: KeyboardEvent): void => {
    if (confirmDelete || event.defaultPrevented) {
      return
    }

    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      const index = slots.findIndex((entry) => entry.slot === selectedSlot)
      const next =
        slots[(index + (event.key === 'ArrowDown' ? 1 : -1) + slots.length) % slots.length]
      select(next.slot)
    } else if (event.key === 'Enter') {
      proceed()
    } else if (event.key === 'Delete' && canDelete) {
      confirmDelete = true
    } else {
      return
    }

    event.preventDefault()
  }
</script>

<svelte:window {onkeydown} />

<div class="pointer-events-none fixed inset-0 z-panel">
  <Veil side="left" size="58%" hold="38%" strength="heavy" />
  <Veil side="bottom" size="44%" hold="12%" strength="heavy" />

  <div
    class="pointer-events-auto absolute inset-y-0 left-0 flex w-[32rem] flex-col gap-10 px-16 py-12"
  >
    <header class="shrink-0">
      <Brand tagline={m.selection_tagline()} size="lg" />
    </header>

    <div class="min-h-0 flex-1 overflow-y-auto">
      <SlotList {slots} selected={selectedSlot} onselect={select} onactivate={proceed} />
    </div>

    <footer class="flex shrink-0 flex-col gap-6">
      <CharacterHero character={selected} slot={selectedSlot} />

      <div class="flex flex-col gap-3">
        <div class="flex items-stretch gap-2">
          {#if canDelete}
            <Button
              variant="danger"
              size="lg"
              icon="trash"
              key="Suppr"
              onclick={() => (confirmDelete = true)}>{m.selection_delete()}</Button
            >
          {/if}
          <div class="min-w-0 flex-1">
            <Button variant="primary" size="lg" block key="Entrée" onclick={proceed}>
              {selected ? m.selection_play() : m.selection_create()}
            </Button>
          </div>
        </div>

        <div class="flex items-center gap-5">
          <Hint keys={['↑', '↓']} gamepad={['D-pad']} label={m.selection_hintNavigate()} />
          <Hint keys={['Entrée']} gamepad={['A']} label={m.selection_hintConfirm()} />
        </div>
      </div>
    </footer>
  </div>

  <div class="pointer-events-auto">
    <DeleteCharacterDialog
      bind:open={confirmDelete}
      name={selected ? fullName(selected) : ''}
      onconfirm={remove}
    />
  </div>
</div>
