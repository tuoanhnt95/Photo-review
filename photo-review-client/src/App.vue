<template>
  <RouterView></RouterView>
  <NavigationBar class="fixed bottom-0 left-0 z-50"></NavigationBar>
</template>

<script setup lang="ts">
import NavigationBar from './components/NavigationBar.vue'
</script>

<style>
@import './assets/main.css';
</style>
