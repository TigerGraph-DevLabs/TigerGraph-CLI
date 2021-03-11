import requests




# Get client_id ???
headers = {
    'accept': '*/*',
    'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
    'accept-encoding': 'gzip, deflate, br',
    'accept-language': 'en-US,en;q=0.9,ar;q=0.8',
    'origin': 'https://tgcloud.io',
    'referer': 'https://tgcloud.io/',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-site',
}

client = requests.get("https://tgcloud.io/api/config/client",headers=headers)

print(client.status_code)
print(client.json())

client_id = client.json()["Result"]["Auth0ClientID"]
# Step 2 using the client_id Post this
print(client.headers)
headers={
'accept': '*/*',
'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
'accept-encoding': 'gzip, deflate, br',
'accept-language': 'en-US,en;q=0.9,ar;q=0.8',
'origin': 'https://tgcloud.io',
'referer': 'https://tgcloud.io/',
'sec-fetch-dest': 'empty',
'sec-fetch-mode': 'cors',
'sec-fetch-site': 'same-site',
# 'auth0-client': 'eyJuYW1lIjoibG9jay5qcyIsInZlcnNpb24iOiIxMS4yNC4xIiwiZW52Ijp7ImF1dGgwLmpzIjoiOS4xMy4yIn19',
# 'cookie' : 'a0_users:sess=eyJjc3JmU2VjcmV0IjoiUmlVYW9Nb2tLS2ZzbkdqQmpudFVKaHRVIn0=; a0_users:sess.sig=619Unovz2sEUjaUp_z4NKz7z16w;'
}


data = {
    "client_id":  client_id, #"M4fBSAq0HoB4QNkBzs1PFztxGEO61QCp",
    "username": "zargonovski@gmail.com",
    "password": "MySuperPassword:)",
    "realm": "Username-Password-Authentication",
    "credential_type": "http://auth0.com/oauth/grant-type/password-realm"
}



res = requests.post("https://auth.tgcloud.io/co/authenticate",headers=headers,data=data)
print(res.status_code)
print(res.json())
print(res.headers)
ress = res.json()
login_ticket = ress["login_ticket"]
co_verifier = ress["co_verifier"]
state = "FdMyku-o2.radXFamQeA9YJ5BTk2Dp-I" #ress["co_id"]

# &redirect_uri=https%3A%2F%2Ftgcloud.io%2Fcallback
# &response_mode=web_message
# &prompt=none
url ="https://auth.tgcloud.io/authorize?client_id={0}&response_type=token%20id_token&scope=openid%20profile%20email%20write%3Asol_shell%20read%3Asol_log%20write%3Aroot_shell%20read%3Asol_file%20write%3Asol_state%20update%3Astarterkits%20create%3Acredits%20create%3Acharge%20read%3Asol_activity%20read%3Aadmin&connection=Username-Password-Authentication&nonce={1}&audience=https%3A%2F%2Ftgcloud.io%2F&realm=Username-Password-Authentication&login_ticket={2}&state={3}&redirect_uri=https%3A%2F%2Ftgcloud.io%2Fcallback".format(client_id,co_verifier,login_ticket,state)

# then call this  GET
ftt = requests.get(url,headers=headers)
print(ftt.url)
print(ftt.text)
print(ftt.status_code)
print(ftt.headers)