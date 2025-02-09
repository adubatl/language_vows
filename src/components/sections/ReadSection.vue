<template>
  <SidebarSection :icon="sectionIcon" title="Read">
    <VowSelect v-model="selectedReadVow" :vows="vows" @change="onVowSelect" />
    <button class="test-button" @click="handleRead">Read Vow</button>
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

const emit = defineEmits(['read', 'missy-moves'])

const selectedReadVow = ref<string>('')

const sectionIcon = 'material-symbols:menu-book-outline'

const resetSelects = inject('resetSelects', () => {})

function handleRead() {
  if (selectedReadVow.value) {
    emit('read', selectedReadVow.value)
    emit('missy-moves')
    resetSelects()
  }
}

function onVowSelect() {
  // Additional handling if needed
}
</script>
