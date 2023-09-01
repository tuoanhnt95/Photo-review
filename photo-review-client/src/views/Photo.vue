<template>
  <div>
    <div class="w-full h-[500px]">
      <AdvancedImage v-if="photo" :cldImg="getCloudinaryImage(photo.image)"
        place-holder="predominant-color"
      />
    </div>
    <h1>Photo name</h1>
    <div>
      <div>
        <button>Delete</button>
        <button>Zoom in</button>
        <button>Zoom out</button>
        <button>No</button>
        <button>Maybe</button>
        <button>Yes</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onBeforeMount, ref, computed } from 'vue';
import { useRoute } from 'vue-router';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { AdvancedImage } from '@cloudinary/vue';

const route = useRoute();

interface Photo {
  id: number,
  image: string,
  album_id: number,
  created_at: Date,
  updated_at: Date
}

const photoId = computed(() => {
  const id = route.params.id;
  return typeof id === 'string' ? parseInt(id) : parseInt(id[0]);
});
const photo = ref<Photo>();
onBeforeMount(async() => {
  await axios
    .get(`http://localhost:3000/photos/${photoId.value}`)
    .then((response) => {
      photo.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
});

const cld = new Cloudinary({
  cloud: {
    cloudName: 'djnvimner',
  }
});
const getCloudinaryImage = (publicId: String) => {
  return cld.image(`photo_review/${publicId}`);
}
</script>

<style scoped></style>
