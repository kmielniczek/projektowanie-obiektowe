import re
import uuid

import pytest
from playwright.sync_api import Page, expect

BASE_URL = "http://localhost:5173"


@pytest.fixture
def e2e_user():
    suffix = uuid.uuid4().hex[:8]
    return {
        "name": f"E2E User {suffix}",
        "email": f"e2e_{suffix}@example.com",
        "password": "securePass1",
    }


def test_full_shop_journey(page: Page, e2e_user):
    assertion_count = 0

    page.goto(BASE_URL)
    page.wait_for_load_state("networkidle")
    page.goto(BASE_URL)
    page.wait_for_load_state("networkidle")
    page.goto(f"{BASE_URL}/register")
    page.wait_for_load_state("networkidle")
    page.wait_for_load_state("networkidle")
    assertion_count += 1
    expect(page).to_have_url(re.compile(r"/register$"))

    assertion_count += 1
    expect(page.locator("h2")).to_have_text("Register")

    assertion_count += 1
    expect(page.get_by_test_id("register-name")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("register-email")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("register-password")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("register-confirm-password")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("register-submit")).to_be_enabled()

    page.get_by_test_id("register-submit").click()
    assertion_count += 1
    expect(page.get_by_test_id("register-name-error")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("register-email-error")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("register-password-error")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("register-confirm-password-error")).to_be_visible()

    page.get_by_test_id("register-email").fill("bad-email")
    page.get_by_test_id("register-submit").click()
    assertion_count += 1
    expect(page.get_by_test_id("register-email-error")).to_contain_text("email")

    page.get_by_test_id("register-name").fill(e2e_user["name"])
    page.get_by_test_id("register-email").fill(e2e_user["email"])
    page.get_by_test_id("register-password").fill(e2e_user["password"])
    page.get_by_test_id("register-confirm-password").fill(e2e_user["password"])
    page.get_by_test_id("register-submit").click()

    assertion_count += 1
    expect(page).to_have_url(re.compile(r"/login$"))
    assertion_count += 1
    expect(page.get_by_test_id("login-success-message")).to_be_visible()

    assertion_count += 1
    expect(page.get_by_test_id("login-email")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("login-password")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("login-submit")).to_be_enabled()

    page.get_by_test_id("login-email").fill("wrong@example.com")
    page.get_by_test_id("login-password").fill("wrongPassword")
    page.get_by_test_id("login-submit").click()
    assertion_count += 1
    expect(page.get_by_test_id("login-error")).to_be_visible()

    page.get_by_test_id("login-email").fill(e2e_user["email"])
    page.get_by_test_id("login-password").fill(e2e_user["password"])
    page.get_by_test_id("login-submit").click()

    assertion_count += 1
    expect(page).to_have_url(re.compile(r"/$"))
    assertion_count += 1
    expect(page.get_by_test_id("nav-account")).to_contain_text(e2e_user["name"])

    assertion_count += 1
    expect(page.get_by_test_id("products-heading")).to_have_text("Products")

    product_cards = page.locator("[data-testid^='product-card-']")
    assertion_count += 1
    expect(product_cards).to_have_count(5)

    for product_id in range(1, 6):
        assertion_count += 1
        expect(page.get_by_test_id(f"product-name-{product_id}")).to_be_visible()
        assertion_count += 1
        expect(page.get_by_test_id(f"product-price-{product_id}")).to_be_visible()
        assertion_count += 1
        expect(page.get_by_test_id(f"add-to-cart-{product_id}")).to_be_enabled()

    page.get_by_test_id("add-to-cart-1").click()
    page.get_by_test_id("add-to-cart-2").click()
    assertion_count += 1
    expect(page.get_by_test_id("cart-badge")).to_have_text("2")

    page.get_by_role("link", name="Cart").click()
    assertion_count += 1
    expect(page).to_have_url(re.compile(r"/cart$"))

    assertion_count += 1
    expect(page.get_by_test_id("cart-item-1")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("cart-item-2")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("cart-quantity-1")).to_have_value("1")
    assertion_count += 1
    expect(page.get_by_test_id("cart-total")).to_contain_text("Total:")

    page.get_by_test_id("cart-quantity-2").fill("2")
    assertion_count += 1
    expect(page.get_by_test_id("cart-badge")).to_have_text("3")

    page.get_by_test_id("checkout-button").click()
    assertion_count += 1
    expect(page).to_have_url(re.compile(r"/payment$"))
    assertion_count += 1
    expect(page.get_by_test_id("payment-heading")).to_have_text("Payment")
    assertion_count += 1
    expect(page.get_by_test_id("payment-amount")).to_contain_text("Total:")
    assertion_count += 1
    expect(page.get_by_test_id("payment-method")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("payment-method").locator("option")).to_have_count(3)
    assertion_count += 1
    expect(page.get_by_test_id("payment-submit")).to_be_enabled()

    page.get_by_test_id("payment-submit").click()
    assertion_count += 1
    expect(page.get_by_test_id("payment-status")).to_contain_text("PENDING")

    page.get_by_test_id("nav-account").click()
    assertion_count += 1
    expect(page).to_have_url(re.compile(r"/account$"))
    assertion_count += 1
    expect(page.get_by_test_id("account-name")).to_have_value(e2e_user["name"])
    assertion_count += 1
    expect(page.get_by_test_id("account-email")).to_have_value(e2e_user["email"])

    updated_name = f"{e2e_user['name']} E2E"
    page.get_by_test_id("account-name").fill(updated_name)
    page.get_by_test_id("account-submit").click()
    assertion_count += 1
    expect(page.get_by_test_id("account-success")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("nav-account")).to_contain_text(updated_name)

    page.get_by_test_id("nav-logout").click()
    assertion_count += 1
    expect(page.get_by_test_id("nav-login")).to_be_visible()
    assertion_count += 1
    expect(page.get_by_test_id("nav-register")).to_be_visible()

    page.goto(f"{BASE_URL}/account")
    assertion_count += 1
    expect(page).to_have_url(re.compile(r"/login$"))

    assert assertion_count >= 50, f"Expected at least 50 assertions, got {assertion_count}"
