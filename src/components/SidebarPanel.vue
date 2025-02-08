<script setup lang="ts">
import { ref } from 'vue'
import type { LanguageVow, Language } from '@/types/vow'
import { ALL_VOWS } from '@/constants/vows'

defineProps<{
  displayText: string
}>()

const emit = defineEmits(['create', 'read', 'update', 'delete', 'missy-moves'])

const newVowText = ref('')
const updateVowText = ref('')
const selectedVow = ref<string>('') // For storing selected vow ID
const selectedLanguage = ref<Language>('typescript')

const languages: Language[] = ['typescript', 'go', 'python']

function handleCreate() {
  emit('create', {
    text: newVowText.value,
    language: selectedLanguage.value,
  })
  newVowText.value = '' // Clear input after creation
}

function handleUpdate() {
  if (selectedVow.value) {
    emit('update', {
      id: selectedVow.value,
      text: updateVowText.value,
    })
  }
}

function handleRead() {
  if (selectedVow.value) {
    emit('read', selectedVow.value)
  }
}

function handleDelete() {
  if (selectedVow.value) {
    emit('delete', selectedVow.value)
  }
}

// When a vow is selected from dropdown, populate update text field
function onVowSelect(event: Event) {
  const target = event.target as HTMLSelectElement
  selectedVow.value = target.value
  const selectedVowObj = ALL_VOWS.find((vow) => vow.id === target.value)
  if (selectedVowObj) {
    updateVowText.value = selectedVowObj.text
  }
}
</script>

<template>
  <div class="left-panel">
    <div class="sidebar-header">
      <span class="emoji">🙏</span>
      <h1>Language Vows</h1>
    </div>

    <div class="sidebar-section">
      <h2>Display</h2>
      <button class="test-button" @click="$emit('missy-moves')">{{ displayText }}</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Create</h2>
      <select v-model="selectedLanguage" class="select-input">
        <option v-for="lang in languages" :key="lang" :value="lang">
          {{ lang.charAt(0).toUpperCase() + lang.slice(1) }}
        </option>
      </select>
      <input v-model="newVowText" type="text" class="text-input" placeholder="Enter your vow..." />
      <button class="test-button" @click="handleCreate">Create Vow</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Read</h2>
      <select v-model="selectedVow" class="select-input" @change="onVowSelect">
        <option value="">Select a vow</option>
        <option v-for="vow in ALL_VOWS" :key="vow.id" :value="vow.id">
          {{ vow.text.slice(0, 30) }}...
        </option>
      </select>
      <button class="test-button" @click="handleRead">Read Vow</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Update</h2>
      <select v-model="selectedVow" class="select-input" @change="onVowSelect">
        <option value="">Select a vow</option>
        <option v-for="vow in ALL_VOWS" :key="vow.id" :value="vow.id">
          {{ vow.text.slice(0, 30) }}...
        </option>
      </select>
      <input
        v-model="updateVowText"
        type="text"
        class="text-input"
        placeholder="Update vow text..."
      />
      <button class="test-button" @click="handleUpdate">Update Vow</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Delete</h2>
      <select v-model="selectedVow" class="select-input" @change="onVowSelect">
        <option value="">Select a vow</option>
        <option v-for="vow in ALL_VOWS" :key="vow.id" :value="vow.id">
          {{ vow.text.slice(0, 30) }}...
        </option>
      </select>
      <button class="test-button" @click="handleDelete">Delete Vow</button>
    </div>
  </div>
</template>

<style scoped>
.sidebar-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-xl);
}

.sidebar-header .emoji {
  font-size: 1.5rem;
}

.sidebar-header h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-color);
}

.sidebar-section {
  margin: var(--spacing-lg) 0;
}

.sidebar-section h2 {
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #666;
  margin: 0 0 var(--spacing-md) 0;
}

.section-divider {
  border: none;
  border-top: 1px solid var(--border-color);
  margin: var(--spacing-md) 0;
}

.test-button {
  width: 100%;
  padding: var(--spacing-md);
  background-color: var(--button-bg);
  color: var(--text-color);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.2s ease;
  margin-top: var(--spacing-sm);
}

.test-button:hover {
  background-color: var(--button-hover);
}

.text-input {
  width: 100%;
  padding: 0.5rem;
  margin-bottom: 0.5rem;
  border: 1px solid var(--border-color);
  background: var(--button-bg);
  color: var(--text-color);
  border-radius: 4px;
}

.select-input {
  width: 100%;
  padding: 0.5rem;
  margin-bottom: 0.5rem;
  border: 1px solid var(--border-color);
  background: var(--button-bg);
  color: var(--text-color);
  border-radius: 4px;
  cursor: pointer;
}

.select-input option {
  background: var(--bg-color);
  color: var(--text-color);
}
</style>
