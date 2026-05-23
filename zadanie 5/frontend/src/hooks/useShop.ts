import { useContext } from "react";
import { ShopContext } from "../context/ShopContext";

export const useShop = () => {
  const context = useContext(ShopContext);
  if (context === null) {
    throw new Error("useShop must be used within a ShopProvider");
  }
  return context;
};
