import React, { useState, useMemo } from 'react';

/**
 * DataTable — Generic sortable table with search and pagination
 *
 * Props:
 *  - columns: Array<{ key, label, sortable?, render?(value, row) }>
 *  - data:    Array<object>
 *  - loading: boolean
 *  - keyField: string (unique row identifier key, default 'id')
 *  - emptyMessage: string
 */
export default function DataTable({
  columns = [],
  data = [],
  loading = false,
  keyField = 'id',
  emptyMessage = 'No records found',
}) {
  const [sortKey,  setSortKey]  = useState(null);
  const [sortDir,  setSortDir]  = useState('asc');
  const [page,     setPage]     = useState(1);
  const PAGE_SIZE = 10;

  const handleSort = (key) => {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortKey(key);
      setSortDir('asc');
    }
    setPage(1);
  };

  const sorted = useMemo(() => {
    if (!sortKey) return data;
    return [...data].sort((a, b) => {
      const av = a[sortKey] ?? '';
      const bv = b[sortKey] ?? '';
      if (av < bv) return sortDir === 'asc' ? -1 : 1;
      if (av > bv) return sortDir === 'asc' ? 1 : -1;
      return 0;
    });
  }, [data, sortKey, sortDir]);

  const totalPages = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
  const paginated  = sorted.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const SortIcon = ({ col }) => {
    if (!col.sortable) return null;
    const active = sortKey === col.key;
    return (
      <span className={`sort-icon ${active ? 'sort-icon--active' : ''}`}>
        {active && sortDir === 'desc' ? (
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="6 9 12 15 18 9"/></svg>
        ) : (
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="18 15 12 9 6 15"/></svg>
        )}
      </span>
    );
  };

  return (
    <div className="datatable-wrapper">
      {loading ? (
        <div className="loading-state">
          <div className="spinner" />
        </div>
      ) : paginated.length === 0 ? (
        <div className="empty-state">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
            <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
          </svg>
          <p>{emptyMessage}</p>
        </div>
      ) : (
        <>
          <div className="datatable-scroll">
            <table className="datatable">
              <thead>
                <tr>
                  {columns.map((col) => (
                    <th
                      key={col.key}
                      className={col.sortable ? 'sortable' : ''}
                      onClick={col.sortable ? () => handleSort(col.key) : undefined}
                    >
                      <span className="th-inner">
                        {col.label}
                        <SortIcon col={col} />
                      </span>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {paginated.map((row) => (
                  <tr key={row[keyField]}>
                    {columns.map((col) => (
                      <td key={col.key}>
                        {col.render ? col.render(row[col.key], row) : (row[col.key] ?? '—')}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="datatable-pagination">
              <span className="pagination-info">
                {(page - 1) * PAGE_SIZE + 1}–{Math.min(page * PAGE_SIZE, sorted.length)} of {sorted.length}
              </span>
              <div className="pagination-controls">
                <button
                  className="btn-ghost"
                  disabled={page === 1}
                  onClick={() => setPage((p) => p - 1)}
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6"/></svg>
                  Prev
                </button>
                <span className="pagination-page">{page} / {totalPages}</span>
                <button
                  className="btn-ghost"
                  disabled={page === totalPages}
                  onClick={() => setPage((p) => p + 1)}
                >
                  Next
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg>
                </button>
              </div>
            </div>
          )}
        </>
      )}

      <style>{`
        .datatable-wrapper {
          overflow: hidden;
        }
        .datatable-scroll {
          overflow-x: auto;
        }
        .datatable {
          width: 100%;
          border-collapse: collapse;
        }
        .datatable thead tr {
          border-bottom: 1px solid var(--border);
        }
        .datatable th {
          padding: 12px 16px;
          text-align: left;
          font-size: 11.5px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.6px;
          color: var(--text-muted);
          white-space: nowrap;
          user-select: none;
        }
        .datatable th.sortable {
          cursor: pointer;
          transition: color var(--transition);
        }
        .datatable th.sortable:hover { color: var(--text-primary); }

        .th-inner {
          display: inline-flex;
          align-items: center;
          gap: 5px;
        }
        .sort-icon { opacity: 0.4; display: flex; align-items: center; }
        .sort-icon--active { opacity: 1; color: var(--accent); }

        .datatable tbody tr {
          border-bottom: 1px solid var(--border);
          transition: background var(--transition);
        }
        .datatable tbody tr:last-child { border-bottom: none; }
        .datatable tbody tr:hover { background: var(--bg-elevated); }

        .datatable td {
          padding: 13px 16px;
          font-size: 13.5px;
          color: var(--text-primary);
          vertical-align: middle;
        }

        .datatable-pagination {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 14px 16px;
          border-top: 1px solid var(--border);
        }
        .pagination-info {
          font-size: 12.5px;
          color: var(--text-muted);
        }
        .pagination-controls {
          display: flex;
          align-items: center;
          gap: 8px;
        }
        .pagination-page {
          font-size: 12.5px;
          color: var(--text-secondary);
          min-width: 60px;
          text-align: center;
        }
        .btn-ghost:disabled {
          opacity: 0.35;
          cursor: not-allowed;
          pointer-events: none;
        }
      `}</style>
    </div>
  );
}
