<script lang="ts">
  import { onMount } from 'svelte'
  import { fade } from 'svelte/transition'
  import { Button, Chip, Divider, Select, Steps, Surface, type StepItem } from '@siku/ui'
  import CameraTips from '@/components/appearance/CameraTips.svelte'
  import CategoryDetail from '@/components/appearance/CategoryDetail.svelte'
  import SummaryStep from '@/components/appearance/SummaryStep.svelte'
  import Brand from '@/components/shared/Brand.svelte'
  import Progress from '@/components/shared/Progress.svelte'
  import { m, tr } from '@/lib/i18n.svelte'
  import {
    APPEARANCE_STEPS,
    BASIC_PED_LABELS,
    createAppearanceDraft,
    limitKeyFor,
    type AppearanceCategory,
    type AppearanceStep,
  } from '@/lib/multicharacter/appearance/catalog'
  import {
    buildAccessoryPayload,
    buildClothingPayload,
    buildHeritagePayload,
    buildPhysicalPayload,
    buildTattooPayload,
  } from '@/lib/multicharacter/appearance/payload'
  import { game } from '@/lib/multicharacter/bridge'
  import { attachCameraControls } from '@/lib/multicharacter/camera'
  import { store } from '@/lib/multicharacter/store.svelte'

  const draft = $state(createAppearanceDraft())
  let currentIndex = $state(0)
  let furthestIndex = $state(0)
  let pedModel = $state('')
  let activeCategoryId = $state('')

  const total = APPEARANCE_STEPS.length
  const step = $derived(APPEARANCE_STEPS[currentIndex] as AppearanceStep)
  const isLast = $derived(currentIndex === total - 1)
  const categories = $derived(step.categories ?? [])
  const steps = $derived<StepItem[]>(
    APPEARANCE_STEPS.map((entry) => ({ id: entry.id, label: tr(entry.label), icon: entry.icon })),
  )

  const groups = $derived.by(() => {
    const list: { key: string; label: string; items: AppearanceCategory[] }[] = []

    for (const category of categories) {
      const key = category.group ?? ''
      const last = list[list.length - 1]

      if (last && last.key === key) {
        last.items.push(category)
      } else {
        list.push({ key, label: category.group ? tr(category.group) : '', items: [category] })
      }
    }

    return list
  })

  const category = $derived(categories.find((entry) => entry.id === activeCategoryId))

  const limited = $derived.by((): AppearanceCategory | undefined => {
    if (!category) {
      return undefined
    }

    return {
      ...category,
      controls: category.controls.map((control) => {
        const key = limitKeyFor(step.id, category.id, control.id)
        const limit = key ? store.appearanceLimits[key] : undefined

        return limit && limit > 0 ? { ...control, max: limit, unit: `/ ${limit}` } : control
      }),
    }
  })

  $effect(() => {
    activeCategoryId = categories[0]?.id ?? ''
  })

  const peds = $derived.by(() => {
    const models = store.pedsConfig.basics.map((id) => ({
      value: id,
      label: BASIC_PED_LABELS[id] ? tr(BASIC_PED_LABELS[id]) : id,
      meta: id,
    }))

    if (store.pedsConfig.authorizeAll) {
      models.push(...store.pedsConfig.peds.map((id) => ({ value: id, label: id, meta: id })))
    }

    return models
  })

  const heritage = $derived(buildHeritagePayload(draft, store.heritageConfig))
  const physical = $derived(buildPhysicalPayload(draft))
  const clothing = $derived(buildClothingPayload(draft))
  const accessories = $derived(buildAccessoryPayload(draft))
  const tattoos = $derived(buildTattooPayload(draft))

  $effect(() => void game.heritageChanged(heritage))
  $effect(() => void game.physicalChanged(physical))
  $effect(() => void game.clothingChanged(clothing))
  $effect(() => void game.accessoriesChanged(accessories))
  $effect(() => void game.tattoosChanged(tattoos))

  const cameraActive = $derived(step.id !== 'ped')

  onMount(() => attachCameraControls(() => cameraActive))

  const selectStep = (id: string): void => {
    const index = APPEARANCE_STEPS.findIndex((entry) => entry.id === id)

    if (index >= 0 && index <= furthestIndex) {
      currentIndex = index
    }
  }

  const selectPed = (model: string): void => {
    pedModel = model
    void game.pedSelected(model)
  }

  const update = (key: string, value: number): void => {
    draft[key] = value
  }

  const back = (): void => {
    currentIndex = Math.max(0, currentIndex - 1)
  }

  const next = (): void => {
    if (isLast) {
      void game.appearanceValidated({
        pedModel,
        appearance: { heritage, physical, clothing, accessories, tattoos },
      })
      return
    }

    currentIndex += 1
    furthestIndex = Math.max(furthestIndex, currentIndex)
  }

  const blocked = $derived(step.id === 'ped' && !pedModel)
