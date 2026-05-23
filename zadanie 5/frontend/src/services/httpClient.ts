import axios from "axios";
import type { Product } from "../types/product";
import type { Payment } from "../types/payment";
import type { Cart, CartItem } from "../types/cart";

const baseURL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:8080/api";

const httpClient = axios.create({
  baseURL,
  headers: {
    "Content-Type": "application/json",
  },
});

export async function getProducts(): Promise<Product[]> {
  try {
    const response = await httpClient.get<Product[]>("/products");
    return response.data;
  } catch (error) {
    console.error("Error fetching products:", error);
    throw error;
  }
}

export async function submitPayment(payment: Payment): Promise<Payment> {
  try {
    const response = await httpClient.post<Payment>("/payments", payment);
    return response.data;
  } catch (error) {
    console.error("Error submitting payment:", error);
    throw error;
  }
}

export async function createCart(
  items: CartItem[],
  total: number,
): Promise<Cart> {
  try {
    const response = await httpClient.post<Cart>("/carts", {
      items: items,
      total,
    });
    return response.data;
  } catch (error) {
    console.error("Error creating cart:", error);
    throw error;
  }
}

export default httpClient;
