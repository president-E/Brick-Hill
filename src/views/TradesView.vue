<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { Trade } from '@/types'

const authStore = useAuthStore()
const trades = ref<Trade[]>([])
const loading = ref(true)
const activeTab = ref<'incoming' | 'outgoing' | 'completed'>('incoming')

onMounted(async () => {
  if (!authStore.profile) return

  try {
    const { data, error } = await supabase
      .from('trades')
      .select('*, sender:users!trades_sender_id_fkey(id, username), receiver:users!trades_receiver_id_fkey(id, username)')
      .or(`sender_id.eq.${authStore.profile.id},receiver_id.eq.${authStore.profile.id}`)
      .order('created_at', { ascending: false })

    if (!error) trades.value = data || []
  } catch (error) {
    console.error('Error loading trades:', error)
  } finally {
    loading.value = false
  }
})

const incomingTrades = () => trades.value.filter(t => t.receiver_id === authStore.profile?.id && t.status === 'pending')
const outgoingTrades = () => trades.value.filter(t => t.sender_id === authStore.profile?.id && t.status === 'pending')
const completedTrades = () => trades.value.filter(t => t.status !== 'pending')

async function respondToTrade(tradeId: number, accept: boolean) {
  const { error } = await supabase
    .from('trades')
    .update({ status: accept ? 'accepted' : 'declined' })
    .eq('id', tradeId)

  if (!error) {
    const trade = trades.value.find(t => t.id === tradeId)
    if (trade) trade.status = accept ? 'accepted' : 'declined'
  }
}
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="font-display text-3xl font-bold text-white mb-8">Trades</h1>

    <div class="flex gap-4 mb-6">
      <button
        @click="activeTab = 'incoming'"
        class="btn relative"
        :class="activeTab === 'incoming' ? 'btn-primary' : 'btn-ghost'"
      >
        Incoming
        <span v-if="incomingTrades().length > 0" class="absolute -top-1 -right-1 w-5 h-5 bg-error-500 text-white text-xs rounded-full flex items-center justify-center">
          {{ incomingTrades().length }}
        </span>
      </button>
      <button
        @click="activeTab = 'outgoing'"
        class="btn"
        :class="activeTab === 'outgoing' ? 'btn-primary' : 'btn-ghost'"
      >
        Outgoing
      </button>
      <button
        @click="activeTab = 'completed'"
        class="btn"
        :class="activeTab === 'completed' ? 'btn-primary' : 'btn-ghost'"
      >
        Completed
      </button>
    </div>

    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="card animate-pulse h-32"></div>
    </div>

    <div v-else class="space-y-4">
      <div v-for="trade in (activeTab === 'incoming' ? incomingTrades() : activeTab === 'outgoing' ? outgoingTrades() : completedTrades())" :key="trade.id" class="card p-4">
        <div class="flex items-center justify-between">
          <div>
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 bg-primary-500 rounded-lg flex items-center justify-center">
                <span class="text-white font-bold">{{ (trade.sender?.username || 'U').charAt(0) }}</span>
              </div>
              <div>
                <p class="text-white font-medium">{{ activeTab === 'incoming' ? trade.sender?.username : trade.receiver?.username }}</p>
                <p class="text-neutral-400 text-sm">
                  {{ trade.sender_items?.length || 0 }} items for {{ trade.receiver_items?.length || 0 }} items
                </p>
              </div>
            </div>
            <p class="text-neutral-500 text-xs mt-2">{{ new Date(trade.created_at).toLocaleDateString() }}</p>
          </div>
          <div class="flex items-center gap-3">
            <span
              class="badge"
              :class="{
                'badge-warning': trade.status === 'pending',
                'badge-success': trade.status === 'accepted',
                'badge-error': trade.status === 'declined',
              }"
            >
              {{ trade.status }}
            </span>
            <div v-if="activeTab === 'incoming' && trade.status === 'pending'" class="flex gap-2">
              <button @click="respondToTrade(trade.id, true)" class="btn-success">Accept</button>
              <button @click="respondToTrade(trade.id, false)" class="btn-error">Decline</button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="(activeTab === 'incoming' ? incomingTrades() : activeTab === 'outgoing' ? outgoingTrades() : completedTrades()).length === 0" class="card p-8 text-center text-neutral-500">
        <p>No {{ activeTab }} trades</p>
      </div>
    </div>
  </div>
</template>
