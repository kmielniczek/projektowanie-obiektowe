import time
import uuid

from selenium.common.exceptions import NoAlertPresentException
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from conftest import BASE_URL, login_user_via_ui, register_user_via_ui

SCRIPT_PAYLOAD = "<script>document.title='XSS'</script>"
IMG_PAYLOAD = "<img src=x onerror=\"document.title='XSS'\">"
ALERT_PAYLOAD = "<script>alert('xss')</script>"


def _register_with_name(driver, name: str) -> dict:
    suffix = uuid.uuid4().hex[:8]
    user = {
        "name": name,
        "email": f"xss_{suffix}@example.com",
        "password": "securePass1",
    }
    register_user_via_ui(driver, user)
    return user


def test_xss_script_tag_in_name(driver):
    user = _register_with_name(driver, SCRIPT_PAYLOAD)
    login_user_via_ui(driver, user)

    assert driver.title != "XSS"


def test_xss_img_onerror(driver):
    user = _register_with_name(driver, IMG_PAYLOAD)
    login_user_via_ui(driver, user)

    assert driver.title != "XSS"


def test_xss_stored_payload_escaped_in_dom(driver):
    user = _register_with_name(driver, SCRIPT_PAYLOAD)
    login_user_via_ui(driver, user)

    driver.get(f"{BASE_URL}/account")
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "[data-testid='account-name']"))
    )

    page_source = driver.page_source
    assert "<script>document.title='XSS'</script>" not in page_source
    assert "&lt;script&gt;" in page_source or SCRIPT_PAYLOAD in driver.find_element(
        By.CSS_SELECTOR, "[data-testid='account-name']"
    ).get_attribute("value")


def test_xss_no_alert_dialog(driver, registered_user):
    driver.get(f"{BASE_URL}/account")
    name_input = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "[data-testid='account-name']"))
    )
    name_input.clear()
    name_input.send_keys(ALERT_PAYLOAD)
    driver.find_element(By.CSS_SELECTOR, "[data-testid='account-submit']").click()
    time.sleep(1)

    try:
        driver.switch_to.alert
        raise AssertionError("XSS alert dialog was displayed")
    except NoAlertPresentException:
        pass


def test_xss_javascript_url(driver):
    suffix = uuid.uuid4().hex[:8]
    driver.get(f"{BASE_URL}/register")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-name']").send_keys(
        "javascript:alert(1)"
    )
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-email']").send_keys(
        f"jsurl_{suffix}@example.com"
    )
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-password']").send_keys("securePass1")
    driver.find_element(
        By.CSS_SELECTOR, "[data-testid='register-confirm-password']"
    ).send_keys("securePass1")
    driver.find_element(By.CSS_SELECTOR, "[data-testid='register-submit']").click()

    WebDriverWait(driver, 10).until(EC.url_contains("/login"))
    assert driver.title != "XSS"

    try:
        driver.switch_to.alert
        raise AssertionError("javascript: URL executed an alert")
    except NoAlertPresentException:
        pass
