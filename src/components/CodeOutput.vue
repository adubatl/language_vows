<script setup lang="ts">
import { ref, watch } from 'vue'

const props = defineProps<{
  content: string
}>()

const outputContent = ref('')

// Watch for new content and append it with timestamp
watch(
  () => props.content,
  (newContent) => {
    if (newContent) {
      const timestamp = new Date().toLocaleTimeString()
      outputContent.value += `[${timestamp}] ${newContent}\n`
    }
  },
)

const clearOutput = () => {
  outputContent.value = ''
}
</script>

<template>
  <div class="code-container">
    <div class="code-header">
      <span class="output-length">{{ outputContent.split('\n').length - 1 }} lines</span>
      <button class="clear-button" @click="clearOutput">Clear</button>
    </div>
    <pre class="code-output" :class="{ empty: !outputContent }">{{
      outputContent || 'No output yet...'
    }}</pre>
  </div>
</template>

<style scoped>
.code-container {
  width: 100%;
  height: 75%;
  padding: var(--spacing-lg);
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  max-width: calc(100vw - var(--sidebar-width));
}

.code-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-sm);
}

.output-length {
  color: var(--text-color);
  opacity: 0.7;
  font-size: 0.9rem;
}

.clear-button {
  background-color: var(--button-bg);
  color: var(--text-color);
  border: 2px solid var(--border-color);
  border-radius: 4px;
  padding: var(--spacing-sm) var(--spacing-md);
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s ease;
}

.clear-button:hover {
  background-color: var(--button-hover);
  transform: translateY(-1px);
}

.clear-button:active {
  transform: translateY(0);
}

.code-output {
  background-color: var(--code-bg);
  color: var(--text-color);
  padding: var(--spacing-lg);
  border-radius: 4px;
  white-space: pre-wrap;
  font-family: monospace;
  width: 100%;
  flex-grow: 1;
  overflow-y: auto;
  overflow-x: hidden;
  margin: 0;
  border: 1px solid var(--border-color);
  box-sizing: border-box;
}

.code-output.empty {
  opacity: 0.7;
  font-style: italic;
}
</style>
