<script setup lang="ts">
import { ref, watch, provide } from 'vue'
import { Icon } from '@iconify/vue'
import type { VowsArray } from '@/types/vow'

import ThemeSection from './sections/ThemeSection.vue'
import DisplaySection from './sections/DisplaySection.vue'
import CreateSection from './sections/CreateSection.vue'
import ReadSection from './sections/ReadSection.vue'
import UpdateSection from './sections/UpdateSection.vue'
import DeleteSection from './sections/DeleteSection.vue'

const props = defineProps<{
  displayText: string
  vows: VowsArray
}>()

const updateVowText = ref('')
const selectedReadVow = ref<string>('')
const selectedUpdateVow = ref<string>('')
const selectedDeleteVow = ref<string>('')

const RESET_SELECTS = Symbol('resetSelects')

const resetTrigger = ref(0)
provide(RESET_SELECTS, () => {
  resetTrigger.value++
})

watch(
  () => props.vows,
  (newVows) => {
    if (selectedReadVow.value && !newVows?.find((v) => v.id === selectedReadVow.value)) {
      selectedReadVow.value = ''
    }
    if (selectedUpdateVow.value && !newVows?.find((v) => v.id === selectedUpdateVow.value)) {
      selectedUpdateVow.value = ''
      updateVowText.value = ''
    }
    if (selectedDeleteVow.value && !newVows?.find((v) => v.id === selectedDeleteVow.value)) {
      selectedDeleteVow.value = ''
    }
  },
)
</script>

<template>
  <div class="left-panel">
    <div class="sidebar-header">
      <div class="emoji-row">
        <span>🙏</span>
        <Icon icon="logos:python" class="language-icon" />
        <span>🙏</span>
      </div>
      <h1>🙏 Language Vows 🙏</h1>
      <div class="emoji-row">
        <Icon icon="logos:typescript-icon" class="language-icon" />
        <span>🙏</span>
        <Icon icon="logos:go" class="language-icon" />
      </div>
    </div>

    <DisplaySection :display-text="displayText" @missy-moves="$emit('missy-moves')" />
    <hr class="section-divider" />

    <CreateSection @create="$emit('create', $event)" @missy-moves="$emit('missy-moves')" />
    <hr class="section-divider" />

    <ReadSection :vows="vows" @read="$emit('read', $event)" @missy-moves="$emit('missy-moves')" />
    <hr class="section-divider" />

    <UpdateSection
      :vows="vows"
      @update="$emit('update', $event)"
      @missy-moves="$emit('missy-moves')"
    />
    <hr class="section-divider" />

    <DeleteSection
      :vows="vows"
      @delete="$emit('delete', $event)"
      @missy-moves="$emit('missy-moves')"
    />
    <hr class="section-divider" />

    <ThemeSection />
  </div>
</template>

<style scoped>
.left-panel {
  flex: 0 0 var(--sidebar-width);
  min-width: var(--sidebar-width);
  max-width: var(--sidebar-width);
  padding: var(--spacing-lg);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.sidebar-header {
  flex-direction: column;
  text-align: center;
  margin-bottom: var(--spacing-lg);
}

.emoji-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-md);
}

.emoji-row span {
  font-size: 1.25rem;
}

.emoji-row .language-icon {
  width: 1.25rem;
  height: 1.25rem;
}

h1 {
  margin: var(--spacing-sm) 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-color);
}

.section-divider {
  border: none;
  border-top: 1px solid var(--border-color);
  margin: var(--spacing-md) 0;
}
</style>
