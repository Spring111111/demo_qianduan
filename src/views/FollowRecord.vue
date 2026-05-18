<template>
  <div class="record-page">
    <!-- 下拉刷新列表 -->
    <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
      <div class="records-list" ref="recordsContainer" @scroll="handleScroll">
        <div v-if="records.length === 0" class="empty-tip">
          暂无跟进记录，点击右下角添加
        </div>
        <div v-for="record in records" :key="record.id" class="record-card" @click="goToRecordDetail(record)">
          <div class="record-subject">{{ record.subject }}</div>
          <div class="record-detail-preview">{{ record.detail }}</div>
          <div class="record-footer">
            <span class="record-next">{{ record.date }}</span>
          </div>
        </div>

        <div v-if="loadingMore" class="load-tip">
          <van-loading size="16px" /> 加载中...
        </div>
        <div v-if="!hasMore && records.length > 0" class="load-tip end">
          已经到底了~
        </div>
      </div>
    </van-pull-refresh>

    <!-- 添加按钮（悬浮） -->
    <div class="add-fab" @click="goToAddRecord">
      ＋
    </div>
  </div>
</template>

<script setup>
  import { ref, onMounted, onUnmounted } from 'vue'
  import { useProjectStore } from '../stores/project'

  const projectStore = useProjectStore()

  const records = ref([])
  const refreshing = ref(false)
  const loadingMore = ref(false)
  const hasMore = ref(true)
  const currentPage = ref(1)
  const pageSize = 8
  const recordsContainer = ref(null)

  // 格式化日期
  const formatDate = (dateStr) => {
    if (!dateStr) return ''
    return dateStr.slice(5, 16)
  }

  // 加载跟进记录（分页）
  const loadRecords = async (isReset = false) => {
    if (loadingMore.value && !isReset) return
    if (!isReset && !hasMore.value) return

    loadingMore.value = true
    await new Promise(r => setTimeout(r, 300))

    const projects = projectStore.getProjects()
    const raw = localStorage.getItem('devops_records') || '[]'
    const allRecords = JSON.parse(raw)
      .map(record => {
        const project = projects.find(p => p.id === record.projectId)
        return { ...record, date: project ? project.date : '' }
      })
      .sort((a, b) => new Date(b.createTime) - new Date(a.createTime))

    const start = (isReset ? 0 : (currentPage.value - 1) * pageSize)
    const end = start + pageSize
    const pageData = allRecords.slice(start, end)

    if (isReset) {
      records.value = pageData
      currentPage.value = 2
      hasMore.value = end < allRecords.length
      if (recordsContainer.value) {
        recordsContainer.value.scrollTop = 0
      }
    } else {
      records.value = [...records.value, ...pageData]
      currentPage.value++
      hasMore.value = end < allRecords.length
    }

    loadingMore.value = false
  }

  // 下拉刷新
  const onRefresh = async () => {
    refreshing.value = true
    currentPage.value = 1
    hasMore.value = true
    await loadRecords(true)
    refreshing.value = false
  }

  // 滑动到底部自动加载
  const handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target
    if (scrollTop + clientHeight >= scrollHeight - 100 && !loadingMore.value && hasMore.value) {
      loadRecords(false)
    }
  }

  // 跳转到记录详情/编辑页
  const goToRecordDetail = (record) => {
    localStorage.setItem('currentRecord', JSON.stringify(record))
    localStorage.setItem('currentProjectId', record.projectId)
    window.location.hash = 'record-edit'
  }

  // 跳转到添加记录页
  const goToAddRecord = () => {
    const projects = projectStore.getProjects()
    if (projects.length > 0) {
      localStorage.setItem('currentProjectId', projects[0].id)
    }
    localStorage.removeItem('currentRecord')
    window.location.hash = 'record-edit'
  }

  // 监听页面返回时刷新
  const handleHashChange = () => {
    const hash = window.location.hash.slice(1)
    if (hash !== 'record-edit' && hash !== 'record-add') {
      currentPage.value = 1
      hasMore.value = true
      loadRecords(true)
    }
  }

  // 监听页面可见性变化（从其他页面返回时刷新）
  const handleVisibilityChange = () => {
    if (!document.hidden) {
      currentPage.value = 1
      hasMore.value = true
      loadRecords(true)
    }
  }

  onMounted(() => {
    loadRecords(true)
    window.addEventListener('hashchange', handleHashChange)
  })

  onUnmounted(() => {
    window.removeEventListener('hashchange', handleHashChange)
  })
</script>

<style scoped>
  .record-page {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    position: relative;
    background: #f5f7fb;
  }

  .records-list {
    flex: 1;
    overflow-y: auto;
    padding: 12px;
    -webkit-overflow-scrolling: touch;
  }

  .record-card {
    background: white;
    border-radius: 12px;
    padding: 14px;
    margin-bottom: 12px;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  }

  .record-card:active {
    transform: scale(0.98);
  }

  .record-subject {
    font-size: 15px;
    font-weight: 600;
    color: #1a2c3e;
    margin-bottom: 8px;
  }

  .record-detail-preview {
    font-size: 13px;
    color: #5a6e8a;
    line-height: 1.4;
    margin-bottom: 10px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
  }

  .record-footer {
    display: flex;
    justify-content: flex-end;
    font-size: 11px;
    color: #8e9eae;
  }

  .record-next {
    color: #8e9eae;
  }

  .load-tip {
    text-align: center;
    padding: 16px;
    font-size: 12px;
    color: #b0b8c4;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }

  .load-tip.end {
    padding-bottom: 30px;
  }

  .add-fab {
    position: absolute;
    bottom: 20px;
    right: 16px;
    width: 56px;
    height: 56px;
    background: #006241;
    border-radius: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 28px;
    font-weight: bold;
    box-shadow: 0 4px 12px rgba(0, 98, 65, 0.4);
    cursor: pointer;
    z-index: 20;
    transition: transform 0.1s;
  }

  .add-fab:active {
    transform: scale(0.94);
  }

  .empty-tip {
    text-align: center;
    padding: 60px 20px;
    color: #8e9eae;
    font-size: 14px;
  }
</style>