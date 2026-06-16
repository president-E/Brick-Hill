<script setup lang="ts">
import { ref, computed } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const route = useRoute()
const mobileMenuOpen = ref(false)

const navLinks = [
  { name: 'Home', path: '/' },
  { name: 'Games', path: '/games' },
  { name: 'Shop', path: '/shop' },
  { name: 'Forum', path: '/forum' },
]

const unreadMessages = computed(() => 0)
const pendingTrades = computed(() => 0)

function isActive(path: string) {
  return route.path === path || route.path.startsWith(path + '/')
}
</script>

<template>
  <nav class="bg-neutral-800 border-b border-neutral-700 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16">
        <div class="flex items-center gap-8">
          <RouterLink to="/" class="flex items-center gap-2">
            <div class="w-8 h-8 bg-primary-500 rounded-lg flex items-center justify-center">
              <span class="text-white font-bold text-lg">B</span>
            </div>
            <span class="font-display font-bold text-xl text-white hidden sm:block">Brick Hill</span>
          </RouterLink>

          <div class="hidden md:flex items-center gap-1">
            <RouterLink
              v-for="link in navLinks"
              :key="link.path"
              :to="link.path"
              class="px-3 py-2 rounded-lg text-sm font-medium transition-colors"
              :class="[
                isActive(link.path)
                  ? 'bg-primary-500/20 text-primary-300'
                  : 'text-neutral-400 hover:text-white hover:bg-neutral-700'
              ]"
            >
              {{ link.name }}
            </RouterLink>
          </div>
        </div>

        <div class="hidden md:flex items-center gap-4">
          <div v-if="authStore.isAuthenticated" class="flex items-center gap-4">
            <div class="flex items-center gap-2 text-sm">
              <span class="text-warning-400 font-medium">{{ authStore.profile?.bucks || 0 }}</span>
              <span class="text-neutral-500">Bucks</span>
              <span class="text-success-400 font-medium ml-2">{{ authStore.profile?.bits || 0 }}</span>
              <span class="text-neutral-500">Bits</span>
            </div>

            <RouterLink
              to="/messages"
              class="relative p-2 text-neutral-400 hover:text-white transition-colors"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
              <span
                v-if="unreadMessages > 0"
                class="absolute -top-1 -right-1 w-4 h-4 bg-error-500 text-xs rounded-full flex items-center justify-center"
              >
                {{ unreadMessages }}
              </span>
            </RouterLink>

            <RouterLink
              to="/trades"
              class="relative p-2 text-neutral-400 hover:text-white transition-colors"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
              </svg>
              <span
                v-if="pendingTrades > 0"
                class="absolute -top-1 -right-1 w-4 h-4 bg-error-500 text-xs rounded-full flex items-center justify-center"
              >
                {{ pendingTrades }}
              </span>
            </RouterLink>

            <RouterLink
              :to="`/user/${authStore.profile?.id}`"
              class="flex items-center gap-2 px-3 py-1.5 bg-neutral-700 rounded-lg hover:bg-neutral-600 transition-colors"
            >
              <div class="w-6 h-6 bg-primary-500 rounded flex items-center justify-center">
                <span class="text-white text-xs font-bold">{{ authStore.profile?.username?.charAt(0).toUpperCase() }}</span>
              </div>
              <span class="text-sm font-medium text-white">{{ authStore.profile?.username }}</span>
            </RouterLink>
          </div>

          <div v-else class="flex items-center gap-2">
            <RouterLink to="/login" class="btn-ghost text-sm">Log In</RouterLink>
            <RouterLink to="/register" class="btn-primary text-sm">Sign Up</RouterLink>
          </div>
        </div>

        <button
          @click="mobileMenuOpen = !mobileMenuOpen"
          class="md:hidden p-2 text-neutral-400 hover:text-white"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="mobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>
    </div>

    <div v-if="mobileMenuOpen" class="md:hidden bg-neutral-800 border-t border-neutral-700">
      <div class="px-4 py-4 space-y-2">
        <RouterLink
          v-for="link in navLinks"
          :key="link.path"
          :to="link.path"
          class="block px-3 py-2 rounded-lg text-sm font-medium"
          :class="isActive(link.path) ? 'bg-primary-500/20 text-primary-300' : 'text-neutral-400'"
          @click="mobileMenuOpen = false"
        >
          {{ link.name }}
        </RouterLink>

        <div v-if="authStore.isAuthenticated" class="pt-4 border-t border-neutral-700 space-y-2">
          <RouterLink to="/dashboard" class="block px-3 py-2 text-neutral-400 hover:text-white" @click="mobileMenuOpen = false">
            Dashboard
          </RouterLink>
          <RouterLink to="/inventory" class="block px-3 py-2 text-neutral-400 hover:text-white" @click="mobileMenuOpen = false">
            Inventory
          </RouterLink>
          <RouterLink to="/avatar" class="block px-3 py-2 text-neutral-400 hover:text-white" @click="mobileMenuOpen = false">
            Avatar
          </RouterLink>
          <RouterLink :to="`/user/${authStore.profile?.id}`" class="block px-3 py-2 text-primary-400" @click="mobileMenuOpen = false">
            {{ authStore.profile?.username }}
          </RouterLink>
        </div>
        <div v-else class="pt-4 border-t border-neutral-700 space-y-2">
          <RouterLink to="/login" class="block px-3 py-2 text-neutral-400 hover:text-white" @click="mobileMenuOpen = false">
            Log In
          </RouterLink>
          <RouterLink to="/register" class="block px-3 py-2 text-primary-400" @click="mobileMenuOpen = false">
            Sign Up
          </RouterLink>
        </div>
      </div>
    </div>
  </nav>
</template>
