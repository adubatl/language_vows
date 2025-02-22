<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import SidebarPanel from '@/components/SidebarPanel.vue'
import MissyDisplay from '@/components/MissyDisplay.vue'
import CodeOutput from '@/components/CodeOutput.vue'
import { DisplayMode, Position } from '@/constants/missy'
import type { LanguageVow, VowsArray, Language, Transaction } from '@/types/vow'
import TransactionHistory from '@/components/TransactionHistory.vue'

const outputContent = ref('')
const currentRotation = ref(0)
const displayMode = ref(0)
const position = ref(Position.CENTER)
const currentLanguage = ref<Language | undefined>()

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

const vows = ref<VowsArray>([])
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

const transactions = ref<Transaction[]>([])

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

    await fetchVows()
    currentLanguage.value = vow.language
    outputContent.value = `✨ Created new vow:\n${vow.text}`
    transactions.value.unshift({
      operation: 'CREATE',
      timestamp: Date.now(),
      language: vow.language,
      text: vow.text,
    })
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
    currentLanguage.value = vow.language
    outputContent.value = `📖 Reading vow:\n${vow.text}`
    transactions.value.unshift({
      operation: 'READ',
      timestamp: Date.now(),
      language: vow.language,
      text: vow.text,
    })
  } catch (error) {
    console.error('Error reading vow:', error)
    outputContent.value = '❌ Failed to read vow'
  }
}

async function handleUpdate(update: { id: string; text: string }) {
  try {
    const vow = vows.value?.find((v) => v.id === update.id)
    const response = await fetch(`${API_BASE_URL}/vows/${update.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text: update.text }),
    })

    if (!response.ok) throw new Error('Failed to update vow')

    await fetchVows()
    currentLanguage.value = vow?.language
    outputContent.value = `📝 Updated vow:\n${update.text}`
    transactions.value.unshift({
      operation: 'UPDATE',
      timestamp: Date.now(),
      language: vow?.language ?? 'typescript',
      text: update.text,
    })
  } catch (error) {
    console.error('Error updating vow:', error)
    outputContent.value = '❌ Failed to update vow'
  }
}

async function handleDelete(vowId: string) {
  try {
    const vow = vows.value?.find((v) => v.id === vowId)
    const response = await fetch(`${API_BASE_URL}/vows/${vowId}`, {
      method: 'DELETE',
    })

    if (!response.ok) throw new Error('Failed to delete vow')

    await fetchVows()
    currentLanguage.value = vow?.language
    outputContent.value = vow ? `🗑️ Deleted vow:\n${vow.text}` : '🗑️ Vow deleted'
    transactions.value.unshift({
      operation: 'DELETE',
      timestamp: Date.now(),
      language: vow?.language ?? 'typescript',
      text: vow ? vow.text : 'Vow deleted',
    })
  } catch (error) {
    console.error('Error deleting vow:', error)
    outputContent.value = '❌ Failed to delete vow'
  }
}

const displayText = computed(() => stateMachine[displayMode.value].displayText)

onMounted(() => {
  fetchVows()
})
</script>

<template>
  <div class="app-container">
    <SidebarPanel
      :vows="vows"
      :display-text="displayText"
      @create="handleCreate"
      @read="handleRead"
      @update="handleUpdate"
      @delete="handleDelete"
      @missy-moves="handleMissyMoves"
    />
    <div class="right-panel">
      <div class="top-section">
        <MissyDisplay :rotation="currentRotation" :position="position" />
      </div>
      <div class="middle-section">
        <TransactionHistory :transactions="transactions" />
      </div>
      <div class="bottom-section">
        <CodeOutput :content="outputContent" :language="currentLanguage" />
      </div>
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
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
  padding: var(--spacing-lg);
  height: 100vh;
  overflow: hidden;
}

.top-section {
  height: 200px;
  min-height: 200px;
  padding: var(--spacing-sm);
  display: flex;
  align-items: center;
  justify-content: center;
}

.middle-section {
  flex: 1;
  height: 400px;
  min-height: 0;
  padding: var(--spacing-sm);
  overflow: hidden;
}

.bottom-section {
  padding: var(--spacing-sm);
  overflow: hidden;
}

.top-section .missy-container {
  height: 100%;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.top-section .missy {
  max-height: 180px;
  width: auto;
}
</style>
