<template>
  <NavigationBar class="fixed bottom-0 left-0 z-50"></NavigationBar>
  <RouterView></RouterView>

  <!-- @closeCreateAlbum="creatingAlbum = false" @addNewAlbum="addNewAlbum" -->
</template>

<script setup lang="ts">
import NavigationBar from './components/NavigationBar.vue'
</script>

<style scoped>
</style>
