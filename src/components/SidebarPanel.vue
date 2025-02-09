<script setup lang="ts">
import { ref, watch } from 'vue'
import type { LanguageVow, Language } from '@/types/vow'
import {
  PlusCircleIcon,
  BookOpenIcon,
  PencilSquareIcon,
  TrashIcon,
} from '@heroicons/vue/24/outline'
import {
  CodeBracketIcon, // For TypeScript
  CubeIcon, // For Go
  BeakerIcon, // For Python
} from '@heroicons/vue/24/solid'
import { TYPESCRIPT_VOWS, GO_VOWS, PYTHON_VOWS } from '@/constants/vows'

const props = defineProps<{
  displayText: string
  vows: LanguageVow[] // New prop to receive vows from parent
}>()

const emit = defineEmits(['create', 'read', 'update', 'delete', 'missy-moves'])

const updateVowText = ref('')
const selectedReadVow = ref<string>('')
const selectedUpdateVow = ref<string>('')
const selectedDeleteVow = ref<string>('')
const selectedLanguage = ref<Language>('typescript')

const languages: Language[] = ['typescript', 'go', 'python']

const languageIcons = {
  typescript: CodeBracketIcon,
  go: CubeIcon,
  python: BeakerIcon,
}

function handleCreate() {
  // Get all vows for the selected language
  const languageVows = {
    typescript: TYPESCRIPT_VOWS,
    go: GO_VOWS,
    python: PYTHON_VOWS,
  }[selectedLanguage.value]

  // Pick a random vow from the selected language
  const randomVow = languageVows[Math.floor(Math.random() * languageVows.length)]

  emit('create', {
    text: randomVow.text,
    language: selectedLanguage.value,
  })
  emit('missy-moves')

  // Clear the selection
  selectedLanguage.value = 'typescript'
}

function handleUpdate() {
  if (selectedUpdateVow.value) {
    emit('update', {
      id: selectedUpdateVow.value,
      text: updateVowText.value,
    })
    emit('missy-moves')
  }
}

function handleRead() {
  if (selectedReadVow.value) {
    emit('read', selectedReadVow.value)
    emit('missy-moves')
    selectedReadVow.value = ''
  }
}

function handleDelete() {
  if (selectedDeleteVow.value) {
    emit('delete', selectedDeleteVow.value)
    emit('missy-moves')
    selectedDeleteVow.value = ''
    updateVowText.value = ''
  }
}

// When a vow is selected from dropdown, populate update text field
function onVowSelect(event: Event, operation: 'read' | 'update' | 'delete') {
  const target = event.target as HTMLSelectElement
  const selectedVowObj = props.vows.find((vow) => vow.id === target.value)

  if (selectedVowObj) {
    if (operation === 'update') {
      updateVowText.value = selectedVowObj.text
    }
  }
}

// Add this function to handle text truncation
function truncateText(text: string, maxLength: number) {
  if (text.length <= maxLength) {
    return text
  }
  return `${text.slice(0, maxLength)}...`
}

// Watch for changes in vows array
watch(
  () => props.vows,
  (newVows) => {
    // Reset selections if their vow no longer exists
    if (selectedReadVow.value && !newVows.find((v) => v.id === selectedReadVow.value)) {
      selectedReadVow.value = ''
    }
    if (selectedUpdateVow.value && !newVows.find((v) => v.id === selectedUpdateVow.value)) {
      selectedUpdateVow.value = ''
      updateVowText.value = ''
    }
    if (selectedDeleteVow.value && !newVows.find((v) => v.id === selectedDeleteVow.value)) {
      selectedDeleteVow.value = ''
    }
  },
)
</script>

<template>
  <div class="left-panel">
    <div class="sidebar-header">
      <span class="emoji">🙏</span>
      <h1>Language Vows</h1>
      <span class="emoji">🙏</span>
    </div>

    <div class="sidebar-section">
      <h2>Display</h2>
      <button class="test-button" @click="$emit('missy-moves')">{{ displayText }}</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <div class="section-header">
        <PlusCircleIcon class="section-icon" />
        <h2>Create</h2>
      </div>
      <select v-model="selectedLanguage" class="select-input">
        <option v-for="lang in languages" :key="lang" :value="lang">
          <component :is="languageIcons[lang]" class="language-icon" />
          {{ lang.charAt(0).toUpperCase() + lang.slice(1) }}
        </option>
      </select>
      <button class="test-button" @click="handleCreate">Create Vow</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <div class="section-header">
        <BookOpenIcon class="section-icon" />
        <h2>Read</h2>
      </div>
      <select v-model="selectedReadVow" class="select-input" @change="onVowSelect($event, 'read')">
        <option value="">Select a vow</option>
        <option v-for="vow in props.vows" :key="vow.id" :value="vow.id">
          <component :is="languageIcons[vow.language]" class="language-icon" />
          {{ truncateText(vow.text, 30) }}
        </option>
      </select>
      <button class="test-button" @click="handleRead">Read Vow</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <div class="section-header">
        <PencilSquareIcon class="section-icon" />
        <h2>Update</h2>
      </div>
      <select
        v-model="selectedUpdateVow"
        class="select-input"
        @change="onVowSelect($event, 'update')"
      >
        <option value="">Select a vow</option>
        <option v-for="vow in props.vows" :key="vow.id" :value="vow.id">
          <component :is="languageIcons[vow.language]" class="language-icon" />
          {{ truncateText(vow.text, 30) }}
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
      <div class="section-header">
        <TrashIcon class="section-icon" />
        <h2>Delete</h2>
      </div>
      <select
        v-model="selectedDeleteVow"
        class="select-input"
        @change="onVowSelect($event, 'delete')"
      >
        <option value="">Select a vow</option>
        <option v-for="vow in props.vows" :key="vow.id" :value="vow.id">
          <component :is="languageIcons[vow.language]" class="language-icon" />
          {{ truncateText(vow.text, 30) }}
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
  justify-content: center;
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
  white-space: nowrap;
}

.sidebar-section {
  margin: var(--spacing-lg) 0;
}

.sidebar-section h2 {
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--icon-color);
  margin: 0 0 var(--spacing-md) 0;
  font-weight: 600;
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

.section-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  margin-bottom: var(--spacing-md);
}

.section-header h2 {
  margin: 0;
  line-height: 1;
  display: flex;
  align-items: center;
}

.section-icon {
  width: 1.25rem;
  height: 1.25rem;
  color: var(--icon-color);
  flex-shrink: 0;
}

.language-icon {
  width: 1rem;
  height: 1rem;
  margin-right: var(--spacing-sm);
  vertical-align: middle;
}

.select-input option {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}
</style>
