import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
/* import the fontawesome core */
import { library } from '@fortawesome/fontawesome-svg-core'

/* import font awesome icon component */
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

/* import specific icons */
import { faPlus, faX, faHouse, faBell, faGear, faUser, faPen, faCalendarDays, faFloppyDisk, faCheck, faXmark, faQuestion, faCaretRight, faCaretLeft, faCaretDown, faArrowLeft, faExclamation, faRotateLeft, faGripLines, faTableColumns, faCircleCheck, faShareFromSquare } from '@fortawesome/free-solid-svg-icons'

import { faTrashCan, faSquareMinus } from '@fortawesome/free-regular-svg-icons'

/* add icons to the library */
library.add(faPlus, faX, faHouse, faBell, faGear, faUser, faPen, faCalendarDays, faFloppyDisk, faCheck, faXmark, faQuestion, faCaretRight, faCaretLeft, faCaretDown, faArrowLeft, faExclamation, faRotateLeft, faGripLines, faTableColumns, faCircleCheck, faShareFromSquare)
library.add( faTrashCan, faSquareMinus )

const app = createApp(App)

app
.use(createPinia())
.use(router)
.component('font-awesome-icon', FontAwesomeIcon)
.mount('#app')
