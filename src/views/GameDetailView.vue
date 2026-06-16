<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { Set, User } from '@/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const game = ref<Set | null>(null)
const creator = ref<User | null>(null)
const loading = ref(true)

const gameId = parseInt(route.params.id as string)

onMounted(async () => {
  try {
    const { data, error } = await supabase
      .from('sets')
      .select('*, creator:users!sets_creator_id_fkey(*)')
      .eq('id', gameId)
      .single()

    if (error) throw error
    game.value = data
  } catch (error) {
    console.error('Error loading game:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div v-if="loading" class="animate-pulse space-y-8">
      <div class="aspect-video bg-neutral-800 rounded-xl"></div>
      <div class="h-8 bg-neutral-800 rounded w-1/2"></div>
    </div>

    <div v-else-if="!game" class="text-center py-16">
      <h1 class="text-2xl text-white mb-2">Game not found</h1>
      <RouterLink to="/games" class="text-primary-400">Back to games</RouterLink>
    </div>

    <div v-else class="space-y-8">
      <div class="card overflow-hidden">
        <div class="aspect-video bg-neutral-700 relative">
          <img
            v-if="game.thumbnail_url"
            :src="game.thumbnail_url"
            :alt="game.name"
            class="w-full h-full object-cover"
          />
          <div class="absolute inset-0 flex items-center justify-center bg-black/50">
            <div class="text-center">
              <h1 class="text-3xl font-bold text-white mb-4">{{ game.name }}</h1>
              <button class="btn-primary text-lg px-12 py-3">
                Play
              </button>
              <p class="text-neutral-400 text-sm mt-4">{{ game.playing }} currently playing</p>
            </div>
          </div>
        </div>
      </div>

      <div class="grid md:grid-cols-3 gap-6">
        <div class="md:col-span-2 space-y-4">
          <div class="card p-6">
            <h2 class="font-semibold text-white mb-4">About</h2>
            <p class="text-neutral-300 whitespace-pre-wrap">{{ game.description || 'No description provided' }}</p>
          </div>
        </div>

        <div class="space-y-4">
          <div class="card p-4">
            <RouterLink :to="`/user/${game.creator_id}`" class="flex items-center gap-4">
              <div class="w-12 h-12 bg-primary-500 rounded-lg flex items-center justify-center">
                <span class="text-white font-bold">{{ (game.creator as User)?.username?.charAt(0).toUpperCase() || '?' }}</span>
              </div>
              <div>
                <p class="text-white font-medium">{{ (game.creator as User)?.username || 'Unknown' }}</p>
                <p class="text-neutral-400 text-sm">Creator</p>
              </div>
            </RouterLink>
          </div>

          <div class="card p-4 space-y-3">
            <div class="flex justify-between">
              <span class="text-neutral-400">Visits</span>
              <span class="text-white">{{ game.visits.toLocaleString() }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-neutral-400">Playing</span>
              <span class="text-success-400">{{ game.playing }}</span>
            </div>
            <div v-if="game.max_players" class="flex justify-between">
              <span class="text-neutral-400">Max Players</span>
              <span class="text-white">{{ game.max_players }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-neutral-400">Created</span>
              <span class="text-white">{{ new Date(game.created_at).toLocaleDateString() }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
