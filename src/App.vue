<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import SidebarPanel from '@/components/SidebarPanel.vue'
import MissyDisplay from '@/components/MissyDisplay.vue'
import CodeOutput from '@/components/CodeOutput.vue'
import { DisplayMode, Position } from '@/constants/missy'
import type { LanguageVow } from '@/types/vow'

const outputContent = ref('')
const currentRotation = ref(0)
const displayMode = ref(0)
const position = ref(Position.CENTER)

/**
 * State machine so Missy can show off her moves
 * the display text is also the state name for ease of use
 * @type {Record<number, { displayText: string, position: (currentPosition: string) => Position, rotation: number }>}
 */
const stateMachine: Record<
  number,
  {
    displayText: string
    position: (currentPosition: Position) => Position
    rotation: number
  }
> = {
  [DisplayMode.THROW_IT_BACK]: {
    displayText: 'Throw it back',
    position: (currentPosition: Position) =>
      currentPosition === Position.CENTER
        ? Position.LEFT
        : currentPosition === Position.LEFT
          ? Position.RIGHT
          : Position.LEFT,
    rotation: 0,
  },
  [DisplayMode.FLIP_IT]: {
    displayText: 'Flip it',
    position: (currentPosition: Position) => currentPosition,
    rotation: 180,
  },
  [DisplayMode.REVERSE_IT]: {
    displayText: 'Reverse it',
    position: (currentPosition: Position) => currentPosition,
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

const vows = ref<LanguageVow[]>([])
const API_BASE_URL = 'http://localhost:8080/api'

async function fetchVows() {
  try {
    console.log('Fetching vows...')
    const response = await fetch(`${API_BASE_URL}/vows`)
    if (!response.ok) throw new Error('Failed to fetch vows')
    console.log('Response:', response)
    const data = await response.json()
    console.log('Fetched vows:', data)
    vows.value = data
  } catch (error) {
    console.error('Error fetching vows:', error)
    outputContent.value = '❌ Failed to fetch vows from server'
  }
}

async function handleCreate(newVow: { text: string; language: LanguageVow['language'] }) {
  const vow: LanguageVow = {
    text: newVow.text,
    language: newVow.language,
    id: `${newVow.language}-${Math.random().toString(36).substr(2, 9)}`,
  }

  try {
    console.log('Creating vow:', vow)
    const response = await fetch(`${API_BASE_URL}/vows`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(vow),
    })

    if (!response.ok) throw new Error('Failed to create vow')

    // Refresh the vows list
    await fetchVows()
    outputContent.value = `✨ Created new vow:\n${vow.text}`
  } catch (error) {
    console.error('Error creating vow:', error)
    outputContent.value = '❌ Failed to create vow'
  }
}

async function handleRead(vowId: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/vows/${vowId}`)
    if (!response.ok) throw new Error('Failed to fetch vow')

    const vow = await response.json()
    outputContent.value = `📖 Reading vow:\n${vow.text}\nLanguage: ${vow.language}`
  } catch (error) {
    console.error('Error reading vow:', error)
    outputContent.value = '❌ Failed to read vow'
  }
}

async function handleUpdate(update: { id: string; text: string }) {
  try {
    const response = await fetch(`${API_BASE_URL}/vows/${update.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text: update.text }),
    })

    if (!response.ok) throw new Error('Failed to update vow')

    // Refresh the vows list
    await fetchVows()
    outputContent.value = `📝 Updated vow:\n${update.text}`
  } catch (error) {
    console.error('Error updating vow:', error)
    outputContent.value = '❌ Failed to update vow'
  }
}

async function handleDelete(vowId: string) {
  try {
    const vow = vows.value.find((v) => v.id === vowId)
    const response = await fetch(`${API_BASE_URL}/vows/${vowId}`, {
      method: 'DELETE',
    })

    if (!response.ok) throw new Error('Failed to delete vow')

    // Refresh the vows list
    await fetchVows()
    outputContent.value = vow ? `🗑️ Deleted vow:\n${vow.text}` : '🗑️ Vow deleted'
  } catch (error) {
    console.error('Error deleting vow:', error)
    outputContent.value = '❌ Failed to delete vow'
  }
}

const displayText = computed(() => stateMachine[displayMode.value].displayText)

// Fetch vows when component mounts
onMounted(() => {
  fetchVows()
})
</script>

<template>
  <div class="app-container">
    <SidebarPanel
      :display-text="displayText"
      :vows="vows"
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
