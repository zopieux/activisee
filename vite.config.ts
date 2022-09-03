import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import type { ViteDevServer } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import serveStatic from 'serve-static'
import { resolve } from 'path'

// MapBox expects Content-Encoding header for vector tiles.
const contentEncodingForTiles = () => ({
  name: 'content-encoding-for-tiles',
  configureServer(server: ViteDevServer) {
    return () => {
      server.middlewares.use('/', serveStatic(resolve(__dirname, 'public'), {
        setHeaders(res, path) {
          if (res.req.url.startsWith('/tiles/') && res.req.url.endsWith('.pbf')) {
            res.setHeader('Content-Encoding', 'gzip')
          }
        }
      }))
    }
  },
})

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue(), vueJsx(), contentEncodingForTiles()],
  publicDir: false,
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  build: {
    rollupOptions: {
      external: ['/_pagefind/pagefind.js'],
    }
  }
})
