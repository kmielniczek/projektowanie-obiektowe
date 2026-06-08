import axios from "axios";

const baseURL = import.meta.env.VITE_API_BASE_URL || "/api";

let csrfToken: string | null = null;

export async function ensureCsrfToken(): Promise<string> {
  const response = await axios.get<{ token: string }>(`${baseURL}/csrf`, {
    withCredentials: true,
  });
  csrfToken = response.data.token;
  return csrfToken;
}

export function getCsrfToken(): string | null {
  return csrfToken;
}

export function setCsrfToken(token: string | null): void {
  csrfToken = token;
}
