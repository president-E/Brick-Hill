<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { User, Item, Set, Crate } from '@/types'

const authStore = useAuthStore()

const inventory = ref<Crate[]>([])
const recentGames = ref<Set[]>([])
const loading = ref(true)

const user = computed(() => authStore.profile)

onMounted(async () => {
  if (!user.value) return

  try {
    const [invResponse, gamesResponse] = await Promise.all([
      supabase
        .from('crates')
        .select('*, item:items(*, type:item_types(*))')
        .eq('user_id', user.value.id)
        .order('acquired_at', { ascending: false })
        .limit(10),
      supabase
        .from('sets')
        .select('*')
        .eq('creator_id', user.value.id)
        .order('updated_at', { ascending: false })
        .limit(5),
    ])

    if (!invResponse.error) inventory.value = invResponse.data || []
    if (!gamesResponse.error) recentGames.value = gamesResponse.data || []
  } catch (error) {
    console.error('Error loading dashboard data:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div v-if="loading" class="animate-pulse space-y-8">
      <div class="h-32 bg-neutral-800 rounded-xl"></div>
      <div class="grid md:grid-cols-2 gap-8">
        <div class="h-64 bg-neutral-800 rounded-xl"></div>
        <div class="h-64 bg-neutral-800 rounded-xl"></div>
      </div>
    </div>

    <div v-else class="space-y-8">
      <div class="card p-6 bg-gradient-to-r from-primary-600/20 to-secondary-600/20 border-primary-500/30">
        <div class="flex flex-col md:flex-row items-start md:items-center gap-6">
          <div class="w-24 h-24 bg-primary-500 rounded-xl flex items-center justify-center">
            <span class="text-white text-4xl font-bold">{{ user?.username?.charAt(0).toUpperCase() }}</span>
          </div>
          <div class="flex-1">
            <h1 class="text-2xl font-bold text-white mb-1">Welcome back, {{ user?.username }}!</h1>
            <p class="text-neutral-400 mb-4">{{ user?.description || 'No description set' }}</p>
            <div class="flex flex-wrap gap-4 text-sm">
              <div class="flex items-center gap-2">
                <span class="text-warning-400 font-semibold">{{ user?.bucks }}</span>
                <span class="text-neutral-500">Bucks</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-success-400 font-semibold">{{ user?.bits }}</span>
                <span class="text-neutral-500">Bits</span>
              </div>
            </div>
          </div>
          <div class="flex gap-2">
            <RouterLink to="/avatar" class="btn-ghost">Edit Avatar</RouterLink>
            <RouterLink to="/settings" class="btn-ghost">Settings</RouterLink>
          </div>
        </div>
      </div>

      <div class="grid md:grid-cols-2 gap-8">
        <div class="card">
          <div class="p-4 border-b border-neutral-700 flex items-center justify-between">
            <h2 class="font-semibold text-white">Recent Items</h2>
            <RouterLink to="/inventory" class="text-primary-400 text-sm hover:text-primary-300">View All</RouterLink>
          </div>
          <div class="p-4">
            <div v-if="inventory.length === 0" class="text-center py-8 text-neutral-500">
              <p>No items yet. Visit the <RouterLink to="/shop" class="text-primary-400">shop</RouterLink>!</p>
            </div>
            <div v-else class="grid grid-cols-5 gap-2">
              <div
                v-for="crate in inventory"
                :key="crate.id"
                class="aspect-square bg-neutral-700 rounded-lg overflow-hidden"
              >
                <img
                  v-if="crate.item?.thumbnail_url"
                  :src="crate.item.thumbnail_url"
                  :alt="crate.item.name"
                  class="w-full h-full object-cover"
                />
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="p-4 border-b border-neutral-700 flex items-center justify-between">
            <h2 class="font-semibold text-white">Your Games</h2>
            <RouterLink to="/games" class="text-primary-400 text-sm hover:text-primary-300">View All</RouterLink>
          </div>
          <div class="p-4">
            <div v-if="recentGames.length === 0" class="text-center py-8 text-neutral-500">
              <p>You haven't created any games yet.</p>
            </div>
            <div v-else class="space-y-3">
              <RouterLink
                v-for="game in recentGames"
                :key="game.id"
                :to="`/games/${game.id}`"
                class="flex items-center gap-4 p-3 bg-neutral-700 rounded-lg hover:bg-neutral-600 transition-colors"
              >
                <div class="w-16 h-12 bg-neutral-800 rounded overflow-hidden">
                  <img
                    v-if="game.thumbnail_url"
                    :src="game.thumbnail_url"
                    :alt="game.name"
                    class="w-full h-full object-cover"
                  />
                </div>
                <div class="flex-1">
                  <h3 class="text-white font-medium">{{ game.name }}</h3>
                  <p class="text-neutral-400 text-sm">{{ game.visits.toLocaleString() }} visits</p>
                </div>
              </RouterLink>
            </div>
          </div>
        </div>
      </div>

      <div class="card p-6">
        <h2 class="font-semibold text-white mb-4">Quick Links</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <RouterLink to="/shop" class="p-4 bg-neutral-700 rounded-lg hover:bg-neutral-600 transition-colors text-center">
            <svg class="w-8 h-8 text-primary-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
            </svg>
            <span class="text-white font-medium">Shop</span>
          </RouterLink>
          <RouterLink to="/games" class="p-4 bg-neutral-700 rounded-lg hover:bg-neutral-600 transition-colors text-center">
            <svg class="w-8 h-8 text-secondary-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10l-2 1m0 0l-2-1m2 1v2.5M20 7l-2 1m2-1l-2-1m2 1v2.5M14 4l-2-1-2 1M4 7l2-1M4 7l2 1M4 7v2.5M12 21l-2-1m2 1l2-1m-2 1v-2.5M6 18l-2-1m2 1l2-1m-2 1v-2.5" />
            </svg>
            <span class="text-white font-medium">Games</span>
          </RouterLink>
          <RouterLink to="/friends" class="p-4 bg-neutral-700 rounded-lg hover:bg-neutral-600 transition-colors text-center">
            <svg class="w-8 h-8 text-success-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <span class="text-white font-medium">Friends</span>
          </RouterLink>
          <RouterLink to="/forum" class="p-4 bg-neutral-700 rounded-lg hover:bg-neutral-600 transition-colors text-center">
            <svg class="w-8 h-8 text-warning-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <span class="text-white font-medium">Forum</span>
          </RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>
