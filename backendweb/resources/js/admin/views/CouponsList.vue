<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <h1 class="h4 mb-4">優惠券管理</h1>
      <p class="text-muted small mb-3">建立優惠碼供客戶註冊時使用，可折抵利息百分比。客戶於 APP 註冊時輸入優惠碼即可享有對應利息折抵。</p>

      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap gap-2">
          <h5 class="mb-0">優惠券列表</h5>
          <button class="btn btn-primary btn-sm" @click="openModal()">
            <span class="me-1">+</span> 新增優惠券
          </button>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>優惠碼</th>
                  <th>名稱</th>
                  <th>利息折抵</th>
                  <th>適用店家</th>
                  <th>有效期限</th>
                  <th>使用次數</th>
                  <th>狀態</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="c in coupons" :key="c.id">
                  <td>{{ c.id }}</td>
                  <td><code class="bg-light px-2 py-1 rounded">{{ c.code }}</code></td>
                  <td>{{ c.name || '-' }}</td>
                  <td><span class="badge bg-success">{{ c.interest_discount_percent }}%</span></td>
                  <td>{{ c.store ? `${c.store.name} - ${c.store.branch_name || ''}` : '全店通用' }}</td>
                  <td>
                    <small>
                      {{ formatDate(c.valid_from) }} ~ {{ formatDate(c.valid_until) || '無限期' }}
                    </small>
                  </td>
                  <td>{{ c.used_count }}{{ c.usage_limit ? ` / ${c.usage_limit}` : ' / ∞' }}</td>
                  <td>
                    <span :class="c.is_active ? 'badge bg-success' : 'badge bg-secondary'">
                      {{ c.is_active ? '啟用' : '停用' }}
                    </span>
                  </td>
                  <td>
                    <button class="btn btn-sm btn-outline-primary me-1" @click="openModal(c)">
                      編輯
                    </button>
                    <button class="btn btn-sm btn-outline-danger" @click="confirmDelete(c)">
                      刪除
                    </button>
                  </td>
                </tr>
                <tr v-if="!coupons.length">
                  <td colspan="9" class="text-center text-muted py-4">尚無優惠券</td>
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
              <h5 class="modal-title">{{ editingId ? '編輯優惠券' : '新增優惠券' }}</h5>
              <button type="button" class="btn-close" @click="closeModal"></button>
            </div>
            <div class="modal-body">
              <div v-if="errorMsg" class="alert alert-danger">{{ errorMsg }}</div>
              <form @submit.prevent="submitForm">
                <div class="mb-3">
                  <label class="form-label">優惠碼 <span class="text-danger">*</span></label>
                  <input
                    v-model="form.code"
                    type="text"
                    class="form-control"
                    placeholder="例如：WELCOME2026"
                    required
                    :disabled="!!editingId"
                  />
                  <small class="text-muted">客戶於註冊時輸入此代碼（建立後不可修改）</small>
                </div>
                <div class="mb-3">
                  <label class="form-label">優惠券名稱</label>
                  <input v-model="form.name" type="text" class="form-control" placeholder="例如：新戶註冊優惠" />
                </div>
                <div class="mb-3">
                  <label class="form-label">利息折抵百分比 <span class="text-danger">*</span></label>
                  <div class="input-group">
                    <input
                      v-model.number="form.interest_discount_percent"
                      type="number"
                      class="form-control"
                      min="0"
                      max="100"
                      step="0.01"
                      placeholder="例如：2"
                    />
                    <span class="input-group-text">%</span>
                  </div>
                  <small class="text-muted">如輸入 2，表示客戶享有的利率減少 2 個百分點（例：10% → 8%）</small>
                </div>
                <div class="mb-3" v-if="user?.role === 'super_admin'">
                  <label class="form-label">限定店家</label>
                  <select v-model="form.store_id" class="form-select">
                    <option :value="null">全店通用</option>
                    <option v-for="s in stores" :key="s.id" :value="s.id">
                      {{ s.name }} - {{ s.branch_name || '' }}
                    </option>
                  </select>
                </div>
                <div class="row mb-3">
                  <div class="col-6">
                    <label class="form-label">有效起始日</label>
                    <input v-model="form.valid_from" type="date" class="form-control" />
                  </div>
                  <div class="col-6">
                    <label class="form-label">有效截止日</label>
                    <input v-model="form.valid_until" type="date" class="form-control" />
                  </div>
                  <small class="text-muted">留空表示無限期</small>
                </div>
                <div class="mb-3">
                  <label class="form-label">使用次數上限</label>
                  <input
                    v-model.number="form.usage_limit"
                    type="number"
                    class="form-control"
                    min="1"
                    placeholder="留空表示無限制"
                  />
                </div>
                <div class="mb-3">
                  <div class="form-check">
                    <input v-model="form.is_active" type="checkbox" class="form-check-input" id="coupon_active" />
                    <label class="form-check-label" for="coupon_active">啟用</label>
                  </div>
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
  name: 'CouponsList',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      coupons: [],
      stores: [],
      showModal: false,
      editingId: null,
      editingCoupon: null,
      errorMsg: '',
      form: {
        code: '',
        name: '',
        interest_discount_percent: 0,
        store_id: null,
        valid_from: '',
        valid_until: '',
        usage_limit: null,
        is_active: true,
      },
    };
  },
  async mounted() {
    await this.fetchUser();
    this.fetchCoupons();
    if (this.user?.role === 'super_admin') {
      this.fetchStores();
    }
  },
  methods: {
    formatDate(val) {
      if (!val) return '';
      const d = typeof val === 'string' ? val : (val.date || val);
      return d ? d.slice(0, 10) : '';
    },
    async fetchUser() {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) this.user = await res.json();
    },
    async fetchCoupons() {
      const res = await fetch('/api/admin/coupons', { credentials: 'same-origin' });
      if (res.ok) {
        const data = await res.json();
        this.coupons = data.coupons || [];
      }
    },
    async fetchStores() {
      const res = await fetch('/api/admin/stores', { credentials: 'same-origin' });
      if (res.ok) {
        const data = await res.json();
        this.stores = data.stores || [];
      }
    },
    openModal(coupon = null) {
      this.editingId = coupon ? coupon.id : null;
      this.editingCoupon = coupon || null;
      this.errorMsg = '';
      if (coupon) {
        this.form = {
          code: coupon.code,
          name: coupon.name || '',
          interest_discount_percent: parseFloat(coupon.interest_discount_percent) || 0,
          store_id: coupon.store_id ?? null,
          valid_from: this.formatDate(coupon.valid_from) || '',
          valid_until: this.formatDate(coupon.valid_until) || '',
          usage_limit: coupon.usage_limit ?? null,
          is_active: !!coupon.is_active,
        };
      } else {
        this.form = {
          code: '',
          name: '',
          interest_discount_percent: 0,
          store_id: null,
          valid_from: '',
          valid_until: '',
          usage_limit: null,
          is_active: true,
        };
      }
      if (!this.stores.length && this.user?.role === 'super_admin') {
        this.fetchStores();
      }
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
      this.editingId = null;
      this.editingCoupon = null;
    },
    async submitForm() {
      this.errorMsg = '';
      if (!this.form.code?.trim()) {
        this.errorMsg = '請輸入優惠碼';
        return;
      }
      if (this.form.interest_discount_percent < 0 || this.form.interest_discount_percent > 100) {
        this.errorMsg = '利息折抵百分比需介於 0 ～ 100';
        return;
      }

      const body = this.editingId
        ? {
            name: this.form.name?.trim() || null,
            interest_discount_percent: this.form.interest_discount_percent,
            store_id: this.form.store_id || null,
            valid_from: this.form.valid_from || null,
            valid_until: this.form.valid_until || null,
            usage_limit: this.form.usage_limit || null,
            is_active: this.form.is_active,
          }
        : {
            code: this.form.code.trim().toUpperCase(),
            name: this.form.name?.trim() || null,
            interest_discount_percent: this.form.interest_discount_percent,
            store_id: this.form.store_id || null,
            valid_from: this.form.valid_from || null,
            valid_until: this.form.valid_until || null,
            usage_limit: this.form.usage_limit || null,
            is_active: this.form.is_active,
          };

      const url = this.editingId ? `/api/admin/coupons/${this.editingId}` : '/api/admin/coupons';
      const res = await fetch(url, {
        method: this.editingId ? 'PUT' : 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'X-CSRF-TOKEN': this.csrfToken || '',
          'X-Requested-With': 'XMLHttpRequest',
        },
        credentials: 'same-origin',
        body: JSON.stringify(body),
      });

      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        this.errorMsg = data.message || (data.errors ? Object.values(data.errors).flat().join(', ') : '操作失敗');
        return;
      }

      if (this.editingId) {
        const idx = this.coupons.findIndex((c) => c.id === this.editingId);
        if (idx >= 0) this.coupons[idx] = data.coupon;
      } else {
        this.coupons.unshift(data.coupon);
      }
      this.closeModal();
    },
    async confirmDelete(coupon) {
      if (!confirm(`確定要刪除優惠券「${coupon.code}」嗎？`)) return;
      const res = await fetch(`/api/admin/coupons/${coupon.id}`, {
        method: 'DELETE',
        headers: {
          Accept: 'application/json',
          'X-CSRF-TOKEN': this.csrfToken || '',
        },
        credentials: 'same-origin',
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        alert(data.message || '刪除失敗');
        return;
      }
      this.coupons = this.coupons.filter((c) => c.id !== coupon.id);
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
