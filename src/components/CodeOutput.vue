<script setup lang="ts">
import { ref, watch } from 'vue'
import { Icon } from '@iconify/vue'
import type { Language } from '@/types/vow'

const props = defineProps<{
  content: string
  language?: Language
}>()

const languageIcons = {
  typescript: 'logos:typescript-icon',
  go: 'logos:go',
  python: 'logos:python',
}

interface OutputLine {
  timestamp: string
  language: Language
  content: string
}

const outputLines = ref<OutputLine[]>([])

watch(
  () => props.content,
  (newContent) => {
    if (newContent) {
      outputLines.value.push({
        timestamp: new Date().toLocaleTimeString(),
        language: props.language || 'typescript',
        content: newContent,
      })
    }
  },
)

const clearOutput = () => {
  outputLines.value = []
}
</script>

<template>
  <div class="code-container">
    <div class="code-header">
      <span class="output-length">{{ outputLines.length }} lines</span>
      <button class="clear-button" @click="clearOutput">Clear</button>
    </div>
    <div class="code-output" :class="{ empty: !outputLines.length }" data-test="code-output">
      <template v-if="outputLines.length">
        <div
          v-for="(line, index) in outputLines"
          :key="index"
          class="output-line"
          :data-test="`output-line-${line.language}`"
        >
          <span class="timestamp">[{{ line.timestamp }}]</span>
          <Icon :icon="languageIcons[line.language]" class="output-icon" />
          <span class="content">{{ line.content }}</span>
        </div>
      </template>
      <template v-else> No output yet... </template>
    </div>
  </div>
</template>

<style scoped>
.code-container {
  width: 100%;
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
  font-family: monospace;
  width: 100%;
  max-height: 300px;
  overflow-y: auto;
  overflow-x: hidden;
  margin: 0;
  border: 1px solid var(--border-color);
  box-sizing: border-box;
}

.output-line {
  white-space: pre-wrap;
  margin-bottom: 0.25rem;
  display: flex;
  align-items: flex-start;
}

.timestamp {
  margin-right: 0.5rem;
  white-space: nowrap;
}

.content {
  flex: 1;
}

.output-icon {
  vertical-align: middle;
  margin: 0 0.5rem;
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.code-output.empty {
  opacity: 0.7;
  font-style: italic;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
