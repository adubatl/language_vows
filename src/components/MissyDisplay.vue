<script setup lang="ts">
defineProps<{
  rotation: number
  position: 'left' | 'center' | 'right'
}>()
</script>

<template>
  <div class="missy-container">
    <img
      alt="Vue missy"
      class="missy"
      src="@/assets/image.webp"
      :style="{
        transform: `
          translateX(${position === 'left' ? '-75%' : position === 'right' ? '75%' : '0'})
          rotateX(${rotation}deg)
        `,
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
}
</style>
