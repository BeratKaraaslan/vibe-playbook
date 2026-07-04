# CHANGELOG — Vibe-Coding Orchestration Playbook

## v3 — 2026-07-04
> Tema: "optimum > mükemmel" — insan yükünü azaltan mekanizmalar eklendi, tören ekleyenler bilinçli olarak eklenmedi.
- **`template/` materialize edildi (en büyük değişiklik):** §14 iskeleti artık prose değil, gerçek dosyalar — LEAN CLAUDE.md (8 kritik kural) · workflow.md (**normatif özet**: yalnız kural, gerekçe playbook'ta — çekirdek/rationale ayrımı playbook'u yeniden yapılandırmadan kendiliğinden oluştu) · STARTGUIDE (kurulum + Faz 0 kickoff hazır) · living-doc başlangıçları · spec şablonu (kapı-profili alanlı) · runbook şablonu · `.claude/` (settings + 3 hook + verifier agent + 6 command) · `memory-seed/`. Bootstrap-drift kaynağı kapandı: prose'dan yeniden-üretim yok, kopyala-kullan var.
- **§9 main-guard + /gate3 ("hook > talimat"ın uygulanması):** "main'e KAPI 4'süz giriş yok" artık fiziksel — main'de kod-commit ve işaretsiz merge bloklanır (docs-only commit serbest; işaret = insan onayı sonrası `.claude/.gate4-ok`). `/gate3` komutu KAPI 3'e mekanik kanıt bloğu üretir (test/lint/typecheck). İlke: doğru hook insan nöbetini kaldırır, tören eklemez. *(Her iki hook 18 senaryoluk testten geçirildi.)*
- **§2 kapı-profili parça bazında:** küçük/düşük-riskli parçada KAPI 1+2 tek onayda birleşir (kapı-yorgunluğuna baştan önlem; §15 retro-kalibrasyonu reaktif katman olarak kalır); para/auth/veri-kaybı yüzeyinde asla. Profil spec alanına yazılır.
- **Yeni §2.1 iptal/geri-dönüş:** parça iptali (branch terk + tek satır kayıt) · IMPL'de plan çürüdü → KAPI 2'ye delta-plan · KAPI 4 spec kusuru buldu → KAPI 1'e dönüş.
- **§9 anti-confabulation genellendi:** yalnız Ops değil — compaction geçirmiş her session: "docs'ta yoksa kayıtlı değil".
- **§10 devir-testi (Ops testinin yönetici simetriği):** devir-prompt'ta docs'ta olmayan bilgi = docs açığı; prompt değil doc düzeltilir. Sert garanti değil devir-anı sağlık kontrolü (tören eklemez).
- **§11 memory mekanizma-notu:** memory proje-dizini bazlı ve rol-körüdür; rol seçiciliği kickoff'ladır. Seed dosyası `memory-seed/`e taşındı (ilk yönetici session kaydeder).
- **④ Tasarım track tooling:** tasarım karar vericisi **Claude Design** (Claude Code'a MCP ile bağlanır); bağlantı için Claude Code'un **terminalden (CLI)** kullanımı zorunlu — §1/§13 + template (workflow, STARTGUIDE, design STATUS) işlendi.
- *Bilinçli eklenmeyenler:* playbook'un iki-doküman yeniden yapılandırması (bakım yükü; template zaten normatif biçim) · S/M/L parça taksonomisi (yargı yeter, takip eden developer) · stateless yönetici (insan sürtünmesi; uzun-ömürlü yönetici cache olarak kalır, tazelik devirde test edilir) · ek ceremony-hook'ları.

## v2 — 2026-07-03
- **§1/§5 (Ops):** "kalıcılık" gerekçesi düzeltildi — kaynak runbook+infra-state, session context'i yalnız cache. **Anında-runbook** + **anti-confabulation** kuralları eklendi (compaction sonrası uydurma "neden"lere karşı: runbook'ta yoksa "kayıtlı değil").
- **§2/§4.3 (KAPI 4):** doğrulama okumaları **verifier-subagent**'a delege — yönetici context'i temiz kalır (erken devir + bayat kod hafızası önlenir); ilke: "yöneticinin kendi kod hafızası da güvenilmez kaynaktır". Sınır tanımı: dev session'ları interaktif kalır (kullanıcı izler/dikte eder); subagent yalnız sınırlı, tek-raporlu doğrulama işleri.
- **§9/§13 (commit):** "uncommitted-until-review" kaldırıldı → **branch + checkpoint commit** modeli; değişmez kural "main'e KAPI 4'süz giriş yok"; squash/curate isteğe bağlı. *(v1'in iç çelişkisi de kapandı: §2 "IMPL (küçük commit)" derken §9 "commit YOK" diyordu.)*
- **§9:** yeni çalışma anlaşması — **"Hook > talimat"**: enforce edilebilen hijyen kuralı harness hook'uyla uygulanır.
- **§10 (devir):** tetik netleşti = **kalite + doğal sınır** (sabit token sayısı değil; büyük context'te tutarlı birimi bitirmek serbest). "/context izle + agent fark etsin" kaldırıldı (model kendi kalan context'ini içgözlemle bilemez) → yerine **PreCompact hook emniyet ağı** — **OPSİYONEL**: proje başında isteğe göre kurulur; devir dayatmaz, compaction öncesi docs'u güvenceler + bildirir.
- **§12/§14:** iskelete `pre-compact.sh` (opsiyonel) eklendi; `workflow.md` başına "← playbook vN" fork işareti.
- **Yeni §15 (meta-öğrenme):** kanonik ev · versiyon+changelog · **faz-retro (3 soru:** hangi kapı gerçek yakaladı / hangisi okunmadan onaylandı / hangi kural neden bypass edildi**)** · PROJE/PLAYBOOK etiketleme · **kapı kalibrasyonu** (kapı-yorgunluğu ölçümü) · base'e geri akış.

## v1 — 2026-07-03 öncesi (scratchpad dönemi)
- İlk domain-nötr sürüm: 4 session tipi · insan kapıları (KAPI 1–4 + faz kapıları) · yönetici döngüsü (zemin-doğrulama, kickoff iskeleti) · Ops session + el-ele protokol · living-docs sistemi (STATE/ARŞİV, bloat-budget) · karar-zamanlaması · çalışma anlaşmaları · track'ler · base-project iskeleti.
