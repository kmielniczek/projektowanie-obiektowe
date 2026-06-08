import React, { useEffect, useState } from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";
import styles from "../styles/Auth.module.css";

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export const Account: React.FC = () => {
  const { user, loading, updateAccount } = useAuth();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (user) {
      setName(user.name);
      setEmail(user.email);
    }
  }, [user]);

  if (!loading && !user) {
    return <Navigate to="/login" replace />;
  }

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setError(null);
    setSuccess(null);

    if (!name.trim() || !email.trim()) {
      setError("Name and email are required");
      return;
    }

    if (!EMAIL_REGEX.test(email.trim())) {
      setError("Invalid email format");
      return;
    }

    setSubmitting(true);
    try {
      await updateAccount({
        name: name.trim(),
        email: email.trim(),
      });
      setSuccess("Account updated successfully");
    } catch {
      setError("Failed to update account");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className={styles.authContainer}>
      <h2>Account Settings</h2>
      <form className={styles.form} onSubmit={handleSubmit} noValidate>
        <div className={styles.formGroup}>
          <label htmlFor="account-name" className={styles.formLabel}>
            Name
          </label>
          <input
            id="account-name"
            data-testid="account-name"
            className={styles.field}
            value={name}
            onChange={(event) => setName(event.target.value)}
          />
        </div>

        <div className={styles.formGroup}>
          <label htmlFor="account-email" className={styles.formLabel}>
            Email
          </label>
          <input
            id="account-email"
            type="email"
            data-testid="account-email"
            className={styles.field}
            value={email}
            onChange={(event) => setEmail(event.target.value)}
          />
        </div>

        {error && (
          <p data-testid="account-error" className={styles.errorText}>
            {error}
          </p>
        )}

        {success && (
          <p data-testid="account-success" className={styles.successText}>
            {success}
          </p>
        )}

        <button
          type="submit"
          data-testid="account-submit"
          className={styles.submitButton}
          disabled={submitting}
        >
          {submitting ? "Saving..." : "Save changes"}
        </button>
      </form>
    </div>
  );
};
