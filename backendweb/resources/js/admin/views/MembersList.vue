<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <h1 class="h4 mb-4">會員資訊</h1>

      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center">
          <h5 class="mb-0">會員列表</h5>
          <span class="text-muted small">共 {{ members.length }} 位會員</span>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>姓名</th>
                  <th>Email</th>
                  <th>會員等級</th>
                  <th>積分</th>
                  <th>電話</th>
                  <th>位置</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="m in members" :key="m.id">
                  <td>{{ m.id }}</td>
                  <td>{{ m.name }}</td>
                  <td>{{ m.email }}</td>
                  <td>
                    <span class="badge" :class="levelBadgeClass(m.member_level)">
                      {{ m.member_level || '一般' }}
                    </span>
                  </td>
                  <td>{{ m.points ?? 0 }}</td>
                  <td>{{ m.phone || '-' }}</td>
                  <td>
                    <router-link :to="`/members/${m.id}/location`" class="btn btn-sm btn-outline-secondary">位置</router-link>
                  </td>
                  <td>
                    <router-link :to="`/members/${m.id}`" class="btn btn-sm btn-outline-primary me-1">詳情</router-link>
                    <button
                      v-if="!isReadOnly"
                      class="btn btn-sm btn-outline-danger"
                      @click="confirmDelete(m)"
                    >
                      刪除
                    </button>
                  </td>
                </tr>
                <tr v-if="!members.length">
                  <td colspan="8" class="text-center text-muted py-4">尚無會員資料</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import AdminLayout from '../layouts/AdminLayout.vue';

export default {
  name: 'MembersList',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      members: [],
    };
  },
  computed: {
    isReadOnly() {
      return this.user?.role === 'shareholder';
    },
  },
  mounted() {
    this.fetchUser();
    this.fetchMembers();
  },
  methods: {
    levelBadgeClass(level) {
      const map = { 一般: 'bg-secondary', 優質: 'bg-info', VIP: 'bg-warning text-dark' };
      return map[level] || 'bg-secondary';
    },
    async fetchUser() {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) this.user = await res.json();
    },
    async fetchMembers() {
      const res = await fetch('/api/admin/members', { credentials: 'same-origin' });
      if (res.ok) {
        const data = await res.json();
        this.members = data.members || [];
      }
    },
    async confirmDelete(member) {
      if (!confirm(`確定要刪除會員「${member.name}」嗎？此操作無法復原。`)) return;
      const res = await fetch(`/api/admin/members/${member.id}`, {
        method: 'DELETE',
        headers: { 'X-CSRF-TOKEN': this.csrfToken, Accept: 'application/json' },
        credentials: 'same-origin',
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        alert(data.message || '刪除失敗');
        return;
      }
      this.members = this.members.filter((m) => m.id !== member.id);
    },
  },
  created() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
  },
};
</script>
