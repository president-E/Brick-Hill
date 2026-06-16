<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

async function handleLogin() {
  error.value = ''
  loading.value = true

  try {
    const { success, error: err } = await authStore.signIn(email.value, password.value)

    if (success) {
      const redirect = route.query.redirect as string || '/dashboard'
      router.push(redirect)
    } else {
      error.value = err instanceof Error ? err.message : 'Failed to sign in'
    }
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'An error occurred'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-neutral-900 py-12 px-4">
    <div class="max-w-md w-full">
      <div class="text-center mb-8">
        <RouterLink to="/" class="inline-flex items-center gap-2 mb-6">
          <div class="w-10 h-10 bg-primary-500 rounded-lg flex items-center justify-center">
            <span class="text-white font-bold text-xl">B</span>
          </div>
          <span class="font-display font-bold text-2xl text-white">Brick Hill</span>
        </RouterLink>
        <h1 class="font-display text-3xl font-bold text-white mb-2">Welcome back</h1>
        <p class="text-neutral-400">Sign in to your account to continue</p>
      </div>

      <form @submit.prevent="handleLogin" class="card p-6 space-y-6">
        <div v-if="error" class="bg-error-500/20 border border-error-500/50 text-error-300 px-4 py-3 rounded-lg text-sm">
          {{ error }}
        </div>

        <div class="space-y-4">
          <div>
            <label for="email" class="block text-sm font-medium text-neutral-300 mb-1">Email</label>
            <input
              id="email"
              v-model="email"
              type="email"
              required
              class="input"
              placeholder="you@example.com"
            />
          </div>

          <div>
            <label for="password" class="block text-sm font-medium text-neutral-300 mb-1">Password</label>
            <input
              id="password"
              v-model="password"
              type="password"
              required
              class="input"
              placeholder="Enter your password"
            />
          </div>
        </div>

        <button
          type="submit"
          :disabled="loading"
          class="btn-primary w-full py-3"
          :class="{ 'opacity-50 cursor-not-allowed': loading }"
        >
          <svg v-if="loading" class="animate-spin h-5 w-5 mr-2" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none" />
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
          {{ loading ? 'Signing in...' : 'Sign In' }}
        </button>

        <p class="text-center text-neutral-400 text-sm">
          Don't have an account?
          <RouterLink to="/register" class="text-primary-400 hover:text-primary-300">Sign up</RouterLink>
        </p>
      </form>
    </div>
  </div>
</template>
