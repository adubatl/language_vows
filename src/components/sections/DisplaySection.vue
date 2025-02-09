<template>
  <SidebarSection :icon="sectionIcon" title="Display">
    <button class="test-button" @click="$emit('missy-moves')">{{ displayText }}</button>
  </SidebarSection>
</template>

<script setup lang="ts">
import SidebarSection from './SidebarSection.vue'

const sectionIcon = 'material-symbols:desktop-windows-outline'

defineProps<{
  displayText: string
}>()

defineEmits(['missy-moves'])
</script>
