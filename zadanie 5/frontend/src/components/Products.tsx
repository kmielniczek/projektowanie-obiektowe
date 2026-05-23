import React from "react";
import { useShop } from "../hooks/useShop";
import { useProducts } from "../hooks/useProducts";
import type { Product } from "../types/product";
import styles from "../styles/Products.module.css";

export const Products: React.FC = () => {
  const { addToCart } = useShop();
  const { products, loading, error } = useProducts();

  if (loading) {
    return (
      <div className={styles["products-container"]}>
        <p>Loading products...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles["products-container"]}>
        <p className={styles.error}>{error}</p>
      </div>
    );
  }

  return (
    <div className={styles["products-container"]}>
      <h2>Products</h2>
      {products.length === 0 ? (
        <p>No products available</p>
      ) : (
        <div className={styles["products-grid"]}>
          {products.map((product: Product) => (
            <div key={product.id} className={styles["product-card"]}>
              <h3>{product.name}</h3>
              <p className={styles.productPrice}>${product.price.toFixed(2)}</p>
              <button
                className={styles["add-to-cart-btn"]}
                onClick={() => addToCart(product)}
              >
                Add to Cart
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
