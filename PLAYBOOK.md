# Vibe-Coding Orchestration Playbook

> Çok-session'lı AI geliştirme için yeniden-kullanılabilir metodoloji + base-project akışı.
> Domain-nötr: her yeni projede kopyalanır, Faz 0'da projeye özelleşir.
> **Üç birinci-sınıf hedef:** tutarlılık · sürdürülebilirlik · bağlamın (context) korunması.
>
> **Sürüm: v2** (2026-07-03) · kanonik ev = bu repo, kopyalar türevdir (§15) · değişiklikler → [CHANGELOG.md](CHANGELOG.md)

---

## 0. Temel ilke

Geliştirme **vibe coding** olarak akar (AI küçük adımlarla ilerler, insan yönlendirir) — ama akış serbest değil: **insan kapıları zorunludur.** AI kapılar arasında özgürce akar, kapılarda durur ve bekler. Para/auth/kredi/prod gibi kritik yerlerde vibe yok, **denetim** var.

**Süreklilik iki katmanda yaşar:** (1) **repo living-docs** (proje durumu) + (2) **memory** (session davranışı). Hiçbir kritik bilgi tek session'ın context'inde kalmaz — her karar bir dokümana işlenir ("session sınırını aşsın").

---

## 1. Session tipleri (4 rol)

| Tip | Yazar mı? | Ömür | Sorumluluk | Kendi living-doc'u |
|---|---|---|---|---|
| **① Yönetici** | Kod ❌ / Doküman ✅ | Faz/proje boyu (devrolur) | Süreç sahibi: fazı parçalara böler · kickoff rafine · kapı denetim · kararları sabitler | progress.md · issues.md · open-questions.md |
| **② Geliştirme** | Kod ✅ | Parça-başı (taze) | Bir parçayı (P-numaralı) uçtan uca kodlar: spec→plan→impl→test→review→merge | module-specs/`<parça>`.md |
| **③ Ops / DevOps** | Config/script ✅, ürün-kodu ❌ | **KALICI** (cache — ↓) | Manuel & altyapı: sunucu · panel (Dokploy vb.) · domain/DNS · ortam kurulumu · CI/CD altyapısı · secret yerleşimi · backup/monitoring | **infra-state.md** · docs/ops/`<runbook>`.md |
| **④ Tasarım** | UI-kod ✅ | İş-başı (G-numaralı) | Görsel/UI parçaları; design-system-guardian guardrail; tasarım-track | docs/design/STATUS.md · `<G-iş>`/brief.md |

> **Yönetici "kod yazmaz" ≠ boş durur.** Yönetici dokümanların ve sürecin sahibidir: living-docs günceller, kickoff üretir, kararı sabitler, kapıyı denetler.

### Neden Ops session AYRI — ve "kalıcı"nın gerçek anlamı
Manuel/altyapı işini yönetici veya geliştirme session'ında yapmak: (a) o session'ın context'ini operasyon gürültüsüyle **doldurur**, (b) geliştirme takibini **kirletir**. Bu yüzden AYRI.

"Kalıcı" ise bir **optimizasyondur, tasarım dayanağı değil**: kaynak her zaman **runbook + infra-state**'tir; session context'i yalnızca ısınmış **cache**'tir (dosyaları yeniden okumama konforu). Kalıcı session compaction'dan defalarca geçer ve özet kaybı sinsidir — bu yüzden iki kural:

1. **Anında-runbook:** her önemli neden-kararı (neden bu port, neden bu PAT tipi, hangi env nerede) iş "bitti" sayılmadan runbook'a düşer. Docs'a yazılmamış karar YOK hükmündedir.
2. **Anti-confabulation:** Ops session "neden X?" sorularına kendi hafızasından değil **runbook'tan** cevap verir; runbook'ta yoksa **"kayıtlı değil"** der — uydurmaz.

Bu iki kural sağlandıkça kalıcılık zararsız konfordur; sağlanmıyorsa kalıcı session taze bir session'dan iyi değildir. *(Test: taze bir Ops session runbook'larla aynı işi görebilmeli.)*

---

