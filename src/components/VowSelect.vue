<template>
  <div
    class="vow-select"
    :class="{ open: isOpen, disabled: !vows?.length }"
    @mouseleave="startCloseTimer"
    @mouseenter="cancelCloseTimer"
  >
    <div
      class="selected"
      :data-test="`vow-select-${vows?.length ? 'active' : 'disabled'}`"
      @click="handleClick"
    >
      <div class="selected-content">
        <template v-if="modelValue && selectedVow">
          <div class="vow-option">
            <Icon :icon="languageIcons[selectedVow.language]" class="language-icon" />
            <span>{{ truncateText(selectedVow.text, 30) }}</span>
          </div>
        </template>
        <template v-else>
          <span class="placeholder">{{ vows?.length ? 'Select a vow' : 'No vows available' }}</span>
        </template>
      </div>
      <Icon
        icon="material-symbols:keyboard-arrow-down-rounded"
        class="chevron"
        :class="{ open: isOpen }"
      />
    </div>
    <div
      v-if="isOpen && vows?.length"
      class="options"
      @mouseleave="startCloseTimer"
      @mouseenter="cancelCloseTimer"
    >
      <div
        v-for="vow in vows"
        :key="vow.id"
        class="vow-option"
        :data-test="`vow-option-${vow.language}`"
        @click="selectVow(vow.id)"
      >
        <Icon :icon="languageIcons[vow.language]" class="language-icon" />
        <span>{{ truncateText(vow.text, 30) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, inject, watch } from 'vue'
import { Icon } from '@iconify/vue'
import type { VowsArray } from '@/types/vow'

const props = defineProps<{
  modelValue: string
  vows: VowsArray
}>()

const emit = defineEmits(['update:modelValue', 'change'])

const isOpen = ref(false)
const resetSelects = inject('resetSelects', () => {})

// Reset state when any action occurs
watch(
  () => resetSelects(),
  () => {
    isOpen.value = false
    emit('update:modelValue', '')
  },
)

// Add watch for vows changes
watch(
  () => props.vows,
  () => {
    // Reset state when vows change
    isOpen.value = false
    emit('update:modelValue', '')
  },
)

const languageIcons = {
  typescript: 'logos:typescript-icon',
  go: 'logos:go',
  python: 'logos:python',
}

const selectedVow = computed(() => props.vows?.find((vow) => vow.id === props.modelValue))

function selectVow(id: string) {
  emit('update:modelValue', id)
  emit('change')
  isOpen.value = false
}

function truncateText(text: string, maxLength: number) {
  if (text.length <= maxLength) return text
  return `${text.slice(0, maxLength)}...`
}

// Click outside handler
function handleClickOutside(event: MouseEvent) {
  const target = event.target as HTMLElement
  if (!target.closest('.vow-select')) {
    isOpen.value = false
  }
}

const closeTimeout = ref<number | null>(null)

function startCloseTimer() {
  closeTimeout.value = window.setTimeout(() => {
    isOpen.value = false
  }, 1000)
}

function cancelCloseTimer() {
  if (closeTimeout.value !== null) {
    clearTimeout(closeTimeout.value)
    closeTimeout.value = null
  }
}

function handleClick() {
  if (props.vows?.length) {
    isOpen.value = !isOpen.value
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  cancelCloseTimer()
})
</script>

<style scoped>
.vow-select {
  position: relative;
  width: 100%;
}

.selected {
  width: 100%;
  padding: 0.5rem;
  border: 2px solid var(--border-color);
  background: var(--button-bg);
  color: var(--text-color);
  border-radius: 4px;
  cursor: pointer;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.selected-content {
  flex: 1;
  min-width: 0; /* Allows text truncation to work */
}

.options {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: var(--bg-color);
  border: 2px solid var(--border-color);
  border-radius: 4px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 10;
}

.vow-option {
  padding: 0.5rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.vow-option:hover {
  background: var(--button-hover);
}

.language-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.placeholder {
  opacity: 0.7;
  font-style: italic;
}

.chevron {
  width: 1.25rem;
  height: 1.25rem;
  transition: transform 0.2s ease;
  flex-shrink: 0;
  margin-left: 0.5rem;
  color: var(--text-color);
  opacity: 0.7;
}

.chevron.open {
  transform: rotate(180deg);
}

.vow-select.disabled .selected {
  opacity: 0.5;
  cursor: not-allowed;
}

.vow-select.disabled .chevron {
  display: none;
}
</style>
