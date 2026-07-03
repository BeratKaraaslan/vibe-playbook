# CHANGELOG — Vibe-Coding Orchestration Playbook

## v2 — 2026-07-03
- **§1/§5 (Ops):** "kalıcılık" gerekçesi düzeltildi — kaynak runbook+infra-state, session context'i yalnız cache. **Anında-runbook** + **anti-confabulation** kuralları eklendi (compaction sonrası uydurma "neden"lere karşı: runbook'ta yoksa "kayıtlı değil").
- **§2/§4.3 (KAPI 4):** doğrulama okumaları **verifier-subagent**'a delege — yönetici context'i temiz kalır (erken devir + bayat kod hafızası önlenir); ilke: "yöneticinin kendi kod hafızası da güvenilmez kaynaktır". Sınır tanımı: dev session'ları interaktif kalır (kullanıcı izler/dikte eder); subagent yalnız sınırlı, tek-raporlu doğrulama işleri.
- **§9/§13 (commit):** "uncommitted-until-review" kaldırıldı → **branch + checkpoint commit** modeli; değişmez kural "main'e KAPI 4'süz giriş yok"; squash/curate isteğe bağlı. *(v1'in iç çelişkisi de kapandı: §2 "IMPL (küçük commit)" derken §9 "commit YOK" diyordu.)*
- **§9:** yeni çalışma anlaşması — **"Hook > talimat"**: enforce edilebilen hijyen kuralı harness hook'uyla uygulanır.
- **§10 (devir):** tetik netleşti = **kalite + doğal sınır** (sabit token sayısı değil; büyük context'te tutarlı birimi bitirmek serbest). "/context izle + agent fark etsin" kaldırıldı (model kendi kalan context'ini içgözlemle bilemez) → yerine **PreCompact hook emniyet ağı**: devir dayatmaz, compaction öncesi docs'u güvenceler + bildirir.
- **§12/§14:** iskelete `pre-compact.sh` eklendi; `workflow.md` başına "← playbook vN" fork işareti.
- **Yeni §15 (meta-öğrenme):** kanonik ev · versiyon+changelog · **faz-retro (3 soru:** hangi kapı gerçek yakaladı / hangisi okunmadan onaylandı / hangi kural neden bypass edildi**)** · PROJE/PLAYBOOK etiketleme · **kapı kalibrasyonu** (kapı-yorgunluğu ölçümü) · base'e geri akış.

## v1 — 2026-07-03 öncesi (scratchpad dönemi)
- İlk domain-nötr sürüm: 4 session tipi · insan kapıları (KAPI 1–4 + faz kapıları) · yönetici döngüsü (zemin-doğrulama, kickoff iskeleti) · Ops session + el-ele protokol · living-docs sistemi (STATE/ARŞİV, bloat-budget) · karar-zamanlaması · çalışma anlaşmaları · track'ler · base-project iskeleti.
