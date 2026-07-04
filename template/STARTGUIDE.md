# STARTGUIDE — yeni proje kurulumu (insan için)

> Kaynak: vibe-playbook v3 `template/`. Toplam süre ~10 dk.
> Süreç kuralları: [workflow.md](workflow.md) · gerekçeler: kanonik playbook reposu.

## 1. Kopyala (2 dk)

```bash
cp -R <vibe-playbook>/template/. <yeni-proje>/
cd <yeni-proje>
chmod +x .claude/hooks/*.sh
git init && git add -A && git commit -m "iskelet: playbook v3 template"
```

## 2. Uyarla (5 dk)

- **CLAUDE.md:** proje adı + tek cümle; Test/Lint/Typecheck komutları (stack netleşince doldur).
- **.claude/settings.json:** `allow` listesindeki `npm` örneklerini kendi stack'ine göre değiştir.
- **Opsiyoneller:**
  - Tasarım track'i kullanılacaksa: **Claude Design MCP'sini bağla** — tasarım karar vericisi Claude Design'dır ve bağlantı için Claude Code **terminalden (CLI)** kullanılmalıdır (**zorunlu**; G-işlerini desktop/IDE'den değil terminalden yürüt). Kullanılmayacaksa `docs/design/` silinebilir.
  - **PreCompact emniyet ağı** istersen `settings.json` → `"hooks"` içine ekle:

```json
"PreCompact": [
  { "hooks": [ { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-compact.sh" } ] }
]
```

## 3. Faz 0'ı başlat

Taze bir Claude session aç ve şunu yapıştır:

```
Sen bu projenin ① YÖNETİCİ session'ısın. Rol ve kurallar: workflow.md + CLAUDE.md (otomatik yüklendi).

İLK İŞ: memory-seed/manager-session-pattern.md dosyasını oku ve memory'ne kaydet
(sonraki yönetici session'lar aynı sözleşmeyle çalışsın).

FAZ 0 = PLANLAMA — kod yazılmaz. İş sırası:
1. Benimle soru-cevap: problem/kapsam netleşir → PRD.md dolar
2. Teknik kararlar (gerekçeli öneri + onayım) → architecture.md + data-model.md
3. İş parçalara bölünür (P kod / G tasarım) → progress.md tablosu + module-specs iskeletleri
4. phase-kickoffs.md: sonraki fazların taslak kickoff'ları
5. open-questions.md + NEEDS-FROM-USER.md: açık kalanlar
   (VARSAYMA — ürün kararlarını bana sor)

ÇIKIŞ 🚦 FAZ 0 KAPISI (en büyük kapı): tüm docs'u onayıma sun; kararlar burada kilitlenir.
İLK ADIM: PRD için bana soracağın soruları çıkar — başka hiçbir şey yapmadan.
```

## 4. Günlük akış (özet)

- **Yeni parça:** yönetici session'da `/new-part P-N` → çıkan kickoff bloğunu **taze** session'a yapıştır.
- **Kapılar:** K1/K2 onayı sende · `/gate3` kanıtı + gerçekte dene (K3) · `/review` + onay işareti (K4).
- **K4 onay işareti:** onay verince session `echo <branch> > .claude/.gate4-ok` yazar → merge → işaret silinir. main-guard hook, işaretsiz merge'i zaten bloklar.
- **Ops işi:** ayrı Ops session; senkron `NEEDS-FROM-USER.md` + `infra-state.md` üzerinden.
- **Faz kapanışı:** retro — 3 soru (workflow.md).
