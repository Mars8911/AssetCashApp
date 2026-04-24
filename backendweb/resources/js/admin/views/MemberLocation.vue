<template>
  <AdminLayout :user="user">
    <div class="container-fluid">
      <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><router-link to="/members">會員資訊</router-link></li>
          <li class="breadcrumb-item"><router-link :to="`/members/${memberId}`">會員詳情</router-link></li>
          <li class="breadcrumb-item active">位置追蹤</li>
        </ol>
      </nav>

      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white d-flex flex-wrap align-items-center gap-2">
          <h5 class="mb-0">{{ member?.name || '載入中...' }} - 定位軌跡</h5>
          <div class="d-flex gap-2 ms-auto flex-wrap">
            <input
              v-model="filterSince"
              type="date"
              class="form-control form-control-sm"
              style="max-width: 160px"
            />
            <button class="btn btn-outline-primary btn-sm" :disabled="loading" @click="fetchLocations">
              {{ loading ? '載入中...' : '重新載入' }}
            </button>
            <button
              class="btn btn-sm"
              :class="requestStatus === 'waiting' ? 'btn-warning' : 'btn-danger'"
              :disabled="requestStatus === 'waiting'"
              @click="requestLocationNow"
            >
              <span v-if="requestStatus === 'idle'">📍 立即定位</span>
              <span v-else-if="requestStatus === 'waiting'">
                ⏳ 等待回傳中（{{ countdown }}s）
              </span>
              <span v-else-if="requestStatus === 'done'">✅ 定位成功</span>
            </button>
          </div>
        </div>

        <!-- 狀態提示列 -->
        <div v-if="requestStatus === 'waiting'" class="alert alert-warning mb-0 rounded-0 py-2 px-3 small">
          已發出定位請求，等待會員 App 回傳位置（最多 30 秒）...
        </div>
        <div v-if="requestStatus === 'done'" class="alert alert-success mb-0 rounded-0 py-2 px-3 small">
          ✅ 已成功取得最新位置，地圖已自動更新。
        </div>

        <div class="card-body p-0">
          <div v-if="loading && !points.length" class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="text-muted mt-2 mb-0">載入定位資料...</p>
          </div>
          <div v-else-if="!points.length" class="text-center py-5">
            <p class="text-muted mb-2">尚無定位紀錄</p>
            <p class="small text-muted">會員需透過 APP 開啟定位追蹤後，資料才會顯示於此。</p>
            <router-link :to="`/members/${memberId}`" class="btn btn-outline-primary mt-2">返回會員詳情</router-link>
          </div>
          <div v-else class="position-relative">
            <div ref="mapContainer" class="location-map"></div>
            <div class="position-absolute top-0 end-0 m-2 bg-white rounded shadow-sm p-2 small">
              <div>共 {{ points.length }} 筆定位</div>
              <div v-if="latestPoint" class="text-muted">
                最新：{{ formatDateTime(latestPoint.created_at) }}
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="mt-2">
        <router-link :to="`/members/${memberId}`" class="btn btn-outline-secondary btn-sm">返回會員詳情</router-link>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import AdminLayout from '../layouts/AdminLayout.vue';

