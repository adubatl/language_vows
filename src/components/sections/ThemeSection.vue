<template>
  <SidebarSection :icon="PaintBrushIcon" title="Theme">
    <div class="theme-name">{{ currentTheme.name }}</div>
    <button class="test-button" @click="generateNewTheme">Generate Random Theme</button>
    <button class="test-button" @click="resetTheme">Reset Theme</button>

    <div class="theme-preview">
      <div
        class="color-sample"
        :style="{
          backgroundColor: currentTheme.background,
          color: currentTheme.text,
          border: `1px solid ${currentTheme.text}`,
        }"
      >
        Background
      </div>
      <div
        class="color-sample"
        :style="{
          backgroundColor: currentTheme.text,
          color: currentTheme.background,
          border: `1px solid ${currentTheme.background}`,
        }"
      >
        Text
      </div>
    </div>
  </SidebarSection>
</template>

<script setup lang="ts">
import { useThemeStore } from '../../stores/theme'
import { storeToRefs } from 'pinia'
import { PaintBrushIcon } from '@heroicons/vue/24/outline'
import SidebarSection from './SidebarSection.vue'

const themeStore = useThemeStore()
const { currentTheme } = storeToRefs(themeStore)
const { generateNewTheme, resetTheme } = themeStore
</script>

<style scoped>
.theme-name {
  color: var(--icon-color);
  font-style: italic;
  margin-bottom: var(--spacing-md);
  font-size: 0.9rem;
}

.theme-preview {
  display: flex;
  gap: 0.5rem;
  margin-top: var(--spacing-md);
}

.color-sample {
  flex: 1;
  padding: 0.5rem;
  border-radius: 4px;
  text-align: center;
  font-size: 0.8rem;
  transition: all 0.3s ease;
}
</style>
