import React, { useState } from "react";
import axios from "axios";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import styles from "../styles/Auth.module.css";

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

interface FormErrors {
  name?: string;
  email?: string;
  password?: string;
  confirmPassword?: string;
  form?: string;
}

export const Register: React.FC = () => {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitting, setSubmitting] = useState(false);

  const validate = (): FormErrors => {
    const nextErrors: FormErrors = {};

    if (!name.trim()) {
      nextErrors.name = "Name is required";
    }

    if (!email.trim()) {
      nextErrors.email = "Email is required";
    } else if (!EMAIL_REGEX.test(email.trim())) {
      nextErrors.email = "Invalid email format";
    }

    if (!password) {
      nextErrors.password = "Password is required";
    } else if (password.length < 8) {
      nextErrors.password = "Password must be at least 8 characters";
    }

    if (!confirmPassword) {
      nextErrors.confirmPassword = "Please confirm your password";
    } else if (password !== confirmPassword) {
      nextErrors.confirmPassword = "Passwords do not match";
    }

    return nextErrors;
  };

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    const validationErrors = validate();
    setErrors(validationErrors);

    if (Object.keys(validationErrors).length > 0) {
      return;
    }

    setSubmitting(true);
    try {
      await register({
        name: name.trim(),
        email: email.trim(),
        password,
        confirm_password: confirmPassword,
      });
      navigate("/login", { state: { registered: true } });
    } catch (error) {
      const responseMessage = axios.isAxiosError(error)
        ? (error.response?.data as { error?: string } | undefined)?.error
        : undefined;
      setErrors({
        form: responseMessage ?? "Registration failed. Please try again.",
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className={styles.authContainer}>
      <h2>Register</h2>
      <form className={styles.form} onSubmit={handleSubmit} noValidate>
        <div className={styles.formGroup}>
          <label htmlFor="register-name" className={styles.formLabel}>
            Name
          </label>
          <input
            id="register-name"
            data-testid="register-name"
            className={`${styles.field} ${errors.name ? styles.fieldError : ""}`}
            value={name}
            onChange={(event) => setName(event.target.value)}
          />
          {errors.name && (
            <span data-testid="register-name-error" className={styles.errorText}>
              {errors.name}
            </span>
          )}
        </div>

        <div className={styles.formGroup}>
          <label htmlFor="register-email" className={styles.formLabel}>
            Email
          </label>
          <input
            id="register-email"
            type="email"
            data-testid="register-email"
            className={`${styles.field} ${errors.email ? styles.fieldError : ""}`}
            value={email}
            onChange={(event) => setEmail(event.target.value)}
          />
          {errors.email && (
            <span
              data-testid="register-email-error"
              className={styles.errorText}
            >
              {errors.email}
            </span>
          )}
        </div>

        <div className={styles.formGroup}>
          <label htmlFor="register-password" className={styles.formLabel}>
            Password
          </label>
          <input
            id="register-password"
            type="password"
            data-testid="register-password"
            className={`${styles.field} ${errors.password ? styles.fieldError : ""}`}
            value={password}
            onChange={(event) => setPassword(event.target.value)}
          />
          {errors.password && (
            <span
              data-testid="register-password-error"
              className={styles.errorText}
            >
              {errors.password}
            </span>
          )}
        </div>

        <div className={styles.formGroup}>
          <label
            htmlFor="register-confirm-password"
            className={styles.formLabel}
          >
            Confirm Password
          </label>
          <input
            id="register-confirm-password"
            type="password"
            data-testid="register-confirm-password"
            className={`${styles.field} ${errors.confirmPassword ? styles.fieldError : ""}`}
            value={confirmPassword}
            onChange={(event) => setConfirmPassword(event.target.value)}
          />
          {errors.confirmPassword && (
            <span
              data-testid="register-confirm-password-error"
              className={styles.errorText}
            >
              {errors.confirmPassword}
            </span>
          )}
        </div>

        {errors.form && (
          <p data-testid="register-form-error" className={styles.errorText}>
            {errors.form}
          </p>
        )}

        <button
          type="submit"
          data-testid="register-submit"
          className={styles.submitButton}
          disabled={submitting}
        >
          {submitting ? "Registering..." : "Register"}
        </button>
      </form>

      <p className={styles.authLink}>
        Already have an account? <Link to="/login">Login</Link>
      </p>
    </div>
  );
};
