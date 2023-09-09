<template>
  <div>
    <div class="flex justify-between mx-8 mt-4">
      <div v-if="!isEditing" class="label-text">
        {{ album.name }}
      </div>
      <div v-else class="label-text">
        <input type="text" v-model="albumName" class="pl-2 rounded text-black" >
      </div>

      <div v-if="!isEditing" class="flex">
        <font-awesome-icon icon="fa-solid fa-pen"
          class="self-center text-slate-400"
          @click="startEditingAlbum"
        />
      </div>
      <div v-else class="flex space-x-6 self-center">
        <font-awesome-icon icon="fa-solid fa-floppy-disk"
          @click="saveEditAlbum()"
        />
        <font-awesome-icon icon="fa-solid fa-x"
          @click="cancelEditAlbum()"
        />
      </div>
    </div>
<!-- Filter -->
    <div class="flex justify-between w-full ml-3 mr-8">
      <div class="flex">
        <font-awesome-icon icon="fa-solid fa-calendar-days" class="mr-2 self-center"/>
        <div v-if="!isEditing" class="text-slate-400">
          {{ formatDate(album.expiry_date) }}
        </div>
        <div v-else>
          <input type="date" class="text-black" v-model="albumExpiryDate">
        </div>
      </div>
      <div class="flex border w-42 bg-slate-200 text-slate-600 rounded-sm">
        <div
          v-for="opt in filterReview"
          :key="opt.icon"
          class="btn-filter w-14 px-2 py-0.5"
          :class="{ 'btn-filter-selected': opt.selected }"
          @click="opt.selected = !opt.selected"
        >
          <div>
            <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`" />
          </div>
          <div>({{ numberOfPhotosWithReview(opt.value) }})</div>
        </div>
      </div>
    </div>

<!-- Photos -->
    <div class="grid grid-cols-5 gap-0.5 w-full mt-4">
      <div @click="isUploadingPhoto = true" class="photo-container flex">
        <font-awesome-icon icon="fa-solid fa-plus" class="m-auto text-violet-600"/>
      </div>
      <div v-for="(photo, i) in photos" :key="i" class="relative cursor-pointer">
        <RouterLink :to="{ name: 'Photo', params: { id: photo.id } }"
          class="photo-container flex justify-center"
        >
          <AdvancedImage :cldImg="getCloudinaryImage(photo.image)"
            :id="photo.image" class="object-cover"
            :class="getPhotoClass(photo)"
          />
        </RouterLink>
        <font-awesome-icon icon="fa-solid fa-x"
          class="absolute top-1 right-1 z-50 text-slate-400"
          @click="deletePhoto(photo.id)"
        />
      </div>
    </div>

    <PhotoUpload v-if="isUploadingPhoto"
      :albumId="album.id"
      class="absolute w-full z-10"
      @uploaded-new-photo="(photos) => addPhoto(photos)"
      @close-upload-photo="isUploadingPhoto = false"
    >
    </PhotoUpload>
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeMount, ref } from 'vue';
import { RouterLink } from 'vue-router';
import { useRoute } from 'vue-router';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { AdvancedImage } from '@cloudinary/vue';

import PhotoUpload from '../components/PhotoUpload.vue';

const route = useRoute();

interface Album {
  id: number,
  name: string,
  expiry_date: Date
}

interface Photo {
  id: number,
  image: string,
  album_id: number,
  review_results: number | null,
  created_at: Date,
  updated_at: Date
}

const album = ref<Album>({
  id: 0,
  name: '',
  expiry_date: new Date()
});
onBeforeMount(async() => {
  await axios
    .get(`http://localhost:3000/albums/${albumId.value}`)
    .then((response) => {
      album.value = response.data;
      // TODO: improve, not bug - fix album date format to be YYYY-MM-DD when reloading page
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

const albumId = computed(() => {
  const id = route.params.id;
  return typeof id === 'string' ? parseInt(id) : parseInt(id[0]);
});

const isUploadingPhoto = ref(false);
const isEditing = ref(false);
const albumName = ref('');
const albumExpiryDate = ref(new Date());

const startEditingAlbum = () => {
  isEditing.value = true;
  albumName.value = album.value.name;
  albumExpiryDate.value = album.value.expiry_date;
}

const cancelEditAlbum = () => {
  albumName.value = '';
  albumExpiryDate.value = new Date();
  isEditing.value = false;
}

const saveEditAlbum = async() => {
  await axios
    .patch('http://localhost:3000/albums/' + albumId.value, {
      name: albumName.value,
      expiry_date: albumExpiryDate.value
    })
    .then(() => {
      album.value.name = albumName.value;
      album.value.expiry_date = albumExpiryDate.value;
      cancelEditAlbum();
    }).catch((error) => {
      console.log(error);
    })
}

const deletePhoto = async (photoId: number) => {
  if (confirm('Delete photo?') === false) {
    return;
  }
  await axios
    .delete('http://localhost:3000/photos/' + photoId)
    .then(() => {
      removePhoto(photoId);
    }).catch((error) => {
      console.log(error);
    })
}
const removePhoto = (photoId: number) => {
  const index = photosData.value.findIndex((photo: Photo) => photo.id === photoId);
  photosData.value.splice(index, 1);
}
const addPhoto = (photos: [Photo]) => {
  photos.forEach(photo => {
    photosData.value.unshift(photo);
  });
}

const formatDate = (date: Date) => {
  date = new Date(date);
  return date.toISOString().split('T')[0];
}

const photos = computed (() => {
  return photosData.value
});

const photosData = ref([<Photo>{}]);
onBeforeMount(async() => {
  await axios
    .get(`http://localhost:3000/albums/${albumId.value}/photos`)
    .then((response) => {
      photosData.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
});

// filter
const filterMode = ref(1); // 1: blur, 2: hide
const filterModes = [
  { value: 1, name: 'blur' },
  { value: 2, name: 'hide' },
];
const filterReview = ref([
  { selected: false, value: 1, icon: 'check' },
  { selected: false, value: 2, icon: 'question' },
  { selected: false, value: 0, icon: 'xmark' },
  { selected: false, value: null, icon: 'exclamation' }
]); // Yes Maybe No
const filterIsSelected = computed(() => {
  return filterReview.value.some((x) => x.selected);
});

function numberOfPhotosWithReview(val: number | null) {
  return photosData.value.filter((x) => x.review_results === val).length;
}

// style
function getPhotoClass(photo: Photo) {
  let result = '';
  const filterOfPhoto = filterReview.value.find((x) => x.value === photo.review_results);
  if (!filterIsSelected.value) {
    return result;
  } else if (!filterOfPhoto || !filterOfPhoto.selected) {
    result += ' opacity-10 saturate-0'
  }
  return result
}
</script>

<style scoped>
@import '../assets/main.css';

.btn-filter {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 0.25rem;
  border-width: 1px;
  cursor: pointer;
}

.btn-filter-selected {
  background-color: white;
  color: var(--color-primary);
}
</style>
