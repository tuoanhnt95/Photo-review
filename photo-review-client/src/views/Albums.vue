<template>
  <div>
    <div :class="{'opacity-25': isCreatingAlbum}">
      <div class="label-text ml-8 mt-4">
        Albums
      </div>

      <div class="flex w-100">
        <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-6 mx-auto mb-6 z-0">
          <div class="w-36 h-44" @click="isCreatingAlbum = true">
            <div class="flex w-100 h-36 rounded border border-slate-600 cursor-pointer">
              <font-awesome-icon icon="fa-solid fa-plus" class="m-auto text-violet-600"/>
            </div>
            <div class="pt-1 text-xs text-slate-400">
              New album
            </div>
          </div>

          <div v-for="(album, i) in albums" :key="album.id">
            <div class="relative w-36 h-46 cursor-pointer">
              <RouterLink :to="{ name: 'Album', params: { id: album.id } }">
                <div class="photo-container flex relative h-36 rounded">
                  <AdvancedImage v-if="album.cover.length > 0" :cldImg="getCloudinaryImage(album.cover)"
                    place-holder="predominant-color"
                    class="object-cover"
                  />
                </div>
                <div class="pl-1 text-md truncate text-white">
                  {{ album.name }}
                </div>
                <div class="pl-1 text-xs text-slate-400">
                  Expire: {{ album.expiry_date }}
                </div>
              </RouterLink>
              <font-awesome-icon icon="fa-solid fa-x"
                class="absolute top-1 right-1 z-50 text-slate-400"
                @click="deleteAlbum(album)"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <AlbumCreate v-if="isCreatingAlbum"
      :albums="albums"
      @closeCreateAlbum="isCreatingAlbum = false"
      class="absolute top-[-200px] left-0 w-full z-10"
    >
    </AlbumCreate>
  </div>
</template>

<script setup lang="ts">
import { onBeforeMount, ref } from 'vue';
import { RouterLink } from 'vue-router';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { AdvancedImage } from '@cloudinary/vue';

import AlbumCreate from '../components/AlbumCreate.vue';

interface Album {
  id: number,
  name: string,
  expiry_date: Date,
  cover: string
}

let albums = ref<Album[]>([]);
onBeforeMount(async () => {
  await axios
    .get('http://localhost:3000/albums')
    .then((response) => {
      console.log('all albums', response.data)
      albums.value = response.data.reverse();
    }).catch((error) => {
      console.log(error);
    })
});

const cld = new Cloudinary({
  cloud: {
    cloudName: 'djnvimner',
  }
});
const getCloudinaryImage = (publicId: String) => {
  return cld.image(`photo_review/${publicId}`);
}

const isCreatingAlbum = ref(false);

const deleteAlbum = async(album: Album) => {
  if (confirm(`Delete album "${album.name}"?`) === false) {
    return;
  }
  await axios
    .delete('http://localhost:3000/albums/' + album.id)
    .then((response) => {
      console.log(response);
      const index = albums.value.findIndex((alb: Album) => alb.id === album.id);
      albums.value.splice(index, 1);
    }).catch((error) => {
      console.log(error);
    })
}
</script>

<style scoped>
@import '../assets/main.css'
</style>
