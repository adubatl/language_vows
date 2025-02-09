<template>
  <SidebarSection :icon="PencilSquareIcon" title="Update">
    <select v-model="selectedUpdateVow" class="select-input" @change="onVowSelect">
      <option value="">Select a vow</option>
      <option v-for="vow in vows" :key="vow.id" :value="vow.id">
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
  </SidebarSection>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { PencilSquareIcon } from '@heroicons/vue/24/outline'
import { CodeBracketIcon, CubeIcon, BeakerIcon } from '@heroicons/vue/24/solid'
import type { LanguageVow } from '@/types/vow'
import SidebarSection from './SidebarSection.vue'

const props = defineProps<{
  vows: LanguageVow[]
}>()

const emit = defineEmits(['update', 'missy-moves'])

const selectedUpdateVow = ref<string>('')
const updateVowText = ref('')

const languageIcons = {
  typescript: CodeBracketIcon,
  go: CubeIcon,
  python: BeakerIcon,
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

function truncateText(text: string, maxLength: number) {
  if (text.length <= maxLength) return text
  return `${text.slice(0, maxLength)}...`
}

function onVowSelect(event: Event) {
  const target = event.target as HTMLSelectElement
  const selectedVowObj = props.vows.find((vow) => vow.id === target.value)
  if (selectedVowObj) {
    updateVowText.value = selectedVowObj.text
  }
}
</script>
