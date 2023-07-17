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

          <div v-for="(album, i) in albums" :key="i">
            <div class="w-36 h-46 cursor-pointer">
              <RouterLink :to="{ name: 'Album', params: { id: album.id } }">
                <div class="flex relative w-100 h-36 rounded border border-slate-600 cursor-pointer">
                  Cover Photo
                  <font-awesome-icon icon="fa-solid fa-x"
                    class="absolute top-1 right-1 text-slate-400"
                    @click="deleteAlbum(album)"
                  />
                </div>
                <div class="pl-1 text-md truncate text-white">
                  {{ album.name }}
                </div>
                <div class="pl-1 text-xs text-slate-400">
                  Expire: {{ album.expiry_date }}
                </div>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </div>

    <AlbumCreate v-if="isCreatingAlbum"
      :albums="albums"
      @closeCreateAlbum="isCreatingAlbum = false"
      class="absolute top-[-500px] left-0 w-full z-10"
    >
    </AlbumCreate>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, type PropType } from 'vue';
import { RouterLink } from 'vue-router';
import axios from 'axios';

import AlbumCreate from '../components/AlbumCreate.vue';

interface Album {
  id: number,
  name: string,
  expiry_date: Date
}

let albums = ref<Album[]>([]);

onMounted(async () => {
  await axios
    .get('http://localhost:3000/albums')
    .then((response) => {
      albums.value = response.data;
    }).catch((error) => {
      console.log(error);
    })
});

const isCreatingAlbum = ref(false);

const deleteAlbum = async(album: Album) => {
  if (confirm(`Delete album "${album.name}"?`) === false) {
    return;
  }
  await axios
    .delete('http://localhost:3000/albums/' + album.id)
    .then((response) => {
      console.log(response);
      // find the album that is changed
      // update the album in the frontend
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