</script>

<div class="pointer-events-none fixed inset-0 z-panel">
  {#if cameraActive}
    <CameraTips />
  {/if}

  <Surface
    elevated
    padding="none"
    class="mc-shell pointer-events-auto absolute left-12 top-1/2 flex w-[36rem] -translate-y-1/2 flex-col overflow-hidden"
  >
    <header class="flex items-center gap-8 px-6 py-5">
      <div class="min-w-0 flex-1">
        <Brand tagline={m.appearance_subtitle()} />
      </div>
      <Progress value={currentIndex + 1} max={total} label={m.appearance_steps()} />
    </header>

    <Divider />

    <div class="flex min-h-0 flex-1">
      <nav class="flex shrink-0 flex-col items-center px-3 py-4" aria-label={m.appearance_steps()}>
        <Steps
          compact
          {steps}
          current={step.id}
          reached={APPEARANCE_STEPS[furthestIndex]?.id}
          label={m.appearance_steps()}
          onselect={selectStep}
        />
      </nav>

      <Divider vertical />

      <section class="flex min-h-0 min-w-0 flex-1 flex-col">
        <div class="flex flex-col gap-0.5 px-6 pb-4 pt-5">
          <h1 class="t-heading">{tr(step.label)}</h1>
          <p class="t-body-sm text-fg-tertiary">{tr(step.subtitle)}</p>
        </div>

        {#if groups.length > 0}
          <div class="flex flex-col gap-3 px-6 pb-4">
            {#each groups as group (group.key || 'root')}
              <div class="flex flex-col gap-2">
                {#if group.label}
                  <span class="t-caption uppercase tracking-wider text-fg-tertiary"
                    >{group.label}</span
                  >
                {/if}
                <div class="flex flex-wrap gap-2">
                  {#each group.items as item (item.id)}
                    <Chip
                      size="sm"
                      icon={item.icon}
                      label={tr(item.label)}
                      selected={item.id === activeCategoryId}
                      onclick={() => (activeCategoryId = item.id)}
                    />
                  {/each}
                </div>
              </div>
            {/each}
          </div>

          <Divider />
        {/if}

        <div class="min-h-0 flex-1 overflow-y-auto px-6 py-5">
          {#key `${step.id}-${activeCategoryId}`}
            <div in:fade={{ duration: 160 }}>
              {#if step.id === 'ped'}
                <div class="flex flex-col gap-2">
                  <Select
                    label={m.appearance_stepPed()}
                    placeholder={m.appearance_pedPlaceholder()}
                    value={pedModel}
                    options={peds}
                    onchange={selectPed}
                  />
                  <span class="t-caption text-fg-tertiary">{m.appearance_pedHelp()}</span>
                </div>
              {:else if step.id === 'summary'}
                <SummaryStep {draft} {pedModel} />
              {:else if limited}
                <CategoryDetail stepId={step.id} category={limited} {draft} onupdate={update} />
              {/if}
            </div>
          {/key}
        </div>

        <Divider />

        <footer class="flex items-center gap-3 px-6 py-4">
          {#if currentIndex > 0}
            <Button variant="ghost" icon="chevl" onclick={back}>{m.appearance_back()}</Button>
          {/if}
          <span class="t-caption ml-auto text-fg-tertiary"
            >{m.appearance_stepOf({ current: currentIndex + 1, total })}</span
          >
          <Button variant="primary" key="Entrée" disabled={blocked} onclick={next}>
            {isLast ? m.appearance_validate() : m.appearance_continue()}
          </Button>
        </footer>
      </section>
    </div>
  </Surface>
</div>
