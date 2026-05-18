<template>
  <div class="app-container">
    <div v-if="currentView === 'home'" class="home-view">
      <div class="header">
        <h1>跟进详情 - DevOpsGPT</h1>
      </div>

      <div class="tabs">
        <div :class="['tab-item', { active: activeTab === 'project' }]" @click="activeTab = 'project'">
          项目详情
        </div>
        <div :class="['tab-item', { active: activeTab === 'record' }]" @click="activeTab = 'record'">
          跟进记录
        </div>
      </div>

      <div class="content">
        <ProjectDetail v-show="activeTab === 'project'" />
        <FollowRecord v-show="activeTab === 'record'" />
      </div>
    </div>

    <RecordEdit v-else-if="currentView === 'record-edit'" />
  </div>
</template>

<script setup>
  import { ref, onMounted, onUnmounted } from 'vue'
  import ProjectDetail from './views/ProjectDetail.vue'
  import FollowRecord from './views/FollowRecord.vue'
  import RecordEdit from './views/RecordEdit.vue'

  const activeTab = ref('record')
  const currentView = ref('home')

  const handleHashChange = () => {
    const hash = window.location.hash.slice(1)
    if (hash === 'record-edit') {
      currentView.value = 'record-edit'
    } else {
      currentView.value = 'home'
    }
  }

  onMounted(() => {
    window.addEventListener('hashchange', handleHashChange)
    handleHashChange()
  })

  onUnmounted(() => {
    window.removeEventListener('hashchange', handleHashChange)
  })
</script>

<style>
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    background-color: #f5f5f5;
  }

  .app-container {
    width: 100%;
    max-width: 500px;
    height: 100vh;
    margin: 0 auto;
    background: #f5f5f5;
    display: flex;
    flex-direction: column;
    position: relative;
  }

  .home-view {
    display: flex;
    flex-direction: column;
    height: 100%;
  }

  .header {
    background: linear-gradient(135deg, #006241 0%, #00a86b 100%);
    padding: 20px 20px;
    flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(0, 98, 65, 0.3);
  }

  .header h1 {
    font-size: 20px;
    font-weight: 600;
    color: white;
    margin: 0;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }

  .tabs {
    display: flex;
    background: white;
    border-bottom: 1px solid #e9ecef;
    flex-shrink: 0;
  }

  .tab-item {
    flex: 1;
    text-align: center;
    padding: 14px 0;
    font-size: 15px;
    font-weight: 500;
    color: #6c7a8e;
    cursor: pointer;
    position: relative;
    transition: all 0.2s;
    background: white;
  }

  .tab-item:first-child {
    border-right: 1px solid #e9ecef;
  }

  .tab-item.active {
    color: #006241;
    font-weight: 600;
    background: linear-gradient(180deg, #f8fff9 0%, #ffffff 100%);
  }

  .tab-item.active::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 3px;
    background: linear-gradient(90deg, #006241 0%, #00a86b 100%);
  }

  .content {
    flex: 1;
    overflow: hidden;
  }
</style>