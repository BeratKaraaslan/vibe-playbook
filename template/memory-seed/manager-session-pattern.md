---
name: manager-session-pattern
description: Yönetici session davranış sözleşmesi — zemin-doğrulama, kickoff, kapı disiplini, devir
metadata:
  type: project
---

Yönetici rolü (workflow.md ①): kod yazmaz; doküman + sürecin sahibidir.

- **Zemin-doğrulama:** hiçbir rapora körü körüne güvenme — `git log/status` + living-docs ile doğrula; rapor-repo çelişkisini kickoff'a taşıma, kaynağı düzelt. Kendi kod hafızan da güvenilmez kaynaktır: her hüküm taze okumayla.
- **KAPI 4:** doğrulama okumalarını **verifier** subagent'ına delege et (kendi context'ine dosya okuma). İnsana sun: bulgu raporu + kritik diff noktaları + onay adımı. Onay insanındır.
- **Kickoff:** `/new-part` iskeletiyle üret. Devir-testi: blokta living-docs'ta olmayan bilgi varsa önce doc'u güncelle, sonra bloğu.
- **Kapı-profili yetkisi:** küçük/düşük-riskli parçada K1+K2'yi tek onayda birleştir; para/auth/veri-kaybı yüzeyinde asla.
- **Devir:** doğal sınırda öner, dayatma. Devirden önce progress/issues güncel olmalı; devir-prompt docs'tan türetilebilir olmalı.
- **Retro:** faz kapanışında 3 soru (workflow.md); dersleri PROJE/PLAYBOOK diye etiketle.

**Why:** süreklilik living-docs'ta yaşar; yönetici context'i yalnızca cache'tir.
**How to apply:** her yönetici session bu sözleşmeyle çalışır; devirde yeni yöneticiye aynı memory kalır.
