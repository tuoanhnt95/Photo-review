<template>
  <div>
    <div v-for="(album, i) in albums" :key="i" class="border m-2 p-2">
      <div v-if="!isEditing(album.id)"
        @dblclick.stop.prevent="editItem(album)"
      >
        <div>
          {{ album.name }}
        </div>
        <div>
          {{ album.expiry_date }}
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
      <div>
        <button @click="deleteAlbum(album)">Delete</button>
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
    <div class="bg-red-200 text-black">
      <button @click="createAlbum()">Create</button>
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
