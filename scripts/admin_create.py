import json
import requests
import os
import argparse

class UserCreator:
    def __init__(self, api_token):
        """
        Initialize the UserCreator class.

        Parameters:
        - api_token (str): The API token for authentication.
        """
        self.headers = {
            "Prosimo-ApiToken": api_token,
            "Content-Type": "application/json"
        }
        self.session = requests.Session()
        self.session.headers.update(self.headers)

    def fetch_role_id(self, base_url):
        """
        Function to fetch the role ID via HTTP GET request.

        Parameters:
        - base_url (str): The base URL for the API.

        Returns:
        - str: Role ID if found, None otherwise.
        """
        request_url = base_url + "role"
        response = self.session.get(request_url)
        if response.status_code == 200:
            roles_data = response.json().get('data', [])
            for role in roles_data:
                if role.get('name') == 'admin':
                    return role.get('id')
        else:
            print(f"Failed to fetch roles. HTTP {response.status_code}: {response.reason}")
            print("Server response:", response.json())
        return None

    def create_user(self, base_url, email, role_id):
        """
        Function to create a new user via HTTP POST request.

        Parameters:
        - base_url (str): The base URL for the API.
        - email (str): The email address for the user.
        - role_id (str): The role ID for the user.

        Returns:
        - dict: Response data from the API.
        """
        request_url = base_url + "user"

        payload = {
            "username": email,
            "firstname": "Student",
            "lastname": "MCN",
            "email": email,
            "roles": [
                {
                    "id": role_id,
                    "name": "admin",
                    "type": "default"
                }
            ],
            "userID": "",
            "type": "customer",
            "state": "APPROVED",
            "usergroups": [],
            "details": {
                "mfa": {
                    "enabled": False,
                    "phoneNumber": ""
                },
                "additionalEmails": []
            }
        }

        response = self.session.post(request_url, json=payload)

        if response.status_code == 200:
            return {
                'status': 'success',
                'data': response.json()
            }
        else:
            return {
                'status': 'failure',
                'error': f"HTTP {response.status_code}: {response.reason}",
                'details': response.json()
            }

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create a new user.')
    parser.add_argument('-e', '--email', required=True, help='Email address for the new user.')
    args = parser.parse_args()

    # Initialize the UserCreator class with the API token
    api_token = os.environ.get('TF_VAR_prosimo_token')  # Retrieve API token from environment variable
    user_creator = UserCreator(api_token)

    # Extract the tenant from the environment variable
    tenant = os.environ.get('INSTRUQT_PARTICIPANT_ID')  # Fallback to 'default_tenant' if tenant is not set
    base_url = f"https://{tenant}.admin.prosimo.io/api/"

    # Fetch the role ID
    role_id = user_creator.fetch_role_id(base_url)
    if role_id is None:
        print("Failed to fetch the role ID. Exiting.")
        exit(1)

    # Invoke the function to create the user
    response = user_creator.create_user(base_url, args.email, role_id)

    # Output the response
    print(json.dumps(response, indent=4))