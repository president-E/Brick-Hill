<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { Item } from '@/types'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const item = ref<Item | null>(null)
const loading = ref(true)
const purchasing = ref(false)
const error = ref('')

const itemId = computed(() => parseInt(route.params.id as string))
const canAffordBucks = computed(() => authStore.profile && item.value && authStore.profile.bucks >= (item.value.price_bucks || 0))
const canAffordBits = computed(() => authStore.profile && item.value && authStore.profile.bits >= (item.value.price_bits || 0))

async function purchase(bucks: boolean) {
  if (!item.value || !authStore.profile) return

  error.value = ''
  purchasing.value = true

  try {
    const price = bucks ? item.value.price_bucks : item.value.price_bits
    const currency = bucks ? 'bucks' : 'bits'

    if (!price || (authStore.profile[currency as keyof typeof authStore.profile] as number) < price) {
      error.value = 'Insufficient funds'
      return
    }

    const { error: purchaseError } = await supabase
      .from('crates')
      .insert({ user_id: authStore.profile.id, item_id: item.value.id })

    if (purchaseError) throw purchaseError

    await supabase
      .from('users')
      .update({ [currency]: authStore.profile[currency as keyof typeof authStore.profile] as number - price })
      .eq('id', authStore.profile.id)

    authStore.fetchProfile()
    router.push('/inventory')
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Purchase failed'
  } finally {
    purchasing.value = false
  }
}

onMounted(async () => {
  try {
    const { data, error: err } = await supabase
      .from('items')
      .select('*, creator:users!items_creator_id_fkey(id, username, is_verified_designer), type:item_types(*)')
      .eq('id', itemId.value)
      .single()

    if (err) throw err
    item.value = data as Item
  } catch (err) {
    console.error('Error loading item:', err)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div v-if="loading" class="animate-pulse grid md:grid-cols-2 gap-8">
      <div class="aspect-square bg-neutral-800 rounded-xl"></div>
      <div class="space-y-4">
        <div class="h-8 bg-neutral-800 rounded w-3/4"></div>
        <div class="h-4 bg-neutral-800 rounded w-1/2"></div>
      </div>
    </div>

    <div v-else-if="!item" class="text-center py-16">
      <h1 class="text-2xl text-white mb-2">Item not found</h1>
      <RouterLink to="/shop" class="text-primary-400">Back to shop</RouterLink>
    </div>

    <div v-else class="grid md:grid-cols-2 gap-8">
      <div class="card aspect-square bg-neutral-700 overflow-hidden">
        <img
          v-if="item.thumbnail_url"
          :src="item.thumbnail_url"
          :alt="item.name"
          class="w-full h-full object-cover"
        />
      </div>

      <div class="space-y-6">
        <div>
          <div class="flex items-center gap-3 mb-2">
            <h1 class="text-2xl font-bold text-white">{{ item.name }}</h1>
            <span v-if="item.special || item.special_edition" class="badge-warning">Special</span>
          </div>
          <p class="text-neutral-400">By {{ item.creator?.username }}</p>
          <p class="text-neutral-500 text-sm mt-2">{{ item.description || 'No description' }}</p>
        </div>

        <div class="card p-4 bg-neutral-800">
          <div class="flex items-center justify-between mb-4">
            <span class="text-neutral-400">Type</span>
            <span class="text-white">{{ item.type?.display_name || 'Unknown' }}</span>
          </div>
          <div v-if="item.special_edition" class="flex items-center justify-between mb-4">
            <span class="text-neutral-400">Stock</span>
            <span class="text-white">{{ item.special_q || 0 }}</span>
          </div>
          <div v-if="item.average_price" class="flex items-center justify-between">
            <span class="text-neutral-400">Average Price</span>
            <span class="text-warning-400">{{ item.average_price.toLocaleString() }} Bucks</span>
          </div>
        </div>

        <div v-if="error" class="bg-error-500/20 text-error-300 px-4 py-3 rounded-lg text-sm">
          {{ error }}
        </div>

        <div v-if="!authStore.isAuthenticated" class="text-center py-4">
          <RouterLink to="/login" class="btn-primary">Log in to purchase</RouterLink>
        </div>

        <div v-else-if="!item.is_approved || item.is_pending" class="text-center py-4 text-neutral-500">
          <p>This item is not available for purchase</p>
        </div>

        <div v-else class="space-y-3">
          <div v-if="item.price_bucks" class="flex items-center justify-between">
            <span class="text-warning-400 text-lg font-medium">{{ item.price_bucks }} Bucks</span>
            <button
              @click="purchase(true)"
              :disabled="purchasing || !canAffordBucks"
              class="btn-warning"
              :class="{ 'opacity-50 cursor-not-allowed': !canAffordBucks }"
            >
              {{ canAffordBucks ? 'Purchase' : 'Insufficient Funds' }}
            </button>
          </div>
          <div v-if="item.price_bits" class="flex items-center justify-between">
            <span class="text-success-400 text-lg font-medium">{{ item.price_bits }} Bits</span>
            <button
              @click="purchase(false)"
              :disabled="purchasing || !canAffordBits"
              class="btn-success"
              :class="{ 'opacity-50 cursor-not-allowed': !canAffordBits }"
            >
              {{ canAffordBits ? 'Purchase' : 'Insufficient Funds' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
