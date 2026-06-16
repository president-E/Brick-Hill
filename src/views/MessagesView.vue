<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { Message } from '@/types'

const authStore = useAuthStore()
const messages = ref<Message[]>([])
const loading = ref(true)
const activeTab = ref<'inbox' | 'sent'>('inbox')
const selectedMessage = ref<Message | null>(null)

onMounted(async () => {
  if (!authStore.profile) return

  try {
    const { data, error } = await supabase
      .from('messages')
      .select('*, author:users!messages_author_id_fkey(id, username)')
      .or(`recipient_id.eq.${authStore.profile.id},author_id.eq.${authStore.profile.id}`)
      .order('created_at', { ascending: false })

    if (!error) messages.value = data || []
  } catch (error) {
    console.error('Error loading messages:', error)
  } finally {
    loading.value = false
  }
})

const inboxMessages = () => messages.value.filter(m => m.recipient_id === authStore.profile?.id)
const sentMessages = () => messages.value.filter(m => m.author_id === authStore.profile?.id)
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="font-display text-3xl font-bold text-white mb-8">Messages</h1>

    <div class="flex gap-4 mb-6">
      <button
        @click="activeTab = 'inbox'"
        class="btn"
        :class="activeTab === 'inbox' ? 'btn-primary' : 'btn-ghost'"
      >
        Inbox
      </button>
      <button
        @click="activeTab = 'sent'"
        class="btn"
        :class="activeTab === 'sent' ? 'btn-primary' : 'btn-ghost'"
      >
        Sent
      </button>
    </div>

    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="card animate-pulse h-20"></div>
    </div>

    <div v-else-if="selectedMessage" class="card">
      <div class="p-4 border-b border-neutral-700 flex items-center justify-between">
        <div>
          <h2 class="text-white font-semibold">{{ selectedMessage.subject }}</h2>
          <p class="text-neutral-400 text-sm">From {{ selectedMessage.author?.username }}</p>
        </div>
        <button @click="selectedMessage = null" class="btn-ghost">Back</button>
      </div>
      <div class="p-6">
        <p class="text-neutral-300 whitespace-pre-wrap">{{ selectedMessage.content }}</p>
      </div>
    </div>

    <div v-else class="space-y-3">
      <div v-for="message in (activeTab === 'inbox' ? inboxMessages() : sentMessages())" :key="message.id" class="card p-4 flex items-center gap-4 cursor-pointer hover:border-primary-500" @click="selectedMessage = message">
        <div class="w-12 h-12 bg-primary-500 rounded-lg flex items-center justify-center flex-shrink-0">
          <span class="text-white font-bold">{{ (message.author?.username || 'U').charAt(0) }}</span>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2">
            <h3 class="text-white font-medium truncate">{{ message.subject }}</h3>
            <span v-if="!message.is_read" class="w-2 h-2 bg-primary-500 rounded-full"></span>
          </div>
          <p class="text-neutral-400 text-sm">{{ activeTab === 'inbox' ? `From ${message.author?.username}` : `To User #${message.recipient_id}` }}</p>
        </div>
        <span class="text-neutral-500 text-sm">{{ new Date(message.created_at).toLocaleDateString() }}</span>
      </div>
      <div v-if="messages.length === 0" class="card p-8 text-center text-neutral-500">
        <p>No messages</p>
      </div>
    </div>
  </div>
</template>
