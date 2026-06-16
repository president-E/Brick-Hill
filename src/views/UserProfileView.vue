<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { User, Item, Set, Crate, Friend } from '@/types'

const route = useRoute()
const authStore = useAuthStore()

const user = ref<User | null>(null)
const inventory = ref<Crate[]>([])
const games = ref<Set[]>([])
const friends = ref<Friend[]>([])
const loading = ref(true)
const activeTab = ref('about')

const userId = computed(() => parseInt(route.params.id as string))
const isOwnProfile = computed(() => authStore.profile?.id === userId.value)

const isOnline = computed(() => {
  if (!user.value) return false
  const lastOnline = new Date(user.value.last_online)
  return (Date.now() - lastOnline.getTime()) < 180000
})

async function sendFriendRequest() {
  if (!authStore.profile || !user.value) return

  await supabase
    .from('friends')
    .insert({
      from_id: authStore.profile.id,
      to_id: user.value.id,
      is_pending: true,
    })
}

onMounted(async () => {
  try {
    const [userResponse, invResponse, gamesResponse, friendsResponse] = await Promise.all([
      supabase
        .from('users')
        .select('*')
        .eq('id', userId.value)
        .single(),
      supabase
        .from('crates')
        .select('*, item:items(*, type:item_types(*))')
        .eq('user_id', userId.value)
        .order('acquired_at', { ascending: false })
        .limit(20),
      supabase
        .from('sets')
        .select('*')
        .eq('creator_id', userId.value)
        .order('visits', { ascending: false })
        .limit(10),
      supabase
        .from('friends')
        .select('*, from_user:users!friends_from_id_fkey(id, username), to_user:users!friends_to_id_fkey(id, username)')
        .or(`from_id.eq.${userId.value},to_id.eq.${userId.value}`)
        .eq('is_pending', false)
        .limit(20),
    ])

    if (!userResponse.error) user.value = userResponse.data as User
    if (!invResponse.error) inventory.value = invResponse.data || []
    if (!gamesResponse.error) games.value = gamesResponse.data || []
    if (!friendsResponse.error) friends.value = friendsResponse.data || []
  } catch (error) {
    console.error('Error loading user profile:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div v-if="loading" class="animate-pulse space-y-8">
      <div class="h-48 bg-neutral-800 rounded-xl"></div>
      <div class="h-64 bg-neutral-800 rounded-xl"></div>
    </div>

    <div v-else-if="!user" class="text-center py-16">
      <h1 class="text-2xl text-white mb-2">User not found</h1>
      <RouterLink to="/" class="text-primary-400 hover:text-primary-300">Go home</RouterLink>
    </div>

    <div v-else class="space-y-8">
      <div class="card overflow-hidden">
        <div class="h-32 bg-gradient-to-r from-primary-600/30 to-secondary-600/30"></div>
        <div class="px-6 pb-6">
          <div class="flex flex-col sm:flex-row items-start sm:items-end gap-4 -mt-12">
            <div class="w-24 h-24 bg-primary-500 rounded-xl flex items-center justify-center border-4 border-neutral-800">
              <span class="text-white text-4xl font-bold">{{ user.username.charAt(0).toUpperCase() }}</span>
            </div>
            <div class="flex-1">
              <div class="flex items-center gap-2">
                <h1 class="text-2xl font-bold text-white">{{ user.username }}</h1>
                <span
                  :class="isOnline ? 'bg-success-500/20 text-success-300' : 'bg-neutral-700 text-neutral-400'"
                  class="badge"
                >
                  {{ isOnline ? 'Online' : 'Offline' }}
                </span>
                <span v-if="user.is_verified_designer" class="badge-success">
                  <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  Verified Designer
                </span>
              </div>
              <p class="text-neutral-400 text-sm mt-1">
                Member since {{ new Date(user.created_at).toLocaleDateString() }}
              </p>
            </div>
            <div v-if="!isOwnProfile && authStore.isAuthenticated" class="flex gap-2">
              <button @click="sendFriendRequest" class="btn-primary">Add Friend</button>
              <RouterLink to="`/trades?user=${user.id}`" class="btn-ghost">Trade</RouterLink>
            </div>
            <div v-if="isOwnProfile" class="flex gap-2">
              <RouterLink to="/avatar" class="btn-ghost">Edit Avatar</RouterLink>
              <RouterLink to="/settings" class="btn-ghost">Settings</RouterLink>
            </div>
          </div>
          <div class="flex gap-6 mt-4 text-sm">
            <div>
              <span class="text-warning-400 font-semibold">{{ user.bucks }}</span>
              <span class="text-neutral-500 ml-1">Bucks</span>
            </div>
            <div>
              <span class="text-success-400 font-semibold">{{ user.bits }}</span>
              <span class="text-neutral-500 ml-1">Bits</span>
            </div>
          </div>
        </div>
      </div>

      <div class="flex border-b border-neutral-700 mb-4">
        <button
          v-for="tab in ['about', 'inventory', 'games', 'friends']"
          :key="tab"
          @click="activeTab = tab"
          class="px-4 py-2 text-sm font-medium capitalize transition-colors"
          :class="activeTab === tab ? 'text-primary-400 border-b-2 border-primary-400' : 'text-neutral-400 hover:text-white'"
        >
          {{ tab }}
        </button>
      </div>

      <div v-if="activeTab === 'about'" class="card p-6">
        <h2 class="font-semibold text-white mb-4">About</h2>
        <p class="text-neutral-300 whitespace-pre-wrap">{{ user.description || 'No description provided' }}</p>
      </div>

      <div v-else-if="activeTab === 'inventory'" class="space-y-4">
        <h2 class="font-semibold text-white">Inventory ({{ inventory.length }} items)</h2>
        <div v-if="inventory.length === 0" class="card p-8 text-center text-neutral-500">
          <p>No items in inventory</p>
        </div>
        <div v-else class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-3">
          <RouterLink
            v-for="crate in inventory"
            :key="crate.id"
            :to="`/shop/${crate.item_id}`"
            class="card p-2 hover:border-primary-500 transition-colors"
          >
            <div class="w-full aspect-square bg-neutral-700 rounded overflow-hidden">
              <img
                v-if="crate.item?.thumbnail_url"
                :src="crate.item.thumbnail_url"
                :alt="crate.item.name"
                class="w-full h-full object-cover"
              />
            </div>
            <p class="text-xs text-white truncate mt-1">{{ crate.item?.name }}</p>
          </RouterLink>
        </div>
      </div>

      <div v-else-if="activeTab === 'games'" class="space-y-4">
        <h2 class="font-semibold text-white">Games ({{ games.length }})</h2>
        <div v-if="games.length === 0" class="card p-8 text-center text-neutral-500">
          <p>No games created yet</p>
        </div>
        <div v-else class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <RouterLink
            v-for="game in games"
            :key="game.id"
            :to="`/games/${game.id}`"
            class="card flex gap-4 hover:border-primary-500 transition-colors"
          >
            <div class="w-24 h-20 bg-neutral-700 rounded-l overflow-hidden flex-shrink-0">
              <img
                v-if="game.thumbnail_url"
                :src="game.thumbnail_url"
                :alt="game.name"
                class="w-full h-full object-cover"
              />
            </div>
            <div class="py-2 pr-4">
              <h3 class="text-white font-medium">{{ game.name }}</h3>
              <p class="text-neutral-400 text-sm">{{ game.visits.toLocaleString() }} visits</p>
            </div>
          </RouterLink>
        </div>
      </div>

      <div v-else-if="activeTab === 'friends'" class="space-y-4">
        <h2 class="font-semibold text-white">Friends ({{ friends.length }})</h2>
        <div v-if="friends.length === 0" class="card p-8 text-center text-neutral-500">
          <p>No friends yet</p>
        </div>
        <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
          <RouterLink
            v-for="friend in friends"
            :key="friend.id"
            :to="`/user/${friend.from_user?.id === userId ? friend.to_user?.id : friend.from_user?.id}`"
            class="card p-3 flex items-center gap-3 hover:border-primary-500 transition-colors"
          >
            <div class="w-10 h-10 bg-primary-500 rounded-lg flex items-center justify-center">
              <span class="text-white font-bold">
                {{ (friend.from_user?.id === userId ? friend.to_user?.username : friend.from_user?.username)?.charAt(0).toUpperCase() }}
              </span>
            </div>
            <span class="text-white text-sm">{{ friend.from_user?.id === userId ? friend.to_user?.username : friend.from_user?.username }}</span>
          </RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>
