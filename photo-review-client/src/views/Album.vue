<template>
  <div class="absolute top-0 left-0 w-full h-full">
    <div class="relative w-full"
      :class="{ 'opacity-10 saturate-0': isUploadingPhoto || isShowingPhoto }"
    >
      <div class="flex justify-between mx-8 mt-4">
        <div v-if="!isEditing" class="label-text">
          {{ album.name }}
        </div>
        <div v-else class="label-text">
          <input type="text"
            v-model="albumName"
            class="pl-2 rounded text-black"
          />
        </div>

        <div v-if="!isEditing" class="flex">
          <font-awesome-icon icon="fa-solid fa-pen"
            class="self-center text-slate-400"
            @click.prevent="startEditingAlbum"
          />
        </div>
        <div v-else class="flex space-x-6 self-center">
          <font-awesome-icon icon="fa-solid fa-floppy-disk"
            @click.prevent="saveEditAlbum()"
          />
          <font-awesome-icon icon="fa-solid fa-x"
            @click.prevent="cancelEditAlbum()"
          />
        </div>
      </div>
      <!-- Filter -->
      <div class="w-100 h-8 ml-3 mt-3">
        <div v-if="selectedPhotoIds.length === 0"
          class="flex justify-between items-center h-full"
        >
          <div class="flex items-center">
            <font-awesome-icon icon="fa-solid fa-calendar-days"
              class="mr-2 self-center"
            />
            <div v-if="!isEditing" class="text-slate-400">
              {{ formatDate(album.expiry_date) }}
            </div>
            <div v-else>
              <input type="date" class="text-black" v-model="albumExpiryDate" />
            </div>
          </div>
          <div class="flex w-42 bg-slate-200 border divide-x divide-slate-400 text-slate-600 rounded-sm">
            <div v-for="opt in filterReview" :key="opt.icon">
              <div class="btn-filter w-14 px-2 py-0.5"
                :class="{ 'btn-filter-selected': opt.selected }"
                @click="opt.selected = !opt.selected"
              >
                <font-awesome-icon :icon="`fa-solid fa-${opt.icon}`" />
                <div>({{ numberOfPhotosWithReview(opt.value) }})</div>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="flex justify-between items-center h-full mr-3">
          <div class="flex justify-between items-center h-full w-20">
            <font-awesome-icon icon="fa-solid fa-xmark"
              class="p-2 cursor-pointer"
              @click.prevent="cancelSelectPhotos"
            />
            <div>{{ selectedPhotoIds.length }}</div>
          </div>
          <div class="flex justify-between w-20">
            <font-awesome-icon icon="fa-solid fa-share-from-square" />
            <font-awesome-icon icon="fa-regular fa-trash-can"
              class="mr-2"
              @click.prevent="deletePhotos"
            />
          </div>
        </div>
      </div>
      <!-- Photos -->
      <div class="grid grid-cols-5 gap-0.5 w-full mt-4">
        <div class="photo-container flex"
          @click.prevent="isUploadingPhoto = true"
        >
          <font-awesome-icon
            icon="fa-solid fa-plus"
            class="m-auto text-violet-600"
          />
        </div>
        <div v-for="(photo, i) in photos" :key="i"
          class="relative cursor-pointer"
        >
          <div class="photo-container flex justify-center cursor-pointer"
            @click.prevent="showPhoto(photo.id)"
          >
            <AdvancedImage :id="photo.image"
              :cldImg="getCloudinaryImage(photo.image, photo.angle)"
              class="object-cover"
              :class="getPhotoClass(photo)"
            />
          </div>
          <!-- </RouterLink> -->
          <font-awesome-icon icon="fa-solid fa-circle-check"
            class="icon-circle-check"
            :class="{ 'icon-circle-check-selected': selectedPhotoIds.includes(photo.id) }"
            @click.prevent="toggleSelectPhoto(photo.id)"
          />
        </div>
      </div>
    </div>

    <PhotoUpload
      v-if="isUploadingPhoto"
      :album="album"
      class="absolute w-full z-10"
      @uploaded-new-photo="(photos) => addPhoto(photos)"
      @close-upload-photo="isUploadingPhoto = false"
    />

    <Photo
      v-if="isShowingPhoto && photoShowing"
      :photo="photoShowing"
      :photos="photos"
      class="absolute top-0 left-0 w-full z-50"
      @reviewed-photo="(photo: Photo) => updatePhoto(photo)"
      @navigate-photo="(photoId: Number) => showPhoto(photoId)"
      @close-review-photo="closeReviewPhoto"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeMount, ref } from 'vue';
// import { RouterLink } from 'vue-router';
import { useRoute } from 'vue-router';
import axios from 'axios';
import { Cloudinary } from '@cloudinary/url-gen';
import { AdvancedImage } from '@cloudinary/vue';
import { byAngle } from '@cloudinary/url-gen/actions/rotate';
// components
import Photo from '../components/Photo.vue';
import PhotoUpload from '../components/PhotoUpload.vue';

const route = useRoute();

interface Album {
  id: number;
  name: string;
  last_upload_batch: number;
  expiry_date: Date;
}

