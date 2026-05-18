<template>
  <div class="edit-page">
    <!-- 头部 -->
    <div class="header">
      <div class="back-btn" @click="goBack">
        ← 返回
      </div>
      <h1 class="title">{{ isEdit ? '编辑跟进记录' : '添加跟进记录' }}</h1>
      <div class="header-actions">
        <div v-if="isEdit" class="delete-btn" @click="deleteRecord">删除</div>
        <div class="save-btn" @click="saveRecord">保存</div>
      </div>
    </div>

    <!-- 表单内容 -->
    <div class="form-content">
      <!-- 沟通主题 -->
      <div class="form-group">
        <div class="form-label">
          沟通主题 <span class="required">*</span>
        </div>
        <input v-model="form.subject" type="text" class="form-input" placeholder="请输入沟通主题" />
      </div>

      <!-- 沟通详情 -->
      <div class="form-group">
        <div class="form-label">
          沟通详情 <span class="required">*</span>
        </div>
        <textarea v-model="form.detail" class="form-textarea" rows="6" placeholder="请输入沟通详情"></textarea>
      </div>

      <!-- 下次沟通时间 -->
      <div class="form-group">
        <div class="form-label">下次沟通时间</div>
        <input v-model="form.nextTime" type="datetime-local" class="form-input" />
      </div>

      <!-- 下次沟通内容 -->
      <div class="form-group">
        <div class="form-label">下次沟通内容</div>
        <textarea v-model="form.nextContent" class="form-textarea" rows="4" placeholder="请输入下次沟通需要讨论的内容..."></textarea>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { ref, onMounted } from 'vue'
  import { useProjectStore } from '../stores/project'
  import { showToast } from 'vant'

  const projectStore = useProjectStore()
  const isEdit = ref(false)
  const recordId = ref(null)
  const projectId = ref('')
  const form = ref({
    subject: '',
    detail: '',
    nextTime: '',
    nextContent: ''
  })

  // 返回上一页
  const goBack = () => {
    window.location.hash = ''
  }

  // 删除记录
  const deleteRecord = () => {
    if (confirm('确定要删除这条记录吗？')) {
      projectStore.deleteRecord(recordId.value)
      showToast('删除成功')
      setTimeout(() => {
        window.location.hash = ''
      }, 500)
    }
  }

  // 保存记录
  const saveRecord = () => {
    if (!form.value.subject.trim()) {
      showToast('请填写沟通主题')
      return
    }
    if (!form.value.detail.trim()) {
      showToast('请填写沟通详情')
      return
    }

    if (isEdit.value) {
      const updatedRecord = {
        id: recordId.value,
        subject: form.value.subject,
        detail: form.value.detail,
        nextTime: form.value.nextTime,
        nextContent: form.value.nextContent
      }
      projectStore.updateRecord(recordId.value, updatedRecord)
      showToast('修改成功')
    } else {
      const newRecord = {
        projectId: projectId.value,
        subject: form.value.subject,
        detail: form.value.detail,
        nextTime: form.value.nextTime,
        nextContent: form.value.nextContent,
        createTime: new Date().toISOString().replace('T', ' ').slice(0, 19)
      }
      projectStore.addRecord(projectId.value, newRecord)
      showToast('添加成功')
    }

    setTimeout(() => {
      window.location.hash = ''
    }, 500)
  }

  // 格式化日期时间
  const formatDateTime = (dateStr) => {
    if (!dateStr) return ''
    return dateStr.replace(' ', 'T').slice(0, 16)
  }

  onMounted(() => {
    const savedRecord = localStorage.getItem('currentRecord')
    const savedProjectId = localStorage.getItem('currentProjectId')

    if (savedProjectId) {
      projectId.value = savedProjectId
    }

    if (savedRecord) {
      isEdit.value = true
      const record = JSON.parse(savedRecord)
      recordId.value = record.id
      form.value = {
        subject: record.subject || '',
        detail: record.detail || '',
        nextTime: formatDateTime(record.nextTime || ''),
        nextContent: record.nextContent || ''
      }
      localStorage.removeItem('currentRecord')
    } else {
      isEdit.value = false
      const tomorrow = new Date()
      tomorrow.setDate(tomorrow.getDate() + 1)
      tomorrow.setHours(14, 0, 0)
      form.value.nextTime = tomorrow.toISOString().slice(0, 16)
    }

    localStorage.removeItem('currentProjectId')
  })
</script>

<style scoped>
  .edit-page {
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100%;
    max-width: 500px;
    margin: 0 auto;
    background: #f5f7fb;
  }

  .header {
    background: white;
    padding: 12px 16px;
    border-bottom: 1px solid #e9ecef;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-shrink: 0;
  }

  .header-actions {
    display: flex;
    gap: 16px;
  }

  .back-btn {
    font-size: 16px;
    color: #006241;
    cursor: pointer;
    padding: 8px 0;
  }

  .back-btn:active {
    opacity: 0.7;
  }

  .title {
    font-size: 18px;
    font-weight: 600;
    color: #1a2c3e;
    margin: 0;
  }

  .save-btn {
    font-size: 16px;
    color: #006241;
    font-weight: 600;
    cursor: pointer;
    padding: 8px 0;
  }

  .save-btn:active {
    opacity: 0.7;
  }

  .delete-btn {
    font-size: 16px;
    color: #e54545;
    font-weight: 600;
    cursor: pointer;
    padding: 8px 0;
  }

  .delete-btn:active {
    opacity: 0.7;
  }

  .form-content {
    flex: 1;
    overflow-y: auto;
    padding: 16px;
  }

  .form-group {
    background: white;
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 16px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  }

  .form-label {
    font-size: 14px;
    font-weight: 500;
    color: #1a2c3e;
    margin-bottom: 10px;
  }

  .required {
    color: #e54545;
    margin-left: 4px;
  }

  .form-input {
    width: 100%;
    padding: 12px;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    font-size: 14px;
    font-family: inherit;
    transition: all 0.2s;
    background: #f8f9fc;
  }

  .form-input:focus {
    outline: none;
    border-color: #006241;
    background: white;
  }

  .form-textarea {
    width: 100%;
    padding: 12px;
    border: 1px solid #e9ecef;
    border-radius: 8px;
    font-size: 14px;
    font-family: inherit;
    resize: vertical;
    transition: all 0.2s;
    background: #f8f9fc;
  }

  .form-textarea:focus {
    outline: none;
    border-color: #006241;
    background: white;
  }
</style>