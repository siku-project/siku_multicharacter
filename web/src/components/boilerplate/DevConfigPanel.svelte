<script lang="ts">
  import { Button, Modal, Segmented, TextField, Tooltip } from '@siku/ui'
  import { locale } from '@/lib/locale.svelte'
  import {
    MOCK_CHARACTERS,
    MOCK_SELECTION_CONFIG,
    applyDevPhotos,
    devCdnKey,
    devPhotos,
    type DevPhotos,
  } from '@/lib/multicharacter/mock'
  import { store } from '@/lib/multicharacter/store.svelte'

  let open = $state(false)
  let roster = $state('three')
  let photos = $state<DevPhotos>(devPhotos())
  let cdnKey = $state(devCdnKey())
  let listing = $state(false)
  let status = $state('')

  const languages = $derived(
    locale.all.map((language) => ({ value: language, label: language.toUpperCase() })),
  )

  const setRoster = (value: string): void => {
    roster = value
    store.setCharacters(value === 'none' ? [] : MOCK_CHARACTERS, MOCK_SELECTION_CONFIG)
  }

  const applyPhotos = async (): Promise<void> => {
    listing = true
    status = ''

    try {
      const count = await applyDevPhotos(photos, cdnKey)

      status = photos === 'cdn' ? `${count} photos listed from the CDN` : ''
    } catch (error) {
      status = (error as Error).message
    } finally {
      listing = false
    }
  }

  const setPhotos = (value: string): void => {
    photos = value as DevPhotos

    if (photos !== 'cdn' || cdnKey) {
      void applyPhotos()
    }
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

    <div class="sk-field">
      <span class="sk-field__label">Catalogue photos</span>
      <Segmented
        label="Catalogue photos"
        block
        value={photos}
        options={[
          { value: 'none', label: 'Sliders' },
          { value: 'files', label: 'Local files' },
          { value: 'cdn', label: 'Siku CDN' },
        ]}
        onchange={setPhotos}
      />
      {#if photos === 'files'}
        <span class="sk-field__help">Reads public/images/catalog, the layout of the CDN.</span>
      {/if}
    </div>

    {#if photos === 'cdn'}
      <TextField
        label="CDN API key"
        placeholder="cdn_…"
        help="A key with the read permission, kept in this browser only."
        bind:value={cdnKey}
      />
      <div class="flex items-center gap-3">
        <Button variant="secondary" loading={listing} disabled={!cdnKey} onclick={applyPhotos}>
          List the photos
        </Button>
        {#if status}
          <span class="t-caption text-fg-tertiary">{status}</span>
        {/if}
      </div>
    {/if}
  </div>

  {#snippet actions()}
    <Button variant="primary" data-autofocus onclick={() => (open = false)}>Done</Button>
  {/snippet}
</Modal>
