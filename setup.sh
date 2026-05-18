#!/bin/bash

# 创建 package.json
cat > package.json << 'PKG'
{
  "name": "customer-followup",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "vue": "^3.3.4",
    "pinia": "^2.1.0",
    "vant": "^4.6.0",
    "dayjs": "^1.11.9"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.2.0",
    "vite": "^4.4.0",
    "unplugin-auto-import": "^0.16.0",
    "unplugin-vue-components": "^0.25.0"
  }
}
PKG

# 创建 vite.config.js
cat > vite.config.js << 'VITE'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { VantResolver } from 'unplugin-vue-components/resolvers'

export default defineConfig({
  plugins: [
    vue(),
    AutoImport({
      imports: ['vue', 'pinia'],
      dts: 'src/auto-imports.d.ts'
    }),
    Components({
      resolvers: [VantResolver()],
      dts: 'src/components.d.ts'
    })
  ],
  server: {
    host: '0.0.0.0',
    port: 5173,
    open: true
  },
  resolve: {
    alias: {
      '@': '/src'
    }
  }
})
VITE

# 创建 index.html
cat > index.html << 'HTML'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>客户跟进助手</title>
</head>
<body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
</body>
</html>
HTML

# 创建 src 目录和文件
mkdir -p src/{pages,components,stores,utils,mock,style}

# 创建 main.js
cat > src/main.js << 'MAIN'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import 'vant/lib/index.css'
import './style/common.css'
import './mock/db'

const app = createApp(App)
app.use(createPinia())
app.mount('#app')
MAIN

# 创建 App.vue
cat > src/App.vue << 'APP'
<template>
  <div class="app-wrapper">
    <div class="nav-bar">
      <div :class="['nav-item', { active: activeTab === 'projects' }]" @click="activeTab = 'projects'">
        项目列表
      </div>
      <div v-if="selectedProject" :class="['nav-item', { active: activeTab === 'records' }]" @click="activeTab = 'records'">
        跟进记录
      </div>
    </div>

    <ProjectList v-show="activeTab === 'projects'" @select="handleSelectProject" />
    
    <div v-show="activeTab === 'records'" style="position: relative;">
      <FollowRecords :project="selectedProject" />
      <div class="fab" @click="showModal = true">＋</div>
    </div>

    <AddRecordModal v-model:show="showModal" :project-id="selectedProject?.id" @success="onRecordAdded" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useProjectStore } from './stores/project'
import ProjectList from './pages/ProjectList.vue'
import FollowRecords from './pages/FollowRecords.vue'
import AddRecordModal from './components/AddRecordModal.vue'

const store = useProjectStore()
store.loadProjects()

const activeTab = ref('projects')
const selectedProject = ref(null)
const showModal = ref(false)

const handleSelectProject = (proj) => {
  selectedProject.value = proj
  activeTab.value = 'records'
}

const onRecordAdded = () => {
  store.loadProjects()
  const temp = selectedProject.value
  selectedProject.value = null
  setTimeout(() => { selectedProject.value = temp }, 10)
}
</script>

<style>
.app-wrapper {
  max-width: 500px;
  margin: 0 auto;
  background: #f5f7fc;
  min-height: 100vh;
  position: relative;
}
.nav-bar {
  background: white;
  padding: 12px 20px;
  display: flex;
  gap: 28px;
  border-bottom: 1px solid #eef2f6;
  position: sticky;
  top: 0;
  z-index: 10;
}
.nav-item {
  font-size: 18px;
  font-weight: 600;
  color: #7e8b9c;
  cursor: pointer;
  padding-bottom: 6px;
  border-bottom: 2px solid transparent;
}
.nav-item.active {
  color: #006241;
  border-bottom-color: #006241;
}
.fab {
  position: fixed;
  bottom: 24px;
  right: calc(50% - 220px);
  width: 56px;
  height: 56px;
  background: #006241;
  border-radius: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 28px;
  box-shadow: 0 4px 12px rgba(0,98,65,0.3);
  cursor: pointer;
  z-index: 20;
}
@media (max-width: 500px) {
  .fab { right: 20px; }
}
</style>
APP

