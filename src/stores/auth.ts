import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import type { User, Session } from '@supabase/supabase-js'

interface Profile {
  id: string
  username: string
  description: string | null
  avatar_items: Record<string, unknown>
  avatar_colors: Record<string, string>
  bucks: number
  bits: number
  power: number
  created_at: string
  last_online: string
  theme: number
  is_verified_designer: boolean
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const session = ref<Session | null>(null)
  const profile = ref<Profile | null>(null)
  const loading = ref(false)
  const initialized = ref(false)

  const isAuthenticated = computed(() => !!user.value && !!profile.value)
  const isAdmin = computed(() => profile.value?.power && profile.value.power > 0)

  async function initialize() {
    try {
      const { data: { session: currentSession } } = await supabase.auth.getSession()

      if (currentSession) {
        session.value = currentSession
        user.value = currentSession.user
        await fetchProfile()
      }
    } catch (error) {
      console.error('Error initializing auth:', error)
    } finally {
      initialized.value = true
    }

    supabase.auth.onAuthStateChange(async (event, newSession) => {
      session.value = newSession
      user.value = newSession?.user ?? null

      if (event === 'SIGNED_IN' && newSession) {
        await fetchProfile()
      } else if (event === 'SIGNED_OUT') {
        profile.value = null
      }
    })
  }

  async function fetchProfile() {
    if (!user.value) return

    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', user.value.id)
      .single()

    if (error) {
      console.error('Error fetching profile:', error)
    } else {
      profile.value = data as Profile
    }
  }

  async function signUp(email: string, password: string, username: string) {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            username: username
          }
        }
      })

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error signing up:', error)
      return { success: false, error }
    } finally {
      loading.value = false
    }
  }

  async function signIn(email: string, password: string) {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) throw error

      session.value = data.session
      user.value = data.user
      await fetchProfile()

      return { success: true, data }
    } catch (error) {
      console.error('Error signing in:', error)
      return { success: false, error }
    } finally {
      loading.value = false
    }
  }

  async function signOut() {
    try {
      await supabase.auth.signOut()
      user.value = null
      session.value = null
      profile.value = null
    } catch (error) {
      console.error('Error signing out:', error)
    }
  }

  async function updateProfile(updates: Partial<Profile>) {
    if (!profile.value) return

    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', profile.value.id)
      .select()
      .single()

    if (!error && data) {
      profile.value = data as Profile
    }

    return { data, error }
  }

  return {
    user,
    session,
    profile,
    loading,
    initialized,
    isAuthenticated,
    isAdmin,
    initialize,
    signUp,
    signIn,
    signOut,
    updateProfile,
    fetchProfile,
  }
})
