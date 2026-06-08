import React, { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import styles from "../styles/Auth.module.css";

interface LocationState {
  registered?: boolean;
}

export const Login: React.FC = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const locationState = location.state as LocationState | null;
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setError(null);

    if (!email.trim() || !password) {
      setError("Email and password are required");
      return;
    }

    setSubmitting(true);
    try {
      await login({ email: email.trim(), password });
      navigate("/");
    } catch {
      setError("Invalid email or password");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className={styles.authContainer}>
      <h2>Login</h2>
      {locationState?.registered && (
        <p data-testid="login-success-message" className={styles.successText}>
          Registration successful. Please log in.
        </p>
      )}
      <form className={styles.form} onSubmit={handleSubmit} noValidate>
        <div className={styles.formGroup}>
          <label htmlFor="login-email" className={styles.formLabel}>
            Email
          </label>
          <input
            id="login-email"
            type="email"
            data-testid="login-email"
            className={styles.field}
            value={email}
            onChange={(event) => setEmail(event.target.value)}
          />
        </div>

        <div className={styles.formGroup}>
          <label htmlFor="login-password" className={styles.formLabel}>
            Password
          </label>
          <input
            id="login-password"
            type="password"
            data-testid="login-password"
            className={styles.field}
            value={password}
            onChange={(event) => setPassword(event.target.value)}
          />
        </div>

        {error && (
          <p data-testid="login-error" className={styles.errorText}>
            {error}
          </p>
        )}

        <button
          type="submit"
          data-testid="login-submit"
          className={styles.submitButton}
          disabled={submitting}
        >
          {submitting ? "Logging in..." : "Login"}
        </button>
      </form>

      <p className={styles.authLink}>
        Need an account? <Link to="/register">Register</Link>
      </p>
    </div>
  );
};
