import axios from 'axios';

const BASE_URL = '/api';

const api = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 15000,
});

/* ── Request interceptor: attach JWT ── */
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('adminToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

/* ── Response interceptor: handle 401 ── */
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      localStorage.removeItem('adminUser');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

/* ─────────────────────────────────────────
   Auth
───────────────────────────────────────── */
export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
};

/* ─────────────────────────────────────────
   Dashboard
───────────────────────────────────────── */
export const dashboardAPI = {
  getStats: () => api.get('/super/dashboard'),
};

/* ─────────────────────────────────────────
   Users
───────────────────────────────────────── */
export const usersAPI = {
  getAll:       (params) => api.get('/super/users', { params }),
  updateStatus: (id, status) => api.patch(`/super/users/${id}/status`, { status }),
};

/* ─────────────────────────────────────────
   Stores
───────────────────────────────────────── */
export const storesAPI = {
  getAll:       (params) => api.get('/super/stores', { params }),
  updateStatus: (id, status) => api.patch(`/super/stores/${id}/status`, { status }),
};

/* ─────────────────────────────────────────
   Orders
───────────────────────────────────────── */
export const ordersAPI = {
  getAll: (params) => api.get('/super/orders', { params }),
};

export default api;
