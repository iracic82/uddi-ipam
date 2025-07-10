import os
import json
import requests
import time

class GCPInfobloxSession:
    def __init__(self):
        self.base_url = "https://csp.infoblox.com"
        self.email = os.getenv("INFOBLOX_EMAIL")
        self.password = os.getenv("INFOBLOX_PASSWORD")
        self.jwt = None
        self.session = requests.Session()
        self.headers = {"Content-Type": "application/json"}

    def login(self):
        payload = {"email": self.email, "password": self.password}
        response = self.session.post(f"{self.base_url}/v2/session/users/sign_in", headers=self.headers, json=payload)
        response.raise_for_status()
        self.jwt = response.json().get("jwt")
        self._save_to_file("gcp_jwt.txt", self.jwt)
        print("✅ Logged in and saved JWT to gcp_jwt.txt")

    def switch_account(self):
        sandbox_id = self._read_file("sandbox_id.txt")
        payload = {"id": f"identity/accounts/{sandbox_id}"}
        headers = self._auth_headers()
        response = self.session.post(f"{self.base_url}/v2/session/account_switch", headers=headers, json=payload)
        response.raise_for_status()
        self.jwt = response.json().get("jwt")
        self._save_to_file("gcp_jwt.txt", self.jwt)
        print(f"✅ Switched to sandbox {sandbox_id} and updated JWT")

    def create_gcp_key(self):
        sa_key_file = "/root/infoblox-lab/sa-key.json"
        if not os.path.exists(sa_key_file):
            raise FileNotFoundError("❌ GCP service account key (sa-key.json) not found.")

        with open(sa_key_file, "r") as f:
            sa_data = json.load(f)


        payload = {
            "name": "gcp-key-instruqt",
            "source_id": "gcp",
            "active": True,
            "key_type": "service_account_key",
            "key_data": {
                "type": "service_account",
                "project_id": sa_data.get("project_id"),
                "private_key_id": sa_data.get("private_key_id"),
                "private_key": sa_data.get("private_key"),
                "client_email": sa_data.get("client_email"),
                "client_id": sa_data.get("client_id"),
                "auth_uri": sa_data.get("auth_uri"),
                "token_uri": sa_data.get("token_uri"),
                "auth_provider_x509_cert_url": sa_data.get("auth_provider_x509_cert_url"),
                "client_x509_cert_url": sa_data.get("client_x509_cert_url"),
                "universe_domain": sa_data.get("universe_domain", "googleapis.com")
            }
        }

        response = self.session.post(
            f"{self.base_url}/api/iam/v2/keys",
            headers=self._auth_headers(),
            json=payload
        )

        if response.status_code == 409:
            print("⚠️ GCP key already exists, skipping creation.")
        if response.status_code != 201:
            print("❌ Failed to create GCP key:")
            print(response.status_code)
            print(response.text)
            response.raise_for_status()
        else:
            response.raise_for_status()
            print("🔐 GCP key created successfully.")

    def fetch_cloud_credential_id(self):
        url = f"{self.base_url}/api/iam/v1/cloud_credential"
        for i in range(5):
            response = self.session.get(url, headers=self._auth_headers())
            response.raise_for_status()
            creds = response.json().get("results", [])

            for cred in creds:
                if cred.get("credential_type") == "Google Cloud Platform":
                    credential_id = cred.get("id")
                    self._save_to_file("gcp_cloud_credential_id.txt", credential_id)
                    print(f"✅ GCP Cloud Credential ID saved: {credential_id}")
                    return credential_id

            print(f"⏳ Waiting for GCP Cloud Credential to appear... ({i+1}/5)")
            time.sleep(2)

        raise RuntimeError("❌ GCP Cloud Credential did not appear in time.")

    def fetch_dns_view_id(self):
        url = f"{self.base_url}/api/ddi/v1/dns/view"
        response = self.session.get(url, headers=self._auth_headers())
        response.raise_for_status()
        dns_view_id = response.json().get("results", [{}])[0].get("id")
        self._save_to_file("gcp_dns_view_id.txt", dns_view_id)
        print(f"✅ DNS View ID saved: {dns_view_id}")
        return dns_view_id

    def inject_variables_into_payload(self, template_file, output_file, dns_view_id, cloud_credential_id, project_id):
        with open(template_file, "r") as f:
            payload = json.load(f)

        payload["destinations"][0]["config"]["dns"]["view_id"] = dns_view_id
        payload["source_configs"][0]["cloud_credential_id"] = cloud_credential_id
        payload["source_configs"][0]["restricted_to_accounts"] = [project_id]
        payload["source_configs"][0]["credential_config"]["access_identifier"] = project_id

        with open(output_file, "w") as f:
            json.dump(payload, f, indent=2)

        print(f"📦 GCP payload created in {output_file} with injected variables")

    def submit_discovery_job(self, payload_file):
        with open(payload_file, "r") as f:
            payload = json.load(f)

        url = f"{self.base_url}/api/cloud_discovery/v2/providers"
        response = self.session.post(url, headers=self._auth_headers(), json=payload)
        response.raise_for_status()
        print("🚀 GCP Cloud Discovery Job submitted:")
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
    project_id = os.getenv("INSTRUQT_GCP_PROJECT_INFOBLOX_DEMO_PROJECT_ID")
    session = GCPInfobloxSession()
    session.login()
    session.switch_account()
    session.create_gcp_key()
    cred_id = session.fetch_cloud_credential_id()
    dns_id = session.fetch_dns_view_id()
    session.inject_variables_into_payload("gcp_payload_template.json", "gcp_payload.json", dns_id, cred_id, project_id)
    session.submit_discovery_job("gcp_payload.json")
