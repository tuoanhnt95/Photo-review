<template>
  <div class="relative px-6 pt-16 pb-8 bg-white dark:bg-slate-800 border rounded">
    <div class="mb-2 text-lg">
      Upload photos
    </div>

    <div class="flex place-content-between w-full mb-6">
      <div>Upload size:</div>

      <select v-model="photoUploadOption" class="text-slate-800">
        <option value="1">1080x720</option>
        <option value="2">1920x1080</option>
        <option value="3">1920x1350</option>
        <option value="4">2100x1600</option>
        <option value="5">2400x1600</option>
      </select>
    </div>

    <div class="flex justify-center mb-2">
      <input type="file" multiple @change="onChangeUploadPhoto($event)">
    </div>
DISABLE UPLOAD BUTTON IF NO FILE SELECTED

    <div>
      <button @click="uploadPhoto" class="w-full mt-4 py-3 bg-violet-600 text-slate-200 rounded text-xl font-bold cursor-pointer">
        Upload
      </button>
    </div>

    <font-awesome-icon icon="fa-solid fa-x"
      class="absolute top-4 right-4 text-slate-400"
      @click="closeUploadPhoto()"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, type PropType, computed } from 'vue';
import axios from 'axios';
interface Photo {
  album_id: number,
  uploadOption: number
}

interface Album {
  id: number,
  name: string,
  expiry_date: Date
}

// t.decimal "size"
//     t.string "dimension"
//     t.bigint "album_id", null: false
//     t.datetime "created_at", null: false
//     t.datetime "updated_at", null: false
//     t.index ["album_id"], name: "index_photos_on_album_id"

const props = defineProps({
  albumId: {
    type: Number as PropType<number>,
    required: true
  }
  // album: {
  //   type: Object as PropType<Album>,
  //   required: true
  // }
})

const $emit = defineEmits(['uploaded-new-photo', 'close-upload-photo']);

const photoUploadOption = ref(1);
// const photoFiles = computed<HTMLInputElement | null>(() => {
//   return inputFiles.value;
// });

const inputFiles = ref([]);
const onChangeUploadPhoto = (event: any) => {
  inputFiles.value = event.target.files;
  console.log(inputFiles.value)
}

const uploadPhoto = async() => {
  const filesData = new FormData();
  filesData.append('album_id', props.albumId.toString());
  filesData.append('upload_option', photoUploadOption.value.toString());
  for (let i = 0; i < inputFiles.value.length; i++) {
    filesData.append('files[]', inputFiles.value[i]);
  }
  await axios
    .post(`http://localhost:3000/albums/${props.albumId}/photos`,
      filesData,
      {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
    ).then((response) => {
      $emit('close-upload-photo');
      $emit('uploaded-new-photo', response.data);
      }
    ).catch((error) => {
      console.log(error);
    });
}

const closeUploadPhoto = () => {
  inputFiles.value = [];
  // photoFiles.value = [];
  photoUploadOption.value = 1;

  $emit('close-upload-photo');
}
</script>
