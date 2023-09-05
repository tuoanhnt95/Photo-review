<template>
  <div class="relative container-no-nav-bar">
    <div class="container-full-flex items-start">
      <AdvancedImage v-if="photo" :cldImg="getCloudinaryImage(photo.image)"
        place-holder="predominant-color"
        class="object-contain"
        @click="navigatePhoto(-1)"
      />
    </div>

    <div class="container-layer w-full h-full grid grid-rows-3">
      <div class="row-start-1">
        <div class="ml-5 mt-5 p-2 w-8 cursor-pointer">
          <RouterLink :to="{ name: 'Album', params: { id: photo?.album_id } }"
            class="text-slate-400"
          >
            <font-awesome-icon icon="fa-solid fa-arrow-left"
              class="text-xl opacity-30 hover:opacity-100"
            />
          </RouterLink>
        </div>
      </div>

      <div class="row-start-2 self-center w-full flex justify-between">
        <font-awesome-icon icon="fa-solid fa-caret-right" flip="horizontal"
          class="btn-navigate-photo ml-6 cursor-pointer"
          @click="navigatePhoto(-1)"
        />
        <font-awesome-icon icon="fa-solid fa-caret-right"
          class="btn-navigate-photo mr-6 cursor-pointer"
          @click="navigatePhoto(1)"
        />
      </div>

      <div class="row-start-3 self-end flex w-full justify-center">
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
      </div> -->
  </div>
</template>

<script setup lang="ts">
import { onBeforeMount, ref, computed } from 'vue';
import { useRoute } from 'vue-router';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { byAngle } from '@cloudinary/url-gen/actions/rotate';
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
  return cld.image(`photo_review/${publicId}`).rotate(byAngle(-90));
}

// Review
const review = ref(-1);
const reviewComputed = computed(() => {
  return review.value;
});

onBeforeMount(async() => {
  await axios
    .get(`http://localhost:3000/photos/${photoId.value}/get_review`)
    .then((response) => {
      if (response.data && parseInt(response.data) !== -1) {
        review.value = parseInt(response.data);
      }
    })
    .catch((error) => {
      console.log(error);
    });
});

function reviewPhoto (value: number) {
  console.log('review before click: ', review.value)
  if (value !== -1) {
    review.value = value;
  }
  console.log('review after click: ', review.value)
}

function saveReview () {
  if (review.value !== -1) {
    axios
      .put(`http://localhost:3000/photos/${photoId.value}/photo_user_reviews`, {
        review_value: review.value
      })
      .then((response) => {
        console.log('review after navigate: ', review.value)
      })
      .catch((error) => {
        console.log(error);
      });
  }
}

// navigate
function navigatePhoto (value: number) {
  // save review if review change
  console.log('review before navigate: ', review.value)
  saveReview();
  // move back or forth photo
  // console.log('navigate before click: ', photoId.value)
  // photoId.value += value;
  // console.log('navigate after click: ', photoId.value)
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
}

.container-full-flex {
  display: flex;
  justify-content: center;
  width: 100%;
  height: 100%;
}
</style>