## 2. İnsan kapıları (kalitenin bel kemiği)

Her geliştirme parçası bu döngüden geçer:

```
SPEC yaz              → 🚦 KAPI 1: spec onayı (kod yok — yanlış yönü en ucuz yerde durdurur)
PLAN (plan mode)      → 🚦 KAPI 2: plan onayı
IMPL                  → agent akar (vibe); parça branch'inde küçük CHECKPOINT commit'leri (§9)
TEST (agent+koştur)   → 🚦 KAPI 3: testleri gör + tarayıcıda/gerçekte dene
KRİTİK REVIEW         → 🚦 KAPI 4: verifier-subagent + yönetici derin okur (§4.3);
                         İNSAN bulgu raporunu okur + kritik diff'lere nokta atışı bakar; ONAY İNSANINDIR
MERGE + docs          → main'e giriş YALNIZ burada → checkpoint → yeni session
```

- **KAPI 4 profili track'e göre değişir:** kod-track (para/auth) = ağır (yukarıdaki tam akış); tasarım-track = hafif (para yok, güvenlik-yüzeyi kadar); ops = "birlikte doğrula" (§6).
- **Faz kapıları** (parça kapılarının üstünde): Faz 0 plan onayı (en büyük) · omurga bitince · her büyük parça bitince.

---

## 3. Faz & parça yapısı

- **Faz 0 = PLANLAMA (kod yok):** yönetici tüm dokümanları üretir → 🚦 en büyük kapı (kararlar burada kilitlenir). Çıktı: living-docs seti + `phase-kickoffs.md` (sonraki fazların taslak komutları).
- **Faz N:** parçalara bölünür — kod parçaları `P1, P2…` · tasarım `G1, G2…` · ops işleri kendi akışında.
- Her parça **taze session**'da başlar (context temiz). Yönetici parçanın kickoff'unu rafine eder.

---

## 4. Yönetici döngüsü (çekirdek)

```
Loop:  çalışan/ops session taslar/rapor verir
   →   YÖNETİCİ zemini REPO'DAN doğrular (git+docs), çelişki taşımaz
   →   YÖNETİCİ sonraki taze-session KICKOFF'unu rafine eder
   →   sen taze session'da çalıştırırsın
```

### 4.1 Zemin-doğrulama kuralı (vazgeçilmez)
Yönetici, kapanan session'ın raporunu **körü körüne ALMAZ.** `git log/status` + ilgili living-docs ile **DOĞRULAR**; rapor ile repo çelişirse çelişkiyi kickoff'a **taşımaz**, kaynağı düzeltir. *(Bu tek kural, "prod adres app. mı apex mi", "port 3000 mü 3100 mü", "artefakt gerçekten yazıldı mı" gibi sessiz sürüklenmeleri yakalar.)*

### 4.2 Kickoff iskeleti (her taze-session prompt'u bu sırayla)
```
rol + konum + parça haritası
→ ÖNCE OKU (kaynak spec = TEK doğruluk; hangi docs)
→ KİLİTLİ kararlar (değiştirme, sorma)
→ çalışma kuralları (ağaç/commit/güvenlik/ortam)
→ iş sırası (alt-adımlar)
→ spec-kapısı mikro-kararları (VARSAYMA; ürün kararı → kullanıcıya sor)
→ KAPI 3/4 somut kabul listeleri
→ döngü + session hijyeni
→ İLK ADIM (kod/artefakt öncesi ne yapılacak)
```

### 4.3 Kapı-onay disiplini (KAPI 4 gibi kritik anlarda)
Yönetici iddiaları koddan doğrular — ama **kendi context'ine dosya okuyarak DEĞİL**: doğrulamayı salt-okur bir **verifier-subagent**'a delege eder (dosyaları okur, gerekirse testi bağımsız koşturur), yöneticiye yalnız **kompakt hüküm + kanıt** döner. Sonra kullanıcıya **"session'a yapıştırılacak onay metni"** bloğu verilir — karar tek yerde, tutarlı ilerler.

