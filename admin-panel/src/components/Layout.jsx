import React from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import Sidebar from './Sidebar';

const PAGE_TITLES = {
  '/':          { title: 'Dashboard',  subtitle: 'Platform overview and key metrics' },
  '/users':     { title: 'Users',      subtitle: 'Manage all platform users' },
  '/stores':    { title: 'Stores',     subtitle: 'Manage registered restaurants & stores' },
  '/orders':    { title: 'Orders',     subtitle: 'Monitor and track all orders' },
  '/analytics': { title: 'Analytics',  subtitle: 'Revenue trends and performance insights' },
};

export default function Layout() {
  const { pathname } = useLocation();
  const meta = PAGE_TITLES[pathname] || { title: 'Admin', subtitle: '' };
  const [isSidebarOpen, setIsSidebarOpen] = React.useState(false);

  React.useEffect(() => {
    setIsSidebarOpen(false);
  }, [pathname]);

  return (
    <div className="layout">
      <Sidebar isOpen={isSidebarOpen} onClose={() => setIsSidebarOpen(false)} />
      
      {isSidebarOpen && (
        <div className="sidebar-overlay" onClick={() => setIsSidebarOpen(false)} />
      )}

      <div className="layout-main">
        {/* Top Header Bar */}
        <header className="layout-header">
          <div className="layout-header-left">
            <button className="menu-toggle-btn" onClick={() => setIsSidebarOpen(true)} title="Toggle Menu">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                <line x1="3" y1="12" x2="21" y2="12" />
                <line x1="3" y1="6" x2="21" y2="6" />
                <line x1="3" y1="18" x2="21" y2="18" />
              </svg>
            </button>
            <div className="header-meta">
              <h2 className="layout-header-title">{meta.title}</h2>
              <p className="layout-header-subtitle">{meta.subtitle}</p>
            </div>
          </div>
          <div className="layout-header-right">
            <div className="header-time">
              {new Date().toLocaleDateString('en-US', {
                weekday: 'short',
                month: 'short',
                day: 'numeric',
                year: 'numeric',
              })}
            </div>
            <div className="header-dot" />
          </div>
        </header>

        {/* Page Content */}
        <main className="layout-content">
          <Outlet />
        </main>
      </div>

      <style>{`
        .layout {
          display: flex;
          min-height: 100vh;
        }

        .layout-main {
          margin-left: var(--sidebar-width);
          flex: 1;
          display: flex;
          flex-direction: column;
          min-height: 100vh;
          min-width: 0;
        }

        .layout-header {
          position: sticky;
          top: 0;
          z-index: 50;
          height: var(--header-height);
          background: rgba(255, 255, 255, 0.85);
          backdrop-filter: blur(12px);
          border-bottom: 1px solid var(--border);
          padding: 0 32px;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 16px;
          flex-shrink: 0;
        }

        .layout-header-left {
          display: flex;
          align-items: center;
          gap: 12px;
        }
        .header-meta {
          display: flex;
          align-items: baseline;
          gap: 12px;
        }
        .layout-header-title {
          font-size: 16px;
          font-weight: 700;
          color: var(--text-primary);
          letter-spacing: -0.3px;
        }
        .layout-header-subtitle {
          font-size: 12.5px;
          color: var(--text-muted);
        }

        .menu-toggle-btn {
          display: none;
        }

        .layout-header-right {
          display: flex;
          align-items: center;
          gap: 12px;
        }
        .header-time {
          font-size: 12px;
          color: var(--text-muted);
          font-weight: 500;
        }
        .header-dot {
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background: var(--green);
          box-shadow: 0 0 0 3px var(--green-muted);
          animation: pulse 2s infinite;
        }
        @keyframes pulse {
          0%, 100% { box-shadow: 0 0 0 3px var(--green-muted); }
          50%       { box-shadow: 0 0 0 6px rgba(34,197,94,0.08); }
        }

        .layout-content {
          flex: 1;
          overflow-y: auto;
        }

        /* ── Responsiveness ── */
        @media (max-width: 1024px) {
          .layout-main {
            margin-left: 0;
          }
          .layout-header {
            padding: 0 16px;
          }
          .menu-toggle-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: none;
            color: var(--text-primary);
            cursor: pointer;
            padding: 6px;
            border-radius: var(--radius-sm);
            transition: background var(--transition);
          }
          .menu-toggle-btn:hover {
            background: var(--bg-hover);
          }
          .sidebar-overlay {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.4);
            backdrop-filter: blur(4px);
            z-index: 90;
          }
        }

        @media (max-width: 600px) {
          .layout-header-subtitle {
            display: none;
          }
          .header-time {
            display: none;
          }
        }
      `}</style>
    </div>
  );
}
