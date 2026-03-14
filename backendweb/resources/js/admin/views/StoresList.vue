<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <h1 class="h4 mb-4">店家管理</h1>
      <p class="text-muted small mb-3">僅最高權限管理者可新增、編輯、刪除店家。</p>

      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap gap-2">
          <h5 class="mb-0">店家列表</h5>
          <button class="btn btn-primary btn-sm" @click="openModal()">
            <span class="me-1">+</span> 新增店家
          </button>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Logo</th>
                  <th>店家名稱</th>
                  <th>分店名稱</th>
                  <th>電話</th>
                  <th>地址</th>
                  <th>關聯使用者數</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="s in stores" :key="s.id">
                  <td>{{ s.id }}</td>
                  <td>
                    <div class="store-logo-wrap">
                      <img v-if="s.logo_url" :src="s.logo_url" :alt="s.name" class="store-logo-img" />
                      <span v-else class="store-logo-initial">{{ firstChar(s.name) }}</span>
                    </div>
                  </td>
                  <td>{{ s.name }}</td>
                  <td>{{ s.branch_name || '-' }}</td>
                  <td>{{ s.phone || '-' }}</td>
                  <td>{{ s.address || '-' }}</td>
                  <td>{{ s.users_count ?? 0 }}</td>
                  <td>
                    <button
                      class="btn btn-sm btn-outline-primary me-1"
                      @click="openModal(s)"
                    >
                      編輯
                    </button>
                    <button
                      class="btn btn-sm btn-outline-danger"
                      :disabled="(s.users_count ?? 0) > 0"
                      :title="(s.users_count ?? 0) > 0 ? '尚有關聯使用者，無法刪除' : '刪除'"
                      @click="confirmDelete(s)"
                    >
                      刪除
                    </button>
                  </td>
                </tr>
                <tr v-if="!stores.length">
                  <td colspan="8" class="text-center text-muted py-4">尚無店家資料</td>
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
              <h5 class="modal-title">{{ editingId ? '編輯店家' : '新增店家' }}</h5>
              <button type="button" class="btn-close" @click="closeModal"></button>
            </div>
            <div class="modal-body">
              <div v-if="errorMsg" class="alert alert-danger">{{ errorMsg }}</div>
              <form @submit.prevent="submitForm">
                <div class="mb-3">
                  <label class="form-label">Logo 圖片</label>
                  <div class="d-flex align-items-center gap-3">
                    <div class="store-logo-wrap store-logo-preview">
                      <img v-if="form.logoPreview" :src="form.logoPreview" alt="預覽" class="store-logo-img" />
                      <img v-else-if="editingStore?.logo_url && !form.remove_logo" :src="editingStore.logo_url" alt="Logo" class="store-logo-img" />
                      <span v-else class="store-logo-initial">{{ firstChar(form.name || '') }}</span>
                    </div>
                    <div class="flex-grow-1">
                      <input
                        ref="logoInput"
                        type="file"
                        class="form-control form-control-sm"
                        accept="image/jpeg,image/png,image/jpg,image/gif,image/webp"
                        @change="onLogoChange"
                      />
                      <small class="text-muted">JPG、PNG、GIF、WebP，最大 2MB。無圖片時顯示名稱首字</small>
                      <div v-if="editingId && (form.logoPreview || editingStore?.logo_url)" class="mt-1">
                        <label class="form-check-label small">
                          <input v-model="form.remove_logo" type="checkbox" class="form-check-input" />
                          移除 Logo
                        </label>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="mb-3">
                  <label class="form-label">店家名稱</label>
                  <input v-model="form.name" type="text" class="form-control" placeholder="例如：A店家" required />
                </div>
                <div class="mb-3">
                  <label class="form-label">分店名稱</label>
                  <input v-model="form.branch_name" type="text" class="form-control" placeholder="例如：總部旗艦店" required />
                </div>
                <div class="mb-3">
                  <label class="form-label">店家電話</label>
                  <input v-model="form.phone" type="text" class="form-control" placeholder="例如：02-12345678" />
                </div>
                <div class="mb-3">
                  <label class="form-label">店家地址</label>
                  <input v-model="form.address" type="text" class="form-control" placeholder="例如：台北市信義區..." />
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

