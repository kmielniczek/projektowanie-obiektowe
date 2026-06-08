import time

import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from conftest import BASE_URL


@pytest.fixture
def two_drivers():
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.chrome.service import Service as ChromeService

    from conftest import _find_chrome_binary

    chrome_options = Options()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--window-size=1400,900")
    chrome_binary = _find_chrome_binary()
    if chrome_binary:
        chrome_options.binary_location = chrome_binary
    driver_one = webdriver.Chrome(service=ChromeService(), options=chrome_options)
    driver_two = webdriver.Chrome(service=ChromeService(), options=chrome_options)
    driver_one.implicitly_wait(3)
    driver_two.implicitly_wait(3)

    yield driver_one, driver_two

    driver_one.quit()
    driver_two.quit()


def _open_products(driver):
    driver.get(BASE_URL)
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "[data-testid='products-heading']"))
    )


def _add_product(driver, product_id: int):
    driver.find_element(By.CSS_SELECTOR, f"[data-testid='add-to-cart-{product_id}']").click()
    time.sleep(0.3)


def _cart_badge_text(driver) -> str:
    badge = driver.find_element(By.CSS_SELECTOR, "[data-testid='cart-badge']")
    return badge.text.strip()


def _go_to_cart(driver):
    driver.find_element(By.CSS_SELECTOR, "a[href='/cart']").click()
    WebDriverWait(driver, 10).until(EC.url_contains("/cart"))


def test_carts_are_independent(two_drivers):
    driver_one, driver_two = two_drivers
    _open_products(driver_one)
    _open_products(driver_two)

    _add_product(driver_one, 1)
    _add_product(driver_two, 2)

    _go_to_cart(driver_one)
    assert driver_one.find_elements(By.CSS_SELECTOR, "[data-testid='cart-item-1']")
    assert not driver_one.find_elements(By.CSS_SELECTOR, "[data-testid='cart-item-2']")

    _go_to_cart(driver_two)
    assert driver_two.find_elements(By.CSS_SELECTOR, "[data-testid='cart-item-2']")
    assert not driver_two.find_elements(By.CSS_SELECTOR, "[data-testid='cart-item-1']")


def test_cart_badge_per_window(two_drivers):
    driver_one, driver_two = two_drivers
    _open_products(driver_one)
    _open_products(driver_two)

    _add_product(driver_one, 1)
    _add_product(driver_one, 1)
    _add_product(driver_two, 3)

    assert _cart_badge_text(driver_one) == "2"
    assert _cart_badge_text(driver_two) == "1"


def test_checkout_in_one_does_not_affect_other(two_drivers):
    driver_one, driver_two = two_drivers
    _open_products(driver_one)
    _open_products(driver_two)

    _add_product(driver_one, 1)
    _add_product(driver_two, 2)

    _go_to_cart(driver_one)
    driver_one.find_element(By.CSS_SELECTOR, "[data-testid='checkout-button']").click()
    WebDriverWait(driver_one, 10).until(EC.url_contains("/payment"))

    _go_to_cart(driver_two)
    assert driver_two.find_elements(By.CSS_SELECTOR, "[data-testid='cart-item-2']")
    assert _cart_badge_text(driver_two) == "1"


def test_quantity_update_isolated(two_drivers):
    driver_one, driver_two = two_drivers
    _open_products(driver_one)
    _open_products(driver_two)

    _add_product(driver_one, 1)
    _add_product(driver_two, 1)

    _go_to_cart(driver_one)
    quantity_input = driver_one.find_element(By.CSS_SELECTOR, "[data-testid='cart-quantity-1']")
    quantity_input.clear()
    quantity_input.send_keys("3")

    _go_to_cart(driver_two)
    quantity_two = driver_two.find_element(By.CSS_SELECTOR, "[data-testid='cart-quantity-1']")
    assert quantity_two.get_attribute("value") == "1"
    assert _cart_badge_text(driver_two) == "1"


def test_remove_item_isolated(two_drivers):
    driver_one, driver_two = two_drivers
    _open_products(driver_one)
    _open_products(driver_two)

    _add_product(driver_one, 4)
    _add_product(driver_two, 4)

    _go_to_cart(driver_two)
    driver_two.find_element(By.CSS_SELECTOR, "[data-testid='remove-item-4']").click()
    time.sleep(0.3)

    assert driver_two.find_elements(By.CSS_SELECTOR, "[data-testid='empty-cart-message']")

    _go_to_cart(driver_one)
    assert driver_one.find_elements(By.CSS_SELECTOR, "[data-testid='cart-item-4']")
    assert _cart_badge_text(driver_one) == "1"
