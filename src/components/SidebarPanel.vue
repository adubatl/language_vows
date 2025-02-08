<script setup lang="ts">
defineEmits(['runTest'])
</script>

<template>
  <div class="left-panel">
    <div class="sidebar-header">
      <span class="emoji">🙏</span>
      <h1>Language Vows</h1>
    </div>

    <div class="sidebar-section">
      <h2>Display</h2>
      <button class="test-button" @click="$emit('runTest')">Run Test</button>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Create</h2>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Read</h2>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Update</h2>
    </div>

    <hr class="section-divider" />

    <div class="sidebar-section">
      <h2>Delete</h2>
    </div>
  </div>
</template>

<style scoped>
.sidebar-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-xl);
}

.sidebar-header .emoji {
  font-size: 1.5rem;
}

.sidebar-header h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--text-color);
}

.sidebar-section {
  margin: var(--spacing-lg) 0;
}

.sidebar-section h2 {
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #666;
  margin: 0 0 var(--spacing-md) 0;
}

.section-divider {
  border: none;
  border-top: 1px solid var(--border-color);
  margin: var(--spacing-md) 0;
}

.test-button {
  width: 100%;
  padding: var(--spacing-md);
  background-color: var(--button-bg);
  color: var(--text-color);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color 0.2s ease;
  margin-top: var(--spacing-sm);
}

.test-button:hover {
  background-color: var(--button-hover);
}
</style>