- **Neden subagent:** yönetici context'i uzun ömürlü ve değerlidir. Okunan dosyalar kalıntı bırakır → (a) context erken dolar → erken devir; (b) **bayat kod hafızası**: P7'de okunan dosya P9'da değişmiştir, yönetici "kodu bildiğini" sanarak eski zemin üstünden hüküm verir. Zemin-doğrulamanın (§4.1) doğal uzantısı: **yöneticinin kendi kod hafızası da güvenilmez kaynaktır** — her hüküm taze okumayla verilir. *(Bonus: aynı güçlü model temiz context'le, kendi kalıntısı arasından okuduğundan daha isabetli yakalar.)*
- **Sınır (kısıtlama değil):** delegasyon yalnız **doğrulama okumaları** içindir — girdisi baştan tanımlı, çıktısı tek rapor, ortasında ürün kararı olmayan işler. **Geliştirme işi subagent'a taşınmaz:** interaktif dev session'ları (kullanıcının izlediği, dikte edebildiği) geliştirme birimi olarak kalır; bulgudan çıkan düzeltmeler yine dev session'lara gider.

---

## 5. Ops / DevOps session (manuel & altyapı)

**Kapsam:** sunucu provizyon · panel kurulumu (Dokploy/Coolify/…) · domain & DNS · ortam açma (staging/prod) · CI/CD altyapısı · registry/secret yerleşimi · backup + monitoring kurulumu · her "kod-dışı, elle yapılan" iş.

**Kalıcılık:** bir optimizasyon — kaynak runbook'tur, context cache'tir; **anında-runbook + anti-confabulation** kuralları geçerli (§1). Context dolunca **infra-state + runbook'larla devrolur** (aynı hijyen).

**Living-doc'ları:**
- `infra-state.md` — **pano**: kurulu altyapının ŞU ANKİ gerçeği (sunucu, ortamlar, domainler, servisler, portlar, "hangi secret nerede"). state doküman = EDIT, küçük kalır. Yönetici/geliştirme **okur**, Ops **yazar**.
- `docs/ops/<runbook>.md` — adım-adım kalıcı talimatlar + **neden-kararları** (ör. "port 23 çünkü…", "classic PAT çünkü fine-grained X'te patladı").

**Senkron (living-docs üzerinden):**
```
Geliştirme/Yönetici  → NEEDS-FROM-USER.md ("şu altyapı/ortam/secret gerekli") → DURAKSA
Ops session          → kurar + infra-state.md + runbook günceller
Herkes               → infra-state.md'yi okuyarak gerçeği bilir (varsaymaz)
```

**Güvenlik:** secret koda/repo'ya asla; `.env`/panel'de. guard-env hook Ops session'da da geçerli.

---

## 6. El-ele protokol (artefakt ↔ kurulum köprüsü)

Deploy/infra işi tek session'ın tek başına "bitirdim" diyebileceği bir şey değildir:
```
② Geliştirme session:  ARTEFAKT yazar (Dockerfile · CI workflow · deploy config) + LOKAL doğrular
③ Ops session (sen):   artefaktı altyapıya UYGULAR (panel/creds/deploy) + infra-state günceller
Birlikte:              gerçek ortamda DOĞRULAR (smoke/restore-test); "deploy edildi"yi AI tek başına diyemez
```
Yönetici bu köprüyü koordine eder (hangi artefakt hazır, hangi ops adımı bekliyor).

---

## 7. Living-docs sistemi (süreç bununla yaşar)

