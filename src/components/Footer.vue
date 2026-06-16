<script setup lang="ts">
const currentYear = new Date().getFullYear()
</script>

<template>
  <footer class="bg-neutral-800 border-t border-neutral-700 mt-auto">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-8">
        <div>
          <h3 class="text-white font-semibold mb-4">Platform</h3>
          <ul class="space-y-2">
            <li><RouterLink to="/games" class="text-neutral-400 hover:text-white transition-colors">Games</RouterLink></li>
            <li><RouterLink to="/shop" class="text-neutral-400 hover:text-white transition-colors">Shop</RouterLink></li>
            <li><RouterLink to="/forum" class="text-neutral-400 hover:text-white transition-colors">Forum</RouterLink></li>
          </ul>
        </div>
        <div>
          <h3 class="text-white font-semibold mb-4">Account</h3>
          <ul class="space-y-2">
            <li><RouterLink to="/login" class="text-neutral-400 hover:text-white transition-colors">Log In</RouterLink></li>
            <li><RouterLink to="/register" class="text-neutral-400 hover:text-white transition-colors">Sign Up</RouterLink></li>
          </ul>
        </div>
        <div>
          <h3 class="text-white font-semibold mb-4">Community</h3>
          <ul class="space-y-2">
            <li><a href="#" class="text-neutral-400 hover:text-white transition-colors">Discord</a></li>
            <li><a href="#" class="text-neutral-400 hover:text-white transition-colors">Twitter</a></li>
            <li><a href="#" class="text-neutral-400 hover:text-white transition-colors">YouTube</a></li>
          </ul>
        </div>
        <div>
          <h3 class="text-white font-semibold mb-4">Legal</h3>
          <ul class="space-y-2">
            <li><a href="#" class="text-neutral-400 hover:text-white transition-colors">Terms of Service</a></li>
            <li><a href="#" class="text-neutral-400 hover:text-white transition-colors">Privacy Policy</a></li>
          </ul>
        </div>
      </div>
      <div class="mt-8 pt-8 border-t border-neutral-700 flex flex-col md:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <div class="w-6 h-6 bg-primary-500 rounded flex items-center justify-center">
            <span class="text-white font-bold text-sm">B</span>
          </div>
          <span class="text-neutral-400 text-sm">Brick Hill</span>
        </div>
        <p class="text-neutral-500 text-sm">&copy; {{ currentYear }} Brick Hill. All rights reserved.</p>
      </div>
    </div>
  </footer>
</template>
