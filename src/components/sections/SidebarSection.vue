<template>
  <div class="sidebar-section">
    <div class="section-header">
      <component :is="icon" class="section-icon" />
      <h2>{{ title }}</h2>
    </div>
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
import type { Component } from 'vue'

defineProps<{
  icon: Component
  title: string
}>()
</script>

<style scoped>
.section-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  margin-bottom: var(--spacing-md);
}

.section-header h2 {
  margin: 0;
  line-height: 1;
  display: flex;
  align-items: center;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--icon-color);
  font-weight: 600;
}

.section-icon {
  width: 1.25rem;
  height: 1.25rem;
  color: var(--icon-color);
  flex-shrink: 0;
}
</style>
