import os
import json
import requests

# === Configuration ===
API_URL = "https://csp.infoblox.com/api/cloud_discovery/v2/providers"
TOKEN = os.environ.get("Infoblox_Token")
ROLE_ARN_FILE = "infoblox_role_arn.txt"

# === Load and validate environment/config ===
if not TOKEN:
    raise EnvironmentError("❌ 'Infoblox_Token' environment variable is not set.")

if not os.path.isfile(ROLE_ARN_FILE):
    raise FileNotFoundError(f"❌ IAM Role ARN file not found: {ROLE_ARN_FILE}")

with open(ROLE_ARN_FILE, "r") as f:
    role_arn = f.read().strip()

print(f"🔐 Using IAM Role ARN: {role_arn}")

# === Construct the payload ===
payload = {
    "name": "AWS_Demo",
    "provider_type": "Amazon Web Services",
    "account_preference": "single",
    "sync_interval": "15",
    "desired_state": "enabled",
    "credential_preference": {
        "credential_type": "dynamic",
        "access_identifier_type": "role_arn"
    },
    "destination_types_enabled": ["DNS"],
    "source_configs": [
        {
            "credential_config": {
                "access_identifier": role_arn
            }
        }
    ],
    "additional_config": {
        "excluded_accounts": [],
        "forward_zone_enabled": False,
        "internal_ranges_enabled": False,
        "object_type": {
            "version": 1,
            "discover_new": True,
            "objects": [
                {
                    "category": {"id": "security", "excluded": False},
                    "resource_set": [{"id": "security_groups", "excluded": False}]
                },
                {
                    "category": {"id": "networking-basics", "excluded": False},
                    "resource_set": [
                        {"id": "internet-gateways", "excluded": False},
                        {"id": "nat-gateways", "excluded": False},
                        {"id": "transit-gateways", "excluded": False},
                        {"id": "eips", "excluded": False},
                        {"id": "route-tables", "excluded": False},
                        {"id": "network-interfaces", "excluded": False},
                        {"id": "vpn-connection", "excluded": False},
                        {"id": "vpn-gateway", "excluded": False},
                        {"id": "customer-gateways", "excluded": False},
                        {"id": "ebs-volumes", "excluded": False},
                        {"id": "directconnect-gateway", "excluded": False},
                        {"id": "s3-buckets", "excluded": False},
                        {"id": "s3-bucket-public-access-blocks", "excluded": False},
                        {"id": "s3-bucket-policies", "excluded": False}
                    ]
                },
                {
                    "category": {"id": "lbs", "excluded": False},
                    "resource_set": [
                        {"id": "elbs", "excluded": False},
                        {"id": "listeners", "excluded": False},
                        {"id": "target-groups", "excluded": False}
                    ]
                },
                {
                    "category": {"id": "compute", "excluded": False},
                    "resource_set": [{"id": "metrics", "excluded": False}]
                },
                {
                    "category": {"id": "ipam", "excluded": False},
                    "resource_set": [
                        {"id": "ipams", "excluded": False},
                        {"id": "scopes", "excluded": False},
                        {"id": "pools", "excluded": False}
                    ]
                }
            ]
        }
    },
    "destinations": [
        {
            "destination_type": "DNS",
            "config": {
                "dns": {
                    "consolidated_zone_data_enabled": False,
                    "view_name": "AWS_Demo_Lab",
                    "sync_type": "read_write",
                    "resolver_endpoints_sync_enabled": False
                }
            }
        }
    ]
}

# === HTTP Headers ===
headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

# === Send the POST request ===
print("🚀 Sending API request to register AWS cloud provider with Infoblox...")

response = requests.post(API_URL, headers=headers, data=json.dumps(payload))

# === Handle Response ===
if response.status_code == 201:
    print("✅ Cloud provider registered successfully.")
    print(json.dumps(response.json(), indent=2))

elif response.status_code == 409:
    print("⚠️ Provider already exists (409 Conflict). You may already have one configured.")
    print(json.dumps(response.json(), indent=2))

else:
    print(f"❌ Error {response.status_code}:")
    try:
        print(json.dumps(response.json(), indent=2))
    except Exception:
        print(response.text)
