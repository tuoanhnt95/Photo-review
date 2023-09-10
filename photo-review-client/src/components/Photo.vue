<template>
  <div>
    <div class="relative container-no-nav-bar">
      <!-- Photo -->
      <div class="container-full-flex items-start">
        <AdvancedImage v-if="props.photo" :cldImg="getCloudinaryImage(props.photo.image)"
          place-holder="predominant-color"
          class="object-contain"
        />
      </div>

      <!-- Buttons -->
      <div class="container-layer w-full h-full grid grid-rows-3">
        <!-- Back to Album -->
        <div class="row-start-1">
          <div class="ml-5 mt-5 p-2 w-8 cursor-pointer text-slate-400" @click="backToAlbum()">
            <font-awesome-icon icon="fa-solid fa-arrow-left"
              class="text-xl opacity-30 hover:opacity-100"
            />
          </div>
        </div>

        <!-- Navigate -->
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

        <!-- Review -->
        <div class="row-start-3 self-end flex w-full justify-center">
          <div class="btn-review" :class="{ 'btn-selected': reviewComputed === 0 }">
            <font-awesome-icon icon="fa-solid fa-xmark"
              v-model="photo.review_results"
              @click="reviewPhoto(0)"
            />
          </div>
          <div class="btn-review" :class="{ 'btn-selected': reviewComputed === 2 }">
            <font-awesome-icon icon="fa-solid fa-question"
              v-model="photo.review_results"
              @click="reviewPhoto(2)"
            />
          </div>
          <div class="btn-review" :class="{ 'btn-selected': reviewComputed === 1 }">
            <font-awesome-icon icon="fa-solid fa-check"
              v-model="photo.review_results"
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, type PropType } from 'vue';
// import { useRoute } from 'vue-router';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { byAngle } from '@cloudinary/url-gen/actions/rotate';
import { AdvancedImage } from '@cloudinary/vue';

// const route = useRoute();
const emit = defineEmits(['reviewed-photo', 'close-review-photo', 'navigate-photo']);

interface Photo {
  id: number,
  name: string,
  image: string,
  album_id: number,
  review_results: number | null,
  created_at: Date,
  updated_at: Date
}

//TODO: pass photoId instead of photo so can track obect prop, when the whole object change cannot track
// const photoId = computed(() => {
//   const id = route.params.id;
//   return typeof id === 'string' ? parseInt(id) : parseInt(id[0]);
// });

// onBeforeMount(async() => {
//   await axios
//     .get(`http://localhost:3000/photos/${photoId.value}`)
//     .then((response) => {
//       photo.value = response.data;
//     })
//     .catch((error) => {
//       console.log(error);
//     });
// });

const props = defineProps({
  photo: {
    type: Object as PropType<Photo>,
    required: true
  },
  // photoId: {
  //   type: Number,
  //   required: true
  // },

  photos: {
    type: Array as PropType<Photo[]>,
    required: true
  }
});
const photo = ref(props.photo);
// const photo = ref(props.photos.find((pho: Photo) => pho.id === props.photoId));
const photos = ref(props.photos);

const cld = new Cloudinary({
  cloud: {
    cloudName: 'djnvimner',
  }
});
const getCloudinaryImage = (publicId: String) => {
  return cld.image(`photo_review/${publicId}`).rotate(byAngle(-90));
}

// Review
const reviewComputed = computed(() => {
  return photo.value.review_results;
});

// onBeforeMount(async() => {
//   await axios
//     .get(`http://localhost:3000/photos/${photoId.value}/get_review`)
//     .then((response) => {
//       if (response.data && parseInt(response.data) !== -1) {
//         review.value = parseInt(response.data);
//       }
//     })
//     .catch((error) => {
//       console.log(error);
//     });
// });

function reviewPhoto (value: number) {
  if (value !== -1) {
    photo.value.review_results = value;
  }
}

function saveReview () {
  if (photo.value.review_results !== -1) {
    axios
      .put(`http://localhost:3000/photos/${photo.value.id}/photo_user_reviews`, {
        review_value: photo.value.review_results
      })
      .then((response) => {
        console.log('review after navigate: ', photo.value.review_results)
      })
      .catch((error) => {
        console.log(error);
      });
  }
}

// navigate
function navigatePhoto (value: number) {
  saveReview();

  // emit navigate
  const index = photos.value.findIndex((pho: Photo) => pho.id === props.photo.id);
  // if first photo and navigate left, end
  // if last photo and navigate right, end
  if ((index === 0 && value === -1) || (index === photos.value.length - 1 && value === 1)) {
    return;
  } else {
    const photoToNavigate = photos.value[index + value];
    emit('navigate-photo', photoToNavigate.id);
  }
}

// back to album
function backToAlbum () {
  saveReview();
  emit('close-review-photo');
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
