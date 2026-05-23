export interface Payment {
  id?: number;
  amount: number;
  method: string;
  status?: string;
  cart_id: string;
  created_at?: string;
}
