import { createRouter, createWebHistory } from 'vue-router'
import Login from '@/views/Login.vue'
import Signup from '@/views/Signup.vue'
import Albums from '@/views/Albums.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Albums
    },
    {
      path: '/users/login',
      name: 'Login',
      component: Login
    }
    ,{
      path: '/users/signup',
      name: 'Signup',
      component: Signup
    }
    // ,{
    //   path: '/about',
    //   name: 'about',
    //   // route level code-splitting
    //   // this generates a separate chunk (About.[hash].js) for this route
    //   // which is lazy-loaded when the route is visited.
    //   component: () => import('../views/AboutView.vue')
    // }
    ,{
      path: '/albums',
      name: 'Albums',
      component: Albums
    }
    ,{
      path: '/albums/:id',
      name: 'Album',
      component: () => import('../views/Album.vue')
    }
    // ,{
    //   path: '/photos/:id',
    //   name: 'Photo',
    //   component: () => import('../views/Photo.vue')
    // }
  ]
})

export default router
