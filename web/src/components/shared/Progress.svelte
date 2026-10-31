<script lang="ts">
  import { Meter } from '@siku/ui'

  let { value, max, label }: { value: number; max: number; label: string } = $props()
</script>

<div class="w-[11rem] shrink-0">
  <Meter {value} {max} {label} valueLabel={`${value} / ${max}`} />
</div>
