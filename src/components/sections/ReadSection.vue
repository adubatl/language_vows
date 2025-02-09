<template>
  <SidebarSection :icon="sectionIcon" title="Read">
    <VowSelect v-model="selectedReadVow" :vows="vows" @change="onVowSelect" />
    <button class="test-button" @click="handleRead">Read Vow</button>
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

const emit = defineEmits(['read', 'missy-moves'])

const selectedReadVow = ref<string>('')

const sectionIcon = 'material-symbols:menu-book-outline'

function handleRead() {
  if (selectedReadVow.value) {
    emit('read', selectedReadVow.value)
    emit('missy-moves')
    selectedReadVow.value = ''
  }
}

function onVowSelect() {
  // Additional handling if needed
}
</script>
