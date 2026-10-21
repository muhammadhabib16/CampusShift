import os

# 1. Perbaikan lib/services/grant_claim_service.dart (Menyediakan parameter wajib untuk ApiClient)
grant_service_path = "lib/services/grant_claim_service.dart"
with open(grant_service_path, "r", encoding="utf-8") as f:
    content = f.read()

# Ganti inisialisasi ApiClient() agar menyertakan argumen yang wajib
content = content.replace("final ApiClient _apiClient = ApiClient();", "final ApiClient _apiClient = ApiClient(baseUrl: 'https://api.campushift.unand.ac.id/api', getToken: () async => null);")

with open(grant_service_path, "w", encoding="utf-8") as f:
    f.write(content)
print("✔ Diperbaiki: grant_claim_service.dart")

# 2. Perbaikan lib/services/social_grant_service.dart
social_service_path = "lib/services/social_grant_service.dart"
with open(social_service_path, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("final ApiClient _apiClient = ApiClient();", "final ApiClient _apiClient = ApiClient(baseUrl: 'https://api.campushift.unand.ac.id/api', getToken: () async => null);")

with open(social_service_path, "w", encoding="utf-8") as f:
    f.write(content)
print("✔ Diperbaiki: social_grant_service.dart")

# 3. Perbaikan lib/services/api_client.dart (Memperbaiki error pemanggilan .get pada exception)
api_client_path = "lib/services/api_client.dart"
if os.path.exists(api_client_path):
    with open(api_client_path, "r", encoding="utf-8") as f:
        api_content = f.read()
    
    # Jika di dalam method delete terdapat pemanggilan get yang salah, ubah menjadi logika delete yang benar
    if "Future<dynamic> delete(String endpoint)" in api_content and "return await get(endpoint);" in api_content:
        api_content = api_content.replace(
            "Future<dynamic> delete(String endpoint) async {\n    return await get(endpoint);\n  }",
            "Future<dynamic> delete(String endpoint) async {\n    return await request('DELETE', endpoint);\n  }"
        )
        with open(api_client_path, "w", encoding="utf-8") as f:
            f.write(api_content)
        print("✔ Diperbaiki: method delete() di api_client.dart")

print("\n✅ Semua parameter ApiClient dan method helper telah disesuaikan!")
