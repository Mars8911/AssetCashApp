<template>
  <div class="d-flex admin-layout">
    <!-- 桌機側邊欄 -->
    <nav class="sidebar d-none d-md-flex flex-column flex-shrink-0 p-3">
      <router-link to="/dashboard" class="navbar-brand text-white mb-4 text-decoration-none">📍 AssetCash APP</router-link>
      <ul class="nav flex-column">
        <li class="nav-item">
          <router-link to="/dashboard" class="nav-link" active-class="active">儀表板</router-link>
        </li>
        <li class="nav-item">
          <router-link to="/members" class="nav-link" active-class="active">會員資訊</router-link>
        </li>
        <li v-if="user?.role !== 'shareholder'" class="nav-item">
          <router-link to="/push-notifications" class="nav-link" active-class="active">訊息推播管理</router-link>
        </li>
        <li v-if="user?.role !== 'shareholder'" class="nav-item">
          <router-link to="/coupons" class="nav-link" active-class="active">優惠券管理</router-link>
        </li>
        <li v-if="user?.role === 'super_admin'" class="nav-item">
          <router-link to="/admins" class="nav-link" active-class="active">管理者管理</router-link>
        </li>
        <li v-if="user?.role === 'super_admin'" class="nav-item">
          <router-link to="/stores" class="nav-link" active-class="active">店家管理</router-link>
        </li>
      </ul>
    </nav>

    <div class="flex-grow-1 d-flex flex-column min-vh-100">
      <nav class="navbar navbar-expand-md navbar-light bg-white border-bottom">
        <div class="container-fluid">
          <!-- 手機版顯示品牌名 -->
          <span class="navbar-brand d-md-none fw-bold text-primary">📍 AssetCash</span>
          <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false">
            <span class="navbar-toggler-icon"></span>
          </button>
          <div class="collapse navbar-collapse" id="navbarNav">
            <!-- 手機版導航連結（桌機不顯示，由側邊欄負責） -->
            <ul class="navbar-nav d-md-none flex-column border-bottom mb-2 pb-2">
              <li class="nav-item">
                <router-link to="/dashboard" class="nav-link" active-class="active" @click="closeNavbar">儀表板</router-link>
              </li>
              <li class="nav-item">
                <router-link to="/members" class="nav-link" active-class="active" @click="closeNavbar">會員資訊</router-link>
              </li>
              <li v-if="user?.role !== 'shareholder'" class="nav-item">
                <router-link to="/push-notifications" class="nav-link" active-class="active" @click="closeNavbar">訊息推播管理</router-link>
              </li>
              <li v-if="user?.role !== 'shareholder'" class="nav-item">
                <router-link to="/coupons" class="nav-link" active-class="active" @click="closeNavbar">優惠券管理</router-link>
              </li>
              <li v-if="user?.role === 'super_admin'" class="nav-item">
                <router-link to="/admins" class="nav-link" active-class="active" @click="closeNavbar">管理者管理</router-link>
              </li>
              <li v-if="user?.role === 'super_admin'" class="nav-item">
                <router-link to="/stores" class="nav-link" active-class="active" @click="closeNavbar">店家管理</router-link>
              </li>
            </ul>
            <!-- 使用者資訊 + 登出 -->
            <span class="navbar-text me-auto">
              <span class="badge me-2" :class="roleBadgeClass(user?.role)">
                {{ roleLabel(user?.role) }}
              </span>
              {{ user?.name }}
              <small v-if="user?.store" class="text-muted">({{ user.store.name }})</small>
            </span>
            <button
              type="button"
              class="btn btn-outline-secondary btn-sm"
              :disabled="loggingOut"
              @click="handleLogout"
            >
              {{ loggingOut ? '登出中...' : '登出' }}
            </button>
          </div>
        </div>
      </nav>

      <main class="p-3 p-md-4 flex-grow-1">
        <slot />
      </main>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdminLayout',
  props: {
    user: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
      csrfToken: '',
      loggingOut: false,
    };
  },
  methods: {
    closeNavbar() {
      const navEl = document.getElementById('navbarNav');
      if (navEl && navEl.classList.contains('show')) {
        const btn = document.querySelector('[data-bs-target="#navbarNav"]');
        btn?.click();
      }
    },
    async handleLogout() {
      if (this.loggingOut) return;
      this.loggingOut = true;
      try {
        const res = await fetch('/admin/logout', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': this.csrfToken || document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
            Accept: 'application/json',
          },
          credentials: 'same-origin',
        });
        // 419 表示 session 已過期，直接導向登入頁
        if (res.status === 419 || res.ok) {
          window.location.href = '/admin/login';
          return;
        }
      } catch (e) {
        console.error(e);
      } finally {
        this.loggingOut = false;
      }
      window.location.href = '/admin/login';
    },
    roleLabel(role) {
      const map = { super_admin: '最高權限管理者', shareholder: '股東管理', store_manager: '店長管理' };
      return map[role] || role || '';
    },
    roleBadgeClass(role) {
      const map = { super_admin: 'bg-danger', shareholder: 'bg-warning text-dark', store_manager: 'bg-primary' };
      return map[role] || 'bg-secondary';
    },
  },
  mounted() {
    this.csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
  },
};
</script>

<style scoped>
.sidebar {
  min-height: 100vh;
  background: #1e3a5f;
  width: 220px;
}
.sidebar .nav-link {
  color: rgba(255, 255, 255, 0.85);
}
.sidebar .nav-link:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.1);
}
.sidebar .nav-link.active {
  color: #fff;
  background: rgba(255, 255, 255, 0.2);
}
.navbar-brand {
  font-weight: 700;
}
</style>
