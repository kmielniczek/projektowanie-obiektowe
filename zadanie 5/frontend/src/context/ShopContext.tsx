/* eslint-disable react-refresh/only-export-components */

import React, { createContext, useState, useMemo } from "react";
import type { ReactNode } from "react";
import type { Product } from "../types/product";
import type { CartItem } from "../types/cart";

interface ShopContextType {
  cart: CartItem[];
  addToCart: (product: Product) => void;
  removeFromCart: (productId: number) => void;
  updateQuantity: (productId: number, quantity: number) => void;
  clearCart: () => void;
}

export const ShopContext = createContext<ShopContextType | null>(null);

export const ShopProvider: React.FC<{ children: ReactNode }> = ({
  children,
}) => {
  const [cart, setCart] = useState<CartItem[]>([]);
  const props = useMemo(() => {
    return {
      cart,
      addToCart,
      removeFromCart,
      updateQuantity,
      clearCart,
    };
  }, [cart]);

  function addToCart(product: Product) {
    setCart((prevCart) => {
      const existingItem = prevCart.find(
        (item) => item.product_id === product.id,
      );
      if (existingItem) {
        return prevCart.map((item) =>
          item.product_id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item,
        );
      }
      return [
        ...prevCart,
        {
          product_id: product.id,
          name: product.name,
          price: product.price,
          quantity: 1,
        },
      ];
    });
  }

  function removeFromCart(productId: number) {
    setCart((prevCart) =>
      prevCart.filter((item) => item.product_id !== productId),
    );
  }

  function updateQuantity(productId: number, quantity: number) {
    if (quantity <= 0 || Number.isNaN(quantity)) {
      setCart((prevCart) =>
        prevCart.filter((item) => item.product_id !== productId),
      );
      return;
    }
    setCart((prevCart) =>
      prevCart.map((item) =>
        item.product_id === productId ? { ...item, quantity } : item,
      ),
    );
  }

  function clearCart() {
    setCart([]);
  }

  return <ShopContext.Provider value={props}>{children}</ShopContext.Provider>;
};
