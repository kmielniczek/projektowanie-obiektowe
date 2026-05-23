export interface CartItem {
  product_id: number;
  name: string;
  price: number;
  quantity: number;
}

export interface Cart {
  id: number;
  items: CartItem[];
  total: number;
}
