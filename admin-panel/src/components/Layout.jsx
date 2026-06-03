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

  return (
    <div className="layout">
      <Sidebar />
      <div className="layout-main">
        {/* Top Header Bar */}
        <header className="layout-header">
          <div className="layout-header-left">
            <h2 className="layout-header-title">{meta.title}</h2>
            <p className="layout-header-subtitle">{meta.subtitle}</p>
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
          background: rgba(15, 23, 42, 0.85);
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
      `}</style>
    </div>
  );
}
