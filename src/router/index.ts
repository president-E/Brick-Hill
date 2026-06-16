import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/HomeView.vue'),
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/RegisterView.vue'),
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('@/views/DashboardView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/user/:id',
      name: 'user',
      component: () => import('@/views/UserProfileView.vue'),
    },
    {
      path: '/avatar',
      name: 'avatar',
      component: () => import('@/views/AvatarEditorView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/shop',
      name: 'shop',
      component: () => import('@/views/ShopView.vue'),
    },
    {
      path: '/shop/:id',
      name: 'item',
      component: () => import('@/views/ItemDetailView.vue'),
    },
    {
      path: '/games',
      name: 'games',
      component: () => import('@/views/GamesView.vue'),
    },
    {
      path: '/games/:id',
      name: 'game',
      component: () => import('@/views/GameDetailView.vue'),
    },
    {
      path: '/friends',
      name: 'friends',
      component: () => import('@/views/FriendsView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/trades',
      name: 'trades',
      component: () => import('@/views/TradesView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/messages',
      name: 'messages',
      component: () => import('@/views/MessagesView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/forum',
      name: 'forum',
      component: () => import('@/views/ForumView.vue'),
    },
    {
      path: '/forum/:id',
      name: 'thread',
      component: () => import('@/views/ThreadView.vue'),
    },
    {
      path: '/inventory',
      name: 'inventory',
      component: () => import('@/views/InventoryView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/settings',
      name: 'settings',
      component: () => import('@/views/SettingsView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/views/NotFoundView.vue'),
    },
  ],
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  if (!authStore.initialized) {
    await authStore.initialize()
  }

  if (to.meta.requiresAuth && !authStore.user) {
    next({ name: 'login', query: { redirect: to.fullPath } })
  } else {
    next()
  }
})

export default router