export default {
  name: 'StoresList',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      stores: [],
      showModal: false,
      editingId: null,
      editingStore: null,
      errorMsg: '',
      form: {
        name: '',
        branch_name: '',
        phone: '',
        address: '',
        logoFile: null,
        logoPreview: null,
        remove_logo: false,
      },
    };
  },
  mounted() {
    this.fetchUser();
    this.fetchStores();
  },
  methods: {
    firstChar(name) {
      return (name || '店').charAt(0);
    },
    onLogoChange(e) {
      const file = e.target.files?.[0];
      this.form.logoFile = file || null;
      this.form.logoPreview = file ? URL.createObjectURL(file) : null;
      if (file) this.form.remove_logo = false;
    },
    async fetchUser() {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) this.user = await res.json();
    },
    async fetchStores() {
      const res = await fetch('/api/admin/stores', { credentials: 'same-origin' });
      if (res.ok) {
        const data = await res.json();
        this.stores = data.stores || [];
      }
    },
    openModal(store = null) {
      this.editingId = store ? store.id : null;
      this.editingStore = store || null;
      this.errorMsg = '';
      if (this.form.logoPreview) {
        URL.revokeObjectURL(this.form.logoPreview);
      }
      if (store) {
        this.form = {
          name: store.name,
          branch_name: store.branch_name || '',
          phone: store.phone || '',
          address: store.address || '',
          logoFile: null,
          logoPreview: null,
          remove_logo: false,
        };
      } else {
        this.form = {
          name: '',
          branch_name: '',
          phone: '',
          address: '',
          logoFile: null,
          logoPreview: null,
          remove_logo: false,
        };
      }
      this.$nextTick(() => {
        const input = this.$refs.logoInput;
        if (input) input.value = '';
      });
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
      this.editingId = null;
      this.editingStore = null;
      if (this.form.logoPreview) {
        URL.revokeObjectURL(this.form.logoPreview);
      }
    },
    async submitForm() {
      this.errorMsg = '';
      if (!this.form.name?.trim()) {
        this.errorMsg = '請輸入店家名稱';
        return;
      }
      if (!this.form.branch_name?.trim()) {
        this.errorMsg = '請輸入分店名稱';
        return;
      }

      const useFormData = this.form.logoFile || (this.editingId && this.form.remove_logo);
      const headers = {
        'X-CSRF-TOKEN': this.csrfToken,
        Accept: 'application/json',
      };

      let body;
      if (useFormData) {
        const fd = new FormData();
        fd.append('name', this.form.name.trim());
        fd.append('branch_name', this.form.branch_name.trim());
        fd.append('phone', this.form.phone?.trim() || '');
        fd.append('address', this.form.address?.trim() || '');
        if (this.form.logoFile) {
          fd.append('logo', this.form.logoFile);
        }
        if (this.editingId && this.form.remove_logo) {
          fd.append('remove_logo', '1');
        }
        if (this.editingId) {
          fd.append('_method', 'PUT');
        }
        body = fd;
      } else {
        headers['Content-Type'] = 'application/json';
        body = JSON.stringify({
          name: this.form.name.trim(),
          branch_name: this.form.branch_name.trim(),
          phone: this.form.phone?.trim() || null,
          address: this.form.address?.trim() || null,
        });
      }

      const url = this.editingId ? `/api/admin/stores/${this.editingId}` : '/api/admin/stores';
      const res = await fetch(url, {
        method: useFormData ? 'POST' : (this.editingId ? 'PUT' : 'POST'),
        headers,
        body,
        credentials: 'same-origin',
      });

      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        this.errorMsg = data.message || (data.errors ? Object.values(data.errors).flat().join(', ') : (this.editingId ? '更新失敗' : '新增失敗'));
        return;
      }

      if (this.editingId) {
        const idx = this.stores.findIndex((s) => s.id === this.editingId);
        if (idx >= 0) this.stores[idx] = data.store;
      } else {
        this.stores.push(data.store);
      }
      this.closeModal();
    },
    async confirmDelete(store) {
      if ((store.users_count ?? 0) > 0) {
        alert('此店家尚有關聯使用者，請先移除或轉移後再刪除');
        return;
      }
      if (!confirm(`確定要刪除店家「${store.name} - ${store.branch_name || ''}」嗎？`)) return;
      const res = await fetch(`/api/admin/stores/${store.id}`, {
        method: 'DELETE',
        headers: { 'X-CSRF-TOKEN': this.csrfToken, Accept: 'application/json' },
        credentials: 'same-origin',
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        alert(data.message || '刪除失敗');
        return;
      }
      this.stores = this.stores.filter((s) => s.id !== store.id);
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
.store-logo-wrap {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e9ecef;
  flex-shrink: 0;
}
.store-logo-preview {
  width: 64px;
  height: 64px;
}
.store-logo-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.store-logo-initial {
  font-size: 1.25rem;
  font-weight: 600;
  color: #495057;
}
.store-logo-preview .store-logo-initial {
  font-size: 1.75rem;
}
</style>
