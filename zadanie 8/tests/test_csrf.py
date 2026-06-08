import time

import requests
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from conftest import API_URL, BASE_URL, get_browser_cookies, login_user_via_ui, register_user_via_ui


def _get_account_name(driver) -> str:
    cookies = get_browser_cookies(driver)
    response = requests.get(f"{API_URL}/me", cookies=cookies)
    response.raise_for_status()
    return response.json()["name"]


def test_csrf_attack_blocked(driver, unique_user, attacker_server):
    register_user_via_ui(driver, unique_user)
    login_user_via_ui(driver, unique_user)

    original_name = _get_account_name(driver)
    assert original_name == unique_user["name"]

    driver.execute_script("window.open('about:blank','_blank');")
    WebDriverWait(driver, 10).until(lambda d: len(d.window_handles) > 1)
    driver.switch_to.window(driver.window_handles[1])
    driver.get(f"{attacker_server}/malicious_page.html")
    time.sleep(2)

    driver.switch_to.window(driver.window_handles[0])
    current_name = _get_account_name(driver)
    assert current_name == original_name
    assert current_name != "HACKED"


def test_valid_csrf_request_succeeds(driver, registered_user):
    driver.get(f"{BASE_URL}/account")
    name_input = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "[data-testid='account-name']"))
    )
    name_input.clear()
    new_name = f"{registered_user['name']} Updated"
    name_input.send_keys(new_name)
    driver.find_element(By.CSS_SELECTOR, "[data-testid='account-submit']").click()

    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "[data-testid='account-success']"))
    )
    assert _get_account_name(driver) == new_name


def test_wrong_csrf_token_rejected(driver, registered_user):
    cookies = get_browser_cookies(driver)
    response = requests.put(
        f"{API_URL}/account",
        json={"name": "HACKED", "email": registered_user["email"]},
        cookies=cookies,
        headers={"X-CSRF-Token": "wrong-token-value"},
    )
    assert response.status_code == 403
    assert _get_account_name(driver) == registered_user["name"]


def test_logout_invalidates_session(driver, registered_user):
    driver.find_element(By.CSS_SELECTOR, "[data-testid='nav-logout']").click()
    time.sleep(0.5)

    cookies = get_browser_cookies(driver)
    response = requests.put(
        f"{API_URL}/account",
        json={"name": "HACKED", "email": registered_user["email"]},
        cookies=cookies,
        headers={"X-CSRF-Token": "any-token"},
    )
    assert response.status_code in {401, 403}
