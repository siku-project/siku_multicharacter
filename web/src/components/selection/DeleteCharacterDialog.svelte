<script lang="ts">
  import { Button, Modal } from '@siku/ui'
  import { m } from '@/lib/i18n.svelte'

  let {
    open = $bindable(false),
    name,
    onconfirm,
  }: { open?: boolean; name: string; onconfirm: () => void } = $props()
</script>

<Modal bind:open title={m.selection_deleteTitle()}>
  {m.selection_deleteWarning({ name })}

  {#snippet actions()}
    <Button variant="quiet" data-autofocus onclick={() => (open = false)}
      >{m.selection_cancel()}</Button
    >
    <Button variant="danger" icon="trash" onclick={onconfirm}>{m.selection_deleteConfirm()}</Button>
  {/snippet}
</Modal>
