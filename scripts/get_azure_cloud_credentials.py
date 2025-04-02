import os
import json
import requests

TOKEN = os.environ.get("Infoblox_Token")
OUTPUT_FILE = "azure_credential_id"
TARGET_NAME = "Azure-Demo-Lab"

if not TOKEN:
    raise EnvironmentError("❌ 'Infoblox_Token' is not set.")

url = "https://csp.infoblox.com/api/iam/v1/cloud_credential"
headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

print("📡 Listing all cloud credentials...")

response = requests.get(url, headers=headers)
try:
    data = response.json()
except Exception:
    data = {"raw": response.text}

print(f"📦 Status Code: {response.status_code}")
print("📥 Cloud Credential List:")
print(json.dumps(data, indent=2))

# Safely extract results list
credentials = data.get("results", [])
print(f"🔎 Found {len(credentials)} credential(s) total.")

# Filter by name (optional)
filtered = [c for c in credentials if c.get("name") == TARGET_NAME]

if filtered:
    cred_id = filtered[0]["id"]
    with open(OUTPUT_FILE, "w") as f:
        f.write(cred_id)
    print(f"✅ Credential ID for '{TARGET_NAME}' saved to {OUTPUT_FILE}: {cred_id}")
else:
    print(f"⚠️ No credential found with name: '{TARGET_NAME}'")
