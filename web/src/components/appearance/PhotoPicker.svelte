<script lang="ts">
  import { gridMove } from '@siku/ui'

  let {
    label,
    count,
    value,
    columns = 4,
    none,
    photo,
    onchange,
  }: {
    label: string
    count: number
    value: number
    columns?: number
    none?: string
    photo: (index: number) => string | undefined
    onchange: (index: number) => void
  } = $props()

  const KEYS = ['ArrowRight', 'ArrowLeft', 'ArrowDown', 'ArrowUp', 'Home', 'End']

  const id = `mc-photos-${Math.random().toString(36).slice(2, 8)}`
  let root = $state<HTMLDivElement | null>(null)
  let broken = $state<Record<number, boolean>>({})

  const isNone = (index: number): boolean => !!none && index === 1

  const pick = (index: number): void => {
    if (index < 1 || index > count || index === value) {
      return
    }

    onchange(index)
  }

  const focusCurrent = (): void => {
    queueMicrotask(() => root?.querySelector<HTMLElement>('[role="radio"][tabindex="0"]')?.focus())
  }

  const onkeydown = (event: KeyboardEvent): void => {
    if (!KEYS.includes(event.key)) {
      return
    }

    event.preventDefault()
    pick(gridMove(value - 1, event.key, columns, count) + 1)
    focusCurrent()
  }

  $effect(() => {
    void value
    root?.querySelector('.is-selected')?.scrollIntoView({ block: 'nearest' })
  })
</script>

<div class="sk-field" bind:this={root}>
  <span class="sk-field__label" id="{id}-l">{label}<span>{value} / {count}</span></span>
  <div
    class="mc-photos"
    role="radiogroup"
    tabindex="-1"
    aria-labelledby="{id}-l"
    style:grid-template-columns="repeat({columns}, minmax(0, 1fr))"
    {onkeydown}
  >
    {#each { length: count } as _, i (i)}
      {@const index = i + 1}
      {@const src = isNone(index) || broken[index] ? undefined : photo(index)}
      <button
        type="button"
        role="radio"
        aria-checked={index === value}
        aria-label={isNone(index) ? none : `${label} ${index}`}
        tabindex={index === value ? 0 : -1}
        class="mc-photo"
        class:is-selected={index === value}
        onclick={() => pick(index)}
      >
        {#if src}
          <img
            class="mc-photo__image"
            {src}
            alt=""
            loading="lazy"
            draggable="false"
            onerror={() => (broken[index] = true)}
          />
        {:else if isNone(index)}
          <span class="mc-photo__empty t-body-sm">{none}</span>
        {:else}
          <span class="mc-photo__empty t-subheading">{index}</span>
        {/if}
        <span class="mc-photo__index t-caption">{index}</span>
      </button>
    {/each}
  </div>
</div>
