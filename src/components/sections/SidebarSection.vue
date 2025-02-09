<template>
  <div class="sidebar-section">
    <div class="section-header">
      <Icon :icon="icon" class="section-icon" />
      <h2>{{ title }}</h2>
    </div>
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
import { Icon } from '@iconify/vue'

defineProps<{
  icon: string
  title: string
}>()
</script>

<style scoped>
.section-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  margin-bottom: var(--spacing-sm);
}

.section-header h2 {
  margin: 0;
  line-height: 1;
  display: flex;
  align-items: center;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--accent-color);
  font-weight: 600;
}

.section-icon {
  width: 1.25rem;
  height: 1.25rem;
  color: var(--accent-color);
  flex-shrink: 0;
}
</style>
