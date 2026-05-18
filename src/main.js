import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import 'vant/lib/index.css'
import './style/common.css'
import './mock/db'

const app = createApp(App)
app.use(createPinia())
app.mount('#app')