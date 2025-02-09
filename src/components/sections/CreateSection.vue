<template>
  <SidebarSection :icon="sectionIcon" title="Create">
    <div class="language-buttons">
      <button
        v-for="lang in languages"
        :key="lang"
        class="language-button"
        @click="handleCreate(lang)"
      >
        <Icon :icon="languageIcons[lang]" class="language-icon" />
      </button>
    </div>
  </SidebarSection>
</template>

<script setup lang="ts">
import { Icon } from '@iconify/vue'
import type { Language } from '@/types/vow'
import { TYPESCRIPT_VOWS, GO_VOWS, PYTHON_VOWS } from '@/constants/vows'
import SidebarSection from './SidebarSection.vue'
import '@/assets/shared-styles.css'

const emit = defineEmits(['create', 'missy-moves'])

const languages: Language[] = ['typescript', 'go', 'python']

const languageIcons = {
  typescript: 'logos:typescript-icon',
  go: 'logos:go',
  python: 'logos:python',
}

const sectionIcon = 'material-symbols:add-circle-outline'

function handleCreate(language: Language) {
  const languageVows = {
    typescript: TYPESCRIPT_VOWS,
    go: GO_VOWS,
    python: PYTHON_VOWS,
  }[language]

  const randomVow = languageVows[Math.floor(Math.random() * languageVows.length)]

  emit('create', {
    text: randomVow.text,
    language,
  })
  emit('missy-moves')
}
</script>

<style scoped>
.language-buttons {
  display: flex;
  gap: var(--spacing-sm);
}

.language-button {
  flex: 1;
  padding: var(--spacing-md);
  background-color: var(--button-bg);
  color: var(--text-color);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.language-button:hover {
  background-color: var(--button-hover);
  transform: translateY(-1px);
}

.language-button:active {
  transform: translateY(0);
}

.language-icon {
  width: 1.5rem;
  height: 1.5rem;
}
</style>
