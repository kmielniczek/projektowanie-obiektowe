import "./App.css";
import { Routes, Route, NavLink } from "react-router-dom";
import { Products } from "./components/Products";
import { Cart } from "./components/Cart";
import { Payments } from "./components/Payments";
import { useShop } from "./hooks/useShop";
import { useMemo } from "react";

function App() {
  const { cart } = useShop();
  const itemsInCart = useMemo(
    () => cart.reduce((sum, item) => sum + item.quantity, 0),
    [cart],
  );

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>Best Shop</h1>
        <nav className="app-nav">
          <NavLink to="/">Products</NavLink>
          <NavLink to="/cart">
            Cart{" "}
            {cart.length > 0 && (
              <span className="cart-badge">{itemsInCart}</span>
            )}
          </NavLink>
        </nav>
      </header>

      <main className="app-main">
        <Routes>
          <Route path="/" element={<Products />} />
          <Route path="/cart" element={<Cart />} />
          <Route path="/payment" element={<Payments />} />
        </Routes>
      </main>
    </div>
  );
}

export default App;
