<script setup lang="ts">
defineProps<{
  content: string
}>()
</script>

<template>
  <div class="code-container">
    <pre class="code-output">{{ content }}</pre>
  </div>
</template>

<style scoped>
.code-container {
  width: 100%;
  height: 50%;
  padding: var(--spacing-lg);
  display: block;
}

.code-output {
  background-color: var(--code-bg);
  padding: var(--spacing-lg);
  border-radius: 4px;
  white-space: pre-wrap;
  font-family: monospace;
  width: 100%;
  height: 100%;
  overflow-y: auto;
  margin: 0;
}
</style>
