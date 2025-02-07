#!/usr/local/bin/python3

import requests
import json
import os

class AutoRefreshAPI:
    def __init__(self):
        self.api_token = os.environ.get("TF_VAR_prosimo_token")
        self.tenant = os.environ.get("INSTRUQT_PARTICIPANT_ID")
        self.aws_account = os.environ.get("INSTRUQT_AWS_ACCOUNT_PROSIMO_DEMO_ACCOUNT_ID")
        self.azure_subscription = os.environ.get("INSTRUQT_AZURE_SUBSCRIPTION_PROSIMO_TENANT_SUBSCRIPTION_ID")
        self.base_url = f"https://{self.tenant}.admin.prosimo.io/api"
        self.headers = {
            "Prosimo-ApiToken": self.api_token,
            "Content-Type": "application/json"
        }
        self.session = requests.Session()
        self.session.headers.update(self.headers)
    def cloud_refresh(self):
        endpoint_url = f"{self.base_url}/datafetch"
        payload = json.dumps(
            [
                {
                "csp": "AWS",
                "accounts": [
                    f"{self.aws_account}"
                ],
                "regions": [
                    "eu-west-1",
                    "us-east-1"
                ]
                },
                {
                    "csp": "AZURE",
                    "accounts": [
                        f"{self.azure_subscription}"
                    ],
                    "regions": [
                        "northeurope"
                    ]
                }
        ])  # Define Instruqt payload
        response = self.session.post(endpoint_url, data=payload)

        if response.status_code == 200:
            return json.loads(response.text)
        else:
            raise Exception(f"API call failed with status code {response.status_code}: {response.text}")
if __name__ == "__main__":
    # Ensure that the TOKEN and TENANT environment variables are set
    if not os.environ.get("TF_VAR_prosimo_token") or not os.environ.get("INSTRUQT_PARTICIPANT_ID"):
        raise Exception("TOKEN and TENANT environment variables must be set")

    api_client = AutoRefreshAPI()

    # Refresh Cloud Assets using POST
    cloud_refresh_response = api_client.cloud_refresh()
    print(f"Refresh Network Discovery Response: {cloud_refresh_response}")