import "./App.css";
import { Routes, Route, NavLink } from "react-router-dom";
import { Products } from "./components/Products";
import { Cart } from "./components/Cart";
import { Payments } from "./components/Payments";
import { Register } from "./components/Register";
import { Login } from "./components/Login";
import { Account } from "./components/Account";
import { AuthProvider } from "./context/AuthContext";
import { useShop } from "./hooks/useShop";
import { useAuth } from "./hooks/useAuth";
import { useMemo } from "react";

function AppContent() {
  const { cart } = useShop();
  const { user, logout } = useAuth();
  const itemsInCart = useMemo(
    () => cart.reduce((sum, item) => sum + item.quantity, 0),
    [cart],
  );

  const handleLogout = async () => {
    await logout();
  };

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>Best Shop</h1>
        <nav className="app-nav">
          <NavLink to="/">Products</NavLink>
          <NavLink to="/cart">
            Cart{" "}
            {cart.length > 0 && (
              <span className="cart-badge" data-testid="cart-badge">
                {itemsInCart}
              </span>
            )}
          </NavLink>
          {user ? (
            <>
              <NavLink to="/account" data-testid="nav-account">
                Account ({user.name})
              </NavLink>
              <button
                type="button"
                className="nav-button"
                data-testid="nav-logout"
                onClick={() => void handleLogout()}
              >
                Logout
              </button>
            </>
          ) : (
            <>
              <NavLink to="/login" data-testid="nav-login">
                Login
              </NavLink>
              <NavLink to="/register" data-testid="nav-register">
                Register
              </NavLink>
            </>
          )}
        </nav>
      </header>

      <main className="app-main">
        <Routes>
          <Route path="/" element={<Products />} />
          <Route path="/cart" element={<Cart />} />
          <Route path="/payment" element={<Payments />} />
          <Route path="/register" element={<Register />} />
          <Route path="/login" element={<Login />} />
          <Route path="/account" element={<Account />} />
        </Routes>
      </main>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;
