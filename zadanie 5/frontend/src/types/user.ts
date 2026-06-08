export interface User {
  id: number;
  name: string;
  email: string;
}

export interface RegisterPayload {
  name: string;
  email: string;
  password: string;
  confirm_password: string;
}

export interface LoginPayload {
  email: string;
  password: string;
}

export interface AccountUpdatePayload {
  name: string;
  email: string;
}
