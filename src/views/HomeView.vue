<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import type { Set, Item } from '@/types'

const featuredGames = ref<Set[]>([])
const featuredItems = ref<Item[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const [gamesResponse, itemsResponse] = await Promise.all([
      supabase
        .from('sets')
        .select('*, creator:users!sets_creator_id_fkey(*)')
        .eq('is_featured', true)
        .order('playing', { ascending: false })
        .limit(6),
      supabase
        .from('items')
        .select('*, creator:users!items_creator_id_fkey(*), type:item_types(*)')
        .eq('is_public', true)
        .eq('is_approved', true)
        .eq('special', true)
        .order('created_at', { ascending: false })
        .limit(6),
    ])

    if (!gamesResponse.error) featuredGames.value = gamesResponse.data || []
    if (!itemsResponse.error) featuredItems.value = itemsResponse.data || []
  } catch (error) {
    console.error('Error loading home data:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="min-h-screen">
    <section class="relative overflow-hidden bg-gradient-to-b from-neutral-800 to-neutral-900 py-20">
      <div class="absolute inset-0 bg-grid-pattern opacity-5"></div>
      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 class="font-display text-5xl md:text-7xl font-bold text-white mb-6 animate-fade-in">
          Welcome to <span class="text-primary-400">Brick Hill</span>
        </h1>
        <p class="text-neutral-400 text-lg md:text-xl max-w-2xl mx-auto mb-8 animate-slide-up">
          Create, play, and socialize in a world of blocks. Build your own games, customize your avatar, and join a vibrant community.
        </p>
        <div class="flex flex-wrap justify-center gap-4 animate-slide-up">
          <RouterLink to="/games" class="btn-primary text-lg px-8 py-3">
            Play Now
          </RouterLink>
          <RouterLink to="/register" class="btn-outline border-primary-500 text-primary-400 text-lg px-8 py-3">
            Create Account
          </RouterLink>
        </div>
      </div>
    </section>

    <section class="bg-neutral-900 py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
          <h2 class="font-display text-3xl font-bold text-white mb-4">Featured Games</h2>
          <p class="text-neutral-400">Join thousands of players in exciting games</p>
        </div>

        <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="i in 6" :key="i" class="card animate-pulse">
            <div class="h-40 bg-neutral-700"></div>
            <div class="p-4 space-y-2">
              <div class="h-4 bg-neutral-700 rounded w-3/4"></div>
              <div class="h-3 bg-neutral-700 rounded w-1/2"></div>
            </div>
          </div>
        </div>

        <div v-else-if="featuredGames.length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <RouterLink
            v-for="game in featuredGames"
            :key="game.id"
            :to="`/games/${game.id}`"
            class="card group hover:border-primary-500 transition-colors"
          >
            <div class="relative h-40 bg-neutral-700 overflow-hidden">
              <img
                v-if="game.thumbnail_url"
                :src="game.thumbnail_url"
                :alt="game.name"
                class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
              />
              <div v-else class="w-full h-full flex items-center justify-center">
                <svg class="w-16 h-16 text-neutral-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10l-2 1m0 0l-2-1m2 1v2.5M20 7l-2 1m2-1l-2-1m2 1v2.5M14 4l-2-1-2 1M4 7l2-1M4 7l2 1M4 7v2.5M12 21l-2-1m2 1l2-1m-2 1v-2.5M6 18l-2-1m2 1l2-1m-2 1v-2.5" />
                </svg>
              </div>
              <div class="absolute bottom-2 right-2 px-2 py-1 bg-success-500/80 text-white text-xs rounded-full flex items-center gap-1">
                <span class="w-2 h-2 bg-white rounded-full animate-pulse"></span>
                {{ game.playing }} playing
              </div>
            </div>
            <div class="p-4">
              <h3 class="text-white font-semibold group-hover:text-primary-400 transition-colors">{{ game.name }}</h3>
              <p class="text-neutral-500 text-sm">{{ game.visits.toLocaleString() }} visits</p>
            </div>
          </RouterLink>
        </div>

        <div v-else class="text-center py-12 text-neutral-500">
          <p>No featured games yet. Check back soon!</p>
        </div>

        <div class="text-center mt-8">
          <RouterLink to="/games" class="btn-ghost">
            View All Games
            <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </RouterLink>
        </div>
      </div>
    </section>

    <section class="bg-neutral-800 py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
          <h2 class="font-display text-3xl font-bold text-white mb-4">Special Items</h2>
          <p class="text-neutral-400">Limited edition items from the shop</p>
        </div>

        <div v-if="loading" class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
          <div v-for="i in 6" :key="i" class="card animate-pulse p-4">
            <div class="w-full aspect-square bg-neutral-700 rounded-lg mb-2"></div>
            <div class="h-3 bg-neutral-700 rounded w-3/4"></div>
          </div>
        </div>

        <div v-else-if="featuredItems.length > 0" class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
          <RouterLink
            v-for="item in featuredItems"
            :key="item.id"
            :to="`/shop/${item.id}`"
            class="card group hover:border-warning-500 transition-colors"
          >
            <div class="p-3">
              <div class="w-full aspect-square bg-neutral-700 rounded-lg mb-2 overflow-hidden relative">
                <img
                  v-if="item.thumbnail_url"
                  :src="item.thumbnail_url"
                  :alt="item.name"
                  class="w-full h-full object-cover"
                />
                <div v-else class="w-full h-full flex items-center justify-center">
                  <svg class="w-12 h-12 text-neutral-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                  </svg>
                </div>
                <span class="absolute top-1 right-1 badge-warning">Special</span>
              </div>
              <h3 class="text-white text-sm font-medium truncate group-hover:text-primary-400 transition-colors">{{ item.name }}</h3>
              <p class="text-warning-400 text-sm font-medium">
                {{ item.average_price ? item.average_price.toLocaleString() : 'N/A' }}
              </p>
            </div>
          </RouterLink>
        </div>

        <div v-else class="text-center py-12 text-neutral-500">
          <p>No special items available right now.</p>
        </div>

        <div class="text-center mt-8">
          <RouterLink to="/shop" class="btn-ghost">
            Visit Shop
            <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </RouterLink>
        </div>
      </div>
    </section>

    <section class="bg-neutral-900 py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid md:grid-cols-3 gap-8 text-center">
          <div class="p-6">
            <div class="w-16 h-16 bg-primary-500/20 rounded-xl flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-primary-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10l-2 1m0 0l-2-1m2 1v2.5M20 7l-2 1m2-1l-2-1m2 1v2.5M14 4l-2-1-2 1M4 7l2-1M4 7l2 1M4 7v2.5M12 21l-2-1m2 1l2-1m-2 1v-2.5M6 18l-2-1m2 1l2-1m-2 1v-2.5" />
              </svg>
            </div>
            <h3 class="text-white font-semibold text-xl mb-2">Build & Create</h3>
            <p class="text-neutral-400">Create your own games and worlds with our easy-to-use tools.</p>
          </div>
          <div class="p-6">
            <div class="w-16 h-16 bg-secondary-500/20 rounded-xl flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-secondary-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </div>
            <h3 class="text-white font-semibold text-xl mb-2">Play Together</h3>
            <p class="text-neutral-400">Join friends and play thousands of user-created games.</p>
          </div>
          <div class="p-6">
            <div class="w-16 h-16 bg-success-500/20 rounded-xl flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-success-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
              </svg>
            </div>
            <h3 class="text-white font-semibold text-xl mb-2">Customize</h3>
            <p class="text-neutral-400">Personalize your avatar with unique items from the shop.</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
