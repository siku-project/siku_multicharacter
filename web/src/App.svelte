<script lang="ts">
  import { onMount } from 'svelte'
  import type { Component } from 'svelte'
  import { fade } from 'svelte/transition'
  import { Toaster } from '@siku/ui'
  import { applyTranslations } from '@/lib/i18n.svelte'
  import { locale } from '@/lib/locale.svelte'
  import { game } from '@/lib/multicharacter/bridge'
  import { store } from '@/lib/multicharacter/store.svelte'
  import type { Screen } from '@/lib/multicharacter/types'
  import { RESOURCE } from '@/lib/nui'
  import AppearanceEditor from '@/views/AppearanceEditor.svelte'
  import CharacterSelection from '@/views/CharacterSelection.svelte'
  import IdentityCreation from '@/views/IdentityCreation.svelte'

  interface LocalePayload {
    language?: string
    translations?: { web?: Record<string, string> }
  }

  interface ReadyResponse {
    locale?: LocalePayload
  }

  interface NuiMessage {
    action?: string
    locale?: LocalePayload
  }

  const SCREEN_VIEWS: Partial<Record<Screen, Component>> = {
    selection: CharacterSelection,
    creation: IdentityCreation,
    appearance: AppearanceEditor,
  }

  let Shell = $state<Component | null>(null)

  const Active = $derived(SCREEN_VIEWS[store.screen] ?? null)

  const applyLocale = (payload?: LocalePayload): void => {
    if (!payload?.language) {
      return
    }

    const web = payload.translations?.web

    if (web && typeof web === 'object') {
      applyTranslations(payload.language, web)
    } else {
      locale.set(payload.language)
    }
  }

  const handleMessage = (event: MessageEvent<NuiMessage>): void => {
    const data = event.data

    if (data?.action === `${RESOURCE}:nui:setLocale`) {
      applyLocale(data.locale)
      return
    }

    store.applyMessage(data)
  }

  onMount(() => {
    window.addEventListener('message', handleMessage)

    void (game.ready() as Promise<ReadyResponse | null>).then((answer) => {
      if (answer) {
        applyLocale(answer.locale)
      }
    })

    if (import.meta.env.DEV) {
      void Promise.all([
        import('@/lib/multicharacter/mock'),
        import('@/views/BoilerplateView.svelte'),
      ]).then(([mock, module]) => {
        mock.loadMocks()
        Shell = module.default
      })
    }

    return () => window.removeEventListener('message', handleMessage)
  })
</script>

{#key locale.current}
  {#if Shell}
    <Shell />
  {:else if Active}
    {#key store.screen}
      <div in:fade={{ duration: 200 }} out:fade={{ duration: 120 }}>
        <Active />
      </div>
    {/key}
  {/if}
{/key}

<Toaster />
