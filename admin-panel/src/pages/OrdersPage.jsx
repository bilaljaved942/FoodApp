import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { ordersAPI } from '../services/api';
import DataTable from '../components/DataTable';

const STATUS_OPTIONS = ['all', 'pending', 'preparing', 'in_transit', 'delivered', 'cancelled'];

const STUB_ORDERS = [
  { id: '9841', store: 'Burger Palace',    customer: 'Alice Johnson',   amount: 34.50, status: 'delivered',  date: '2026-06-05 18:24' },
  { id: '9840', store: 'Pizza Hut Express', customer: 'Bob Martinez',    amount: 22.00, status: 'in_transit', date: '2026-06-05 19:12' },
  { id: '9839', store: 'Sushi Corner',     customer: 'Carol White',     amount: 67.80, status: 'preparing',  date: '2026-06-05 20:05' },
  { id: '9838', store: 'Taco Town',        customer: 'David Lee',       amount: 18.90, status: 'delivered',  date: '2026-06-05 21:10' },
  { id: '9837', store: 'The Salad Bar',    customer: 'Eve Thompson',    amount: 14.20, status: 'cancelled',  date: '2026-06-05 21:40' },
  { id: '9836', store: 'Noodle House',     customer: 'Frank Garcia',    amount: 45.10, status: 'pending',    date: '2026-06-05 22:02' },
  { id: '9835', store: 'Grill Master',     customer: 'Grace Kim',       amount: 89.90, status: 'preparing',  date: '2026-06-05 22:15' },
  { id: '9834', store: 'Sweet Treats',     customer: 'Henry Brown',     amount: 12.50, status: 'delivered',  date: '2026-06-05 22:20' },
];

const STATUS_BADGE = {
  delivered:  { cls: 'badge-green',  label: 'Delivered' },
  in_transit: { cls: 'badge-blue',   label: 'In Transit' },
  preparing:  { cls: 'badge-yellow', label: 'Preparing' },
  pending:    { cls: 'badge-muted',  label: 'Pending' },
  cancelled:  { cls: 'badge-red',    label: 'Cancelled' },
};

export default function OrdersPage() {
  const [orders,       setOrders]       = useState([]);
  const [loading,      setLoading]      = useState(true);
  const [error,        setError]        = useState(null);
  const [search,       setSearch]       = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const fetchOrders = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = {};
      if (statusFilter !== 'all') params.status = statusFilter;
      if (search) params.search = search;

      const { data } = await ordersAPI.getAll(params);
      setOrders(data.orders || data);
    } catch (err) {
      if (err.response?.status !== 401) {
        setError('Could not load orders — showing demo data.');
        setOrders(STUB_ORDERS);
      }
    } finally {
      setLoading(false);
    }
  }, [statusFilter, search]);

  useEffect(() => {
    const id = setTimeout(fetchOrders, 350);
    return () => clearTimeout(id);
  }, [fetchOrders]);

  const filtered = useMemo(() => {
    let result = orders;
    
    // Status client filter
    if (statusFilter !== 'all') {
      result = result.filter((o) => o.status === statusFilter);
    }

    // Search client filter
    if (search) {
      const q = search.toLowerCase();
      result = result.filter(
        (o) =>
          o.id?.toLowerCase().includes(q) ||
          o.store?.toLowerCase().includes(q) ||
          o.customer?.toLowerCase().includes(q)
      );
    }
    return result;
  }, [orders, statusFilter, search]);

  const columns = useMemo(() => [
    {
      key: 'id',
      label: 'Order ID',
      sortable: true,
      render: (v) => <span className="order-id-val">#ORD-{v}</span>,
    },
    {
      key: 'store',
      label: 'Store / Restaurant',
      sortable: true,
      render: (v) => (
        <div className="store-cell">
          <div className="store-icon-sm">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
              <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            </svg>
          </div>
          <span className="store-name-val">{v}</span>
        </div>
      ),
    },
    {
      key: 'customer',
      label: 'Customer',
      sortable: true,
    },
    {
      key: 'amount',
      label: 'Amount',
      sortable: true,
      render: (v) => <span className="amount-val">${typeof v === 'number' ? v.toFixed(2) : v}</span>,
    },
    {
      key: 'date',
      label: 'Date & Time',
      sortable: true,
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (v) => {
        const badge = STATUS_BADGE[v] || STATUS_BADGE.pending;
        return <span className={`badge ${badge.cls}`}>{badge.label}</span>;
      },
    },
  ], []);

  return (
    <div className="page-wrapper">
      <div className="page-header">
        <div>
          <h1>Orders</h1>
          <p>Monitor platform transaction orders and real-time delivery status</p>
        </div>
        <div className="badge badge-muted" style={{ fontSize: 13, padding: '6px 14px' }}>
          {filtered.length} orders
        </div>
      </div>

      {error && (
        <div className="error-banner">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          {error}
        </div>
      )}

      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        {/* Toolbar Filters */}
        <div className="table-toolbar">
          <div className="search-box">
            <svg className="search-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input
              type="text"
              className="form-input search-input"
              placeholder="Search by order ID, store, or customer…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
            {search && (
              <button className="search-clear" onClick={() => setSearch('')}>
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                  <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
              </button>
            )}
          </div>
          
          <div className="filter-group">
            <select
              className="form-input filter-select"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              {STATUS_OPTIONS.map((opt) => (
                <option key={opt} value={opt}>
                  {opt === 'all' ? 'All Statuses' : opt.replace('_', ' ').replace(/\b\w/g, (c) => c.toUpperCase())}
                </option>
              ))}
            </select>
          </div>
        </div>

        <DataTable
          columns={columns}
          data={filtered}
          loading={loading}
          keyField="id"
          emptyMessage="No orders found matching search criteria"
        />
      </div>

      <style>{`
        .table-toolbar {
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
          padding: 16px 20px;
          border-bottom: 1px solid var(--border);
          flex-wrap: wrap;
        }

        .search-box {
          position: relative;
          display: flex;
          align-items: center;
          flex: 1;
          min-width: 200px;
          max-width: 380px;
        }
        .search-icon {
          position: absolute;
          left: 11px;
          color: var(--text-muted);
          pointer-events: none;
        }
        .search-input {
          padding-left: 34px;
          padding-right: 34px;
          height: 36px;
        }
        .search-clear {
          position: absolute;
          right: 8px;
          background: transparent;
          color: var(--text-muted);
          display: flex;
          align-items: center;
        }

        .filter-group {
          display: flex;
          gap: 8px;
        }
        .filter-select {
          height: 36px;
          padding: 0 10px;
          min-width: 140px;
          cursor: pointer;
        }

        .order-id-val {
          font-weight: 700;
          color: var(--accent);
          font-family: monospace;
          font-size: 13.5px;
        }

        .store-cell {
          display: flex;
          align-items: center;
          gap: 8px;
        }
        .store-icon-sm {
          width: 24px;
          height: 24px;
          border-radius: 6px;
          background: var(--bg-hover);
          color: var(--text-secondary);
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }
        .store-name-val {
          font-weight: 500;
        }

        .amount-val {
          font-weight: 600;
        }
      `}</style>
    </div>
  );
}
