/* eslint-disable react-refresh/only-export-components */

import React, {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from "react";
import type { ReactNode } from "react";
import httpClient from "../services/httpClient";
import { ensureCsrfToken } from "../services/csrf";
import type {
  AccountUpdatePayload,
  LoginPayload,
  RegisterPayload,
  User,
} from "../types/user";

interface AuthContextType {
  user: User | null;
  loading: boolean;
  register: (payload: RegisterPayload) => Promise<void>;
  login: (payload: LoginPayload) => Promise<void>;
  logout: () => Promise<void>;
  updateAccount: (payload: AccountUpdatePayload) => Promise<void>;
}

export const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({
  children,
}) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const refreshUser = useCallback(async () => {
    try {
      const response = await httpClient.get<User>("/me");
      setUser(response.data);
    } catch {
      setUser(null);
    }
  }, []);

  useEffect(() => {
    const loadUser = async () => {
      setLoading(true);
      try {
        await ensureCsrfToken();
        await refreshUser();
      } finally {
        setLoading(false);
      }
    };

    void loadUser();
  }, [refreshUser]);

  const register = useCallback(async (payload: RegisterPayload) => {
    await ensureCsrfToken();
    await httpClient.post("/register", payload);
  }, []);

  const login = useCallback(async (payload: LoginPayload) => {
    await ensureCsrfToken();
    const response = await httpClient.post<User>("/login", payload);
    setUser(response.data);
    await ensureCsrfToken();
  }, []);

  const logout = useCallback(async () => {
    await ensureCsrfToken();
    await httpClient.post("/logout");
    setUser(null);
    await ensureCsrfToken();
  }, []);

  const updateAccount = useCallback(async (payload: AccountUpdatePayload) => {
    await ensureCsrfToken();
    const response = await httpClient.put<User>("/account", payload);
    setUser(response.data);
    await ensureCsrfToken();
  }, []);

  const value = useMemo(
    () => ({
      user,
      loading,
      register,
      login,
      logout,
      updateAccount,
    }),
    [user, loading, register, login, logout, updateAccount],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
