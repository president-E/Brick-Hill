<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { Crate } from '@/types'

const authStore = useAuthStore()
const inventory = ref<Crate[]>([])
const loading = ref(true)
const selectedType = ref<string | null>(null)

const filteredInventory = computed(() => {
  if (!selectedType.value) return inventory.value
  return inventory.value.filter(c => c.item?.type?.name === selectedType.value)
})

onMounted(async () => {
  if (!authStore.profile) return

  try {
    const { data, error } = await supabase
      .from('crates')
      .select('*, item:items(*, type:item_types(*), creator:users!items_creator_id_fkey(id, username))')
      .eq('user_id', authStore.profile.id)
      .order('acquired_at', { ascending: false })

    if (!error) inventory.value = data || []
  } catch (error) {
    console.error('Error loading inventory:', error)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="font-display text-3xl font-bold text-white mb-8">Inventory</h1>

    <div v-if="loading" class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4">
      <div v-for="i in 12" :key="i" class="card animate-pulse p-3 h-40"></div>
    </div>

    <div v-else-if="inventory.length === 0" class="card p-16 text-center">
      <svg class="w-16 h-16 text-neutral-600 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
      </svg>
      <p class="text-neutral-400 mb-2">No items in your inventory</p>
      <RouterLink to="/shop" class="text-primary-400 hover:text-primary-300">Visit the shop</RouterLink>
    </div>

    <div v-else class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4">
      <RouterLink
        v-for="crate in filteredInventory"
        :key="crate.id"
        :to="`/shop/${crate.item_id}`"
        class="card p-3 hover:border-primary-500 transition-colors"
      >
        <div class="w-full aspect-square bg-neutral-700 rounded overflow-hidden mb-2">
          <img
            v-if="crate.item?.thumbnail_url"
            :src="crate.item.thumbnail_url"
            :alt="crate.item.name"
            class="w-full h-full object-cover"
          />
        </div>
        <h3 class="text-white text-sm truncate">{{ crate.item?.name }}</h3>
        <p class="text-neutral-500 text-xs">{{ crate.item?.type?.display_name }}</p>
      </RouterLink>
    </div>
  </div>
</template>
