# <PROJE ADI> — CLAUDE.md

> LEAN tutulur (~50 satır): harita + kritik kurallar. Süreç detayı: [workflow.md](workflow.md).

## Proje

<tek cümle — Faz 0'da doldurulur>

- Stack: <Faz 0'da> · Test: `<komut>` · Lint: `<komut>` · Typecheck: `<komut>`

## Doküman haritası (ne zaman ne yüklenir)

- `progress.md` + `issues.md` → her session başı
- `module-specs/<parça>.md` → o parçada çalışırken (**TEK doğruluk**)
- `architecture.md` / `data-model.md` → ilgili işte
- `infra-state.md` → ops/deploy işinde
- `workflow.md` → süreç sorusu olduğunda
- `docs/archive/*` · `docs/ops/*` → **ASLA otomatik** — yalnız talep üzerine

## Kritik kurallar (İHLAL EDİLMEZ)

1. **main'e KAPI 4'süz giriş YOK.** İş parça branch'inde akar (`wip/P-N`); küçük checkpoint commit'leri serbest ve teşvikli. *(main-guard hook enforce eder; main'de docs-only commit serbesttir.)*
2. **Git güvenliği:** uncommitted iş varken `git restore/stash/clean/checkout --` ASLA; yıkıcı işlem (force/reset/branch-sil) önce sorar.
3. **Secret:** `.env` okunmaz/yazılmaz/yazdırılmaz *(guard-env hook enforce eder)*; koda gömülmez. Değer gerekiyorsa → `NEEDS-FROM-USER.md` + DUR.
4. **VARSAYMA:** ürün kararı → kullanıcıya sor; karar veremediğin teknik açık → `open-questions.md`.
5. **Altın kural:** yapısal karar/değişiklik inline söylenmez — ilgili doc'a **İŞLENİR**.
6. **Anti-confabulation:** "neden X?" cevabı docs'tan verilir; docs'ta yoksa **"kayıtlı değil"** de — uydurma.
7. **Test:** dış-servis/LLM çağrıları **mock-first**; gerçek çağrı yalnız kontrollü ölçüm script'i.
8. **Kapıda DUR:** 🚦 işaretli adımlarda onay insanındır — onaysız devam etme.
