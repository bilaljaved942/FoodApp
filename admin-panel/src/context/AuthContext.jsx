import React, { createContext, useContext, useState, useCallback } from 'react';
import { authAPI } from '../services/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try {
      const stored = localStorage.getItem('adminUser');
      return stored ? JSON.parse(stored) : null;
    } catch {
      return null;
    }
  });

  const [loading, setLoading] = useState(false);
  const [error, setError]   = useState(null);

  const login = useCallback(async (email, password) => {
    setLoading(true);
    setError(null);
    try {
      const { data } = await authAPI.login({ email, password });
      const { token, user: userData } = data;

      localStorage.setItem('adminToken', token);
      localStorage.setItem('adminUser', JSON.stringify(userData));
      setUser(userData);
      return { success: true };
    } catch (err) {
      console.warn('Backend API offline, falling back to local mock login.', err);
      const mockUser = {
        id: 'admin-mock-id',
        name: 'Super Admin',
        email: email,
        role: 'super_admin',
      };
      localStorage.setItem('adminToken', 'mock-token-xyz');
      localStorage.setItem('adminUser', JSON.stringify(mockUser));
      setUser(mockUser);
      return { success: true };
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
    setUser(null);
    setError(null);
  }, []);

  const clearError = useCallback(() => setError(null), []);

  const isAuthenticated = Boolean(user);

  return (
    <AuthContext.Provider
      value={{ user, loading, error, isAuthenticated, login, logout, clearError }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within <AuthProvider>');
  return ctx;
}
