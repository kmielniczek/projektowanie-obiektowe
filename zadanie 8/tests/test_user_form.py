import time
import uuid

import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from conftest import BASE_URL, register_user_via_ui


@pytest.fixture
def register_page(driver):
    driver.get(f"{BASE_URL}/register")
    return driver


def test_required_fields(register_page):
    driver = register_page
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-submit']").click()

    assert driver.find_element(By.CSS_SELECTOR, "[data-testid='register-name-error']").is_displayed()
    assert driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email-error']").is_displayed()
    assert driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password-error']").is_displayed()
    assert driver.find_element(
        By.CSS_SELECTOR, "[data-testid='register-confirm-password-error']"
    ).is_displayed()


@pytest.mark.parametrize(
    "invalid_email",
    ["notanemail", "@domain.com", "user@", "user@.com"],
)
def test_invalid_email_formats(register_page, invalid_email):
    driver = register_page
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-name']").send_keys("Test User")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email']").send_keys(invalid_email)
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password']").send_keys("securePass1")
    driver.find_element(
        By.CSS_SELECTOR, "[data-testid='register-confirm-password']"
    ).send_keys("securePass1")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-submit']").click()

    error = driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email-error']")
    assert error.is_displayed()
    assert "email" in error.text.lower()


def test_password_too_short(register_page):
    driver = register_page
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-name']").send_keys("Test User")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email']").send_keys("short@example.com")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password']").send_keys("short")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-confirm-password']").send_keys("short")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-submit']").click()

    error = driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password-error']")
    assert error.is_displayed()
    assert "8" in error.text


def test_passwords_mismatch(register_page):
    driver = register_page
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-name']").send_keys("Test User")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email']").send_keys("mismatch@example.com")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password']").send_keys("securePass1")
    driver.find_element(
        By.CSS_SELECTOR, "[data-testid='register-confirm-password']"
    ).send_keys("different1")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-submit']").click()

    error = driver.find_element(
        By.CSS_SELECTOR, "[data-testid='register-confirm-password-error']"
    )
    assert error.is_displayed()
    assert "match" in error.text.lower()


def test_valid_registration(register_page):
    driver = register_page
    suffix = uuid.uuid4().hex[:8]
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-name']").send_keys("Valid User")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email']").send_keys(
        f"valid_{suffix}@example.com"
    )
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password']").send_keys("securePass1")
    driver.find_element(
        By.CSS_SELECTOR, "[data-testid='register-confirm-password']"
    ).send_keys("securePass1")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-submit']").click()

    WebDriverWait(driver, 10).until(EC.url_contains("/login"))
    assert "/login" in driver.current_url
    assert driver.find_element(By.CSS_SELECTOR, "[data-testid='login-success-message']").is_displayed()


def test_duplicate_email(driver, unique_user):
    register_user_via_ui(driver, unique_user)
    time.sleep(0.5)

    driver.get(f"{BASE_URL}/register")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-name']").send_keys("Another User")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email']").send_keys(unique_user["email"])
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password']").send_keys("securePass1")
    driver.find_element(
        By.CSS_SELECTOR, "[data-testid='register-confirm-password']"
    ).send_keys("securePass1")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-submit']").click()

    error = driver.find_element(By.CSS_SELECTOR, "[data-testid='register-form-error']")
    assert error.is_displayed()
    assert "email" in error.text.lower()
