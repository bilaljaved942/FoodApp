import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const { login, loading, error, clearError } = useAuth();
  const navigate = useNavigate();

  const [email,    setEmail]    = useState('');
  const [password, setPassword] = useState('');
  const [showPwd,  setShowPwd]  = useState(false);

  useEffect(() => {
    if (error) clearError();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [email, password]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const result = await login(email.trim(), password);
    if (result.success) navigate('/');
  };

  return (
    <div className="login-root">
      {/* Decorative background glows */}
      <div className="login-glow login-glow-1" />
      <div className="login-glow login-glow-2" />

      <div className="login-card fade-up">
        {/* Logo */}
        <div className="login-logo">
          <div className="login-logo-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
              <circle cx="12" cy="12" r="10" fill="#f97316" opacity="0.2"/>
              <path d="M8 12c0-2.2 1.8-4 4-4s4 1.8 4 4-1.8 4-4 4" stroke="#f97316" strokeWidth="2.5" strokeLinecap="round"/>
              <circle cx="12" cy="12" r="1.5" fill="#f97316"/>
            </svg>
          </div>
          <span className="login-logo-text">FoodApp</span>
        </div>

        <h1 className="login-title">Welcome back</h1>
        <p className="login-subtitle">Sign in to the Super Admin panel</p>

        {error && (
          <div className="error-banner">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            {error}
          </div>
        )}

        <form className="login-form" onSubmit={handleSubmit} noValidate>
          {/* Email */}
          <div className="form-group">
            <label className="form-label">Email address</label>
            <div className="input-wrapper">
              <span className="input-prefix">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                  <polyline points="22,6 12,13 2,6"/>
                </svg>
              </span>
              <input
                type="email"
                className="form-input login-input"
                placeholder="admin@foodapp.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                autoFocus
                autoComplete="email"
              />
            </div>
          </div>

          {/* Password */}
          <div className="form-group">
            <label className="form-label">Password</label>
            <div className="input-wrapper">
              <span className="input-prefix">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                  <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
              </span>
              <input
                type={showPwd ? 'text' : 'password'}
                className="form-input login-input"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                autoComplete="current-password"
              />
              <button
                type="button"
                className="input-suffix"
                onClick={() => setShowPwd((v) => !v)}
                tabIndex={-1}
              >
                {showPwd ? (
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                ) : (
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                )}
              </button>
            </div>
          </div>

          <button
            type="submit"
            className="btn-primary login-submit"
            disabled={loading || !email || !password}
          >
            {loading ? (
              <>
                <span className="btn-spinner" />
                Signing in…
              </>
            ) : (
              <>
                Sign In
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
              </>
            )}
          </button>
        </form>

        <p className="login-footer">
          FoodApp Super Admin &copy; {new Date().getFullYear()}
        </p>
      </div>

      <style>{`
        .login-root {
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          background: var(--bg-base);
          padding: 24px;
          position: relative;
          overflow: hidden;
        }

        .login-glow {
          position: absolute;
          border-radius: 50%;
          filter: blur(100px);
          pointer-events: none;
          z-index: 0;
        }
        .login-glow-1 {
          width: 500px;
          height: 500px;
          background: radial-gradient(circle, rgba(249,115,22,0.12) 0%, transparent 70%);
          top: -150px;
          right: -100px;
        }
        .login-glow-2 {
          width: 400px;
          height: 400px;
          background: radial-gradient(circle, rgba(59,130,246,0.08) 0%, transparent 70%);
          bottom: -100px;
          left: -80px;
        }

        .login-card {
          background: var(--bg-surface);
          border: 1px solid var(--border);
          border-radius: var(--radius-lg);
          padding: 40px;
          width: 100%;
          max-width: 420px;
          position: relative;
          z-index: 1;
          box-shadow: var(--shadow-lg);
        }

        .login-logo {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-bottom: 28px;
        }
        .login-logo-icon {
          width: 44px;
          height: 44px;
          border-radius: var(--radius-md);
          background: var(--accent-muted);
          border: 1px solid rgba(249,115,22,0.25);
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .login-logo-text {
          font-size: 20px;
          font-weight: 800;
          color: var(--text-primary);
          letter-spacing: -0.5px;
        }

        .login-title {
          font-size: 22px;
          font-weight: 700;
          color: var(--text-primary);
          letter-spacing: -0.5px;
        }
        .login-subtitle {
          margin-top: 4px;
          font-size: 13.5px;
          color: var(--text-secondary);
          margin-bottom: 24px;
        }

        .login-form {
          display: flex;
          flex-direction: column;
          gap: 18px;
          margin-top: 20px;
        }

        .form-group {
          display: flex;
          flex-direction: column;
          gap: 7px;
        }
        .form-label {
          font-size: 12.5px;
          font-weight: 600;
          color: var(--text-secondary);
          letter-spacing: 0.2px;
        }

        .input-wrapper {
          position: relative;
          display: flex;
          align-items: center;
        }
        .input-prefix {
          position: absolute;
          left: 12px;
          display: flex;
          align-items: center;
          color: var(--text-muted);
          pointer-events: none;
        }
        .input-suffix {
          position: absolute;
          right: 10px;
          display: flex;
          align-items: center;
          justify-content: center;
          width: 28px;
          height: 28px;
          border-radius: 4px;
          background: transparent;
          color: var(--text-muted);
          transition: all var(--transition);
        }
        .input-suffix:hover { color: var(--text-primary); }

        .login-input {
          padding-left: 40px;
          padding-right: 44px;
          height: 44px;
        }

        .login-submit {
          width: 100%;
          height: 44px;
          justify-content: center;
          font-size: 14.5px;
          margin-top: 4px;
        }
        .login-submit:disabled {
          opacity: 0.55;
          cursor: not-allowed;
          pointer-events: none;
        }

        .btn-spinner {
          width: 16px;
          height: 16px;
          border: 2px solid rgba(255,255,255,0.3);
          border-top-color: #fff;
          border-radius: 50%;
          animation: spin 0.7s linear infinite;
          flex-shrink: 0;
        }

        .login-footer {
          margin-top: 24px;
          font-size: 12px;
          color: var(--text-muted);
          text-align: center;
        }
      `}</style>
    </div>
  );
}
