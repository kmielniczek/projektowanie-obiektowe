import { useState } from "react";
import type { Cart, CartItem } from "../types/cart";
import type { Payment } from "../types/payment";
import {
  createCart as createCartAPI,
  submitPayment as submitPaymentAPI,
} from "../services/httpClient";

export const useCheckout = () => {
  const [creatingCart, setCreatingCart] = useState(false);
  const [submittingPayment, setSubmittingPayment] = useState(false);
  const [paymentStatus, setPaymentStatus] = useState<string>("");
  const [error, setError] = useState<string | null>(null);

  const createCart = async (
    items: CartItem[],
    total: number,
  ): Promise<Cart> => {
    setCreatingCart(true);
    setError(null);
    try {
      const response = await createCartAPI(items, total);
      if (!response.id) {
        throw new Error("Cart ID missing in response");
      }
      return response;
    } catch (err) {
      setError("Failed to create cart");
      throw err;
    } finally {
      setCreatingCart(false);
    }
  };

  const submitPayment = async (payment: Payment): Promise<Payment> => {
    setSubmittingPayment(true);
    setError(null);
    try {
      const response = await submitPaymentAPI(payment);
      setPaymentStatus(response.status ?? "unknown");
      return response;
    } catch (err) {
      setPaymentStatus("failed");
      setError("Failed to submit payment");
      throw err;
    } finally {
      setSubmittingPayment(false);
    }
  };

  return {
    createCart,
    submitPayment,
    creatingCart,
    submittingPayment,
    paymentStatus,
    error,
  };
};
