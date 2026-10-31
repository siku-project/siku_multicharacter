<script lang="ts">
  import { Button, Modal, Segmented, Tooltip } from '@siku/ui'
  import { locale } from '@/lib/locale.svelte'
  import { MOCK_CHARACTERS, MOCK_SELECTION_CONFIG } from '@/lib/multicharacter/mock'
  import { store } from '@/lib/multicharacter/store.svelte'

  let open = $state(false)
  let roster = $state('three')

  const languages = $derived(
    locale.all.map((language) => ({ value: language, label: language.toUpperCase() })),
  )

  const setRoster = (value: string): void => {
    roster = value
    store.setCharacters(value === 'none' ? [] : MOCK_CHARACTERS, MOCK_SELECTION_CONFIG)
  }
</script>

<Tooltip text="Simulation">
  <Button
    variant="secondary"
    iconOnly
    icon="settings"
    label="Simulation"
    class="rounded-full"
    onclick={() => (open = true)}
  />
</Tooltip>

<Modal bind:open title="Simulation">
  <div class="flex flex-col gap-5">
    <p class="t-body-sm text-fg-tertiary">
      What the server would send. Nothing here reaches the game.
    </p>

    <div class="sk-field">
      <span class="sk-field__label">Characters</span>
      <Segmented
        label="Characters"
        block
        value={roster}
        options={[
          { value: 'three', label: 'Three characters' },
          { value: 'none', label: 'No character' },
        ]}
        onchange={setRoster}
      />
    </div>

    <div class="sk-field">
      <span class="sk-field__label">Language</span>
      <Segmented
        label="Language"
        block
        value={locale.current}
        options={languages}
        onchange={(value) => locale.set(value)}
      />
    </div>
  </div>

  {#snippet actions()}
    <Button variant="primary" data-autofocus onclick={() => (open = false)}>Done</Button>
  {/snippet}
</Modal>
