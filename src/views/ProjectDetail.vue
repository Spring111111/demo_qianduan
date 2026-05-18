<template>
  <div class="project-page">
    <div class="empty-tip">
      暂时没有内容
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
  .project-page {
    flex: 1;
    overflow-y: auto;
    padding: 16px;
    -webkit-overflow-scrolling: touch;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .empty-tip {
    text-align: center;
    color: #8e9eae;
    font-size: 14px;
  }
</style>