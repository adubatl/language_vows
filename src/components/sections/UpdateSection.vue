<template>
  <SidebarSection :icon="sectionIcon" title="Update">
    <VowSelect v-model="selectedUpdateVow" :vows="vows" @change="onVowSelect" />
    <input
      v-model="updateVowText"
      type="text"
      class="text-input"
      placeholder="Update vow text..."
      :disabled="!selectedUpdateVow"
    />
    <button
      class="test-button"
      @click="handleUpdate"
      :disabled="!selectedUpdateVow || !updateVowText.trim()"
    >
      Update Vow
    </button>
  </SidebarSection>
</template>

<script setup lang="ts">
import { ref, inject, watch } from 'vue'
import type { VowsArray } from '@/types/vow'
import SidebarSection from './SidebarSection.vue'
import VowSelect from '@/components/VowSelect.vue'

const props = defineProps<{
  vows: VowsArray
}>()

const emit = defineEmits(['update', 'missy-moves'])

const selectedUpdateVow = ref<string>('')
const updateVowText = ref('')

const sectionIcon = 'material-symbols:edit-outline'

const resetSelects = inject('resetSelects', () => {})

// Reset input when vows change
watch(
  () => props.vows,
  () => {
    updateVowText.value = ''
  },
)

// Reset input when reset is triggered
watch(
  () => resetSelects(),
  () => {
    updateVowText.value = ''
  },
)

function handleUpdate() {
  if (selectedUpdateVow.value && updateVowText.value.trim()) {
    emit('update', {
      id: selectedUpdateVow.value,
      text: updateVowText.value.trim(),
    })
    emit('missy-moves')
    resetSelects()
  }
}

function onVowSelect() {
  const selectedVowObj = props.vows?.find((vow) => vow.id === selectedUpdateVow.value)
  if (selectedVowObj) {
    updateVowText.value = selectedVowObj.text
  } else {
    updateVowText.value = ''
  }
}
</script>

<style scoped>
.text-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.test-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background-color: var(--button-bg);
}

.test-button:disabled:hover {
  background-color: var(--button-bg);
  transform: none;
}
</style>
