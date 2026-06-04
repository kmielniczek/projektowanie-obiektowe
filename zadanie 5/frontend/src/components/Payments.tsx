import React, { useState } from "react";
import { Navigate, useLocation, useNavigate } from "react-router-dom";
import { useCheckout } from "../hooks/useCheckout";
import { useShop } from "../hooks/useShop";
import type { Payment } from "../types/payment";
import styles from "../styles/Payments.module.css";

const PAYMENT_METHODS = ["card", "applepay", "blik"];

interface PaymentRouteState {
  cartId: string;
  amount: number;
}

export const Payments: React.FC = () => {
  const { cart, clearCart } = useShop();
  const { submitPayment, submittingPayment, paymentStatus, error } =
    useCheckout();
  const navigate = useNavigate();
  const location = useLocation();
  const state = location.state as PaymentRouteState | null;
  const cartId = state?.cartId;
  const amount = typeof state?.amount === "number" ? state.amount : null;
  const [method, setMethod] = useState("card");
  const [paymentSent, setPaymentSent] = useState(false);

  if (!cartId || amount === null || Number.isNaN(amount)) {
    return <Navigate to="/cart" replace />;
  }

  const handleSubmit = async (e: React.SubmitEvent) => {
    e.preventDefault();
    try {
      const payload: Payment = {
        amount,
        method,
        cart_id: cartId,
      };
      await submitPayment(payload);
      setPaymentSent(true);
      clearCart();
    } catch (error) {
      console.error("Payment submission error:", error);
    }
  };

  return (
    <div className={styles["payments-container"]}>
      <h2>Payment</h2>
      {cart.length > 0 && (
        <div className={styles["cart-summary"]}>
          <h3>Order Summary</h3>
          <div className={styles["summary-items"]}>
            {cart.map((item) => (
              <div key={item.product_id} className={styles["summary-item"]}>
                <span>
                  {item.name} x {item.quantity}
                </span>
                <span>${(item.price * item.quantity).toFixed(2)}</span>
              </div>
            ))}
          </div>
          <div className={styles["summary-total"]}>
            <strong>Total: ${amount.toFixed(2)}</strong>
          </div>
        </div>
      )}

      {paymentSent ? (
        <div className={styles["post-payment-actions"]}>
          <div
            className={`${styles.paymentStatus} ${styles[paymentStatus] || ""}`}
          >
            <p>
              Payment Status: <strong>{paymentStatus.toUpperCase()}</strong>
            </p>
          </div>

          <button
            type="button"
            className={styles["submit-button"]}
            onClick={() => navigate("/")}
          >
            Back to products
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className={styles["payment-form"]}>
          <div className={styles["form-group"]}>
            <label htmlFor="method" className={styles["form-label"]}>
              Payment Method:
            </label>
            <select
              id="method"
              value={method}
              onChange={(event) => setMethod(event.target.value)}
              className={styles["form-field"]}
            >
              {PAYMENT_METHODS.map((method) => (
                <option key={method} value={method}>
                  {method.charAt(0).toUpperCase() + method.slice(1)}
                </option>
              ))}
            </select>
          </div>
          <button
            type="submit"
            className={styles["submit-button"]}
            disabled={submittingPayment}
          >
            {submittingPayment ? "Processing..." : "Pay"}
          </button>
        </form>
      )}

      {error && <p className={styles["payment-error"]}>{error}</p>}
    </div>
  );
};
