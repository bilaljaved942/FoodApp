import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { usersAPI } from '../services/api';
import DataTable from '../components/DataTable';

const ROLE_OPTIONS   = ['all', 'customer', 'driver', 'store_owner'];
const STATUS_OPTIONS = ['all', 'active', 'suspended'];

const STUB_USERS = Array.from({ length: 22 }, (_, i) => ({
  id:        `u${i + 1}`,
  name:      ['Alice Johnson', 'Bob Martinez', 'Carol White', 'David Lee', 'Eve Thompson',
              'Frank Garcia', 'Grace Kim', 'Henry Brown', 'Isla Davis', 'Jack Wilson'][i % 10],
  email:     `user${i + 1}@example.com`,
  role:      ['customer', 'driver', 'store_owner', 'customer', 'customer'][i % 5],
  status:    i % 7 === 0 ? 'suspended' : 'active',
  orders:    Math.floor(Math.random() * 120),
  joined:    `2024-${String(Math.ceil((i + 1) / 2)).padStart(2, '0')}-${String((i % 28) + 1).padStart(2, '0')}`,
}));

const ROLE_BADGE = {
  customer:    { cls: 'badge-blue',   label: 'Customer' },
  driver:      { cls: 'badge-green',  label: 'Driver' },
  store_owner: { cls: 'badge-purple', label: 'Store Owner' },
};

export default function UsersPage() {
  const [users,     setUsers]     = useState([]);
  const [loading,   setLoading]   = useState(true);
  const [error,     setError]     = useState(null);
  const [search,    setSearch]    = useState('');
  const [roleFilter,   setRoleFilter]   = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [toggling,  setToggling]  = useState(null); // id being toggled

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = {};
      if (roleFilter   !== 'all') params.role   = roleFilter;
      if (statusFilter !== 'all') params.status  = statusFilter;
      if (search) params.search = search;

      const { data } = await usersAPI.getAll(params);
      setUsers(data.users || data);
    } catch (err) {
      if (err.response?.status !== 401) {
        setError('Could not load users — showing demo data.');
        setUsers(STUB_USERS);
      }
    } finally {
      setLoading(false);
    }
  }, [roleFilter, statusFilter, search]);

  useEffect(() => {
    const id = setTimeout(fetchUsers, 350);
    return () => clearTimeout(id);
  }, [fetchUsers]);

  const handleToggleStatus = useCallback(async (user) => {
    const newStatus = user.status === 'active' ? 'suspended' : 'active';
    setToggling(user.id);
    try {
      await usersAPI.updateStatus(user.id, newStatus);
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? { ...u, status: newStatus } : u))
      );
    } catch {
      alert('Failed to update user status. Please try again.');
    } finally {
      setToggling(null);
    }
  }, []);

  /* Client-side quick filter on top of server search */
  const filtered = useMemo(() => {
    let result = users;
    if (search) {
      const q = search.toLowerCase();
      result = result.filter(
        (u) =>
          u.name?.toLowerCase().includes(q) ||
          u.email?.toLowerCase().includes(q)
      );
    }
    return result;
  }, [users, search]);

  const columns = useMemo(() => [
    {
      key: 'name',
      label: 'User',
      sortable: true,
      render: (_, row) => (
        <div className="user-cell">
          <div className="user-avatar-sm">{row.name?.[0]?.toUpperCase() || '?'}</div>
          <div>
            <div className="user-name">{row.name}</div>
            <div className="user-email">{row.email}</div>
          </div>
        </div>
      ),
    },
    {
      key: 'role',
      label: 'Role',
      sortable: true,
      render: (v) => {
        const b = ROLE_BADGE[v] || { cls: 'badge-muted', label: v };
        return <span className={`badge ${b.cls}`}>{b.label}</span>;
      },
    },
    {
      key: 'orders',
      label: 'Orders',
      sortable: true,
      render: (v) => <span className="mono-val">{v ?? 0}</span>,
    },
    {
      key: 'joined',
      label: 'Joined',
      sortable: true,
      render: (v) => v || '—',
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (v) => (
        <span className={`badge ${v === 'active' ? 'badge-green' : 'badge-red'}`}>
          {v === 'active' ? 'Active' : 'Suspended'}
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
          {toggling === row.id ? (
            '…'
          ) : row.status === 'active' ? (
            'Suspend'
          ) : (
            'Activate'
          )}
        </button>
      ),
    },
  ], [handleToggleStatus, toggling]);

  return (
    <div className="page-wrapper">
      <div className="page-header">
        <div>
          <h1>Users</h1>
          <p>Manage all platform users — customers, drivers, and store owners</p>
        </div>
        <div className="badge badge-muted" style={{ fontSize: 13, padding: '6px 14px' }}>
          {filtered.length} total
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
        {/* Filters */}
        <div className="table-toolbar">
          <div className="search-box">
            <svg className="search-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            <input
              type="text"
              className="form-input search-input"
              placeholder="Search by name or email…"
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
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
            >
              {ROLE_OPTIONS.map((r) => (
                <option key={r} value={r}>
                  {r === 'all' ? 'All Roles' : r.replace('_', ' ').replace(/\b\w/g, (c) => c.toUpperCase())}
                </option>
              ))}
            </select>
            <select
              className="form-input filter-select"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              {STATUS_OPTIONS.map((s) => (
                <option key={s} value={s}>
                  {s === 'all' ? 'All Statuses' : s.charAt(0).toUpperCase() + s.slice(1)}
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
          emptyMessage="No users match your filters"
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
          max-width: 340px;
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
          transition: color var(--transition);
        }
        .search-clear:hover { color: var(--text-primary); }

        .filter-group {
          display: flex;
          gap: 8px;
          flex-shrink: 0;
        }
        .filter-select {
          height: 36px;
          padding: 0 10px;
          min-width: 130px;
          cursor: pointer;
        }

        .user-cell {
          display: flex;
          align-items: center;
          gap: 10px;
        }
        .user-avatar-sm {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          background: var(--accent-muted);
          color: var(--accent);
          font-size: 13px;
          font-weight: 700;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }
        .user-name { font-weight: 600; font-size: 13.5px; }
        .user-email { font-size: 12px; color: var(--text-muted); }

        .mono-val { font-family: monospace; font-size: 13px; }

        .toggle-btn {
          font-size: 12px;
          font-weight: 600;
          padding: 5px 12px;
          border-radius: var(--radius-sm);
          transition: all var(--transition);
          min-width: 72px;
          text-align: center;
        }
        .toggle-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .toggle-suspend {
          background: var(--red-muted);
          color: var(--red);
          border: 1px solid rgba(239,68,68,0.2);
        }
        .toggle-suspend:hover:not(:disabled) {
          background: rgba(239,68,68,0.25);
        }
        .toggle-activate {
          background: var(--green-muted);
          color: var(--green);
          border: 1px solid rgba(34,197,94,0.2);
        }
        .toggle-activate:hover:not(:disabled) {
          background: rgba(34,197,94,0.25);
        }
      `}</style>
    </div>
  );
}
