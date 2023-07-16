<template>
  <div class="bg-white dark:bg-slate-800 text-slate-900 dark:text-white">
    <div class="mb-2 text-xl font-bold text-violet-600">Albums</div>
    <div class="grid grid-cols-2 gap-3 md:grid-cols-4 lg:grid-cols-6 mb-6">
      <div class="w-36 h-44" @click="createAlbum()">
        <div class="flex w-100 h-36 rounded border border-slate-600 cursor-pointer">
          <font-awesome-icon icon="fa-solid fa-plus" class="m-auto text-violet-600"/>
        </div>
        <div class="pt-1 text-xs text-slate-400">
          New album
        </div>
      </div>
      <div v-for="(album, i) in albums" :key="i">
        <div v-if="!isEditing(album.id)"
          class="w-36 h-46 cursor-pointer"
          @dblclick.stop.prevent="editItem(album)"
        >
          <div class="flex relative w-100 h-36 rounded border border-slate-600 cursor-pointer">
            Cover Photo
            <font-awesome-icon icon="fa-solid fa-x"
              class="absolute top-1 right-1 text-slate-400"
              @click="deleteAlbum(album)"
            />
          </div>
          <div class="pl-1 text-md truncate">
            {{ album.name }}
          </div>
          <div class="pl-1 text-xs text-slate-400">
            Expire: {{ album.expiry_date }}
          </div>
        </div>
        <div v-else>
          <div>
            <input type="text" class="text-black" v-model="albumName">
          </div>
          <div>
            <input type="date" class="text-black" v-model="albumExpiryDate">
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="border border-white p-2">
    <div>Add new album</div>
    <div>
      <label for="album-name">Name</label>
      <input type="text" class="text-black" v-model="albumName">
    </div>
    <div>
      <label for="album-expiry-date">Expiry date</label>
      <input type="date" class="text-black" v-model="albumExpiryDate">
    </div>
    <div>
      <label for="invitee">Invitee</label>
    </div>
    <div>
      <button @click="saveEditAlbum()">Save Edit</button>
    </div>
    <div>
      <button @click="cancelEditAlbum()">Cancel Edit</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, type PropType } from 'vue';
import axios from 'axios';

interface Album {
  id: number,
  name: string,
  expiry_date: Date
}

let albums = ref<Album[]>([]);
let currentEditItem = ref<Album>({
  id: 0,
  name: '',
  expiry_date: new Date()
}); // empty object


onMounted(async () => {
  await axios
    .get('http://localhost:3000/albums')
    .then((response) => {
      albums.value = response.data;
    }).catch((error) => {
      console.log(error);
    })
});

const albumName = ref('');
const albumExpiryDate = ref('');
const createAlbum = async() => {
  await axios
    .post('http://localhost:3000/albums', {
      name: albumName.value,
      expiry_date: albumExpiryDate.value
    })
    .then((response) => {
      console.log(response);
      albums.value.push(response.data);
    }).catch((error) => {
      console.log(error);
    })
}

const editItem = (item: any) => {
  currentEditItem.value = item;
  albumName.value = item.name;
  albumExpiryDate.value = item.expiry_date;
}

const isEditing = (id: number) => {
  return currentEditItem.value.id === id;
}

const cancelEditAlbum = () => {
  currentEditItem.value = {
    id: 0,
    name: '',
    expiry_date: new Date()
  };
  albumName.value = '';
  albumExpiryDate.value = '';
}

const saveEditAlbum = async() => {
  await axios
    .patch('http://localhost:3000/albums/' + currentEditItem.value.id, {
      name: albumName.value,
      expiry_date: albumExpiryDate.value
    })
    .then((response) => {
      console.log(response);
      // find the album that is changed
      // update the album in the frontend
      const index = albums.value.findIndex((album: any) => album.id === currentEditItem.value.id);
      const album: any = albums.value[index];
      album.name = albumName.value
      album.expiry_date = albumExpiryDate.value
      cancelEditAlbum();
    }).catch((error) => {
      console.log(error);
    })
}

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
