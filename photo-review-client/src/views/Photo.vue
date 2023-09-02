<template>
  <div>
    <div class="w-full h-[500px]">
      <AdvancedImage v-if="photo" :cldImg="getCloudinaryImage(photo.image)"
        place-holder="predominant-color"
      />
    </div>
    <div class="flex justify-center border border-1">
      <!-- <div>
        <button>Delete</button>
        <button>Zoom in</button>
        <button>Zoom out</button>
        Move to next previous photo
        Back to album
      </div> -->
      <div class="flex justify-center">
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
</style>

# Todo tomorrow: add file name to Photo model. we need it to display the file name in the Photo view.
