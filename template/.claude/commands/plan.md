---
description: Onaylı spec'ten implementasyon planı — KAPI 2'de durur
---

$ARGUMENTS parçasının planını çıkar:

1. Spec K1-onaylı mı kontrol et (`module-specs/<parça>.md` durum alanı). Değilse DUR → önce /spec akışı.
2. Spec **TEK doğruluktur** — plan spec kapsamı dışına çıkmaz; çıkma ihtiyacı = önce spec güncellenir (K1'e döner).
3. Adım-adım plan: dosyalar · iş sırası · test stratejisi (**mock-first**) · riskler.
4. 🚦 **KAPI 2:** onaya sun ve **DUR**. *(Kapı-profili `K1+K2-birleşik` ise spec ile birlikte tek onaydır.)*

Onay sonrası ilk iş: parça branch'i — `git switch -c wip/<parça>`.