export default {
  name: 'MemberLocation',
  components: { AdminLayout },
  data() {
    return {
      user: null,
      member: null,
      points: [],
      loading: false,
      filterSince: '',
      map: null,
      // 立即定位狀態：idle | waiting | done
      requestStatus: 'idle',
      countdown: 30,
      _countdownTimer: null,
      _pollTimer: null,
    };
  },
  computed: {
    memberId() {
      return this.$route.params.id;
    },
    latestPoint() {
      return this.points.length ? this.points[this.points.length - 1] : null;
    },
  },
  mounted() {
    this.fetchUser();
    this.fetchLocations();
  },
  beforeUnmount() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
    this._clearTimers();
  },
  methods: {
    formatDateTime(val) {
      if (!val) return '-';
      const d = new Date(val);
      if (isNaN(d.getTime())) return val;
      return d.toLocaleString('zh-TW', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      });
    },
    async fetchUser() {
      const res = await fetch('/api/admin/user', { credentials: 'same-origin' });
      if (res.ok) this.user = await res.json();
    },
    async fetchLocations() {
      this.loading = true;
      try {
        const params = new URLSearchParams();
        if (this.filterSince) params.set('since', this.filterSince);
        params.set('limit', '500');
        const res = await fetch(`/api/admin/members/${this.memberId}/locations?${params}`, {
          credentials: 'same-origin',
        });
        if (res.ok) {
          const data = await res.json();
          this.member = data.member;
          this.points = data.points || [];
          this.$nextTick(() => this.renderMap());
        } else {
          this.points = [];
        }
      } finally {
        this.loading = false;
      }
    },

    // 後台點「立即定位」→ 發請求，開始輪詢等待結果
    async requestLocationNow() {
      this._clearTimers();
      this.requestStatus = 'waiting';
      this.countdown = 30;

      try {
        await fetch(`/api/admin/members/${this.memberId}/location-request`, {
          method: 'POST',
          credentials: 'same-origin',
          headers: { 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.content || '' },
        });
      } catch {
        this.requestStatus = 'idle';
        return;
      }

      // 倒數計時
      this._countdownTimer = setInterval(() => {
        this.countdown--;
        if (this.countdown <= 0) {
          this._clearTimers();
          this.requestStatus = 'idle';
        }
      }, 1000);

      // 每 5 秒拉一次最新定位，看是否有新資料
      const beforeLatest = this.latestPoint?.created_at || null;
      this._pollTimer = setInterval(async () => {
        try {
          const res = await fetch(`/api/admin/members/${this.memberId}/location-latest`, {
            credentials: 'same-origin',
          });
          if (!res.ok) return;
          const data = await res.json();
          const newPoint = data.point;
          if (newPoint && newPoint.created_at !== beforeLatest) {
            this._clearTimers();
            this.requestStatus = 'done';
            await this.fetchLocations();
            setTimeout(() => { this.requestStatus = 'idle'; }, 5000);
          }
        } catch { /* 忽略 */ }
      }, 5000);
    },

    _clearTimers() {
      if (this._countdownTimer) { clearInterval(this._countdownTimer); this._countdownTimer = null; }
      if (this._pollTimer) { clearInterval(this._pollTimer); this._pollTimer = null; }
    },

    renderMap() {
      if (!this.points.length || !this.$refs.mapContainer) return;

      if (this.map) {
        this.map.remove();
      }

      const latlngs = this.points.map((p) => [parseFloat(p.latitude), parseFloat(p.longitude)]);
      const center = latlngs[0];
      const bounds = L.latLngBounds(latlngs);

      this.map = L.map(this.$refs.mapContainer, {
        center,
        zoom: 14,
      });

      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      }).addTo(this.map);

      if (latlngs.length > 1) {
        L.polyline(latlngs, { color: '#3b82f6', weight: 4 }).addTo(this.map);
      }

      const lastIcon = L.divIcon({
        className: 'location-marker',
        html: '<div style="width:12px;height:12px;background:#ef4444;border:2px solid white;border-radius:50%;box-shadow:0 1px 3px rgba(0,0,0,0.3)"></div>',
        iconSize: [12, 12],
        iconAnchor: [6, 6],
      });
      L.marker(latlngs[latlngs.length - 1], { icon: lastIcon }).addTo(this.map);

      if (latlngs.length > 1) {
        const firstIcon = L.divIcon({
          className: 'location-marker',
          html: '<div style="width:10px;height:10px;background:#22c55e;border:2px solid white;border-radius:50%;box-shadow:0 1px 3px rgba(0,0,0,0.3)"></div>',
          iconSize: [10, 10],
          iconAnchor: [5, 5],
        });
        L.marker(latlngs[0], { icon: firstIcon }).addTo(this.map);
      }

      this.map.fitBounds(bounds.pad(0.1));
    },
  },
};
</script>

<style scoped>
.location-map {
  height: 480px;
  min-height: 400px;
}
</style>
