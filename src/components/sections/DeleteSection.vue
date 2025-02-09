<template>
  <SidebarSection :icon="TrashIcon" title="Delete">
    <select v-model="selectedDeleteVow" class="select-input" @change="onVowSelect">
      <option value="">Select a vow</option>
      <option v-for="vow in vows" :key="vow.id" :value="vow.id">
        <component :is="languageIcons[vow.language]" class="language-icon" />
        {{ truncateText(vow.text, 30) }}
      </option>
    </select>
    <button class="test-button" @click="handleDelete">Delete Vow</button>
  </SidebarSection>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { TrashIcon } from '@heroicons/vue/24/outline'
import { CodeBracketIcon, CubeIcon, BeakerIcon } from '@heroicons/vue/24/solid'
import type { LanguageVow } from '@/types/vow'
import SidebarSection from '../SidebarSection.vue'

defineProps<{
  vows: LanguageVow[]
}>()

const emit = defineEmits(['delete', 'missy-moves'])

const selectedDeleteVow = ref<string>('')

const languageIcons = {
  typescript: CodeBracketIcon,
  go: CubeIcon,
  python: BeakerIcon,
}

function handleDelete() {
  if (selectedDeleteVow.value) {
    emit('delete', selectedDeleteVow.value)
    emit('missy-moves')
    selectedDeleteVow.value = ''
  }
}

function truncateText(text: string, maxLength: number) {
  if (text.length <= maxLength) return text
  return `${text.slice(0, maxLength)}...`
}

function onVowSelect() {
  // Additional handling if needed
}
</script>
