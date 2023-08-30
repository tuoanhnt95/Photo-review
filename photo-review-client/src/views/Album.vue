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

    <div class="flex justify-between ml-3 mr-8">
      <div class="flex">
        <font-awesome-icon icon="fa-solid fa-calendar-days" class="mr-2 self-center"/>
        <div v-if="!isEditing" class="text-slate-400">
          {{ formatDate(album.expiry_date) }}
        </div>
        <div v-else>
          <input type="date" class="text-black" v-model="albumExpiryDate">
        </div>
      </div>
      <div>Filter</div>
    </div>

    <div class="grid grid-cols-5 gap-0.5 w-full mt-4">
      <div @click="isUploadingPhoto = true" class="photo-container flex border border-slate-600 cursor-pointer">
        <font-awesome-icon icon="fa-solid fa-plus" class="m-auto text-violet-600"/>
      </div>
      <div v-for="(photo, i) in photos" :key="i"
        class="photo-container flex border border-slate-600 cursor-pointer"
      >
        <AdvancedImage :cldImg="getCloudinaryImage(photo)"/>
        <!-- <img :src="photo" class="object-cover w-full h-full"> -->
      </div>
    </div>

    <PhotoUpload v-if="isUploadingPhoto"
      :albumId="album.id"
      class="absolute w-full z-10"
      @uploaded-new-photo="reloadAlbum"
      @close-upload-photo="isUploadingPhoto = false"
    >
    </PhotoUpload>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { useRoute } from 'vue-router';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { AdvancedImage } from '@cloudinary/vue';
import PhotoUpload from '../components/PhotoUpload.vue';

const route = useRoute();
const cld = new Cloudinary({
  cloud: {
    cloudName: 'djnvimner',
  },
});

onMounted(async() => {
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

interface Album {
  id: number,
  name: string,
  expiry_date: Date
}

interface Photo {
  id: number,
  image: string,
  album_id: number,
  created_at: Date,
  updated_at: Date
}

const getCloudinaryImage = (photo: Photo) => {
  return cld.image(`photo_review/${photo.image}`);
}

const album = ref<Album>({
  id: 0,
  name: '',
  expiry_date: new Date()
});

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

const formatDate = (date: Date) => {
  date = new Date(date);
  return date.toISOString().split('T')[0];
}

const photos = computed (() => {
  return photoData.value
});

const photoData = ref([]);
onMounted(async() => {
  await axios
    .get(`http://localhost:3000/albums/${albumId.value}/photos`)
    .then((response) => {
      photoData.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
});

const reloadAlbum = async() => {
  await axios
    .get(`http://localhost:3000/albums/${albumId.value}/photos`)
    .then((response) => {
      photoData.value = response.data;
    })
    .catch((error) => {
      console.log(error);
    });
}
</script>

<style scoped>
@import '../assets/main.css';

.photo-container {
  aspect-ratio : 1 / 1;
  width: 100%;
}
</style>
