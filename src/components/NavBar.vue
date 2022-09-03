<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
let pagefind: { search: any }
(async function () {
  // String interpolation forces an invalid Vite "dynamic import" which AFAICT
  // is the only way to tell Vite we know what we're doing and let us use native
  // JS module import()s. Javascript is definitely a very sane ecosystem.
  const pf = 'pagefind'
  pagefind = await import(/* @vite-ignore */`/_${pf}/${pf}.js`)
})()

const results = ref([])

async function onSearch(e: any) {
  const s = await pagefind.search(e.target.value)
  const dat = await Promise.all(s.results.map((r: any) => r.data()))
  results.value = dat
}
</script>

<template>
  <div>
    <h3>activisee™</h3>
    <input type="search" placeholder="Search…" @keyup="onSearch" />
    <ul>
      <li v-for="r in results" v-bind:key="r.raw_url">{{ r.meta.title }}<br /><small>{{ r.raw_url }}</small></li>
    </ul>
    <RouterLink to="/about">About</RouterLink>
  </div>
</template>

<style scoped lang="sass">
div
  display: flex
  flex-direction: column
  gap: 1rem

input[type=search]
  padding: 0.5rem
</style>
