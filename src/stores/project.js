
import { defineStore } from 'pinia'

const STORAGE_PROJECTS_KEY = 'devops_projects'
const STORAGE_RECORDS_KEY = 'devops_records'

export const useProjectStore = defineStore('project', {
  state: () => ({
    projects: [],
    currentProject: null
  }),

  actions: {
    // 获取所有项目
    getProjects() {
      const raw = localStorage.getItem(STORAGE_PROJECTS_KEY) || '[]'
      return JSON.parse(raw)
    },

    // 获取项目的所有跟进记录
    getRecordsByProject(projectId) {
      const all = JSON.parse(localStorage.getItem(STORAGE_RECORDS_KEY) || '[]')
      return all.filter(r => r.projectId === projectId)
        .sort((a, b) => new Date(b.createTime) - new Date(a.createTime))
    },

    // 分页获取记录
    getPaginatedRecords(projectId, page, pageSize = 8) {
      const records = this.getRecordsByProject(projectId)
      const start = (page - 1) * pageSize
      const data = records.slice(start, start + pageSize)
      return {
        data,
        hasMore: start + pageSize < records.length,
        total: records.length
      }
    },

    // 添加记录
    addRecord(projectId, record) {
      const all = JSON.parse(localStorage.getItem(STORAGE_RECORDS_KEY) || '[]')
      const newRecord = {
        id: Date.now().toString(),
        projectId,
        subject: record.subject,
        detail: record.detail,
        nextTime: record.nextTime || '',
        nextContent: record.nextContent || '',
        createTime: new Date().toISOString().replace('T', ' ').slice(0, 19)
      }
      all.unshift(newRecord)
      localStorage.setItem(STORAGE_RECORDS_KEY, JSON.stringify(all))
      return newRecord
    },

    // 更新记录
    updateRecord(recordId, newData) {
      const all = JSON.parse(localStorage.getItem(STORAGE_RECORDS_KEY) || '[]')
      const index = all.findIndex(r => r.id === recordId)
      if (index !== -1) {
        all[index] = { ...all[index], ...newData }
        localStorage.setItem(STORAGE_RECORDS_KEY, JSON.stringify(all))
      }
    },

    // 删除记录
    deleteRecord(recordId) {
      const all = JSON.parse(localStorage.getItem(STORAGE_RECORDS_KEY) || '[]')
      const filtered = all.filter(r => r.id !== recordId)
      localStorage.setItem(STORAGE_RECORDS_KEY, JSON.stringify(filtered))
    }
  }
})
