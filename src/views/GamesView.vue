<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import type { Set } from '@/types'

const games = ref<Set[]>([])
const loading = ref(true)
const searchQuery = ref('')
const sortBy = ref<'playing' | 'visits' | 'created'>('playing')

const sortedGames = computed(() => {
  let sorted = [...games.value]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    sorted = sorted.filter(game =>
      game.name.toLowerCase().includes(query) ||
      game.description?.toLowerCase().includes(query)
    )
  }

  switch (sortBy.value) {
    case 'playing':
      return sorted.sort((a, b) => b.playing - a.playing)
    case 'visits':
      return sorted.sort((a, b) => b.visits - a.visits)
    case 'created':
      return sorted.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
    default:
      return sorted
  }
})

onMounted(async () => {
  try {
    const { data, error } = await supabase
      .from('sets')
      .select('*, creator:users!sets_creator_id_fkey(id, username)')
      .order('playing', { ascending: false })

    if (!error) games.value = data || []
  } catch (error) {
    console.error('Error loading games:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="mb-8">
      <h1 class="font-display text-3xl font-bold text-white mb-2">Games</h1>
      <p class="text-neutral-400">Play games created by the community</p>
    </div>

    <div class="flex flex-col sm:flex-row gap-4 mb-8">
      <div class="flex-1">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search games..."
          class="input"
        />
      </div>
      <div class="flex gap-2">
        <button
          @click="sortBy = 'playing'"
          class="btn-ghost"
          :class="{ 'bg-primary-500/20 text-primary-300': sortBy === 'playing' }"
        >
          Playing
        </button>
        <button
          @click="sortBy = 'visits'"
          class="btn-ghost"
          :class="{ 'bg-primary-500/20 text-primary-300': sortBy === 'visits' }"
        >
          Most Visited
        </button>
        <button
          @click="sortBy = 'created'"
          class="btn-ghost"
          :class="{ 'bg-primary-500/20 text-primary-300': sortBy === 'created' }"
        >
          New
        </button>
      </div>
    </div>

    <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="i in 9" :key="i" class="card animate-pulse">
        <div class="h-48 bg-neutral-700"></div>
        <div class="p-4 space-y-2">
          <div class="h-4 bg-neutral-700 rounded w-3/4"></div>
          <div class="h-3 bg-neutral-700 rounded w-1/2"></div>
        </div>
      </div>
    </div>

    <div v-else-if="sortedGames.length === 0" class="text-center py-16">
      <svg class="w-16 h-16 text-neutral-600 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10l-2 1m0 0l-2-1m2 1v2.5M20 7l-2 1m2-1l-2-1m2 1v2.5M14 4l-2-1-2 1M4 7l2-1M4 7l2 1M4 7v2.5M12 21l-2-1m2 1l2-1m-2 1v-2.5M6 18l-2-1m2 1l2-1m-2 1v-2.5" />
      </svg>
      <p class="text-neutral-400 mb-2">No games found</p>
      <p class="text-neutral-500 text-sm">Be the first to create a game!</p>
    </div>

    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <RouterLink
        v-for="game in sortedGames"
        :key="game.id"
        :to="`/games/${game.id}`"
        class="card group hover:border-primary-500 transition-colors"
      >
        <div class="relative h-48 bg-neutral-700 overflow-hidden">
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
          <div class="absolute top-2 left-2 px-2 py-1 bg-success-500/80 text-white text-xs rounded-full flex items-center gap-1">
            <span class="w-2 h-2 bg-white rounded-full animate-pulse"></span>
            {{ game.playing }} playing
          </div>
          <div v-if="game.is_featured" class="absolute top-2 right-2 badge-warning">Featured</div>
        </div>
        <div class="p-4">
          <h3 class="text-white font-semibold group-hover:text-primary-400 transition-colors">{{ game.name }}</h3>
          <div class="flex items-center gap-2 mt-1">
            <span class="text-neutral-400 text-sm">{{ game.visits.toLocaleString() }} visits</span>
            <span v-if="game.max_players" class="text-neutral-500 text-sm">| {{ game.max_players }} max</span>
          </div>
          <p class="text-neutral-500 text-sm mt-2 line-clamp-2">{{ game.description || 'No description' }}</p>
        </div>
      </RouterLink>
    </div>

    <p v-if="!loading" class="text-neutral-500 text-sm text-center mt-8">
      {{ games.length }} games available
    </p>
  </div>
</template>