**İki sınıf:**
- **STATE** (progress · issues · architecture · data-model · infra-state · specs) → **EDIT**, küçük kalır, "şu anki gerçek".
- **ARŞİV** (docs/archive/*) → **APPEND**, büyür, **asla otomatik yüklenmez** (yalnız talep üzerine).

**Manifesto:**

| Doküman | Amaç | Yaşam | Yüklenme |
|---|---|---|---|
| `CLAUDE.md` | konvansiyon + doküman haritası + kritik kurallar (LEAN) | Edit | otomatik, her session |
| `progress.md` | durum panosu (log DEĞİL) | Edit | session başı |
| `issues.md` | yalnız AÇIK maddeler | Edit (çözülen silinir) | session başı |
| `architecture.md` · `data-model.md` | stack + sistem + şema | Edit | ilgili işte |
| `infra-state.md` | kurulu altyapı gerçeği | Edit | ops/deploy işinde |
| `module-specs/*` | parça başına spec | Edit (kilitlenince stabil) | o parçada |
| `open-questions.md` · `NEEDS-FROM-USER.md` | açık kararlar · gereken key/hesap | Edit | ihtiyaç çıkınca |
| `phase-kickoffs.md` | sonraki faz taslak komutları | Edit | faz geçişinde |
| `workflow.md` / bu playbook | metodoloji (başında: "← playbook vN") | Edit (nadir) | referans |
| `docs/archive/*` · `docs/ops/*` · `docs/design/*` | geçmiş · runbook · tasarım | Append | **talep üzerine** |

**Rotasyon:** issues çözülünce → changelog tek satır · progress'te tamamlanan faz tek satıra iner · her faz sonu `phase-N-summary.md` · **bloat-budget** ~150–200 satır → proaktif buda + bildir.

**Altın kural:** yapısal karar/değişiklik **inline söyleyip geçilmez** — ilgili spec/issues/architecture'a **işlenir** (session sınırını aşsın). Sadece o anki ekranı etkiliyorsa → söyle; bir dokümandaki kararı değiştiriyorsa → dokümanı güncellet.

---

## 8. NEEDS · open-questions · karar-zamanlaması

- **NEEDS-FROM-USER:** AI bir key/hesap/manuel-iş'e ihtiyaç duyunca yazar + **DURAKSA**; sen sağlayınca "karşılandı" işaretlenir.
- **open-questions:** yönetici karar veremediğinde. **VARSAYMA →** buraya. Ürün kararları kullanıcıya, teknik kararları gerekçeyle yönetici.
- **Karar-zamanlaması (bağımlılık):** bazı kararlar **ölçüme/önceki adıma bağlıdır** — "önce ölç, sonra karar ver, **sıra zorunlu**". Erken karar = zarar/borç. Bağımlı kararlar open-questions'ta **sıralı bağlı-çift** olarak izlenir.

---

## 9. Çalışma anlaşmaları (kalıcı davranış sözleşmesi)

Memory + CLAUDE.md'de tutulan, session'lar-arası tutarlılığı sağlayan kurallar. Projeye göre uyarlanır; tipik çekirdek:

- **Commit disiplini (branch + checkpoint):** parça kendi branch'inde akar (`wip/P-N`, `feat/…` — main'de doğrudan iş YOK). Küçük **checkpoint commit'leri serbest ve teşviklidir** — kayıp penceresi (crash · yanlış tool çağrısı · kas-hafızası refleksi) hiç açılmaz. **Değişmez kural: main'e KAPI 4'süz hiçbir şey girmez.** Review diff'i tek komut: `git diff main...<branch>`. İstenirse KAPI 4 sonrası history squash/curate edilir (yalnız o branch'te, önceden izinli).
- **Git güvenliği:** uncommitted iş varken **`git restore/stash/clean/checkout --` ASLA**; yıkıcı işlem (force/reset/branch-sil) için önce sor. *(Checkpoint disiplini bu riski zaten küçültür.)*
- **Hook > talimat:** enforce edilebilen hijyen kuralı modele talimatla değil **harness hook'uyla** uygulanır (guard-env = secret · PreCompact = devir-durumu). Talimat unutulur/atlanır; hook unutmaz.
- **Secret hijyeni:** `.env` okunmaz/yazdırılmaz (**PreToolUse guard hook** enforce eder); koda gömülmez.
- **Test:** dış-servis/LLM çağrıları **mock-first** (deterministik + ücretsiz); gerçek çağrı yalnız kontrollü ölçüm script'i.
- **Ortam kuralları:** projeye özel footgun'lar (portlar, sürüm pinleri, "şu komut şu path'te") — spec/memory'de.

---

## 10. Session hijyeni & devir

- **Tetik = kalite + doğal sınır, sabit token sayısı DEĞİL.** Taze session, compaction geçirmiş session'dan daha kalitelidir — devir bunun için yapılır. Context bütçesi modele göre değişir (200k vs 1M); **teknik kapasite varken tutarlı bir birimi aynı session'da BİTİRMEK serbesttir** — yarım işi devretmek çoğu zaman daha pahalıdır. Doğal sınırda öneri: *"Bu birim bitti / kalite düşmeye başladı. Yeni session öneriyorum; docs güncel. Onaylıyor musun?"*
- **Emniyet ağı (zorlayıcı değil):** model kendi kalan context'ini içgözlemle BİLEMEZ — "agent doluluğu fark etsin" güvenilmezdir. Bunun yerine **PreCompact hook**: compaction tetiklenmeden önce koşar → devir-durumunun living-docs'a yazılmasını güvenceler + kullanıcıya haber verir. **Devir dayatmaz** — compaction sonrası aynı session'da devam edilebilir; sadece kalıcı durum önceden yazılmış olur. *(İsteğe bağlı: statusline'da context% — insan takibini kolaylaştırır.)*
- **Devir kanalları:** çalışan/ops → **durum raporu** + güncel living-docs. Yönetici → **devir-prompt** + memory + living-docs (yeni yönetici otomatik yükler).
- İdeal granülerlik: parça-başına bir session; büyük parçada alt-adım başına.

---

## 11. Memory (davranış kalıcılığı)

- **`manager-session-pattern`** (memory): yönetici rolünün çalışma şekli — kickoff iskeleti, zemin-doğrulama, kapı-onay disiplini, çalışma anlaşmaları, devir kuralı. Yeni yönetici session **otomatik yükler** → akış kesintisiz.
- Memory = repo'nun kaydetMEDİĞİ **davranış/tercih** bilgisi. Proje durumu repo'da; davranış memory'de. İkisi çakışmaz.

---

## 12. `.claude/` yapısı (baştan solid)

```
.claude/
├─ settings.json       # permissions: allow (güvenli read/build/test) · ask (commit/push/deploy) ·
│                      #   deny (.env oku/yaz, rm -rf, force-push, curl…)
├─ hooks/
│  ├─ guard-env.sh     # PreToolUse: secret dosya erişimini fiziksel engelle
│  └─ pre-compact.sh   # PreCompact: compaction öncesi devir-durumu → living-docs + bildirim (§10)
├─ agents/             # spec-writer · test-writer · code-reviewer/verifier (KAPI 4, §4.3) ·
│                      #   design-system-guardian · <domain>-expert (opsiyonel)
└─ commands/           # /spec · /plan · /checkpoint · /review · /new-part
```

---

## 13. Track'ler (paralel, farklı kapı profili)

| Track | Numara | Ağır kapı | Not |
|---|---|---|---|
| **Kod** | P1, P2… | KAPI 4 (para/auth) | branch + checkpoint commit (§9); main'e KAPI 4'süz giriş YOK |
| **Tasarım** | G1, G2… | KAPI 3 (görsel/tarayıcı) | guardian guardrail; docs/design/ + STATUS |
| **Ops** | (ad-hoc) | "birlikte doğrula" | kalıcı(cache) session; infra-state + runbook |

---

## 14. Base-project iskeleti (kopyala-kullan)

```
<repo>/
├─ STARTGUIDE.md          # insan: manuel setup + Faz 0 kickoff komutu
├─ workflow.md            # bu playbook'un projeye inmiş hâli (başına: "← playbook vN")
├─ CLAUDE.md              # LEAN: doküman haritası + kritik kurallar (otomatik yüklenir)
├─ progress.md · issues.md            # state panoları (boş başlar; session başı yüklenir)
├─ open-questions.md · NEEDS-FROM-USER.md · .env.example
├─ PRD.md · architecture.md · data-model.md      # plan-track (Faz 0'da dolar)
├─ infra-state.md         # Ops session panosu (altyapı gerçeği)
├─ module-specs/_TEMPLATE.md · phase-kickoffs.md
├─ docs/
│  ├─ archive/{changelog.md, phase-N-summary.md}
│  ├─ ops/<runbook>.md                 # Ops session runbook'ları + neden-kararları
│  └─ design/{STATUS.md, design-system-notes.md, <G-iş>/brief.md}   # opsiyonel
└─ .claude/{settings.json, hooks/{guard-env.sh, pre-compact.sh}, agents/*, commands/*}
+ memory/manager-session-pattern.md    # yönetici davranışı (devirde otomatik)
```

**Genelleştirme:** projeye özel her şeyi (domain, stack, iş kuralları) Faz 0'da doldur. **Domain-bağımsız çekirdek:** 4 session tipi · insan kapıları · track'ler · living-docs lifecycle · el-ele · kickoff iskeleti · çalışma anlaşmaları · memory.

---

## 15. Playbook'un kendi yaşam döngüsü (meta-öğrenme)

Playbook da koddur — **versiyonlu süreç-kodu** ("prompts/ koddur" ile aynı muamele). Living-docs projenin *kendisi* hakkında öğrenir; bu bölüm **metodolojinin** öğrenmesini kurar. Kanal kurulmazsa fork-drift kaçınılmaz: her projenin workflow.md'si başka yöne sürüklenir, dersler base'e geri akmaz, sonraki proje eski şablondan başlar.

- **Kanonik ev:** bu repo. Tek doğruluk buradadır; scratchpad/proje kopyaları türevdir.
- **Versiyon + changelog:** her anlamlı değişiklik sürüm + CHANGELOG satırı alır. Proje kopyasının başına **"← playbook vN"** yazılır → hangi projenin hangi sürümden türediği görünür.
- **Faz-retro (yönetici sorar, ~5 dk, faz kapanışında):**
  1. Hangi kapı **gerçek** bir şey yakaladı?
  2. Hangi kapıyı **okumadan/özetten** onayladın?
  3. Hangi kural **ihlal/bypass** edildi — ve neden?
  Cevaplar etiketlenir: **PROJE** (o projenin workflow/spec'ine işlenir) · **PLAYBOOK** (base'e changelog adayı).
- **Kapı kalibrasyonu:** aynı kapı üst üste "okumadan onayladım" alıyorsa o track'te **hafifletilir**; gerçek yakalayan kapı ağır kalır. Kapılar yalnız eklenmez, **kalibre edilir** — ölçülmeyen sistemde onay teatralleşir (kapı yorgunluğu).
- **Geri akış:** PLAYBOOK etiketli dersler buraya işlenir + versiyon artar; sonraki proje güncel sürümü kopyalar.

---

## 16. Özet akış

```
Faz 0 (plan)──[🚦ONAY]──> Faz N parçalara böl
     │
     ├─ ② Geliştirme (P): spec[🚦]→plan[🚦]→impl(checkpoint'ler)→test[🚦]→review[🚦]→merge→checkpoint
     ├─ ④ Tasarım (G):    docs/design + guardian; KAPI3 görsel ağır
     └─ ③ Ops:            infra-state + runbook; el-ele (artefakt↔kurulum)
     │
  ① YÖNETİCİ her track'i koordine eder: rapor→DOĞRULA(verifier-subagent)→kickoff rafine→kapı denetim
     │
  doğal sınırda → [yeni session önerisi 🚦] → devir (docs + memory + prompt) → taze session
     │              (PreCompact emniyet ağı arkada — §10)
     │
  faz kapanışı → RETRO (3 soru) → PROJE dersleri workflow'a · PLAYBOOK dersleri base'e (§15)
```

> **Üç hedefin nasıl korunduğu:** TUTARLILIK = kararlar living-doc'a işlenir + zemin-doğrulama (yöneticinin kendi hafızası dahil hiçbir kaynağa körü körüne güven yok) · SÜRDÜRÜLEBİLİRLİK = state/arşiv ayrımı + bloat-budget + devir kanalları + faz-retro/geri-akış · BAĞLAM KORUNMASI = session tipleri ayrık context + taze-session tercihi + verifier-subagent (yönetici context'i temiz) + PreCompact emniyet ağı.
