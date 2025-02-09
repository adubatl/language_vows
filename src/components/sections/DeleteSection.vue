<template>
  <SidebarSection :icon="sectionIcon" title="Delete">
    <VowSelect v-model="selectedDeleteVow" :vows="vows" @change="onVowSelect" />
    <button class="test-button" @click="handleDelete">Delete Vow</button>
  </SidebarSection>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import type { LanguageVow } from '@/types/vow'
import SidebarSection from './SidebarSection.vue'
import VowSelect from '@/components/VowSelect.vue'

defineProps<{
  vows: LanguageVow[]
}>()

const emit = defineEmits(['delete', 'missy-moves'])

const selectedDeleteVow = ref<string>('')

const sectionIcon = 'material-symbols:delete-outline'

function handleDelete() {
  if (selectedDeleteVow.value) {
    emit('delete', selectedDeleteVow.value)
    emit('missy-moves')
    selectedDeleteVow.value = ''
  }
}

function onVowSelect() {
  // Additional handling if needed
}
</script>
