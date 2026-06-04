import React, { useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { useCheckout } from "../hooks/useCheckout";
import { useShop } from "../hooks/useShop";
import styles from "../styles/Cart.module.css";

export const Cart: React.FC = () => {
  const { cart, updateQuantity, removeFromCart } = useShop();
  const { createCart, creatingCart, error } = useCheckout();
  const navigate = useNavigate();
  const cartTotal = useMemo(
    () => cart.reduce((sum, item) => sum + item.price * item.quantity, 0),
    [cart],
  );

  const handleCheckout = async () => {
    if (cart.length === 0 || creatingCart) {
      return;
    }
    try {
      const createdCart = await createCart(cart, cartTotal);
      navigate("/payment", {
        state: {
          cartId: String(createdCart.id),
          amount: cartTotal,
        },
      });
    } catch (err) {
      console.error("Cart submission error:", err);
    }
  };

  if (cart.length === 0) {
    return (
      <div className={styles["cart-container"]}>
        <h2>Shopping Cart</h2>
        <p className={styles["empty-cart"]}>Your cart is empty</p>
      </div>
    );
  }

  return (
    <div className={styles["cart-container"]}>
      <h2>Shopping Cart</h2>
      <div className={styles["cart-items"]}>
        {cart.map((item) => (
          <div key={item.product_id} className={styles["cart-item"]}>
            <div className={styles["item-info"]}>
              <h3>{item.name}</h3>
              <p className={styles.itemPrice}>${item.price.toFixed(2)}</p>
            </div>
            <div className={styles["item-controls"]}>
              <input
                type="number"
                min="1"
                value={item.quantity}
                onChange={(e) =>
                  updateQuantity(
                    item.product_id,
                    Number.parseInt(e.target.value),
                  )
                }
                className={styles["quantity-input"]}
              />
              <button
                className={styles["remove-btn"]}
                onClick={() => removeFromCart(item.product_id)}
              >
                Remove
              </button>
            </div>
            <div className={styles["item-total"]}>
              ${(item.price * item.quantity).toFixed(2)}
            </div>
          </div>
        ))}
      </div>
      <div className={styles["cart-summary"]}>
        <h3 className={styles["summary-total"]}>
          Total: ${cartTotal.toFixed(2)}
        </h3>
        <button
          type="button"
          className={styles["checkout-btn"]}
          onClick={handleCheckout}
          disabled={creatingCart}
        >
          {creatingCart ? "Preparing Payment..." : "Go to payment"}
        </button>
      </div>
      {error && <p className={styles["checkout-error"]}>{error}</p>}
    </div>
  );
};
