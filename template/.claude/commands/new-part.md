---
description: (Yönetici) Living-docs'tan taze-session kickoff taslağı üret
---

$ARGUMENTS parçası için kickoff üret.

**ÖNCE zemini doğrula:** `git log/status` + `progress.md` + `module-specs/<parça>.md` — rapor değil REPO esastır; çelişki varsa kickoff'a taşıma, önce kaynağı düzelt.

Kickoff iskeleti (bu sırayla, hepsi somut dolu):
1. rol + konum + parça haritası (progress'ten)
2. ÖNCE OKU — kaynak spec = TEK doğruluk + hangi docs
3. KİLİTLİ kararlar (değiştirme, sorma)
4. çalışma kuralları: branch (`wip/<parça>`) · checkpoint · CLAUDE.md kritik kuralları
5. iş sırası (alt-adımlar)
6. spec-kapısı mikro-kararları: VARSAYMA → kullanıcıya sor / open-questions
7. KAPI 3/4 somut kabul listeleri (spec'ten kopya)
8. döngü + session hijyeni (doğal sınırda devir önerisi)
9. İLK ADIM (kod/artefakt öncesi ne yapılacak)

**Çıktı:** tek kopyalanabilir blok.
**Devir-testi:** blokta living-docs'ta olmayan bilgi varsa önce doc'u güncelle, sonra bloğu üret.
