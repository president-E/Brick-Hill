<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import type { Item, ItemType } from '@/types'

const items = ref<Item[]>([])
const itemTypes = ref<ItemType[]>([])
const loading = ref(true)
const searchQuery = ref('')
const selectedType = ref<number | null>(null)
const showSpecialOnly = ref(false)

const filteredItems = computed(() => {
  let filtered = items.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(item =>
      item.name.toLowerCase().includes(query) ||
      item.description?.toLowerCase().includes(query)
    )
  }

  if (selectedType.value) {
    filtered = filtered.filter(item => item.type_id === selectedType.value)
  }

  if (showSpecialOnly.value) {
    filtered = filtered.filter(item => item.special || item.special_edition)
  }

  return filtered
})

onMounted(async () => {
  try {
    const [itemsResponse, typesResponse] = await Promise.all([
      supabase
        .from('items')
        .select('*, creator:users!items_creator_id_fkey(id, username), type:item_types(*)')
        .eq('is_public', true)
        .eq('is_approved', true)
        .order('created_at', { ascending: false }),
      supabase
        .from('item_types')
        .select('*')
        .order('name'),
    ])

    if (!itemsResponse.error) items.value = itemsResponse.data || []
    if (!typesResponse.error) itemTypes.value = typesResponse.data || []
  } catch (error) {
    console.error('Error loading shop data:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="mb-8">
      <h1 class="font-display text-3xl font-bold text-white mb-2">Shop</h1>
      <p class="text-neutral-400">Browse and purchase items for your avatar</p>
    </div>

    <div class="flex flex-col md:flex-row gap-8">
      <aside class="w-full md:w-64 flex-shrink-0">
        <div class="card p-4 space-y-6 sticky top-20">
          <div>
            <h3 class="text-sm font-semibold text-neutral-300 mb-3">Search</h3>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search items..."
              class="input"
            />
          </div>

          <div>
            <h3 class="text-sm font-semibold text-neutral-300 mb-3">Category</h3>
            <div class="space-y-1">
              <button
                @click="selectedType = null"
                class="w-full text-left px-3 py-2 rounded-lg text-sm transition-colors"
                :class="selectedType === null ? 'bg-primary-500/20 text-primary-300' : 'text-neutral-400 hover:bg-neutral-700'"
              >
                All Items
              </button>
              <button
                v-for="type in itemTypes"
                :key="type.id"
                @click="selectedType = type.id"
                class="w-full text-left px-3 py-2 rounded-lg text-sm transition-colors"
                :class="selectedType === type.id ? 'bg-primary-500/20 text-primary-300' : 'text-neutral-400 hover:bg-neutral-700'"
              >
                {{ type.display_name }}
              </button>
            </div>
          </div>

          <div>
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                v-model="showSpecialOnly"
                type="checkbox"
                class="w-4 h-4 rounded border-neutral-600 bg-neutral-700 text-primary-500 focus:ring-primary-500"
              />
              <span class="text-sm text-neutral-300">Special items only</span>
            </label>
          </div>
        </div>
      </aside>

      <div class="flex-1">
        <div v-if="loading" class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          <div v-for="i in 12" :key="i" class="card animate-pulse p-4">
            <div class="w-full aspect-square bg-neutral-700 rounded-lg mb-3"></div>
            <div class="h-4 bg-neutral-700 rounded w-3/4 mb-2"></div>
            <div class="h-3 bg-neutral-700 rounded w-1/2"></div>
          </div>
        </div>

        <div v-else-if="filteredItems.length === 0" class="text-center py-16">
          <svg class="w-16 h-16 text-neutral-600 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M12 2a10 10 0 100 20 10 10 0 000-20z" />
          </svg>
          <p class="text-neutral-400 mb-2">No items found</p>
          <p class="text-neutral-500 text-sm">Try adjusting your filters or search query</p>
        </div>

        <div v-else class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          <RouterLink
            v-for="item in filteredItems"
            :key="item.id"
            :to="`/shop/${item.id}`"
            class="card group hover:border-primary-500 transition-colors"
          >
            <div class="p-4">
              <div class="w-full aspect-square bg-neutral-700 rounded-lg mb-3 overflow-hidden relative">
                <img
                  v-if="item.thumbnail_url"
                  :src="item.thumbnail_url"
                  :alt="item.name"
                  class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <div v-else class="w-full h-full flex items-center justify-center">
                  <svg class="w-12 h-12 text-neutral-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                  </svg>
                </div>
                <span v-if="item.special || item.special_edition" class="absolute top-2 right-2 badge-warning">Special</span>
              </div>
              <h3 class="text-white text-sm font-medium truncate group-hover:text-primary-400 transition-colors">{{ item.name }}</h3>
              <div class="flex items-center gap-2 mt-1">
                <span v-if="item.price_bucks" class="text-warning-400 text-sm">{{ item.price_bucks }} Bucks</span>
                <span v-else-if="item.price_bits" class="text-success-400 text-sm">{{ item.price_bits }} Bits</span>
                <span v-else class="text-neutral-500 text-sm">Free</span>
              </div>
              <p v-if="item.type" class="text-neutral-500 text-xs mt-1">{{ item.type.display_name }}</p>
            </div>
          </RouterLink>
        </div>

        <p v-if="!loading" class="text-neutral-500 text-sm text-center mt-8">
          Showing {{ filteredItems.length }} of {{ items.length }} items
        </p>
      </div>
    </div>
  </div>
</template>
