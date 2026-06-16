<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'
import type { Item } from '@/types'

const authStore = useAuthStore()
const inventory = ref<Item[]>([])
const loading = ref(true)
const saving = ref(false)

const avatarColors = ref({
  head: 'F3B700',
  torso: 'B1B1B1',
  left_arm: 'F3B700',
  right_arm: 'F3B700',
  left_leg: 'E9EAEE',
  right_leg: 'E9EAEE',
})

const avatarItems = ref<Record<string, number[]>>({
  hats: [],
  face: 0,
  head: 0,
  tool: 0,
})

const colorPresets = [
  { name: 'Yellow', colors: { head: 'F3B700', torso: 'B1B1B1', left_arm: 'F3B700', right_arm: 'F3B700', left_leg: 'E9EAEE', right_leg: 'E9EAEE' } },
  { name: 'Blue', colors: { head: '3B82F6', torso: '60A5FA', left_arm: '3B82F6', right_arm: '3B82F6', left_leg: '1E40AF', right_leg: '1E40AF' } },
  { name: 'Red', colors: { head: 'EF4444', torso: 'FCA5A5', left_arm: 'EF4444', right_arm: 'EF4444', left_leg: '991B1B', right_leg: '991B1B' } },
  { name: 'Green', colors: { head: '22C55E', torso: '86EFAC', left_arm: '22C55E', right_arm: '22C55E', left_leg: '166534', right_leg: '166534' } },
  { name: 'White', colors: { head: 'F5F5F5', torso: 'E5E5E5', left_arm: 'F5F5F5', right_arm: 'F5F5F5', left_leg: 'D4D4D4', right_leg: 'D4D4D4' } },
  { name: 'Black', colors: { head: '262626', torso: '404040', left_arm: '262626', right_arm: '262626', left_leg: '171717', right_leg: '171717' } },
]

onMounted(async () => {
  if (!authStore.profile) return

  avatarColors.value = { ...authStore.profile.avatar_colors as typeof avatarColors.value }
  avatarItems.value = { ...authStore.profile.avatar_items as typeof avatarItems.value }

  try {
    const { data, error } = await supabase
      .from('crates')
      .select('*, item:items(*, type:item_types(*))')
      .eq('user_id', authStore.profile.id)

    if (!error && data) {
      inventory.value = data.map(c => c.item).filter(Boolean) as Item[]
    }
  } catch (error) {
    console.error('Error loading inventory:', error)
  } finally {
    loading.value = false
  }
})

async function saveAvatar() {
  if (!authStore.profile) return
  saving.value = true

  try {
    await authStore.updateProfile({
      avatar_colors: avatarColors.value,
      avatar_items: avatarItems.value,
    })
  } finally {
    saving.value = false
  }
}

function applyPreset(preset: typeof colorPresets[0]) {
  avatarColors.value = { ...preset.colors }
}
</script>

<template>
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="font-display text-3xl font-bold text-white mb-8">Avatar Editor</h1>

    <div class="grid lg:grid-cols-2 gap-8">
      <div class="space-y-6">
        <div class="card aspect-square flex items-center justify-center bg-neutral-800">
          <div class="w-48 h-48 relative">
            <div
              class="absolute bottom-0 w-48 h-32 bg-gradient-to-t from-transparent to-transparent"
              :style="{ backgroundColor: '#' + avatarColors.torso }"
            ></div>
            <div
              class="absolute top-0 w-48 h-24 rounded-t-3xl"
              :style="{ backgroundColor: '#' + avatarColors.head }"
            ></div>
            <div class="text-center text-white mt-2 text-sm">Avatar Preview</div>
          </div>
        </div>

        <button @click="saveAvatar" :disabled="saving" class="btn-primary w-full">
          {{ saving ? 'Saving...' : 'Save Avatar' }}
        </button>
      </div>

      <div class="space-y-6">
        <div class="card p-6">
          <h2 class="font-semibold text-white mb-4">Body Colors</h2>
          <div class="space-y-4">
            <div v-for="(color, part) in avatarColors" :key="part" class="flex items-center gap-4">
              <label class="text-neutral-400 w-24 capitalize">{{ part.replace('_', ' ') }}</label>
              <input
                :value="color"
                type="color"
                class="w-10 h-10 rounded cursor-pointer bg-transparent"
                @input="avatarColors[part] = ($event.target as HTMLInputElement).value.slice(1)"
              />
              <input
                :value="color"
                type="text"
                class="input w-24"
                maxlength="6"
                @input="avatarColors[part] = ($event.target as HTMLInputElement).value"
              />
            </div>
          </div>

          <h3 class="text-neutral-400 text-sm mt-6 mb-3">Presets</h3>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="preset in colorPresets"
              :key="preset.name"
              @click="applyPreset(preset)"
              class="px-3 py-1 bg-neutral-700 text-neutral-300 rounded-lg hover:bg-neutral-600 transition-colors text-sm"
            >
              {{ preset.name }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
