<template>
  <NavigationBar class="fixed bottom-0 left-0 z-50"></NavigationBar>
  <RouterView class="absolute left-0 top-0 w-full h-full"></RouterView>
</template>

<script setup lang="ts">
import NavigationBar from './components/NavigationBar.vue'
</script>

<style scoped>
</style>
