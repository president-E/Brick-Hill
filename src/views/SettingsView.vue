<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { supabase } from '@/lib/supabase'

const authStore = useAuthStore()
const description = ref('')
const saving = ref(false)
const error = ref('')

onMounted(() => {
  if (authStore.profile) {
    description.value = authStore.profile.description || ''
  }
})

async function saveSettings() {
  if (!authStore.profile) return

  saving.value = true
  error.value = ''

  try {
    await authStore.updateProfile({ description: description.value })
  } catch (err) {
    error.value = 'Failed to save settings'
  } finally {
    saving.value = false
  }
}

async function signOut() {
  await authStore.signOut()
}
</script>

<template>
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="font-display text-3xl font-bold text-white mb-8">Settings</h1>

    <div class="space-y-6">
      <div class="card p-6">
        <h2 class="font-semibold text-white mb-4">Profile</h2>

        <div v-if="error" class="bg-error-500/20 text-error-300 px-4 py-3 rounded-lg text-sm mb-4">
          {{ error }}
        </div>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-neutral-300 mb-1">Description</label>
            <textarea
              v-model="description"
              rows="4"
              class="input"
              placeholder="Tell others about yourself..."
            ></textarea>
          </div>
          <button @click="saveSettings" :disabled="saving" class="btn-primary">
            {{ saving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </div>

      <div class="card p-6">
        <h2 class="font-semibold text-white mb-4">Account</h2>
        <p class="text-neutral-400 text-sm mb-4">
          Logged in as <span class="text-white">{{ authStore.profile?.username }}</span>
        </p>
        <button @click="signOut" class="btn-error">Sign Out</button>
      </div>
    </div>
  </div>
</template>
