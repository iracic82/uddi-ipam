import os
import json
from sandbox_api import SandboxAccountAPI

BASE_URL = "https://csp.infoblox.com/v2"
TOKEN = os.environ.get('Infoblox_Token')
TEAM_ID = os.environ.get('INSTRUQT_PARTICIPANT_ID', 'default-team')
SANDBOX_ID_FILE = "sandbox_id.txt"

sandbox_request_body = {
    "name": TEAM_ID,
    "description": "Created via Python script Instruqt Demo",
    "state": "active",
    "tags": {"instruqt": "igor"},
    "admin_user": {
        "email": os.environ.get("INSTRUQT_EMAIL"),
        "name": TEAM_ID
    }
}

api = SandboxAccountAPI(base_url=BASE_URL, token=TOKEN)
create_response = api.create_sandbox_account(sandbox_request_body)

if create_response["status"] == "success":
    print("✅ Sandbox created successfully.")

    sandbox_data = create_response["data"]
    sandbox_id = None

    # Support response with "result" wrapper or flat "id"
    if isinstance(sandbox_data, dict):
        if "result" in sandbox_data and "id" in sandbox_data["result"]:
            sandbox_id = sandbox_data["result"]["id"]
        elif "id" in sandbox_data:
            sandbox_id = sandbox_data["id"]

    # Optional: Strip "identity/accounts/" prefix if only UUID is needed
    if sandbox_id and sandbox_id.startswith("identity/accounts/"):
        sandbox_id = sandbox_id.split("/")[-1]

    if sandbox_id:
        with open(SANDBOX_ID_FILE, "w") as f:
            f.write(sandbox_id)
        print(f"📁 Sandbox ID saved to {SANDBOX_ID_FILE}: {sandbox_id}")
    else:
        print("⚠️ Sandbox ID not found in API response.")
        print("Raw API response:")
        print(json.dumps(sandbox_data, indent=2))
else:
    print(f"❌ Sandbox creation failed: {create_response['error']}")