# 创建 stores/project.js
cat > src/stores/project.js << 'STORE'
import { defineStore } from 'pinia'

const STORAGE_PROJECTS_KEY = 'devops_projects'
const STORAGE_RECORDS_KEY = 'devops_records'

export const useProjectStore = defineStore('project', {
  state: () => ({
    projects: [],
    currentProject: null
  }),
  actions: {
    loadProjects() {
      const raw = localStorage.getItem(STORAGE_PROJECTS_KEY) || '[]'
      const projects = JSON.parse(raw)
      this.projects = projects.map(p => ({
        ...p,
        lastRecord: this.getLatestRecord(p.id)
      }))
    },
    getLatestRecord(projectId) {
      const records = this.getRecordsByProject(projectId)
      return records.length > 0 ? records[0] : null
    },
    getRecordsByProject(projectId) {
      const all = JSON.parse(localStorage.getItem(STORAGE_RECORDS_KEY) || '[]')
      return all.filter(r => r.projectId === projectId)
        .sort((a, b) => new Date(b.createTime) - new Date(a.createTime))
    },
    getPaginatedRecords(projectId, page, pageSize = 5) {
      const records = this.getRecordsByProject(projectId)
      const start = (page - 1) * pageSize
      const data = records.slice(start, start + pageSize)
      return {
        data,
        hasMore: start + pageSize < records.length,
        total: records.length
      }
    },
    addRecord(projectId, record) {
      const all = JSON.parse(localStorage.getItem(STORAGE_RECORDS_KEY) || '[]')
      const newRecord = {
        id: Date.now().toString(),
        projectId,
        subject: record.subject,
        detail: record.detail,
        nextTime: record.nextTime || '',
        createTime: new Date().toISOString().replace('T', ' ').slice(0, 19)
      }
      all.unshift(newRecord)
      localStorage.setItem(STORAGE_RECORDS_KEY, JSON.stringify(all))
      return newRecord
    }
  }
})
STORE

# 创建 pages/ProjectList.vue
cat > src/pages/ProjectList.vue << 'PROJECT'
<template>
  <div class="project-list">
    <div v-for="proj in store.projects" :key="proj.id" class="project-card" @click="$emit('select', proj)">
      <div class="project-header">
        <span class="project-name">{{ proj.name }}</span>
        <span class="project-date">{{ proj.date }}</span>
      </div>
      <div class="project-desc">{{ proj.desc }}</div>
      <div class="recent-tag" v-if="proj.lastRecord">
        📋 最近跟进: {{ proj.lastRecord.subject }}
      </div>
      <div class="recent-tag" v-else>暂无跟进记录</div>
    </div>
    <van-empty v-if="store.projects.length === 0" description="暂无项目" />
  </div>
</template>

<script setup>
import { useProjectStore } from '../stores/project'
const store = useProjectStore()
defineEmits(['select'])
</script>

