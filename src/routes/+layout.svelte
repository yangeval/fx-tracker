<script lang="ts">
  import '../app.css';
  import { onMount } from 'svelte';
  import { fetchContracts, subscribeToContracts } from '$lib/stores/contracts';

  let { children } = $props();

  onMount(() => {
    fetchContracts();
    const unsubscribe = subscribeToContracts();
    return () => unsubscribe();
  });
</script>

<main>
  {@render children()}
</main>

<style>
  main {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }
</style>
