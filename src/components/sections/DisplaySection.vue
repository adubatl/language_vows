<template>
  <SidebarSection :icon="DisplayIcon" title="Display">
    <button class="test-button" @click="$emit('missy-moves')">{{ displayText }}</button>
  </SidebarSection>
</template>

<script setup lang="ts">
import { ComputerDesktopIcon as DisplayIcon } from '@heroicons/vue/24/outline'
import SidebarSection from '../SidebarSection.vue'

defineProps<{
  displayText: string
}>()

defineEmits(['missy-moves'])
</script>
