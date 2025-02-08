<script setup lang="ts">
import { ref } from 'vue'
import SidebarPanel from './components/SidebarPanel.vue'
import CodeOutput from './components/CodeOutput.vue'
import LogoDisplay from './components/LogoDisplay.vue'

const outputText = ref('')

const runTest = () => {
  outputText.value = `Test run at: ${new Date().toISOString()}\nSample output here...`
}
</script>

<template>
  <div class="app-container">
    <SidebarPanel @run-test="runTest" />
    <div class="right-panel">
      <LogoDisplay />
      <CodeOutput :content="outputText" />
    </div>
  </div>
</template>

<style>
/* Global styles and CSS variables */
:root {
  --bg-color: #1a1a1a;
  --text-color: #e0e0e0;
  --button-bg: #2c2c2c;
  --button-hover: #3c3c3c;
  --border-color: #333;
  --code-bg: #2a2a2a;
  --sidebar-width: 25%;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
}

body {
  background-color: var(--bg-color);
  color: var(--text-color);
  margin: 0;
  padding: 0;
}

body * {
  box-sizing: border-box;
}

.app-container {
  display: flex;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

.left-panel {
  flex: 0 0 var(--sidebar-width);
  padding: var(--spacing-lg);
  border-right: 1px solid var(--border-color);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.right-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
</style>
