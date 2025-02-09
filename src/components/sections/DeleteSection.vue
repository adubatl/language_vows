<template>
  <SidebarSection :icon="sectionIcon" title="Delete">
    <VowSelect v-model="selectedDeleteVow" :vows="vows" @change="onVowSelect" />
    <button class="test-button" @click="handleDelete">Delete Vow</button>
  </SidebarSection>
</template>

<script setup lang="ts">
import { ref, inject } from 'vue'
import type { VowsArray } from '@/types/vow'
import SidebarSection from './SidebarSection.vue'
import VowSelect from '@/components/VowSelect.vue'

defineProps<{
  vows: VowsArray
}>()

const emit = defineEmits(['delete', 'missy-moves'])

const selectedDeleteVow = ref<string>('')

const sectionIcon = 'material-symbols:delete-outline'

const resetSelects = inject('resetSelects', () => {})

function handleDelete() {
  if (selectedDeleteVow.value) {
    emit('delete', selectedDeleteVow.value)
    emit('missy-moves')
    resetSelects()
  }
}

function onVowSelect() {
  // Additional handling if needed
}
</script>
