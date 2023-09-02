<template>
  <div class="relative container-no-nav-bar">
    <div class="container-full-flex items-center">
      <AdvancedImage v-if="photo" :cldImg="getCloudinaryImage(photo.image)"
        place-holder="predominant-color"
        class="object-contain"
      />
    </div>
    <div class="container-layer container-full-flex items-center">
      <div class="w-full flex justify-between">
        <font-awesome-icon icon="fa-solid fa-caret-right" flip="horizontal"
        class="btn-navigate-photo ml-6"
        />
        <font-awesome-icon icon="fa-solid fa-caret-right"
        class="btn-navigate-photo mr-6"
        />
      </div>
    </div>
    <div class="container-layer container-full-flex items-end">
      <div class="flex w-full justify-center">
        <div class="btn-review" :class="{ 'btn-selected': reviewComputed === 0 }">
          <font-awesome-icon icon="fa-solid fa-xmark"
            v-model="review"
            @click="reviewPhoto(0)"
          />
        </div>
        <div class="btn-review" :class="{ 'btn-selected': reviewComputed === 2 }">
          <font-awesome-icon icon="fa-solid fa-question"
            v-model="review"
            @click="reviewPhoto(2)"
          />
        </div>
        <div class="btn-review" :class="{ 'btn-selected': reviewComputed === 1 }">
          <font-awesome-icon icon="fa-solid fa-check"
            v-model="review"
            @click="reviewPhoto(1)"
          />
        </div>
      </div>
    </div>
    <!-- <div>
        <button>Delete</button>
        <button>Zoom in</button>
        <button>Zoom out</button>
        Back to album
      </div> -->
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
  name: string,
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

// Review
const review = ref(null as number | null);
const reviewComputed = computed(() => {
  return review.value;
});
const reviewPhoto = (value: number) => {
  console.log('review before click: ', review.value)
  review.value = value;
}
</script>

<style scoped>
@import '../assets/main.css';

/* Navigation */
.btn-navigate-photo {
  font-size: 40px;
  cursor: pointer;
}

/* Button */
.btn-review {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 5px;
  width: 5rem;
  height: 5rem;
  border-radius: 50%;
  font-size: 40px;
  background-color: transparent;
  cursor: pointer;
}
.btn-review:hover {
  background-color: rgb(203 213 225);
  color: rgb(31 41 55);
}

.btn-selected {
  background-color: rgb(71 85 105 / 50%);
}

/* Container */
.container-layer {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 10;
}

.container-full-flex {
  display: flex;
  justify-content: center;
  width: 100%;
  height: 100%;
}
</style>

# Todo tomorrow: add file name to Photo model. we need it to display the file name in the Photo view.
