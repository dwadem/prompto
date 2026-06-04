# Google Play store listing — Prompto

Everything you must prepare in the Play Console before Production. Items marked
**[required]** block submission. Draft copy below is a starting point — edit freely.

## App details
- **App name [required]:** `Prompto` (max 30 chars)
- **Short description [required]** (max 80 chars):
  > Learn to prompt AI well. Bite-sized lessons with a live, AI-graded Prompt Lab.
- **Full description [required]** (max 4000 chars):
  > Prompto is the fun, honest way to master working with AI. Like a language app
  > for the new "language" of prompting, it turns prompt engineering into a short
  > daily habit — 2–5 minute lessons that build a real, useful skill.
  >
  > What makes Prompto different is the **Prompt Lab**: you write a real prompt and
  > get instant, rubric-based feedback — clarity, context, format, constraints —
  > plus the model's output and concrete before/after tips. You practice, not just
  > read.
  >
  > • Skill tree from basics to advanced (context, few-shot, structure, and more)
  > • Live, AI-style grading that rewards quality, not just clicking
  > • Streaks, XP and gentle daily goals — no "lives", no dark patterns
  > • A library of proven prompts with explanations of *why* they work
  > • Light & dark themes
  >
  > The basics are free, forever. Learn something today.
- **App icon [required]:** 512×512 PNG (32-bit). Generated from
  `assets/icon/icon.png` via `flutter_launcher_icons`; export a 512 version for the
  listing.

## Graphics
- **Feature graphic [required]:** 1024×500 PNG/JPG (no alpha).
- **Phone screenshots [required]:** 2–8, 16:9 or 9:16, min 320px side. Suggested:
  skill tree, a Prompt Lab grade, lesson complete, profile/stats, dark mode.
- *(Optional)* 7" / 10" tablet screenshots, promo video (YouTube URL).

## Policy & compliance forms
- **Privacy policy URL [required]:** host `docs/PRIVACY_POLICY.md` somewhere public
  (GitHub Pages, your site) and paste the URL.
- **Data safety [required]:** for the current prototype, declare **no data collected
  and no data shared** (all state is on-device). Revisit when you add accounts /
  the real grading API (then you collect at least usage + the prompts sent for
  grading).
- **Content rating [required]:** complete the IARC questionnaire (Education category;
  expected rating: Everyone).
- **Target audience & content [required]:** select age groups (recommend 13+ /
  not primarily child-directed).
- **Ads [required]:** declare whether the app contains ads (prototype: No).
- **Category:** Education. **Tags:** add relevant ones (education, productivity).
- **Contact details [required]:** support email; website/phone optional.

## Pricing & distribution
- Free app (in-app purchases later for Pro — declare when added).
- Select countries/regions; confirm content guidelines & US export laws.

## Release
1. **Internal testing** first: upload the `.aab`, add tester emails, share the opt-in
   link, validate on real devices.
2. Promote to **Closed** (larger group) → **Open** (public beta) → **Production**.
3. Production submission triggers Google review (can take hours to days).

## Versioning reminder
Each upload needs a higher `versionCode` — bump `version:` in `pubspec.yaml`
(the `+N` after `0.1.0` is the build number = `versionCode`).
