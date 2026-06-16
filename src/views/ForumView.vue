<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import type { ForumThread } from '@/types'

const threads = ref<ForumThread[]>([])
const loading = ref(true)
const searchQuery = ref('')
const selectedCategory = ref<string | null>(null)

const filteredThreads = computed(() => {
  let filtered = [...threads.value]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(thread =>
      thread.title.toLowerCase().includes(query)
    )
  }

  return filtered
})

onMounted(async () => {
  try {
    const { data, error } = await supabase
      .from('forum_threads')
      .select('*, author:users!forum_threads_author_id_fkey(id, username)')
      .order('is_pinned', { ascending: false })
      .order('updated_at', { ascending: false })

    if (!error) threads.value = data || []
  } catch (error) {
    console.error('Error loading forum threads:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="font-display text-3xl font-bold text-white mb-2">Forum</h1>
        <p class="text-neutral-400">Discuss with the community</p>
      </div>
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search threads..."
        class="input w-64"
      />
    </div>

    <div v-if="loading" class="space-y-4">
      <div v-for="i in 5" :key="i" class="card animate-pulse p-4">
        <div class="h-4 bg-neutral-700 rounded w-3/4 mb-2"></div>
        <div class="h-3 bg-neutral-700 rounded w-1/2"></div>
      </div>
    </div>

    <div v-else-if="filteredThreads.length === 0" class="card p-8 text-center">
      <svg class="w-12 h-12 text-neutral-600 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
      </svg>
      <p class="text-neutral-400">No threads found</p>
    </div>

    <div v-else class="space-y-3">
      <RouterLink
        v-for="thread in filteredThreads"
        :key="thread.id"
        :to="`/forum/${thread.id}`"
        class="card p-4 flex items-center gap-4 hover:border-primary-500 transition-colors"
      >
        <div class="w-12 h-12 bg-primary-500 rounded-lg flex items-center justify-center flex-shrink-0">
          <span class="text-white font-bold">{{ thread.author?.username?.charAt(0).toUpperCase() }}</span>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2">
            <h3 class="text-white font-medium truncate">{{ thread.title }}</h3>
            <span v-if="thread.is_pinned" class="badge-warning">Pinned</span>
            <span v-if="thread.is_locked" class="badge-error">Locked</span>
          </div>
          <p class="text-neutral-400 text-sm">
            by {{ thread.author?.username }} | {{ new Date(thread.created_at).toLocaleDateString() }}
          </p>
        </div>
      </RouterLink>
    </div>
  </div>
</template>
