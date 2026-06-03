import React, { useState, useEffect, useCallback } from 'react';
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import { dashboardAPI } from '../services/api';
import StatCard from '../components/StatCard';

/* ── Fallback stub data shown when API is not yet connected ── */
const STUB_STATS = {
  totalUsers:    12_847,
  totalStores:   384,
  activeOrders:  1_293,
  totalRevenue:  '$284,920',
};

const STUB_REVENUE = [
  { month: 'Jan', revenue: 18400, orders: 940 },
  { month: 'Feb', revenue: 22100, orders: 1120 },
  { month: 'Mar', revenue: 19800, orders: 1050 },
  { month: 'Apr', revenue: 26300, orders: 1380 },
  { month: 'May', revenue: 31200, orders: 1640 },
  { month: 'Jun', revenue: 28700, orders: 1510 },
  { month: 'Jul', revenue: 34500, orders: 1820 },
  { month: 'Aug', revenue: 38900, orders: 2040 },
  { month: 'Sep', revenue: 35400, orders: 1870 },
  { month: 'Oct', revenue: 41200, orders: 2190 },
  { month: 'Nov', revenue: 46800, orders: 2470 },
  { month: 'Dec', revenue: 52100, orders: 2740 },
];

const RECENT_ORDERS = [
  { id: '#ORD-9841', store: 'Burger Palace',    customer: 'Alice Johnson',   amount: '$34.50', status: 'delivered' },
  { id: '#ORD-9840', store: 'Pizza Hut Express', customer: 'Bob Martinez',    amount: '$22.00', status: 'in_transit' },
  { id: '#ORD-9839', store: 'Sushi Corner',     customer: 'Carol White',     amount: '$67.80', status: 'preparing' },
  { id: '#ORD-9838', store: 'Taco Town',        customer: 'David Lee',       amount: '$18.90', status: 'delivered' },
  { id: '#ORD-9837', store: 'The Salad Bar',    customer: 'Eve Thompson',    amount: '$14.20', status: 'cancelled' },
];

const STATUS_BADGE = {
  delivered:  { cls: 'badge-green',  label: 'Delivered' },
  in_transit: { cls: 'badge-blue',   label: 'In Transit' },
  preparing:  { cls: 'badge-yellow', label: 'Preparing' },
  pending:    { cls: 'badge-muted',  label: 'Pending' },
  cancelled:  { cls: 'badge-red',    label: 'Cancelled' },
};

/* ── Custom tooltip for the chart ── */
function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="chart-tooltip">
      <p className="chart-tooltip-label">{label}</p>
      {payload.map((p) => (
        <p key={p.dataKey} style={{ color: p.color }}>
          {p.name}: <strong>
            {p.dataKey === 'revenue' ? `$${p.value.toLocaleString()}` : p.value.toLocaleString()}
          </strong>
        </p>
      ))}
    </div>
  );
}

