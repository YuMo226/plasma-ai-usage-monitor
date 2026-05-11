#!/usr/bin/env python3
"""Fetch AI API usage/balance and output a JSON summary to stdout.

Supports:
- OpenAI official
- Third-party proxies (one-api, new-api, etc.)
- DeepSeek
"""

import json
import sys
from pathlib import Path

import requests

CONFIG_PATH = Path.home() / ".config" / "ai_widget.json"
TIMEOUT = 10


def load_config():
    with open(CONFIG_PATH, encoding="utf-8") as f:
        return json.load(f)


def fetch_openai_official(api_url: str, api_key: str):
    """Fetch from OpenAI official billing API."""
    headers = {"Authorization": f"Bearer {api_key}"}
    base = api_url.rstrip("/")

    sub_resp = requests.get(f"{base}/v1/dashboard/billing/subscription", headers=headers, timeout=TIMEOUT)
    sub_resp.raise_for_status()
    sub_data = sub_resp.json()
    total = sub_data.get("hard_limit_usd", 0.0)

    usage_resp = requests.get(f"{base}/v1/dashboard/billing/usage", headers=headers, timeout=TIMEOUT)
    usage_resp.raise_for_status()
    usage_data = usage_resp.json()
    used = usage_data.get("total_usage", 0.0) / 100.0

    return total, used


def fetch_deepseek(api_url: str, api_key: str):
    """Fetch from DeepSeek API."""
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Accept": "application/json",
    }
    base = api_url.rstrip("/")
    resp = requests.get(f"{base}/user/balance", headers=headers, timeout=TIMEOUT)
    resp.raise_for_status()
    data = resp.json()

    if not data.get("is_available"):
        raise RuntimeError("DeepSeek API not available")

    infos = data.get("balance_infos", [])
    if not infos:
        raise RuntimeError("No balance info returned")

    # DeepSeek returns current balance, not historical usage
    # We'll use total_balance as current remaining balance
    balance = float(infos[0].get("total_balance", 0))
    granted = float(infos[0].get("granted_balance", 0))
    topped_up = float(infos[0].get("topped_up_balance", 0))

    # Note: DeepSeek API doesn't provide total limit or historical usage
    # We can only show current balance. limit and usage will be set to 0.
    return 0, 0, balance


def fetch_proxy_api(api_url: str, api_key: str, paths: dict, fields: dict):
    """Fetch from third-party proxy APIs (one-api, new-api, etc.)."""
    headers = {"Authorization": f"Bearer {api_key}"}
    base = api_url.rstrip("/")

    if paths.get("usage"):
        resp = requests.get(f"{base}{paths['usage']}", headers=headers, timeout=TIMEOUT)
        resp.raise_for_status()
        data = resp.json()

        if isinstance(data, dict) and "data" in data:
            data = data["data"]

        total = data.get(fields.get("limit", "quota"), 0.0)
        used = data.get(fields.get("usage", "used_quota"), 0.0)
        return total, used

    total = 0.0
    used = 0.0

    if paths.get("limit"):
        resp = requests.get(f"{base}{paths['limit']}", headers=headers, timeout=TIMEOUT)
        resp.raise_for_status()
        data = resp.json()
        if isinstance(data, dict) and "data" in data:
            data = data["data"]
        total = data.get(fields.get("limit", "quota"), 0.0)

    if paths.get("usage"):
        resp = requests.get(f"{base}{paths['usage']}", headers=headers, timeout=TIMEOUT)
        resp.raise_for_status()
        data = resp.json()
        if isinstance(data, dict) and "data" in data:
            data = data["data"]
        used = data.get(fields.get("usage", "used_quota"), 0.0)

    return total, used


def main():
    try:
        cfg = load_config()
        api_url = cfg["api_url"]
        api_key = cfg["api_key"]
    except FileNotFoundError:
        print(json.dumps({"success": False, "limit": 0, "usage": 0, "balance": 0, "error_msg": f"Config not found: {CONFIG_PATH}"}))
        sys.exit(0)
    except (json.JSONDecodeError, KeyError) as e:
        print(json.dumps({"success": False, "limit": 0, "usage": 0, "balance": 0, "error_msg": f"Config error: {e}"}))
        sys.exit(0)

    provider = cfg.get("provider", "openai")
    paths = cfg.get("paths", {})
    fields = cfg.get("fields", {})
    unit = cfg.get("unit", 1.0)

    try:
        if provider == "openai":
            total, used = fetch_openai_official(api_url, api_key)
            balance = round(total - used, 4)
        elif provider == "deepseek":
            total, used, balance = fetch_deepseek(api_url, api_key)
        else:
            total, used = fetch_proxy_api(api_url, api_key, paths, fields)
            total = total * unit
            used = used * unit
            balance = round(total - used, 4)

        print(json.dumps({
            "success": True,
            "limit": round(total, 4),
            "usage": round(used, 4),
            "balance": round(balance, 4),
            "error_msg": "",
        }))
    except requests.exceptions.Timeout:
        print(json.dumps({"success": False, "limit": 0, "usage": 0, "balance": 0, "error_msg": "Request timed out"}))
    except requests.exceptions.ConnectionError:
        print(json.dumps({"success": False, "limit": 0, "usage": 0, "balance": 0, "error_msg": "Connection failed"}))
    except requests.exceptions.HTTPError as e:
        print(json.dumps({"success": False, "limit": 0, "usage": 0, "balance": 0, "error_msg": f"HTTP {e.response.status_code}"}))
    except Exception as e:
        print(json.dumps({"success": False, "limit": 0, "usage": 0, "balance": 0, "error_msg": str(e)}))


if __name__ == "__main__":
    main()
