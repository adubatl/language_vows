<script setup lang="ts"></script>

<template>
  <div class="logo-container">
    <img alt="Vue logo" class="logo" src="@/assets/logo.svg" />
  </div>
</template>

<style scoped>
.logo-container {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 50%;
  padding: var(--spacing-lg);
  overflow: hidden; /* Prevent any overflow */
  box-sizing: border-box; /* Add this to include padding in width calculation */
}

.logo {
  max-width: 200px;
  max-height: 200px;
  width: auto;
  height: auto;
}
</style>
