const STORAGE_PROJECTS_KEY = 'devops_projects'
const STORAGE_RECORDS_KEY = 'devops_records'

const seedProjects = [
  { id: 'p1', name: '星巴克咖啡商谈细节', date: '06-09' },
  { id: 'p2', name: '跨赴科技办公室深入了解', date: '06-08' },
  { id: 'p3', name: '奇绩DemoDay', date: '06-07' }
]

const seedRecords = [
  { id: 'r1', projectId: 'p1', subject: '星巴克咖啡商谈细节', detail: '沟通投资细节。', createTime: '06-09' },
  { id: 'r2', projectId: 'p2', subject: '跨赴科技办公室深入了解', detail: '深入沟通项目，了解产品和业务的进展，打算投一个亿。', createTime: '06-08' },
  { id: 'r3', projectId: 'p3', subject: '奇绩DemoDay', detail: '第一次在DemoDay上接触，印象不错。', createTime: '06-07' }
]

if (!localStorage.getItem(STORAGE_PROJECTS_KEY)) {
  localStorage.setItem(STORAGE_PROJECTS_KEY, JSON.stringify(seedProjects))
}
if (!localStorage.getItem(STORAGE_RECORDS_KEY)) {
  localStorage.setItem(STORAGE_RECORDS_KEY, JSON.stringify(seedRecords))
}