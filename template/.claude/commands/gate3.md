---
description: KAPI 3 mekanik kanıt — test+lint+typecheck koştur, kompakt kanıt bloğu bas
---

KAPI 3'ün mekanik kanıt adımı ($ARGUMENTS):

1. CLAUDE.md'deki Test/Lint/Typecheck komutlarını kullan. Doldurulmamışsa `package.json`/`Makefile`'dan tespit et ve CLAUDE.md'ye işlenmesini öner.
2. Üçünü de koştur (projede olmayanı `—` işaretle).
3. Şu formatta KOMPAKT blok bas (ham çıktı yığını DEĞİL — insan 10 saniyede okur):

```
KAPI 3 KANITI — <parça> @ <branch>
test:      ✅/❌  (n passed / n failed — kırmızıysa ilk hatanın tek satır özeti)
lint:      ✅/❌
typecheck: ✅/❌
Manuel doğrulama listesi (spec'in KAPI 3 kabul listesi):
- [ ] <madde — insan gerçekte dener>
```

4. ❌ varsa: KAPI 3 insana sunulMAZ — önce düzeltme öner. Kapıya yalnız yeşil tablo gider.
