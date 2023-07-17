<template>
  <div>
    Album name {{ $route.params.id }}
    <div>Edit button</div>
    <div>Expiry Date</div>
    <div>Filter</div>
    <div>
      List all photos
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, type PropType } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();

const destinationId = computed(() => {
  const id = route.params.id;
  console.log(id)
  return id;
});

// const albumName = computed(() => {
//   return albums.value.filter((album) => {
//     return album.name.toLowerCase().includes(filter.value.toLowerCase());
//   });
// });
</script>
