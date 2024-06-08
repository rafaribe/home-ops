import requests

def get_zone_id(zone_name, api_token):
    url = "https://api.cloudflare.com/client/v4/zones"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    params = {
        "name": zone_name
    }
    
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    
    zones = response.json()["result"]
    if not zones:
        raise Exception(f"No zones found with name {zone_name}")
    
    return zones[0]["id"]

def get_dns_records(zone_id, api_token, record_type="TXT"):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    params = {
        "type": record_type
    }
    
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    
    return response.json()["result"]

def delete_dns_record(zone_id, record_id, api_token):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    
    response = requests.delete(url, headers=headers)
    response.raise_for_status()
    
    return response.json()

def main():
    zone_name = input("Enter your Cloudflare zone name: ")
    api_token = input("Enter your Cloudflare API token: ")

    try:
        zone_id = get_zone_id(zone_name, api_token)
        print(f"Zone ID for {zone_name} is {zone_id}")
    except Exception as e:
        print(e)
        return

    # Fetch all TXT records
    txt_records = get_dns_records(zone_id, api_token, record_type="TXT")

    if not txt_records:
        print("No TXT records found.")
        return

    print(f"Found {len(txt_records)} TXT records. Deleting...")

    # Delete each TXT record
    for record in txt_records:
        record_id = record["id"]
        delete_response = delete_dns_record(zone_id, record_id, api_token)
        print(f"Deleted record ID: {record_id}")

    print("All TXT records have been deleted.")

if __name__ == "__main__":
    main()
