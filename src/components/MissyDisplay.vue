<script setup lang="ts">
import { Position } from '@/constants/missy'

defineProps<{
  rotation: number
  position: Position
}>()
</script>

<template>
  <div class="missy-container">
    <img
      alt="Vue missy"
      class="missy"
      data-test="missy-image"
      src="@/assets/image.webp"
      :style="{
        transform: `
          translateX(${position === Position.LEFT ? '-100%' : position === Position.RIGHT ? '100%' : '0'})
          rotateX(${rotation}deg)
        `,
        borderColor: 'var(--accent-color, var(--icon-color))',
      }"
    />
  </div>
</template>

<style scoped>
.missy-container {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 25%;
  padding: var(--spacing-lg);
  overflow: hidden;
  position: relative;
}

.missy {
  max-width: 200px;
  max-height: 200px;
  width: auto;
  height: auto;
  transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  transform-style: preserve-3d;
  backface-visibility: visible;
  border-radius: 50%;
  border: 3px solid var(--accent-color);
  object-fit: cover;
  aspect-ratio: 1;
}
</style>
