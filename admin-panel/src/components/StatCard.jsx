import React from 'react';

/**
 * StatCard
 * Props:
 *  - title: string
 *  - value: string | number
 *  - subtitle: string (optional)
 *  - icon: ReactNode
 *  - color: 'orange' | 'green' | 'blue' | 'purple' | 'red' | 'yellow'
 *  - trend: { value: string, up: boolean } (optional)
 */
const COLOR_MAP = {
  orange: { bg: 'var(--accent-muted)',  icon: 'var(--accent)',  border: 'rgba(249,115,22,0.25)' },
  green:  { bg: 'var(--green-muted)',   icon: 'var(--green)',   border: 'rgba(34,197,94,0.25)' },
  blue:   { bg: 'var(--blue-muted)',    icon: 'var(--blue)',    border: 'rgba(59,130,246,0.25)' },
  purple: { bg: 'var(--purple-muted)',  icon: 'var(--purple)',  border: 'rgba(168,85,247,0.25)' },
  red:    { bg: 'var(--red-muted)',     icon: 'var(--red)',     border: 'rgba(239,68,68,0.25)' },
  yellow: { bg: 'var(--yellow-muted)',  icon: 'var(--yellow)',  border: 'rgba(234,179,8,0.25)' },
};

export default function StatCard({ title, value, subtitle, icon, color = 'orange', trend }) {
  const c = COLOR_MAP[color] || COLOR_MAP.orange;

  return (
    <div className="stat-card fade-up">
      <div className="stat-card-header">
        <div className="stat-card-title">{title}</div>
        <div className="stat-card-icon" style={{ background: c.bg, color: c.icon, border: `1px solid ${c.border}` }}>
          {icon}
        </div>
      </div>

      <div className="stat-card-value">{value ?? '—'}</div>

      <div className="stat-card-footer">
        {subtitle && <span className="stat-card-subtitle">{subtitle}</span>}
        {trend && (
          <span className={`stat-card-trend ${trend.up ? 'trend-up' : 'trend-down'}`}>
            {trend.up ? (
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                <polyline points="18 15 12 9 6 15"/>
              </svg>
            ) : (
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3">
                <polyline points="6 9 12 15 18 9"/>
              </svg>
            )}
            {trend.value}
          </span>
        )}
      </div>

      <style>{`
        .stat-card {
          background: var(--bg-surface);
          border: 1px solid var(--border);
          border-radius: var(--radius-lg);
          padding: 22px 24px;
          display: flex;
          flex-direction: column;
          gap: 12px;
          transition: border-color var(--transition), transform var(--transition), box-shadow var(--transition);
          cursor: default;
        }
        .stat-card:hover {
          border-color: var(--border-light);
          transform: translateY(-2px);
          box-shadow: var(--shadow-md);
        }

        .stat-card-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
        }
        .stat-card-title {
          font-size: 12.5px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.6px;
          color: var(--text-muted);
        }
        .stat-card-icon {
          width: 40px;
          height: 40px;
          border-radius: var(--radius-sm);
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }

        .stat-card-value {
          font-size: 30px;
          font-weight: 800;
          color: var(--text-primary);
          letter-spacing: -1px;
          line-height: 1;
        }

        .stat-card-footer {
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 8px;
        }
        .stat-card-subtitle {
          font-size: 12px;
          color: var(--text-muted);
        }
        .stat-card-trend {
          display: inline-flex;
          align-items: center;
          gap: 3px;
          font-size: 12px;
          font-weight: 600;
        }
        .trend-up   { color: var(--green); }
        .trend-down { color: var(--red); }
      `}</style>
    </div>
  );
}
