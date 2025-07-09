import os
import json
import requests

class InfobloxSession:
    def __init__(self):
        self.base_url = "https://csp.infoblox.com"
        self.email = os.getenv("INFOBLOX_EMAIL")
        self.password = os.getenv("INFOBLOX_PASSWORD")
        self.jwt = None
        self.session = requests.Session()
        self.headers = {"Content-Type": "application/json"}

    def login(self):
        payload = {"email": self.email, "password": self.password}
        response = self.session.post(f"{self.base_url}/v2/session/users/sign_in", 
                                     headers=self.headers, json=payload)
        response.raise_for_status()
        self.jwt = response.json().get("jwt")
        self._save_to_file("jwt.txt", self.jwt)
        print("✅ Logged in and saved JWT to jwt.txt")

    def switch_account(self):
        sandbox_id = self._read_file("sandbox_id.txt")
        payload = {"id": f"identity/accounts/{sandbox_id}"}
        headers = self._auth_headers()
        response = self.session.post(f"{self.base_url}/v2/session/account_switch", 
                                     headers=headers, json=payload)
        response.raise_for_status()
        self.jwt = response.json().get("jwt")
        self._save_to_file("jwt.txt", self.jwt)
        print(f"✅ Switched to sandbox {sandbox_id} and updated JWT")

    def get_current_account(self):
        response = self.session.get(f"{self.base_url}/v2/current_account", 
                                    headers=self._auth_headers())
        response.raise_for_status()
        print("🔍 Current Account Info:")
        print(json.dumps(response.json(), indent=2))

    def fetch_cloud_credential_id(self):
        url = f"{self.base_url}/api/iam/v1/cloud_credential"
        response = self.session.get(url, headers=self._auth_headers())
        response.raise_for_status()
        credential_id = response.json().get("results", [{}])[0].get("id")
        self._save_to_file("cloud_credential_id.txt", credential_id)
        print(f"✅ Cloud Credential ID saved: {credential_id}")
        return credential_id

    def fetch_dns_view_id(self):
        url = f"{self.base_url}/api/ddi/v1/dns/view"
        response = self.session.get(url, headers=self._auth_headers())
        response.raise_for_status()
        dns_view_id = response.json().get("results", [{}])[0].get("id")
        self._save_to_file("dns_view_id.txt", dns_view_id)
        print(f"✅ DNS View ID saved: {dns_view_id}")
        return dns_view_id

    def inject_variables_into_payload(self, template_file, output_file, dns_view_id, cloud_credential_id):
        with open(template_file, "r") as f:
            payload = json.load(f)

        # Inject DNS View ID
        payload["destinations"][0]["config"]["dns"]["view_id"] = dns_view_id
        # Inject Cloud Credential ID
        payload["source_configs"][0]["cloud_credential_id"] = cloud_credential_id

        with open(output_file, "w") as f:
            json.dump(payload, f, indent=2)

        print(f"📦 Payload created in {output_file} with injected variables")

    def submit_discovery_job(self, payload_file):
        with open(payload_file, "r") as f:
            payload = json.load(f)

        url = f"{self.base_url}/api/cloud_discovery/v2/providers"
        response = self.session.post(url, headers=self._auth_headers(), json=payload)
        response.raise_for_status()
        print("🚀 Cloud Discovery Job submitted:")
        print(json.dumps(response.json(), indent=2))

    def _auth_headers(self):
        return {"Content-Type": "application/json", "Authorization": f"Bearer {self.jwt}"}

    def _save_to_file(self, filename, content):
        with open(filename, "w") as f:
            f.write(content.strip())

    def _read_file(self, filename):
        with open(filename, "r") as f:
            return f.read().strip()


if __name__ == "__main__":
    session = InfobloxSession()
    session.login()
    session.switch_account()
    session.get_current_account()
    cloud_credential_id = session.fetch_cloud_credential_id()
    dns_view_id = session.fetch_dns_view_id()
    session.inject_variables_into_payload(
        "payload_template.json", "payload.json",
        dns_view_id=dns_view_id,
        cloud_credential_id=cloud_credential_id
    )
    session.submit_discovery_job("payload.json")