export default function DashboardPage() {
  const [stats,   setStats]   = useState(null);
  const [revenue, setRevenue] = useState(STUB_REVENUE);
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const { data } = await dashboardAPI.getStats();
      setStats(data.stats || data);
      if (data.revenue) setRevenue(data.revenue);
    } catch (err) {
      if (err.response?.status !== 401) {
        setError('Could not load dashboard data — showing demo values.');
        setStats(STUB_STATS);
      }
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const s = stats || STUB_STATS;

  const formatRevenue = (v) =>
    typeof v === 'number' ? `$${v.toLocaleString()}` : v;

  return (
    <div className="page-wrapper">
      {error && (
        <div className="error-banner">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          {error}
        </div>
      )}

      {/* ── Stat Cards ── */}
      <section className="stats-grid">
        <StatCard
          title="Total Users"
          value={loading ? '…' : (s.totalUsers ?? s.total_users ?? 0).toLocaleString()}
          subtitle="Registered accounts"
          color="blue"
          trend={{ value: '+12% this month', up: true }}
          icon={
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
              <circle cx="9" cy="7" r="4"/>
              <path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
          }
        />
        <StatCard
          title="Total Stores"
          value={loading ? '…' : (s.totalStores ?? s.total_stores ?? 0).toLocaleString()}
          subtitle="Active restaurants"
          color="purple"
          trend={{ value: '+8 this week', up: true }}
          icon={
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
              <polyline points="9 22 9 12 15 12 15 22"/>
            </svg>
          }
        />
        <StatCard
          title="Active Orders"
          value={loading ? '…' : (s.activeOrders ?? s.active_orders ?? 0).toLocaleString()}
          subtitle="Right now"
          color="orange"
          trend={{ value: '+5.2% today', up: true }}
          icon={
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
              <line x1="3" y1="6" x2="21" y2="6"/>
              <path d="M16 10a4 4 0 0 1-8 0"/>
            </svg>
          }
        />
        <StatCard
          title="Total Revenue"
          value={loading ? '…' : formatRevenue(s.totalRevenue ?? s.total_revenue ?? 0)}
          subtitle="All time"
          color="green"
          trend={{ value: '+18.4% this month', up: true }}
          icon={
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <line x1="12" y1="1" x2="12" y2="23"/>
              <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
            </svg>
          }
        />
      </section>

      {/* ── Revenue Chart ── */}
      <div className="card">
        <div className="card-header">
          <div>
            <h3 className="card-title">Revenue Overview</h3>
            <p className="card-subtitle">Monthly revenue and order trends</p>
          </div>
          <div className="badge badge-green">
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'currentColor', display: 'inline-block' }} />
            Live
          </div>
        </div>
        <div className="chart-container">
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={revenue} margin={{ top: 5, right: 10, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id="gradRevenue" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%"  stopColor="#f97316" stopOpacity={0.25} />
                  <stop offset="95%" stopColor="#f97316" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="gradOrders" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%"  stopColor="#3b82f6" stopOpacity={0.2} />
                  <stop offset="95%" stopColor="#3b82f6" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
              <XAxis
                dataKey="month"
                tick={{ fill: '#64748b', fontSize: 12 }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                tick={{ fill: '#64748b', fontSize: 12 }}
                axisLine={false}
                tickLine={false}
                tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
                yAxisId="revenue"
                orientation="left"
              />
              <YAxis
                yAxisId="orders"
                orientation="right"
                tick={{ fill: '#64748b', fontSize: 12 }}
                axisLine={false}
                tickLine={false}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend
                wrapperStyle={{ paddingTop: 16, fontSize: 12, color: '#94a3b8' }}
              />
              <Area
                yAxisId="revenue"
                type="monotone"
                dataKey="revenue"
                name="Revenue ($)"
                stroke="#f97316"
                strokeWidth={2.5}
                fill="url(#gradRevenue)"
                dot={false}
                activeDot={{ r: 5, fill: '#f97316' }}
              />
              <Area
                yAxisId="orders"
                type="monotone"
                dataKey="orders"
                name="Orders"
                stroke="#3b82f6"
                strokeWidth={2}
                fill="url(#gradOrders)"
                dot={false}
                activeDot={{ r: 4, fill: '#3b82f6' }}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* ── Recent Orders ── */}
      <div className="card">
        <div className="card-header">
          <div>
            <h3 className="card-title">Recent Orders</h3>
            <p className="card-subtitle">Latest platform activity</p>
          </div>
        </div>
        <div className="recent-orders-table">
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr>
                {['Order ID', 'Store', 'Customer', 'Amount', 'Status'].map((h) => (
                  <th key={h} className="recent-th">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {RECENT_ORDERS.map((o) => {
                const badge = STATUS_BADGE[o.status] || STATUS_BADGE.pending;
                return (
                  <tr key={o.id} className="recent-row">
                    <td className="recent-td recent-id">{o.id}</td>
                    <td className="recent-td">{o.store}</td>
                    <td className="recent-td">{o.customer}</td>
                    <td className="recent-td recent-amount">{o.amount}</td>
                    <td className="recent-td">
                      <span className={`badge ${badge.cls}`}>{badge.label}</span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      <style>{`
        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 16px;
        }

        .card-header {
          display: flex;
          align-items: flex-start;
          justify-content: space-between;
          margin-bottom: 20px;
          gap: 12px;
        }
        .card-title {
          font-size: 15px;
          font-weight: 700;
          color: var(--text-primary);
          letter-spacing: -0.3px;
        }
        .card-subtitle {
          font-size: 12.5px;
          color: var(--text-muted);
          margin-top: 3px;
        }

        .chart-container {
          margin: 0 -8px;
        }

        .chart-tooltip {
          background: var(--bg-elevated);
          border: 1px solid var(--border);
          border-radius: var(--radius-sm);
          padding: 10px 14px;
          font-size: 12.5px;
          box-shadow: var(--shadow-md);
          line-height: 1.8;
        }
        .chart-tooltip-label {
          font-weight: 700;
          color: var(--text-primary);
          margin-bottom: 4px;
        }

        .recent-orders-table { overflow-x: auto; }
        .recent-th {
          padding: 10px 14px;
          text-align: left;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.6px;
          color: var(--text-muted);
          border-bottom: 1px solid var(--border);
        }
        .recent-row {
          transition: background var(--transition);
        }
        .recent-row:hover { background: var(--bg-elevated); }
        .recent-td {
          padding: 12px 14px;
          font-size: 13.5px;
          color: var(--text-primary);
          border-bottom: 1px solid var(--border);
          vertical-align: middle;
        }
        .recent-row:last-child .recent-td { border-bottom: none; }
        .recent-id   { font-weight: 600; color: var(--accent); font-family: monospace; }
        .recent-amount { font-weight: 600; }
      `}</style>
    </div>
  );
}
