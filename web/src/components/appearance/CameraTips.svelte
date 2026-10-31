<script lang="ts">
  import { fly } from 'svelte/transition'
  import { Divider, Icon, Key, Surface } from '@siku/ui'
  import { m } from '@/lib/i18n.svelte'

  const tips = $derived([
    {
      id: 'pan',
      icon: 'mouse-left' as const,
      label: m.appearance_tipPan(),
      hint: m.appearance_tipPanHint(),
    },
    {
      id: 'zoom',
      icon: 'mouse-wheel' as const,
      label: m.appearance_tipZoom(),
      hint: m.appearance_tipZoomHint(),
    },
    {
      id: 'rotate',
      icon: 'mouse-right' as const,
      label: m.appearance_tipRotate(),
      hint: m.appearance_tipRotateHint(),
    },
  ])
</script>

<div
  class="pointer-events-none fixed left-1/2 top-8 z-overlay -translate-x-1/2"
  transition:fly={{ y: -12, duration: 320 }}
>
  <Surface elevated padding="none" radius="lg" class="flex items-center gap-5 px-5 py-3">
    {#each tips as tip, index (tip.id)}
      {#if index > 0}<div class="flex h-6"><Divider vertical /></div>{/if}
      <div class="flex items-center gap-3">
        <span class="text-fg-secondary"><Icon name={tip.icon} size="lg" /></span>
        <div class="flex flex-col">
          <span class="t-caption text-fg-primary">{tip.label}</span>
          <span class="t-caption text-fg-tertiary">{tip.hint}</span>
        </div>
      </div>
    {/each}
    <div class="flex h-6"><Divider vertical /></div>
    <div class="flex items-center gap-3">
      <Key label="X" size="lg" />
      <div class="flex flex-col">
        <span class="t-caption text-fg-primary">{m.appearance_tipHandsUp()}</span>
        <span class="t-caption text-fg-tertiary">{m.appearance_tipHandsUpHint()}</span>
      </div>
    </div>
  </Surface>
</div>
