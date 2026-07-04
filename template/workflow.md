# workflow.md — çalışma kuralları (normatif özet)

> **← playbook v3** · kanonik ev: vibe-playbook reposu. Burada yalnız KURAL var; gerekçeler playbook'ta.
> Projeye özel sapmalar en alttaki "Proje sapmaları" bölümüne işlenir — bu özetin gövdesine dokunulmaz.
> Kısaltma: K1–K4 = KAPI 1–4 (insan kapıları).

## Session tipleri

| Tip | Yazar | Ömür | Living-doc'u |
|---|---|---|---|
| ① Yönetici | doküman (kod ❌) | faz/proje boyu (devirle) | progress · issues · open-questions |
| ② Geliştirme | kod | parça-başı (taze) | module-specs/`<parça>`.md |
| ③ Ops | config/script (ürün-kodu ❌) | kalıcı = cache; kaynak = runbook | infra-state · docs/ops/* |
| ④ Tasarım | UI-kod | iş-başı (G-numaralı) | docs/design/* |

> Tasarım (G) işlerinde **karar verici: Claude Design** (MCP ile bağlı). Bağlantı için Claude Code **terminalden (CLI)** kullanılır — **zorunlu**.

## Parça döngüsü

```
/spec → 🚦K1 · /plan → 🚦K2 · IMPL (branch'te checkpoint'ler) ·
/gate3 → 🚦K3 (kanıt bloğu + insan gerçekte dener) ·
/review → 🚦K4 (verifier-subagent + İNSAN onayı) · MERGE + docs → yeni session
```

- **Kapı-profili** (spec'te yazar): küçük/düşük-riskli parçada **K1+K2 tek onayda birleşir**; para/auth/veri-kaybı yüzeyinde **asla** — tam profil.
- **K4 onayı insanındır.** Onay sonrası: `echo <branch> > .claude/.gate4-ok` → merge → `rm .claude/.gate4-ok`. (main-guard hook işaretsiz merge'i bloklar.)
- **İptal / geri-dönüş:** parça iptali = branch terk (silme = önce sor) + issues'a tek satır + spec'e `İPTAL` · IMPL'de plan çürüdü = K2'ye **delta-plan** ile dön (sıfırdan değil) · K4 spec-seviyesi kusur buldu = K1'e dön, ders retro'ya.

## Kritik kurallar

CLAUDE.md'deki 8 kural her session'da geçerlidir. 1 ve 3 fizikseldir: **main-guard** (main'de kod-commit + işaretsiz merge bloğu) ve **guard-env** (secret dosya erişim bloğu) hook'ları enforce eder.

## Living-docs

- **STATE** (progress · issues · architecture · data-model · infra-state · specs) = **EDIT**, küçük kalır, "şu anki gerçek". **ARŞİV** (docs/archive/*) = **APPEND**, otomatik YÜKLENMEZ (yalnız talep üzerine).
- **Rotasyon:** çözülen issue → archive/changelog'a tek satır · biten faz → progress'te tek satıra iner + `phase-N-summary.md` · **bloat-budget** ~150–200 satır → proaktif buda + bildir.
- **Altın kural:** yapısal karar inline söylenmez, ilgili doc'a **İŞLENİR** (session sınırını aşsın).

## Yönetici döngüsü

rapor al → **REPO'DAN doğrula** (git log/status + docs; rapor-repo çelişkisini kickoff'a taşıma, kaynağı düzelt) → `/new-part` ile kickoff rafine → taze session'da çalıştırılır.

- K4 doğrulama okumaları **verifier-subagent**'a delege edilir — yönetici kendi context'ine dosya okumaz (temiz kalır; kendi kod hafızası da güvenilmez kaynaktır).

## Ops

- **Anında-runbook:** her neden-kararı iş "bitti" sayılmadan runbook'a düşer. Yazılmamış karar YOK hükmündedir.
- **El-ele:** ② artefaktı yazar + lokal doğrular → ③ altyapıya uygular + infra-state günceller → **birlikte** gerçek ortamda doğrulanır. "Deploy edildi"yi AI tek başına diyemez.
- İhtiyaç akışı: `NEEDS-FROM-USER.md`'ye yaz + **DUR**.

## Devir

- **Tetik = kalite + doğal sınır** (sabit token sayısı değil). Tutarlı birimi aynı session'da bitirmek serbest; doğal sınırda öner: *"birim bitti / kalite düşüyor — docs güncel, yeni session?"*
- **Devir-testi:** devir-prompt'ta living-docs'ta olmayan bilgi varsa bu **docs'un açığıdır** — prompt değil doc düzeltilir.
- PreCompact hook = opsiyonel emniyet ağı (kurulum: STARTGUIDE §2).

## Faz-retro (kapanışta, ~5 dk)

1. Hangi kapı **gerçek** bir şey yakaladı?
2. Hangi kapı **okunmadan/özetten** onaylandı?
3. Hangi kural **ihlal/bypass** edildi — neden?

→ **PROJE** dersi = buraya ("Proje sapmaları") / ilgili spec'e işlenir · **PLAYBOOK** dersi = kanonik repoya changelog adayı.
**Kalibrasyon:** üst üste okunmadan onaylanan kapı o track'te hafifletilir; gerçek yakalayan ağır kalır.

## Proje sapmaları

*(Faz 0'da ve retrolarda doldurulur — boş)*
