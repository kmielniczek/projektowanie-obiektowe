import glob
import os
import shutil
import socket
import threading
import time
import uuid
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import pytest
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service as ChromeService

BASE_URL = "http://localhost:5173"
API_URL = f"{BASE_URL}/api"
FIXTURES_DIR = Path(__file__).parent / "fixtures"


def wait_for_server(url: str, timeout: float = 30.0) -> None:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            response = requests.get(url, timeout=2)
            if response.status_code < 500:
                return
        except requests.RequestException:
            pass
        time.sleep(0.5)
    raise RuntimeError(f"Server not available at {url}")


@pytest.fixture(scope="session", autouse=True)
def ensure_app_is_running():
    wait_for_server(f"{API_URL}/products")
    wait_for_server(BASE_URL)


def _find_chrome_binary() -> str | None:
    try:
        from playwright.sync_api import sync_playwright

        playwright = sync_playwright().start()
        path = playwright.chromium.executable_path
        playwright.stop()
        if path and os.path.exists(path):
            return path
    except Exception:
        pass

    for command in ("google-chrome", "google-chrome-stable", "chromium", "chromium-browser"):
        path = shutil.which(command)
        if path:
            return path

    playwright_patterns = [
        os.path.expanduser("~/.cache/ms-playwright/chromium-*/chrome-linux64/chrome"),
        os.path.expanduser("~/.cache/ms-playwright/chromium-*/chrome-linux/chrome"),
    ]
    for pattern in playwright_patterns:
        matches = glob.glob(pattern)
        if matches:
            return sorted(matches)[-1]
    return None


@pytest.fixture
def driver():
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1400,900")

    chrome_binary = _find_chrome_binary()
    if chrome_binary:
        options.binary_location = chrome_binary

    browser = webdriver.Chrome(service=ChromeService(), options=options)
    browser.implicitly_wait(3)
    yield browser
    browser.quit()


@pytest.fixture
def unique_user():
    suffix = uuid.uuid4().hex[:8]
    return {
        "name": f"Test User {suffix}",
        "email": f"user_{suffix}@example.com",
        "password": "securePass1",
    }


def register_user_via_ui(browser, user: dict) -> None:
    browser.get(f"{BASE_URL}/register")
    browser.find_element("css selector", "[data-testid='register-name']").send_keys(
        user["name"]
    )
    browser.find_element("css selector", "[data-testid='register-email']").send_keys(
        user["email"]
    )
    browser.find_element(
        "css selector", "[data-testid='register-password']"
    ).send_keys(user["password"])
    browser.find_element(
        "css selector", "[data-testid='register-confirm-password']"
    ).send_keys(user["password"])
    browser.find_element("css selector", "[data-testid='register-submit']").click()
    time.sleep(0.5)


def login_user_via_ui(browser, user: dict) -> None:
    browser.get(f"{BASE_URL}/login")
    browser.find_element("css selector", "[data-testid='login-email']").send_keys(
        user["email"]
    )
    browser.find_element("css selector", "[data-testid='login-password']").send_keys(
        user["password"]
    )
    browser.find_element("css selector", "[data-testid='login-submit']").click()
    time.sleep(0.5)


@pytest.fixture
def registered_user(driver, unique_user):
    register_user_via_ui(driver, unique_user)
    login_user_via_ui(driver, unique_user)
    return unique_user


class _QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        return


@pytest.fixture
def attacker_server():
    class Handler(_QuietHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(FIXTURES_DIR), **kwargs)

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("localhost", 0))
        port = sock.getsockname()[1]

    server = ThreadingHTTPServer(("localhost", port), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()

    yield f"http://localhost:{port}"

    server.shutdown()
    thread.join(timeout=2)


def get_browser_cookies(browser) -> requests.cookies.RequestsCookieJar:
    jar = requests.cookies.RequestsCookieJar()
    for cookie in browser.get_cookies():
        jar.set(cookie["name"], cookie["value"])
    return jar
