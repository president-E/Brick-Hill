<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { Friend, User } from '@/types'

const authStore = useAuthStore()
const friends = ref<Friend[]>([])
const requests = ref<Friend[]>([])
const loading = ref(true)
const activeTab = ref<'all' | 'requests'>('all')

const userId = computed(() => authStore.profile?.id)

onMounted(async () => {
  if (!userId.value) return

  try {
    const [friendsRes, requestsRes] = await Promise.all([
      supabase
        .from('friends')
        .select('*, from_user:users!friends_from_id_fkey(*), to_user:users!friends_to_id_fkey(*)')
        .or(`from_id.eq.${userId.value},to_id.eq.${userId.value}`)
        .eq('is_pending', false),
      supabase
        .from('friends')
        .select('*, from_user:users!friends_from_id_fkey(*)')
        .eq('to_id', userId.value)
        .eq('is_pending', true),
    ])

    if (!friendsRes.error) friends.value = friendsRes.data || []
    if (!requestsRes.error) requests.value = requestsRes.data || []
  } catch (error) {
    console.error('Error loading friends:', error)
  } finally {
    loading.value = false
  }
})

async function acceptRequest(friendId: number) {
  const { error } = await supabase
    .from('friends')
    .update({ is_pending: false })
    .eq('id', friendId)

  if (!error) {
    const req = requests.value.find(r => r.id === friendId)
    if (req) {
      requests.value = requests.value.filter(r => r.id !== friendId)
      friends.value.push(req)
    }
  }
}

async function declineRequest(friendId: number) {
  const { error } = await supabase
    .from('friends')
    .delete()
    .eq('id', friendId)

  if (!error) {
    requests.value = requests.value.filter(r => r.id !== friendId)
  }
}

function getFriendUser(friend: Friend): User | null {
  return friend.from_user?.id === userId.value ? friend.to_user : friend.from_user
}
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="font-display text-3xl font-bold text-white mb-8">Friends</h1>

    <div class="flex gap-4 mb-6">
      <button
        @click="activeTab = 'all'"
        class="btn"
        :class="activeTab === 'all' ? 'btn-primary' : 'btn-ghost'"
      >
        Friends ({{ friends.length }})
      </button>
      <button
        @click="activeTab = 'requests'"
        class="btn relative"
        :class="activeTab === 'requests' ? 'btn-primary' : 'btn-ghost'"
      >
        Requests ({{ requests.length }})
        <span
          v-if="requests.length > 0"
          class="absolute -top-1 -right-1 w-5 h-5 bg-error-500 text-white text-xs rounded-full flex items-center justify-center"
        >
          {{ requests.length }}
        </span>
      </button>
    </div>

    <div v-if="loading" class="grid grid-cols-2 gap-4">
      <div v-for="i in 4" :key="i" class="card animate-pulse p-4 h-20"></div>
    </div>

    <div v-else-if="activeTab === 'requests'">
      <div v-if="requests.length === 0" class="card p-8 text-center text-neutral-500">
        <p>No pending requests</p>
      </div>
      <div v-else class="space-y-3">
        <div
          v-for="request in requests"
          :key="request.id"
          class="card p-4 flex items-center gap-4"
        >
          <RouterLink :to="`/user/${request.from_user?.id}`" class="flex items-center gap-4 flex-1">
            <div class="w-12 h-12 bg-primary-500 rounded-lg flex items-center justify-center">
              <span class="text-white font-bold">{{ request.from_user?.username?.charAt(0).toUpperCase() }}</span>
            </div>
            <span class="text-white font-medium">{{ request.from_user?.username }}</span>
          </RouterLink>
          <div class="flex gap-2">
            <button @click="acceptRequest(request.id)" class="btn-success">Accept</button>
            <button @click="declineRequest(request.id)" class="btn-ghost">Decline</button>
          </div>
        </div>
      </div>
    </div>

    <div v-else>
      <div v-if="friends.length === 0" class="card p-8 text-center text-neutral-500">
        <p>No friends yet. Visit other users' profiles to add them!</p>
      </div>
      <div v-else class="grid grid-cols-2 gap-4">
        <RouterLink
          v-for="friend in friends"
          :key="friend.id"
          :to="`/user/${getFriendUser(friend)?.id}`"
          class="card p-4 flex items-center gap-4 hover:border-primary-500 transition-colors"
        >
          <div class="w-12 h-12 bg-primary-500 rounded-lg flex items-center justify-center">
            <span class="text-white font-bold">{{ getFriendUser(friend)?.username?.charAt(0).toUpperCase() }}</span>
          </div>
          <span class="text-white font-medium">{{ getFriendUser(friend)?.username }}</span>
        </RouterLink>
      </div>
    </div>
  </div>
</template>
