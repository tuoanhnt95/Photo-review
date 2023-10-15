<template>
  <div>
    <div class="relative container-no-nav-bar">
      <!-- Photo -->
      <div class="container-full-flex items-start">
        <AdvancedImage v-if="props.photo" :cldImg="getCloudinaryImage(photo.image, photo.angle)"
          place-holder="predominant-color"
          class="object-contain w-full h-full"
        />
      </div>

      <!-- Buttons -->
      <div class="container-layer w-full h-full grid grid-rows-3">
        <!-- Back to Album -->
        <div class="row-start-1 flex justify-between">
          <div class="ml-5 btn-small" @click="backToAlbum">
            <font-awesome-icon icon="fa-solid fa-arrow-left" class="btn-small-icon"/>
          </div>
          <div class="mr-5 btn-small" @click="rotatePhoto">
            <font-awesome-icon icon="fa-solid fa-rotate-left" class="btn-small-icon"/>
          </div>
        </div>

        <!-- Navigate -->
        <div class="row-start-2 self-center w-full flex justify-between">
          <font-awesome-icon icon="fa-solid fa-caret-left"
            class="btn-navigate-photo ml-6"
            :class="[ isFirstPhoto ? 'opacity-0': 'cursor-pointer' ]"
            @click="navigatePhoto(-1)"
          />
          <font-awesome-icon icon="fa-solid fa-caret-right"
            class="btn-navigate-photo mr-6"
            :class="[ isLastPhoto ? 'opacity-0': 'cursor-pointer' ]"
            @click="navigatePhoto(1)"
          />
        </div>

        <!-- Review -->
        <div class="row-start-3 self-end flex w-full justify-center">
          <div v-for="opt in reviewDisplayOptions" :key="opt.value"
            class="btn-review" :class="{ 'btn-selected': reviewComputed === opt.value }"
          >
            <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`"
              v-model="photo.review_results"
              @click="reviewPhoto(opt.value)"
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
import { ref, computed, type PropType, watch } from 'vue';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { byAngle } from '@cloudinary/url-gen/actions/rotate';
import { AdvancedImage } from '@cloudinary/vue';

const emit = defineEmits(['reviewed-photo', 'close-review-photo', 'navigate-photo']);

interface Photo {
  id: number,
  name: string,
  image: string,
  angle: number,
  album_id: number,
  review_results: number | null,
  created_at: Date,
  updated_at: Date
}

const props = defineProps({
  photo: {
    type: Object as PropType<Photo>,
    required: true
  },
  photos: {
    type: Array as PropType<Photo[]>,
    required: true
  }
});
const photo = ref(props.photo);
const photos = ref(props.photos);

const cld = new Cloudinary({
  cloud: {
    cloudName: 'djnvimner',
  }
});
const getCloudinaryImage = (publicId: String, angle: number) => {
  return cld.image(`photo_review/${publicId}`).rotate(byAngle(angle));
}

// Review
const reviewComputed = computed(() => {
  return photo.value.review_results;
});

function reviewPhoto (value: number) {
  if (value !== -1) {
    photo.value.review_results = value;
    navigatePhoto(1);
  }
}

function saveReview () {
  if ((photo.value.review_results !== -1) ||
      (props.photo.angle !== photo.value.angle)) {
    axios
      .put(`http://localhost:3000/photos/${photo.value.id}/photo_user_reviews`, {
        review_value: photo.value.review_results,
        angle: photo.value.angle
      })
      .then(() => {
        rotateCounter.value = 0;
        return;
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

const isFirstPhoto = computed(() => {
  const index = photos.value.findIndex((pho: Photo) => pho.id === props.photo.id);
  return (index === 0);
});

const isLastPhoto = computed(() => {
  const index = photos.value.findIndex((pho: Photo) => pho.id === props.photo.id);
  return (index === photos.value.length - 1);
});

// back to album
function backToAlbum () {
  saveReview();
  emit('close-review-photo');
}

// rotate photo
const rotateCounter = ref(0);
let photoOriginalAngle = props.photo.angle;
function rotatePhoto () {
  if (rotateCounter.value === 3) {
    rotateCounter.value = 0;
    photo.value.angle = photoOriginalAngle;
  } else {
    rotateCounter.value++;
    photo.value.angle = photoOriginalAngle - (rotateCounter.value * 90);
    console.log('1', photo.value.angle)
  }
}

watch(() => props.photo, (newVal) => {
  photo.value = newVal;
  photoOriginalAngle = newVal.angle;
});

// display v-for
const reviewDisplayOptions = [
  { value: 0, icon: 'xmark' },
  { value: 2, icon: 'question' },
  { value: 1, icon: 'check' }
];
</script>

<style scoped>
@import '../assets/main.css';

/* Navigation */
.btn-navigate-photo {
  font-size: 40px;
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

.btn-small {
  margin-top: 1.25rem;
  padding: 0.5rem;
  width: fit-content;
  height: fit-content;
  color: rgb(148 163 184);
  cursor: pointer;
}

.btn-small-icon {
  font-size: 1.125rem;
  line-height: 1.75rem;
  opacity: 0.3;
}

.btn-small-icon:hover {
  opacity: 1;
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
