<template>
  <SidebarSection :icon="PlusCircleIcon" title="Create">
    <select v-model="selectedLanguage" class="select-input">
      <option v-for="lang in languages" :key="lang" :value="lang">
        <component :is="languageIcons[lang]" class="language-icon" />
        {{ lang.charAt(0).toUpperCase() + lang.slice(1) }}
      </option>
    </select>
    <button class="test-button" @click="handleCreate">Create Vow</button>
  </SidebarSection>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { PlusCircleIcon } from '@heroicons/vue/24/outline'
import { CodeBracketIcon, CubeIcon, BeakerIcon } from '@heroicons/vue/24/solid'
import type { Language } from '@/types/vow'
import { TYPESCRIPT_VOWS, GO_VOWS, PYTHON_VOWS } from '@/constants/vows'
import SidebarSection from './SidebarSection.vue'
import '@/assets/shared-styles.css'

const emit = defineEmits(['create', 'missy-moves'])

const selectedLanguage = ref<Language>('typescript')
const languages: Language[] = ['typescript', 'go', 'python']

const languageIcons = {
  typescript: CodeBracketIcon,
  go: CubeIcon,
  python: BeakerIcon,
}

function handleCreate() {
  const languageVows = {
    typescript: TYPESCRIPT_VOWS,
    go: GO_VOWS,
    python: PYTHON_VOWS,
  }[selectedLanguage.value]

  const randomVow = languageVows[Math.floor(Math.random() * languageVows.length)]

  emit('create', {
    text: randomVow.text,
    language: selectedLanguage.value,
  })
  emit('missy-moves')

  selectedLanguage.value = 'typescript'
}
</script>
