<script setup lang="ts">
import MainMap from '@/components/MainMap.vue'
import NavBar from '@/components/NavBar.vue'
</script>

<template>
  <aside>
    <NavBar />
  </aside>
  <main>
    <MainMap />
  </main>
</template>

<style scoped lang="sass">
main
  flex-grow: 1
  overflow: hidden
  height: 100vh
</style>
