<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <h1 class="h4 mb-4">管理者管理</h1>
      <p class="text-muted small mb-3">僅最高權限管理者可新增、編輯、刪除管理者帳號。</p>

      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap gap-2">
          <h5 class="mb-0">管理者列表</h5>
          <button class="btn btn-primary btn-sm" @click="openModal()">
            <span class="me-1">+</span> 新增管理者
          </button>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>姓名</th>
                  <th>Email</th>
                  <th>身份</th>
                  <th>所屬店家</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="a in admins" :key="a.id">
                  <td>{{ a.id }}</td>
                  <td>{{ a.name }}</td>
                  <td>{{ a.email }}</td>
                  <td>
                    <span class="badge" :class="roleBadgeClass(a.role)">
                      {{ roleLabel(a.role) }}
                    </span>
                  </td>
                  <td>{{ a.store ? a.store.name : '-' }}</td>
                  <td>
                    <button
                      v-if="a.role !== 'super_admin' || user?.id !== a.id"
                      class="btn btn-sm btn-outline-primary me-1"
                      @click="openModal(a)"
                    >
                      編輯
                    </button>
                    <button
                      v-if="a.role !== 'super_admin' && user?.id !== a.id"
                      class="btn btn-sm btn-outline-danger"
                      @click="confirmDelete(a)"
                    >
                      刪除
                    </button>
                  </td>
                </tr>
                <tr v-if="!admins.length">
                  <td colspan="6" class="text-center text-muted py-4">尚無管理者資料</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- 新增/編輯 Modal -->
      <div v-if="showModal" class="modal fade show d-block" tabindex="-1" role="dialog">
        <div class="modal-backdrop fade show" @click="closeModal"></div>
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">{{ editingId ? '編輯管理者' : '新增管理者' }}</h5>
              <button type="button" class="btn-close" @click="closeModal"></button>
            </div>
            <div class="modal-body">
              <div v-if="errorMsg" class="alert alert-danger">{{ errorMsg }}</div>
              <form @submit.prevent="submitForm">
                <div class="mb-3">
                  <label class="form-label">姓名</label>
                  <input v-model="form.name" type="text" class="form-control" required />
                </div>
                <div class="mb-3">
                  <label class="form-label">Email</label>
                  <input
                    v-model="form.email"
                    type="email"
                    class="form-control"
                    :readonly="!!editingId"
                    required
                  />
                  <small v-if="editingId" class="text-muted">Email 不可修改</small>
                </div>
                <div class="mb-3">
                  <label class="form-label">密碼 {{ editingId ? '(留空則不變更)' : '' }}</label>
                  <input v-model="form.password" type="password" class="form-control" :required="!editingId" />
                </div>
                <div v-if="editingId" class="mb-3">
                  <label class="form-label">確認密碼</label>
                  <input v-model="form.password_confirmation" type="password" class="form-control" />
                </div>
                <div v-else class="mb-3">
                  <label class="form-label">確認密碼</label>
                  <input v-model="form.password_confirmation" type="password" class="form-control" required />
                </div>
                <div class="mb-3">
                  <label class="form-label">身份</label>
                  <select v-model="form.role" class="form-select" :disabled="isEditingSuperAdmin">
                    <option v-if="editingId && isEditingSuperAdmin" value="super_admin">最高權限管理者</option>
                    <option value="shareholder">股東管理</option>
                    <option value="store_manager">店長管理</option>
                  </select>
                  <small v-if="!editingId" class="text-muted">僅可新增股東管理或店長管理</small>
                </div>
                <div v-if="form.role === 'store_manager'" class="mb-3">
                  <label class="form-label">所屬店家</label>
                  <select v-model="form.store_id" class="form-select" required>
                    <option value="">請選擇</option>
                    <option v-for="s in stores" :key="s.id" :value="s.id">
                      {{ s.name }} - {{ s.branch_name || '' }}
                    </option>
                  </select>
                </div>
              </form>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="closeModal">取消</button>
              <button type="button" class="btn btn-primary" @click="submitForm">
                {{ editingId ? '儲存' : '新增' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import AdminLayout from '../layouts/AdminLayout.vue';

const ROLE_LABELS = {
  super_admin: '最高權限管理者',
  shareholder: '股東管理',
  store_manager: '店長管理',
};

export default {
  name: 'AdminsList',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      admins: [],
      stores: [],
      showModal: false,
      editingId: null,
      errorMsg: '',
      form: {
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
        role: 'store_manager',
        store_id: '',
      },
    };
  },
  computed: {
    isEditingSuperAdmin() {
      const a = this.admins.find((x) => x.id === this.editingId);
      return a && a.role === 'super_admin';
    },
  },
  mounted() {
    this.fetchUser();
    this.fetchAdmins();
    this.fetchStores();
  },
  methods: {
    roleLabel(role) {
      return ROLE_LABELS[role] || role;
    },
    roleBadgeClass(role) {
      const map = {
        super_admin: 'bg-danger',
        shareholder: 'bg-warning text-dark',
        store_manager: 'bg-primary',
      };
      return map[role] || 'bg-secondary';
    },
    async fetchUser() {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) this.user = await res.json();
    },
    async fetchAdmins() {
      const res = await fetch('/api/admin/admins', { credentials: 'same-origin' });
      if (res.ok) {
        const data = await res.json();
        this.admins = data.admins || [];
      }
    },
    async fetchStores() {
      const res = await fetch('/api/admin/admins/stores/list', { credentials: 'same-origin' });
      if (res.ok) {
        const data = await res.json();
        this.stores = data.stores || [];
      }
    },
    openModal(admin = null) {
      this.editingId = admin ? admin.id : null;
      this.errorMsg = '';
      if (admin) {
        this.form = {
          name: admin.name,
          email: admin.email,
          password: '',
          password_confirmation: '',
          role: admin.role,
          store_id: admin.store_id || '',
        };
      } else {
        this.form = {
          name: '',
          email: '',
          password: '',
          password_confirmation: '',
          role: 'store_manager',
          store_id: this.stores[0]?.id || '',
        };
      }
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
      this.editingId = null;
    },
    async submitForm() {
      this.errorMsg = '';
      if (this.form.password && this.form.password !== this.form.password_confirmation) {
        this.errorMsg = '兩次密碼輸入不一致';
        return;
      }
      if (this.form.role === 'store_manager' && !this.form.store_id) {
        this.errorMsg = '店長管理必須選擇所屬店家';
        return;
      }

      const payload = {
        name: this.form.name,
        email: this.form.email,
        role: this.form.role,
      };
      if (this.form.password) {
        payload.password = this.form.password;
        payload.password_confirmation = this.form.password_confirmation;
      }
      if (this.form.role === 'store_manager') {
        payload.store_id = this.form.store_id;
      }

      if (this.editingId) {
        const res = await fetch(`/api/admin/admins/${this.editingId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': this.csrfToken, Accept: 'application/json' },
          body: JSON.stringify(payload),
          credentials: 'same-origin',
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) {
          this.errorMsg = data.message || data.errors ? Object.values(data.errors).flat().join(', ') : '更新失敗';
          return;
        }
        const idx = this.admins.findIndex((a) => a.id === this.editingId);
        if (idx >= 0) this.admins[idx] = data.admin;
        this.closeModal();
      } else {
        if (this.form.role === 'super_admin') {
          this.errorMsg = '僅可新增股東管理或店長管理';
          return;
        }
        const res = await fetch('/api/admin/admins', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': this.csrfToken, Accept: 'application/json' },
          body: JSON.stringify({ ...payload, password: this.form.password, password_confirmation: this.form.password_confirmation }),
          credentials: 'same-origin',
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) {
          this.errorMsg = data.message || (data.errors ? Object.values(data.errors).flat().join(', ') : '新增失敗');
          return;
        }
        this.admins.push(data.admin);
        this.closeModal();
      }
    },
    async confirmDelete(admin) {
      if (!confirm(`確定要刪除管理者「${admin.name}」嗎？`)) return;
      const res = await fetch(`/api/admin/admins/${admin.id}`, {
        method: 'DELETE',
        headers: { 'X-CSRF-TOKEN': this.csrfToken, Accept: 'application/json' },
        credentials: 'same-origin',
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        alert(data.message || '刪除失敗');
        return;
      }
      this.admins = this.admins.filter((a) => a.id !== admin.id);
    },
  },
  created() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
  },
};
</script>

<style scoped>
.modal-backdrop {
  background-color: rgba(0, 0, 0, 0.25);
}
.modal-dialog {
  position: relative;
  z-index: 1051;
}
</style>
