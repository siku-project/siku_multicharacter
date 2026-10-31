<script lang="ts">
  let { tagline, size = 'md' }: { tagline: string; size?: 'md' | 'lg' } = $props()
</script>

<div class="flex items-center gap-3">
  <span class="mc-brand-bar" aria-hidden="true"></span>
  <div class="flex min-w-0 flex-col gap-1">
    <span class={size === 'lg' ? 't-title' : 't-subheading'}>SIKU</span>
    <span class="t-caption truncate uppercase tracking-wider text-fg-tertiary">{tagline}</span>
  </div>
</div>