interface Photo {
  id: number;
  name: string;
  image: string;
  angle: number;
  album_id: number;
  review_results: number | null;
  created_at: Date;
  updated_at: Date;
}

const album = ref<Album>({
  id: -1,
  name: '',
  last_upload_batch: 0,
  expiry_date: new Date(),
});
onBeforeMount(async () => {
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

// TODO: Add rotate button

const cld = new Cloudinary({
  cloud: {
    cloudName: 'djnvimner',
  },
});
const getCloudinaryImage = (publicId: String, angle: number) => {
  return cld.image(`photo_review/${publicId}`).rotate(byAngle(angle));
};

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
};

const cancelEditAlbum = () => {
  albumName.value = '';
  albumExpiryDate.value = new Date();
  isEditing.value = false;
};

const saveEditAlbum = async () => {
  await axios
    .patch('http://localhost:3000/albums/' + albumId.value, {
      name: albumName.value,
      expiry_date: albumExpiryDate.value,
    })
    .then(() => {
      album.value.name = albumName.value;
      album.value.expiry_date = albumExpiryDate.value;
      cancelEditAlbum();
    })
    .catch((error) => {
      console.log(error);
    });
};

// Select photos for option
const selectedPhotoIds = ref<number[]>([]);
function toggleSelectPhoto(photoId: number) {
  if (selectedPhotoIds.value.includes(photoId)) {
    const index = selectedPhotoIds.value.findIndex((x) => (x = photoId));
    selectedPhotoIds.value.splice(index, 1);
  } else {
    selectedPhotoIds.value.push(photoId);
  }
}

function cancelSelectPhotos() {
  selectedPhotoIds.value = [];
}

const deletePhotos = async () => {
  let message = ''
  if (selectedPhotoIds.value.length === 1) {
    const selectedPhoto = photos.value.find((x: Photo) => x.id === selectedPhotoIds.value[0]);
    message = `Delete '${ selectedPhoto?.name }'?`;
  } else {
    message = `Delete ${ selectedPhotoIds.value.length } photos?`
  }
  if (confirm(message) === false) {
    return;
  }
  await axios
    .delete('http://localhost:3000/delete_photos', {
      data: {
        photo_ids: selectedPhotoIds.value,
      }
    }).then(() => {
      selectedPhotoIds.value.forEach((photoId) => {
        removePhoto(photoId);
      });
    })
    .catch((error) => {
      console.log(error);
    });
};
const removePhoto = (photoId: number) => {
  const index = photosData.value.findIndex(
    (photo: Photo) => photo.id === photoId
  );
  photosData.value.splice(index, 1);
};
const addPhoto = (photos: [Photo]) => {
  photos.forEach((photo) => {
    // photosData.value.unshift(photo);
    photosData.value.push(photo);
  });
};

const formatDate = (date: Date) => {
  date = new Date(date);
  return date.toISOString().split('T')[0];
};

const photos = computed(() => {
  return photosData.value;
});

const photosData = ref([<Photo>{}]);
onBeforeMount(async () => {
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
  { selected: false, value: null, icon: 'exclamation' },
]); // Yes Maybe No
const filterIsSelected = computed(() => {
  return filterReview.value.some((x) => x.selected);
});

function numberOfPhotosWithReview(val: number | null) {
  return photosData.value.filter((x) => x.review_results === val).length;
}

// photo review
const isShowingPhoto = ref(false);
const photoShowing = ref<Photo>();
// const photoShowing = ref<Photo | null>();
const showPhoto = (photoId: Number) => {
  photoShowing.value = photosData.value.find((x) => x.id === photoId);
  isShowingPhoto.value = true;
};
const updatePhoto = (photo: Photo) => {
  const index = photosData.value.findIndex((x) => x.id === photo.id);
  photosData.value[index] = photo;
};
function closeReviewPhoto() {
  isShowingPhoto.value = false;
  // photoShowing.value = {};
}

// style
function getPhotoClass(photo: Photo) {
  let result = '';
  const filterOfPhoto = filterReview.value.find(
    (x) => x.value === photo.review_results
  );
  if (!filterIsSelected.value) {
    return result;
  } else if (!filterOfPhoto || !filterOfPhoto.selected) {
    result += ' opacity-10 saturate-0';
  }
  return result;
}
</script>

<style scoped>
@import '../assets/main.css';

.btn-filter {
  display: flex;
  justify-content: space-around;
  align-items: center;
  border-radius: 0.25rem;
  border-width: 1px;
  cursor: pointer;
}

.btn-filter-selected {
  background-color: white;
  color: var(--color-primary);
}

.icon-circle-check {
  position: absolute;
  top: 0.25rem;
  left: 0.25rem;
  z-index: 50;
  opacity: 0;
}

.icon-circle-check:hover {
  opacity: 1;
  color: var(--slate-300);
}

.icon-circle-check-selected, .icon-circle-check-selected:hover  {
  opacity: 1;
  color: var(--color-primary);
  background-color: white;
  border-radius: 50%;
}
</style>
