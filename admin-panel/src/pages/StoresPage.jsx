import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { storesAPI } from '../services/api';
import DataTable from '../components/DataTable';

const STUB_STORES = Array.from({ length: 18 }, (_, i) => ({
  id:       `s${i + 1}`,
  name:     ['Burger Palace', 'Pizza Hut Express', 'Sushi Corner', 'Taco Town',
             'The Salad Bar', 'Noodle House', 'Grill Master', 'Sweet Treats',
             'Wrap It Up', 'The Curry Pot'][i % 10],
  owner:    ['Alice Johnson', 'Bob Martinez', 'Carol White', 'David Lee', 'Eve Thompson'][i % 5],
  cuisine:  ['Burgers', 'Pizza', 'Japanese', 'Mexican', 'Healthy', 'Asian', 'BBQ', 'Desserts', 'Wraps', 'Indian'][i % 10],
  rating:   (3.5 + (i % 15) * 0.1).toFixed(1),
  orders:   Math.floor(Math.random() * 2000) + 100,
  status:   i % 6 === 0 ? 'disabled' : 'active',
  joined:   `2024-${String(Math.ceil((i + 1) / 2)).padStart(2, '0')}-${String((i % 28) + 1).padStart(2, '0')}`,
}));

export default function StoresPage() {
  const [stores,   setStores]   = useState([]);
  const [loading,  setLoading]  = useState(true);
  const [error,    setError]    = useState(null);
  const [search,   setSearch]   = useState('');
  const [toggling, setToggling] = useState(null);

  const fetchStores = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = search ? { search } : {};
      const { data } = await storesAPI.getAll(params);
      setStores(data.stores || data);
    } catch (err) {
      if (err.response?.status !== 401) {
        setError('Could not load stores — showing demo data.');
        setStores(STUB_STORES);
      }
    } finally {
      setLoading(false);
    }
  }, [search]);

  useEffect(() => {
    const id = setTimeout(fetchStores, 350);
    return () => clearTimeout(id);
  }, [fetchStores]);

  const handleToggleStatus = useCallback(async (store) => {
    const newStatus = store.status === 'active' ? 'disabled' : 'active';
    setToggling(store.id);
    try {
      await storesAPI.updateStatus(store.id, newStatus);
      setStores((prev) =>
        prev.map((s) => (s.id === store.id ? { ...s, status: newStatus } : s))
      );
    } catch {
      alert('Failed to update store status. Please try again.');
    } finally {
      setToggling(null);
    }
  }, []);

  const filtered = useMemo(() => {
    if (!search) return stores;
    const q = search.toLowerCase();
    return stores.filter(
      (s) =>
        s.name?.toLowerCase().includes(q) ||
        s.owner?.toLowerCase().includes(q) ||
        s.cuisine?.toLowerCase().includes(q)
    );
  }, [stores, search]);

  const columns = useMemo(() => [
    {
      key: 'name',
      label: 'Store',
      sortable: true,
      render: (v, row) => (
        <div className="store-cell">
          <div className="store-icon">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
              <polyline points="9 22 9 12 15 12 15 22"/>
            </svg>
          </div>
          <div>
            <div className="store-name">{v}</div>
            <div className="store-owner">{row.owner}</div>
          </div>
        </div>
      ),
    },
    {
      key: 'cuisine',
      label: 'Cuisine',
      sortable: true,
      render: (v) => <span className="badge badge-muted">{v}</span>,
    },
    {
      key: 'rating',
      label: 'Rating',
      sortable: true,
      render: (v) => (
        <span className="rating-cell">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="#eab308" stroke="#eab308" strokeWidth="1">
            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
          </svg>
          {v}
        </span>
      ),
    },
    {
      key: 'orders',
      label: 'Total Orders',
      sortable: true,
      render: (v) => <span className="mono-val">{(v ?? 0).toLocaleString()}</span>,
    },
    {
      key: 'joined',
      label: 'Joined',
      sortable: true,
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (v) => (
        <span className={`badge ${v === 'active' ? 'badge-green' : 'badge-red'}`}>
          {v === 'active' ? 'Active' : 'Disabled'}
        </span>
      ),
    },
    {
      key: 'id',
      label: 'Action',
      render: (_, row) => (
        <button
          className={`toggle-btn ${row.status === 'active' ? 'toggle-suspend' : 'toggle-activate'}`}
          onClick={() => handleToggleStatus(row)}
          disabled={toggling === row.id}
        >
          {toggling === row.id ? '…' : row.status === 'active' ? 'Disable' : 'Enable'}
        </button>
      ),
    },
  ], [handleToggleStatus, toggling]);

  return (
    <div className="page-wrapper">
      <div className="page-header">
        <div>
          <h1>Stores</h1>
          <p>Manage registered restaurants and food stores</p>
        </div>
        <div className="badge badge-muted" style={{ fontSize: 13, padding: '6px 14px' }}>
          {filtered.length} stores
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
        {/* Search bar */}
        <div className="table-toolbar">
          <div className="search-box">
            <svg className="search-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input
              type="text"
              className="form-input search-input"
              placeholder="Search by store, owner, or cuisine…"
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
          {/* Quick stats */}
          <div className="stores-quick-stats">
            <span className="quick-stat">
              <span className="quick-stat-dot" style={{ background: 'var(--green)' }} />
              {stores.filter((s) => s.status === 'active').length} active
            </span>
            <span className="quick-stat">
              <span className="quick-stat-dot" style={{ background: 'var(--red)' }} />
              {stores.filter((s) => s.status !== 'active').length} disabled
            </span>
          </div>
        </div>

        <DataTable
          columns={columns}
          data={filtered}
          loading={loading}
          keyField="id"
          emptyMessage="No stores match your search"
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
        .search-input { padding-left: 34px; padding-right: 34px; height: 36px; }
        .search-clear {
          position: absolute;
          right: 8px;
          background: transparent;
          color: var(--text-muted);
          display: flex;
          align-items: center;
          transition: color var(--transition);
        }
        .search-clear:hover { color: var(--text-primary); }

        .stores-quick-stats {
          display: flex;
          align-items: center;
          gap: 16px;
          flex-shrink: 0;
        }
        .quick-stat {
          display: flex;
          align-items: center;
          gap: 6px;
          font-size: 12.5px;
          color: var(--text-secondary);
          font-weight: 500;
        }
        .quick-stat-dot {
          width: 7px;
          height: 7px;
          border-radius: 50%;
          flex-shrink: 0;
        }

        .store-cell {
          display: flex;
          align-items: center;
          gap: 10px;
        }
        .store-icon {
          width: 32px;
          height: 32px;
          border-radius: var(--radius-sm);
          background: var(--accent-muted);
          color: var(--accent);
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }
        .store-name  { font-weight: 600; font-size: 13.5px; }
        .store-owner { font-size: 12px; color: var(--text-muted); }

        .rating-cell {
          display: inline-flex;
          align-items: center;
          gap: 4px;
          font-weight: 600;
          color: var(--yellow);
        }

        .mono-val { font-family: monospace; font-size: 13px; }

        .toggle-btn {
          font-size: 12px;
          font-weight: 600;
          padding: 5px 12px;
          border-radius: var(--radius-sm);
          transition: all var(--transition);
          min-width: 66px;
          text-align: center;
        }
        .toggle-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .toggle-suspend {
          background: var(--red-muted);
          color: var(--red);
          border: 1px solid rgba(239,68,68,0.2);
        }
        .toggle-suspend:hover:not(:disabled) { background: rgba(239,68,68,0.25); }
        .toggle-activate {
          background: var(--green-muted);
          color: var(--green);
          border: 1px solid rgba(34,197,94,0.2);
        }
        .toggle-activate:hover:not(:disabled) { background: rgba(34,197,94,0.25); }
      `}</style>
    </div>
  );
}
