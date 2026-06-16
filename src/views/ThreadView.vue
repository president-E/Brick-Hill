<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '@/lib/supabase'
import type { ForumThread, ForumPost } from '@/types'

const route = useRoute()
const thread = ref<ForumThread | null>(null)
const posts = ref<ForumPost[]>([])
const loading = ref(true)

const threadId = parseInt(route.params.id as string)

onMounted(async () => {
  try {
    const [threadRes, postsRes] = await Promise.all([
      supabase
        .from('forum_threads')
        .select('*, author:users!forum_threads_author_id_fkey(id, username)')
        .eq('id', threadId)
        .single(),
      supabase
        .from('forum_posts')
        .select('*, author:users!forum_posts_author_id_fkey(id, username)')
        .eq('thread_id', threadId)
        .order('created_at', { ascending: true }),
    ])

    if (!threadRes.error) thread.value = threadRes.data
    if (!postsRes.error) posts.value = postsRes.data || []
  } catch (error) {
    console.error('Error loading thread:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div v-if="loading" class="animate-pulse space-y-8">
      <div class="h-12 bg-neutral-800 rounded w-3/4"></div>
      <div class="card h-40"></div>
    </div>

    <div v-else-if="!thread" class="text-center py-16">
      <h1 class="text-2xl text-white mb-2">Thread not found</h1>
      <RouterLink to="/forum" class="text-primary-400">Back to forum</RouterLink>
    </div>

    <div v-else class="space-y-6">
      <div class="flex items-center justify-between">
        <div>
          <div class="flex items-center gap-3 mb-2">
            <h1 class="text-2xl font-bold text-white">{{ thread.title }}</h1>
            <span v-if="thread.is_pinned" class="badge-warning">Pinned</span>
            <span v-if="thread.is_locked" class="badge-error">Locked</span>
          </div>
          <p class="text-neutral-400 text-sm">By {{ thread.author?.username }} | {{ new Date(thread.created_at).toLocaleDateString() }}</p>
        </div>
        <RouterLink to="/forum" class="btn-ghost">Back to Forum</RouterLink>
      </div>

      <div class="space-y-4">
        <div v-for="post in posts" :key="post.id" class="card overflow-hidden">
          <div class="flex">
            <div class="w-32 bg-neutral-800 p-4 flex-shrink-0 border-r border-neutral-700">
              <RouterLink :to="`/user/${post.author_id}`" class="block text-center">
                <div class="w-16 h-16 bg-primary-500 rounded-lg mx-auto mb-2 flex items-center justify-center">
                  <span class="text-white font-bold text-xl">{{ (post.author?.username || 'U').charAt(0) }}</span>
                </div>
                <p class="text-white text-sm font-medium">{{ post.author?.username }}</p>
              </RouterLink>
            </div>
            <div class="flex-1 p-4">
              <p class="text-neutral-300 whitespace-pre-wrap">{{ post.content }}</p>
              <p class="text-neutral-500 text-xs mt-4">{{ new Date(post.created_at).toLocaleString() }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
