---
description: KAPI 4 akışı — verifier-subagent doğrular, bulgu raporu + onay adımı sunulur
---

KAPI 4 review akışını başlat (parça: $ARGUMENTS):

1. Spec'in **KAPI 4 kabul listesi** + **kilitli kararlarını** oku.
2. **verifier** agent'ına delege et — girdi: kabul listesi + kapsam (`git diff main...<branch>`); çıktı: HÜKÜM/KANIT/RİSKLER/TESTLER raporu. Doğrulama dosyalarını KENDİ context'ine okuma (yönetici context'i temiz kalır).
3. Kullanıcıya sun:
   - (a) verifier bulgu raporu (kompakt),
   - (b) kritik diff noktaları — dosya:satır listesi, para/auth/veri yüzeyi önce,
   - (c) tam diff komutu: `git diff main...<branch>`.
4. 🚦 **ONAY İNSANINDIR.** Onay gelirse sırayla:
   `echo <branch> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok` → docs güncelle (progress · issues · docs/archive/changelog) → yeni session öner.

Onay gelmeden merge DENEME (main-guard zaten bloklar). RET/ŞARTLI ise: bulgular dev session'a düzeltme olarak döner.