<style scoped>
.project-list { padding: 16px; }
.project-card {
  background: white;
  border-radius: 24px;
  padding: 18px 16px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.03);
  cursor: pointer;
  border: 1px solid #edf2f8;
}
.project-card:active { transform: scale(0.98); }
.project-header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 8px; }
.project-name { font-size: 18px; font-weight: 700; color: #0f2b2d; }
.project-date { font-size: 12px; color: #7c8b9c; background: #f0f3f9; padding: 4px 10px; border-radius: 30px; }
.project-desc { font-size: 14px; color: #3a4a66; margin: 8px 0; }
.recent-tag { font-size: 12px; color: #006241; background: #e6f4ea; display: inline-block; padding: 4px 12px; border-radius: 50px; }
</style>
PROJECT

# 创建 pages/FollowRecords.vue
cat > src/pages/FollowRecords.vue << 'RECORD'
<template>
  <div class="records-page" ref="scrollContainer">
    <div class="header-info">
      <div class="title">{{ project?.name }}</div>
      <div class="count">共 {{ total }} 条记录 · 下拉刷新</div>
    </div>

    <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
      <div v-if="list.length">
        <div v-for="item in list" :key="item.id" class="record-item">
          <div class="subject">{{ item.subject }}</div>
          <div class="detail">{{ item.detail }}</div>
          <div class="meta">
            <span>📅 {{ formatTime(item.createTime) }}</span>
            <span v-if="item.nextTime">⏰ 下次: {{ item.nextTime }}</span>
          </div>
        </div>
      </div>
      <van-empty v-else description="暂无跟进记录" />

      <div v-if="loadingMore" class="load-tip">加载更多中...</div>
      <div v-if="!hasMore && list.length" class="load-tip end">—— 已经到底了 ——</div>
    </van-pull-refresh>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { useProjectStore } from '../stores/project'

const props = defineProps({ project: Object })
const store = useProjectStore()

const list = ref([])
const currentPage = ref(1)
const hasMore = ref(true)
const loadingMore = ref(false)
const refreshing = ref(false)
const total = ref(0)
const pageSize = 5
const scrollContainer = ref(null)

const loadRecords = async (isReset = false) => {
  if (loadingMore.value) return
  if (!isReset && !hasMore.value) return
  loadingMore.value = true
  await new Promise(r => setTimeout(r, 300))
  const page = isReset ? 1 : currentPage.value
  const { data, hasMore: more, total: t } = store.getPaginatedRecords(props.project.id, page, pageSize)
  if (isReset) {
    list.value = data
    currentPage.value = 2
  } else {
    list.value = [...list.value, ...data]
    currentPage.value = page + 1
  }
  hasMore.value = more
  total.value = t
  loadingMore.value = false
  if (isReset && refreshing.value) refreshing.value = false
}

const onRefresh = async () => {
  refreshing.value = true
  currentPage.value = 1
  hasMore.value = true
  await loadRecords(true)
}

const handleScroll = () => {
  if (!scrollContainer.value) return
  if (loadingMore.value || !hasMore.value) return
  const { scrollTop, scrollHeight, clientHeight } = scrollContainer.value
  if (scrollTop + clientHeight >= scrollHeight - 80) {
    loadRecords(false)
  }
}

watch(() => props.project, async () => {
  if (!props.project) return
  currentPage.value = 1
  hasMore.value = true
  await loadRecords(true)
  await nextTick()
  if (scrollContainer.value) {
    scrollContainer.value.scrollTop = 0
  }
}, { immediate: true })

onMounted(() => {
  if (scrollContainer.value) {
    scrollContainer.value.addEventListener('scroll', handleScroll)
  }
})
onUnmounted(() => {
  if (scrollContainer.value) {
    scrollContainer.value.removeEventListener('scroll', handleScroll)
  }
})

const formatTime = (t) => t ? t.slice(5, 16) : ''
</script>

<style scoped>
.records-page {
  height: calc(100vh - 100px);
  overflow-y: auto;
  padding: 16px;
  padding-bottom: 80px;
}
.header-info { margin-bottom: 16px; }
.title { font-size: 20px; font-weight: 700; color: #0f2b2d; }
.count { font-size: 13px; color: #6f7d95; margin-top: 4px; }
.record-item {
  background: white;
  border-radius: 20px;
  margin-bottom: 14px;
  padding: 16px;
  border-left: 4px solid #1e7b4b;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.subject { font-weight: 700; font-size: 16px; margin-bottom: 8px; }
.detail { font-size: 14px; color: #2c3e50; background: #f8fafd; padding: 10px; border-radius: 14px; margin: 8px 0; }
.meta { display: flex; justify-content: space-between; font-size: 12px; color: #6f7d95; }
.load-tip { text-align: center; padding: 16px; color: #98a9bc; font-size: 13px; }
.end { padding-top: 8px; }
</style>
RECORD

# 创建 components/AddRecordModal.vue
cat > src/components/AddRecordModal.vue << 'MODAL'
<template>
  <van-dialog v-model:show="visible" title="添加跟进记录" show-cancel-button @confirm="handleSubmit" @cancel="resetForm">
    <div style="padding: 8px 20px 20px;">
      <van-field v-model="form.subject" label="主题" placeholder="请输入沟通主题" required :rules="[{ required: true }]" />
      <van-field v-model="form.detail" label="沟通详情" type="textarea" rows="3" placeholder="详细记录沟通内容" required />
      <van-field v-model="form.nextTime" label="下次沟通时间" placeholder="例如 2024-07-10 14:00" />
    </div>
  </van-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useProjectStore } from '../stores/project'
import { showToast } from 'vant'

const props = defineProps({ show: Boolean, projectId: String })
const emit = defineEmits(['update:show', 'success'])

const store = useProjectStore()
const visible = ref(false)
const form = ref({ subject: '', detail: '', nextTime: '' })

watch(() => props.show, (val) => { visible.value = val })
watch(visible, (val) => { emit('update:show', val) })

const handleSubmit = () => {
  if (!form.value.subject || !form.value.detail) {
    showToast('主题和沟通详情为必填项')
    return false
  }
  if (props.projectId) {
    store.addRecord(props.projectId, form.value)
    showToast('添加成功')
    resetForm()
    emit('success')
    return true
  }
  return false
}

const resetForm = () => {
  form.value = { subject: '', detail: '', nextTime: '' }
}
</script>
MODAL

# 创建 mock/db.js
cat > src/mock/db.js << 'DB'
const STORAGE_PROJECTS_KEY = 'devops_projects'
const STORAGE_RECORDS_KEY = 'devops_records'

const seedProjects = [
  { id: 'p1', name: '星巴克咖啡商谈细节', date: '06-09', desc: '沟通投资细节，估值及股权占比初步洽谈。' },
  { id: 'p2', name: '跨赴科技办公室深入了解', date: '06-08', desc: '深入沟通项目，了解产品和业务的进展，打算投一个亿。' },
  { id: 'p3', name: '奇绩 DemoDay', date: '06-07', desc: '第一次在DemoDay上接触，印象不错，后续跟进技术细节。' }
]

const seedRecords = [
  { id: 'r1', projectId: 'p1', subject: '星巴克咖啡商谈细节', detail: '沟通投资细节：双方就首轮融资额度、投后估值达成初步意向。', createTime: '2024-06-09 14:30:00', nextTime: '2024-06-20 10:00:00' },
  { id: 'r2', projectId: 'p2', subject: '跨赴科技办公室深入了解', detail: 'CTO展示产品demo，明确投资意向一个亿。', createTime: '2024-06-08 11:20:00', nextTime: '2024-06-18 15:00:00' },
  { id: 'r3', projectId: 'p3', subject: '奇绩 DemoDay 初接触', detail: '创始人路演效果很好，约定技术尽调。', createTime: '2024-06-07 09:45:00', nextTime: '2024-06-14 16:00:00' },
  { id: 'r4', projectId: 'p1', subject: '星巴克二次跟进', detail: '探讨合作模式与品牌联名可能性。', createTime: '2024-06-10 18:20:00', nextTime: '2024-06-25 14:00:00' }
]

if (!localStorage.getItem(STORAGE_PROJECTS_KEY)) {
  localStorage.setItem(STORAGE_PROJECTS_KEY, JSON.stringify(seedProjects))
}
if (!localStorage.getItem(STORAGE_RECORDS_KEY)) {
  localStorage.setItem(STORAGE_RECORDS_KEY, JSON.stringify(seedRecords))
}
DB

# 创建 style/common.css
cat > src/style/common.css << 'CSS'
* { margin: 0; padding: 0; box-sizing: border-box; }
body { background: #f5f7fc; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
::-webkit-scrollbar { width: 4px; background: transparent; }
::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
CSS

echo "✅ 项目文件创建完成！"
echo "📦 现在运行: pnpm install"
