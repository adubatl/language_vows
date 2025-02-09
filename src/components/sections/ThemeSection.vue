<template>
  <SidebarSection :icon="sectionIcon" title="Theme">
    <div class="theme-name">{{ currentTheme.name }}</div>

    <!-- AI Theme Toggle -->
    <div class="ai-toggle">
      <span>Random</span>
      <label class="switch">
        <input type="checkbox" v-model="useAI" data-test="ai-theme-toggle" />
        <span class="slider"></span>
      </label>
      <span>AI</span>
    </div>

    <!-- AI Theme Input (shown when AI is enabled) -->
    <input
      v-if="useAI"
      v-model="prompt"
      type="text"
      class="text-input"
      placeholder="Enter theme prompt (optional)"
      data-test="theme-prompt-input"
      :disabled="isGenerating"
    />

    <!-- Theme Generation Button -->
    <button
      class="test-button"
      @click="handleGenerateTheme"
      data-test="generate-theme-button"
      :disabled="isGenerating"
    >
      <span v-if="isGenerating" class="loading-spinner"></span>
      <span v-else>
        {{ useAI ? 'Generate Theme with AI' : 'Generate Random Theme' }}
      </span>
    </button>

    <button class="test-button" @click="resetTheme" :disabled="isGenerating">Reset Theme</button>

    <div class="theme-preview">
      <div
        class="color-sample"
        :style="{
          backgroundColor: currentTheme.background,
          color: currentTheme.text,
          border: `1px solid ${currentTheme.text}`,
        }"
      >
        Background
      </div>
      <div
        class="color-sample"
        :style="{
          backgroundColor: currentTheme.text,
          color: currentTheme.background,
          border: `1px solid ${currentTheme.background}`,
        }"
      >
        Text
      </div>
    </div>
  </SidebarSection>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useThemeStore } from '../../stores/theme'
import { storeToRefs } from 'pinia'
import SidebarSection from './SidebarSection.vue'

const sectionIcon = 'material-symbols:palette-outline'

const themeStore = useThemeStore()
const { currentTheme, isGenerating } = storeToRefs(themeStore)
const { generateNewTheme, resetTheme, generateAITheme } = themeStore

const useAI = ref(false)
const prompt = ref('')

async function handleGenerateTheme() {
  if (useAI.value) {
    await generateAITheme(prompt.value)
    prompt.value = '' // Clear prompt after use
  } else {
    generateNewTheme()
  }
}

watch(
  () => isGenerating.value,
  (newVal) => {
    console.log('isGenerating changed:', newVal)
  },
)
</script>

<style scoped>
.theme-name {
  color: var(--icon-color);
  font-style: italic;
  margin-bottom: var(--spacing-md);
  font-size: 0.9rem;
}

.theme-preview {
  display: flex;
  gap: 0.5rem;
  margin-top: var(--spacing-md);
}

.color-sample {
  flex: 1;
  padding: 0.5rem;
  border-radius: 4px;
  text-align: center;
  font-size: 0.8rem;
  transition: all 0.3s ease;
}

.ai-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: var(--spacing-md);
  color: var(--text-color);
}

/* Switch styles */
.switch {
  position: relative;
  display: inline-block;
  width: 48px;
  height: 24px;
}

.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: var(--button-bg);
  transition: 0.4s;
  border-radius: 24px;
  border: 2px solid var(--border-color);
}

.slider:before {
  position: absolute;
  content: '';
  height: 16px;
  width: 16px;
  left: 2px;
  bottom: 2px;
  background-color: var(--text-color);
  transition: 0.4s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: var(--accent-color);
}

input:checked + .slider:before {
  transform: translateX(24px);
}

.loading-spinner {
  display: inline-block;
  width: 1.2rem;
  height: 1.2rem;
  border: 3px solid var(--text-color);
  border-radius: 50%;
  border-top-color: transparent;
  animation: spin 0.8s linear infinite;
  margin: 0 0.5rem;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.test-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background-color: var(--button-bg);
  pointer-events: none;
}

.text-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background-color: var(--button-bg);
}
</style>
