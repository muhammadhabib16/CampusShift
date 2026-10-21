import os

# 1. Perbaiki grant_claim_service.dart (Ubah getToken menjadi synchronous returning null atau string)
for path in ["lib/services/grant_claim_service.dart", "lib/services/social_grant_service.dart"]:
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Perbaiki getToken agar sesuai dengan tipe 'String? Function()'
        content = content.replace(
            "getToken: () async => null",
            "getToken: () => null"
        )
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✔ Diperbaiki getToken di: {path}")

# 2. Perbaiki api_client.dart (Menghapus method tambahan yang keliru di akhir file)
api_path = "lib/services/api_client.dart"
if os.path.exists(api_path):
    with open(api_path, "r", encoding="utf-8") as f:
        api_content = f.read()
    
    # Hapus penambahan method delete / request yang sempat terselip salah di exception
    if "Future<dynamic> delete(String endpoint)" in api_content:
        # Bersihkan blok tambahan di akhir file sebelum kurung kurawal penutup terakhir
        idx = api_content.rfind("Future<dynamic> delete(String endpoint)")
        if idx != -1:
            api_content = api_content[:idx].strip() + "\n}\n"
            with open(api_path, "w", encoding="utf-8") as f:
                f.write(api_content)
            print("✔ Dibersihkan method tambahan yang salah di api_client.dart")

print("\n✅ Perbaikan final selesai!")
