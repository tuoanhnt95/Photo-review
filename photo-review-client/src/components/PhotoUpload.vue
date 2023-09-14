<template>
  <div class="relative px-6 pt-10 pb-8 bg-white dark:bg-slate-800 border rounded">
    <div class="mb-2 text-lg">
      Upload photos
    </div>

<!-- Upload file -->
    <div class="flex justify-center mb-3">
      <input type="file" multiple @change="onChangeUploadPhoto($event)">
    </div>

    <div class="flex place-content-between w-full">
      <div>Upload size:</div>
<!-- Upload quality option -->
      <select v-model="photoUploadOption" class="text-slate-800">
        <option value="1">1080x720</option>
        <option value="2">1920x1080</option>
        <option value="3">1920x1350</option>
        <option value="4">2100x1600</option>
        <option value="5">2400x1600</option>
      </select>
    </div>

    <div>
      <button @click="uploadPhoto"
        class="w-full mt-4 py-3 text-slate-200 bg-violet-600 rounded text-xl font-bold"
        :class="[ inputFiles.length === 0 ? 'opacity-30 cursor-not-allowed' : 'cursor-pointer']"
      >
        Upload
      </button>
    </div>

<!-- Upload progress -->
    <div class="mt-2">
      <div class="flex justify-center bg-gray-200 text-slate-600 cursor-pointer" @click="toggleUploadProgress">
        <font-awesome-icon icon="fa-solid fa-grip-lines"/>
      </div>
      <div v-if="isExpanded" class="border w-full max-h-40 overflow-auto">
        <div v-for="upload in uploadProgress" :key="upload.name" class="px-2">
          <div class="flex justify-between mb-1">
            <div>{{ upload.name }}</div>
            <div>
              <font-awesome-icon icon="fa-solid fa-x"
                class="text-slate-400 cursor-pointer"
                @click="cancelUpload()"
              />
            </div>
          </div>
          <div class="mb-4 h-1 bg-gray-200">
            <div class="h-1 bg-violet-400" :style="`width: ${ upload.progress }%`"></div>
          </div>
        </div>
      </div>
    </div>
{{  check + ' & ' + filesInProgress.map(x => x.name) }}
<!-- Close Upload menu -->
    <font-awesome-icon icon="fa-solid fa-x"
      class="absolute top-4 right-4 text-slate-400"
      @click="closeUploadPhoto()"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, type PropType, computed, watch } from 'vue';
import axios from 'axios';

// create a model Upload in database
// every file that gets uploaded or sent from the front end will be stored in the Upload table with an id, and completion status %
// file name will be stored in the Upload table
// once done, the result will be sent back to the front end with the file name and the completion status (using file name to identify the file)
// once the upload is complete, the file will be moved to the Photo table with the album_id and the file path. Delete the completed upload from the Upload table
// while uploading, make a call every second to the backend to get the completion status of the upload
interface Photo {
  album_id: number,
  uploadOption: number
}

interface Album {
  id: number,
  name: string,
  expiry_date: Date
}

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
const inputFiles = ref([]);
const onChangeUploadPhoto = (event: any) => {
  inputFiles.value = event.target.files;
}

const uploadPhoto = async() => {
  const filesData = new FormData();
  filesData.append('album_id', props.albumId.toString());
  filesData.append('upload_option', photoUploadOption.value.toString());
  for (let i = 0; i < inputFiles.value.length; i++) {
    filesData.append('files[]', inputFiles.value[i]);
  }
  getUploadProgress()
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

const isExpanded = ref(true)
function toggleUploadProgress () {
  isExpanded.value = !isExpanded.value;
}

function cancelUpload () {
  inputFiles.value = [];
}

const closeUploadPhoto = () => {
  inputFiles.value = [];
  // photoFiles.value = [];
  photoUploadOption.value = 1;

  $emit('close-upload-photo');
}

// upload progress
interface Upload {
  name: string,
  progress: number
}

const inputFilesComputed = computed(() => {
  return [...inputFiles.value]
})

const uploadProgress = ref([] as Upload[]);
watch(inputFilesComputed, () => {
  uploadProgress.value = inputFilesComputed.value.map((file: File) => ({name: file.name, progress: 0}))
});

const check = computed(() => {
  console.log('1', inputFilesComputed.value)
  console.log('2', uploadProgress.value)
  return uploadProgress.value
})

// any file that is not completed
const filesInProgress = computed(() => {
  console.log('3', uploadProgress.value.filter((upload: Upload) => upload.progress < 100))
  return uploadProgress.value.filter((upload: Upload) => upload.progress < 100)
})

function getUploadProgress () {
  console.log('start')
  const getProgressRepeatedly = setInterval(getProgress, 1000) ;
    // call backend to get upload progress
    // with this album id, get the upload progress of items that are not completed
    // album id, file name. If there are multiple files with the same name, get the one not deleted and the last one
  if (filesInProgress.value.length === 0) {
    console.log('stop')
    clearInterval(getProgressRepeatedly)
  }
}

// write two functions, one to call backend at interval of 1 second
// another to clear interval when upload is complete
async function getProgress () {
  await axios
    .get(`http://localhost:3000/albums/${props.albumId}/upload_progress`)
    .then((response) => {
      console.log('234', response.data)
      // update uploadProgress for any file that is not completed
      response.data.forEach((element: Upload) => {
        const index = uploadProgress.value.findIndex((upload: Upload) => upload.name === element.name)
        uploadProgress.value[index].progress = element.progress
      });
    })
    .catch((error) => {
      console.log(error);
    });
  // inputFiles.value.map((file: File) => ({name: file.name, progress: Math.floor(Math.random() * 100)}))
    // console.log('2', uploadProgress.value)
}
</script>
