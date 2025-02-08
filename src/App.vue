<script setup lang="ts">
import { ref, computed } from 'vue'
import SidebarPanel from '@/components/SidebarPanel.vue'
import MissyDisplay from '@/components/MissyDisplay.vue'
import CodeOutput from '@/components/CodeOutput.vue'
import { ALL_VOWS } from '@/constants/vows'
import type { LanguageVow } from '@/types/vow'

const outputContent = ref('')
const currentRotation = ref(0)
const displayMode = ref(0)
const position = ref<'left' | 'center' | 'right'>('center')

enum DisplayMode {
  THROW_IT_BACK,
  FLIP_IT,
  REVERSE_IT,
}

const displayText = computed(() => {
  switch (displayMode.value) {
    case DisplayMode.THROW_IT_BACK:
      return 'Throw it back'
    case DisplayMode.FLIP_IT:
      return 'Flip it'
    case DisplayMode.REVERSE_IT:
      return 'Reverse it'
    default:
      return 'Throw it back'
  }
})

const stateMachine = {
  [DisplayMode.THROW_IT_BACK]: {
    displayText: 'Throw it back',
    position: (currentPosition: string) =>
      currentPosition === 'center' ? 'left' : currentPosition === 'left' ? 'right' : 'left',
    rotation: 0,
  },
  [DisplayMode.FLIP_IT]: {
    displayText: 'Flip it',
    position: (currentPosition: string) => currentPosition,
    rotation: 180,
  },
  [DisplayMode.REVERSE_IT]: {
    displayText: 'Reverse it',
    position: (currentPosition: string) => currentPosition,
    rotation: 0,
  },
}

function handleMissyMoves() {
  const currentState = stateMachine[displayMode.value]

  // Update position and rotation based on current state
  position.value = currentState.position(position.value)
  currentRotation.value = currentState.rotation

  // Move to next state
  displayMode.value = (displayMode.value + 1) % 3
}

const vows = ref<LanguageVow[]>(ALL_VOWS)

function handleCreate(newVow: { text: string; language: LanguageVow['language'] }) {
  const vow: LanguageVow = {
    text: newVow.text,
    language: newVow.language,
    id: `${newVow.language}-${Math.random().toString(36).substr(2, 9)}`,
  }
  vows.value.push(vow)
  outputContent.value = `✨ Created new vow:\n${vow.text}`
}

function handleRead(vowId: string) {
  const vow = vows.value.find((v) => v.id === vowId)
  if (vow) {
    outputContent.value = `📖 Reading vow:\n${vow.text}\nLanguage: ${vow.language}`
  }
}

function handleUpdate(update: { id: string; text: string }) {
  const index = vows.value.findIndex((v) => v.id === update.id)
  if (index !== -1) {
    vows.value[index] = { ...vows.value[index], text: update.text }
    outputContent.value = `📝 Updated vow:\n${update.text}`
  }
}

function handleDelete(vowId: string) {
  const index = vows.value.findIndex((v) => v.id === vowId)
  if (index !== -1) {
    const deletedVow = vows.value[index]
    vows.value = vows.value.filter((v) => v.id !== vowId)
    outputContent.value = `🗑️ Deleted vow:\n${deletedVow.text}`
  }
}
</script>

<template>
  <div class="app-container">
    <SidebarPanel
      :display-text="displayText"
      @missy-moves="handleMissyMoves"
      @create="handleCreate"
      @read="handleRead"
      @update="handleUpdate"
      @delete="handleDelete"
    />
    <div class="right-panel">
      <MissyDisplay :rotation="currentRotation" :position="position" />
      <CodeOutput :content="outputContent" />
    </div>
  </div>
</template>

<style>
/* Global styles and CSS variables */
:root {
  --bg-color: #1a1a1a;
  --text-color: #e0e0e0;
  --button-bg: #2c2c2c;
  --button-hover: #3c3c3c;
  --border-color: #333;
  --code-bg: #2a2a2a;
  --sidebar-width: 25%;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
  --spin-direction: normal;
  --rotation: 0deg;
}

body {
  background-color: var(--bg-color);
  color: var(--text-color);
  margin: 0;
  padding: 0;
}

body * {
  box-sizing: border-box;
}

.app-container {
  display: flex;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

.left-panel {
  flex: 0 0 var(--sidebar-width);
  padding: var(--spacing-lg);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.right-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
</style>
