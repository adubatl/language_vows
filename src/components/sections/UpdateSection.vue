<template>
  <SidebarSection :icon="sectionIcon" title="Update">
    <VowSelect v-model="selectedUpdateVow" :vows="vows" @change="onVowSelect" />
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
import type { LanguageVow } from '@/types/vow'
import SidebarSection from './SidebarSection.vue'
import VowSelect from '@/components/VowSelect.vue'

const props = defineProps<{
  vows: LanguageVow[]
}>()

const emit = defineEmits(['update', 'missy-moves'])

const selectedUpdateVow = ref<string>('')
const updateVowText = ref('')

const sectionIcon = 'material-symbols:edit-outline'

function handleUpdate() {
  if (selectedUpdateVow.value) {
    emit('update', {
      id: selectedUpdateVow.value,
      text: updateVowText.value,
    })
    emit('missy-moves')
  }
}

function onVowSelect() {
  const selectedVowObj = props.vows.find((vow) => vow.id === selectedUpdateVow.value)
  if (selectedVowObj) {
    updateVowText.value = selectedVowObj.text
  }
}
</script>
