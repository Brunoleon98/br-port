# Prototyping a Premium Mobile Management Game with AI: A Practical Guide

**TL;DR**
- **Build the prototype to answer one question — "Is the core loop fun?" — not to ship a game.** For a premium mobile management/tycoon title, that means proving 30–90 seconds of "decide → invest → numbers move → new pressure → decide again" feels good before you touch art, monetization, tutorial, or content volume.
- **Use a staged technical approach: start in a single-file web prototype (React/HTML+JS in a Claude artifact or similar) for 1–3 weeks of core-loop iteration; then port to Godot 4 (preferred for a small/2D management game) or Unity once you need true mobile/touch validation.** Web-first lets the AI iterate fastest; engine-second proves the game survives a thumb and a 6.1" screen.
- **Treat the AI like a junior engineer with no taste: give it a written GDD as the single source of truth, force it to validate plans before coding, keep scope minimal, and throw away prototypes that don't earn their keep.** The successful premium mobile mgmt games — Mini Metro, Pocket City, Plague Inc., Mini Motorways — were all prototyped fast and cheaply by tiny teams who validated one idea before scaling.

---

## Key Findings

1. **Premium mobile management is a small but real market.** It's dominated by a handful of studios who built reputations for craft, not by F2P giants. Dinosaur Polo Club (Mini Metro/Mini Motorways), Codebrew Games (Pocket City), Ndemic Creations (Plague Inc.), Two Point Studios (Two Point Hospital mobile via subscription), and Kairosoft (Game Dev Story) define the space. Apple Arcade is now the most reliable distribution route for the model.
2. **Their prototypes were small, fast, and answered one question.** Mini Metro's prototype "Mind the Gap" was built in Unity (using Matt Rix's Futile framework) during the 72-hour Ludum Dare 26 Jam in April 2013 on the theme "Minimalism." Co-founder Robert Curry says: "We verbally designed the game in about 15 minutes, coded it up over the weekend, and that formed about 90% of what Mini Metro is today." [GameFeatured](https://gamefeatured.com/interviews/dinosaur-polo-club-mini-metro) Plague Inc. shipped on a sub-$5,000 budget and recouped costs on day one. [Modojo](https://modojo.com/article/4998/plague_inc_interview_with_ndemic_creations_james_vaughan) Pocket City was a solo project that Bobby Li shipped using web tech (TypeScript + Phaser + Cordova) — billed in his own words as "Or, how I made a mobile game as a web developer." [Pocket City Blog](https://blog.pocketcitygame.com/tag/game-development/) [Pocket City Blog](https://blog.pocketcitygame.com/)
3. **Core loop validation beats feature count.** Across every postmortem and design analysis, the same pattern repeats: prove that the moment-to-moment decision feels good, then layer juice, content, and depth. Tom Francis (Gunpoint, Heat Signature) puts it plainly at GDC: "Until you make something you don't know anything. You have to make things by prototyping them." [Game Developer](https://www.gamedeveloper.com/design/scope-creep-a-useful-treacherous-tool-says-i-heat-signature-i-dev)
4. **For AI-assisted prototyping, single-file output is the sweet spot.** Claude Artifacts, ChatGPT Canvas, and equivalent tools work best when the entire prototype is one file the AI can hold in its head. The instant you have multi-file architecture, the AI's tendency to invent, drift, and lose context multiplies.
5. **Mobile-feel cannot be validated in a browser on desktop.** Thumb zones, touch target size (44 pt minimum per Apple HIG / 48 dp per Google Material Design), one-handed grip, screen size, and battery/thermals are real constraints. A web prototype proves the loop; an engine build on a real device proves the game.

---

## PART A — Game Prototyping Best Practices (Engine-Agnostic)

### A1. What a prototype IS and IS NOT

A prototype **is**:
- A throwaway, ugly artifact whose only job is to **answer the riskiest design question** about your game.
- The fastest possible way to feel whether the core loop is fun on a real device or screen.
- A way to surface unknown unknowns — interactions, pacing problems, and "wait, that's not fun" moments that only emerge in play.

A prototype **is NOT**:
- A small version of the final game.
- A demo to show publishers (that's a vertical slice — a different artifact, built later, that proves you *can* make the game rather than *should*).
- A place for final art, sound, story, tutorial, settings menus, save systems, monetization, or analytics.
- A codebase you'll ship. If you find yourself refactoring your prototype, you've already failed the prototype's purpose.

Rami Ismail draws the line: "The Prototypes are to help you figure out whether you **should** make a game, and the Vertical Slice is to help you figure out whether you **can** make it." [Ramiismail](https://ltpf.ramiismail.com/prototypes-and-vertical-slice/) Confusing the two is the most common indie mistake.

### A2. Define the ONE core design question

Before opening an editor or AI tool, write **one sentence** on a sticky note:

> "This prototype answers: ____________________________"

For a management/tycoon game, valid questions look like:
- "Is the loop of [place building → wait for output → reinvest] satisfying at 30-second cadence?"
- "Does balancing [staff happiness vs. profit] create interesting weekly decisions or just busywork?"
- "When the numbers go up, does it feel earned or automatic?"
- "Can a player understand the economy in 60 seconds of play with no tutorial?"

**Invalid** prototype questions (these are scope, not questions):
- "What features should the game have?"
- "How big is the city / hospital / studio?"
- "What art style works?"
- "How do we monetize?"

Rule: **if you can't write the question, you're not ready to prototype.** Spend another hour on the GDD.

### A3. Paper, greybox, vertical slice — when each applies to management games

| Type | What it is | When to use it for a mgmt game | What you'll learn |
|---|---|---|---|
| **Paper prototype** | Cards, dice, spreadsheets, hand-drawn screens | When testing economy formulas, building costs, decision trees, win/loss conditions | Whether the math creates interesting decisions before you code anything |
| **Spreadsheet sim** | Excel/Google Sheets modeling income, costs, growth curves over turns | Almost always — management games ARE spreadsheets with skin. Mandatory before code. | Whether progression pacing works (e.g., does player double money every ~3 minutes?) |
| **Greybox / digital prototype** | Playable code with placeholder rectangles, default fonts, no art | After spreadsheet is plausible — to test feel, click cadence, feedback loops | Whether the loop is fun in motion, not just on paper |
| **Vertical slice** | Polished slice with final art/audio for ~5 min of play | AFTER prototype proves fun. Used to pitch publishers/Apple Arcade. | Whether you can produce the game at shipping quality |

For a management game, **always** do the spreadsheet sim. The economy IS the gameplay; numbers that don't work on paper won't work on screen. James Vaughan modeled Plague Inc.'s disease propagation algorithms in Excel before any code was written: "I modeled them all in Excel but the only real way to see how they feel is to play the game and that took time." [PocketGamer](https://www.pocketgamer.biz/plague-vs-pandemic-qanda-with-james-vaughan-founder-of-ndemic-studios/)

### A4. Core loop, juice, and "numbers going up" for management games

The core loop of every management game is a variant of:

> **observe state → make a decision → commit a resource → wait/simulate → see consequence → observe new state**

For mobile, that full cycle should resolve in **5–30 seconds at the moment-to-moment level** (placing a building, hiring staff, drawing a road) and roll up into **2–10 minute macro decisions** (expanding a district, opening a new map). A session should give a player ~3–5 satisfying macro cycles in 5–10 minutes of play.

**What "juice" means in a management game** (different from action games):
- **Number popups with easing/tween** on every income tick. Tiny +$25 floaters teach the player which buildings earn money.
- **Counter rollups** (not snap-to-value) on the cash/score display. "Numbers going up" must literally animate going up.
- **Audio confirmation on commits** — a satisfying click/chime when a building is placed and money is spent. Silence = limbo. [Game Developer](https://www.gamedeveloper.com/design/squeezing-more-juice-out-of-your-game-design-)
- **Progress bars that fill smoothly**, not jump in steps. Construction, research, training — anything timed gets a visible bar.
- **Camera/scroll inertia** and a slight zoom-out when something big completes (a building unlocks, a milestone hits).
- **Subtle pulse/glow** on the next recommended action so the player always knows what to tap.

What "juice" does NOT mean here: screen shake on every click, particle storms, intrusive popups. Two Point Hospital and Mini Motorways are the reference — restrained, readable, and the satisfaction comes from systems clicking, not from explosions. [Wayline](https://www.wayline.io/blog/the-seductive-squeeze-when-juice-in-game-development-becomes-a-crutch)

**Feedback loops to prototype explicitly:**
- **Positive loop** (rewards): income → bigger building → more income. Must exist, but must be capped or it trivializes the game.
- **Negative loop** (pressure): more residents → more demand for services → more cost. Without this the game has no tension.
- **Decision cadence**: the player must have a meaningful choice every 5–30 seconds, not be a passive observer of a simulation.

If your prototype has a positive loop but no negative loop, the game will be boring within 10 minutes. Test for this explicitly.

### A5. Common beginner mistakes (and antidotes)

| Mistake | Why it kills the prototype | Antidote |
|---|---|---|
| **Building features instead of validating fun** | You end up with a system that works but isn't enjoyable | Write the ONE question on a sticky note; reject any work that doesn't answer it |
| **Polishing too early** | Art and audio camouflage broken design; you can't tell if it's fun or just pretty | Use rectangles and Comic Sans on purpose. If it's not fun ugly, it won't be fun pretty. |
| **Scope creep into "wouldn't it be cool if…"** | Project balloons; never ships | Hard timebox (1–3 weeks). Maintain a "v2 list" — write the idea down and DO NOT build it. |
| **No kill criteria** | You keep iterating on a dead idea because of sunk cost | Define kill criteria before starting (see A6) |
| **Building systems before validating fun** | Months on save-load, settings, achievements before anyone plays | Hardcode every state. Use `localStorage` or a single global object. No save system. |
| **Skipping playtesting** | You're the worst judge of your own game | Test with one human (not yourself) every 3–5 days. Watch silently. |
| **Treating prototype code as production code** | You refactor instead of throwing away | Name the folder `prototype-01/`. Plan to delete it. |

Tom Francis on "good" scope creep: when prototyping reveals a better idea than your plan, follow the better idea. When it just adds features, cut them. The discipline is knowing the difference.

### A6. Kill criteria and "definition of done"

Before you start prototyping, write down both:

**"Done" criteria (the prototype answered YES):**
- Three playtesters independently say "one more turn" / ask to keep playing after 10 minutes.
- You yourself want to play it instead of working on it (the strongest signal).
- The core decision feels meaningful at least 70% of the time (not auto-pilot).
- The session has a natural beat — "I just finished X, that felt good, what's next?"

**"Kill" criteria (the prototype answered NO):**
- After 3 iterations of major rework, the core loop is still boring.
- Playtesters can't articulate what they're trying to do after 5 minutes.
- The most interesting decision is "should I keep playing?"
- You're dreading opening the project.

If you hit a kill criterion: write a one-page postmortem on what you learned and either pivot the core question or shelve the idea. Do not pour another month in hoping it gets fun.

### A7. Playtesting a management prototype with minimal players

You don't need 50 testers. You need 3–5 humans who are not you, ideally including at least one who plays the genre and one who doesn't.

**Protocol:**
1. **Sit them down with the prototype, say nothing**, point at the screen. (No tutorial, no explanation.) Watch for the first 60 seconds — that's where ~80% of UX failures surface.
2. **Ask them to think aloud.** What are they trying to do? What do they think the buttons mean?
3. **Time their first meaningful decision.** If it takes >60 seconds to make a non-trivial choice, the loop is buried.
4. **Stop them at 5, 10, and 15 minutes.** Ask: "Do you want to keep playing? Why?"
5. **Take notes, not feedback.** Players are bad at design ("you should add X"); they are excellent at reporting their experience ("I was confused here").

Useful management-game-specific questions:
- "What were you optimizing for?"
- "Did you understand why your income went up/down?"
- "What did you wish you could do that you couldn't?"

Tools: PlaytestCloud (mobile-specific), [Boston Institute of Analytics](https://bostoninstituteofanalytics.org/blog/the-importance-of-playtesting-how-to-get-valuable-feedback-on-your-game/) or just hand them your phone and watch.

### A8. Premium mobile management — what makes it succeed

**Session length & cadence (the premium model):**
- Per objc.io's "Designing Elegant Mobile Games," citing third-party studies: "Most studies peg the average iOS game session length at somewhere between one and two minutes." [objc.io](https://www.objc.io/issues/18-games/designing-elegant-mobile-games/) Plan for "easy in, easy out" — a player should be able to make one satisfying decision in 60 seconds and quit without loss.
- BUT — premium players will also sit down for 30–60 minute sessions. Premium games avoid the F2P "energy/timer" forced-exit pattern. The exit decision belongs to the player.
- Design for **resumability**: dropping the app and returning 3 hours later should be lossless.

**Touch/mobile UX constraints (non-negotiable for prototype-to-mobile transition):**
- Tap targets ≥44 pt (Apple HIG) / 48 dp (Google Material Design). NN/g research adds: minimum 1cm × 1cm based on Parhi, Karlson & Bederson. [Nielsen Norman Group](https://www.nngroup.com/articles/touch-target-size/) Period.
- Primary actions in the bottom thumb-zone; destructive/rare actions top corners. Steven Hoober's research found that ~49% of users hold a phone one-handed and 75% of mobile interactions are thumb-driven. [Parachutedesign](https://parachutedesign.ca/blog/thumb-zone-ux/)
- One-handed portrait usable for at least the core loop. Pocket City, Game Dev Story, Plague Inc. all pass this test.
- No hover states. Every action must be tap or drag.
- Account for thumb occlusion — the bottom 40% of the screen will be covered when the player taps.

**What separates successful premium from F2P management:**
| Dimension | Premium (succeeds) | F2P (different game) |
|---|---|---|
| Pricing | $1.99–$6.99 one-time, or Apple Arcade subscription | Free + IAP + ads |
| Time pressure | Player-controlled pacing | Energy timers / wait gates |
| Progression | Earned through play | Accelerated via IAP |
| UI density | High — respects player intelligence | Low — funnels to spend |
| Session purpose | Pure play | Engagement metric driving |
| Marketing hook | Craft, reviews, word of mouth | Performance ads |

The premium player is paying for **respect** — no ads, no nags, no FOMO timers. Your prototype must demonstrate that the loop is intrinsically rewarding without extrinsic carrots.

**Reference titles and what their prototypes focused on:**

- **Mini Metro / Mini Motorways (Dinosaur Polo Club):** The original prototype "Mind the Gap" was built in Unity using Matt Rix's Futile framework during the 72-hour Ludum Dare 26 Jam (April 26–29, 2013) on the theme "Minimalism." Co-founder Robert Curry: "We verbally designed the game in about 15 minutes, coded it up over the weekend, and that formed about 90% of what Mini Metro is today." Peter Curry's Gamasutra postmortem adds: "We chose to use Unity for our Ludum Dare entry because of the high uptake of the Unity Web Player… we wanted as many people to play our game as possible, and reasoned that a game playable in the browser would get more attention than a downloadable executable." [Game Developer](https://www.gamedeveloper.com/audio/postmortem-dinosaur-polo-club-s-i-mini-metro-i-) The prototype validated **one question**: is drawing lines between dots under increasing pressure fun? Everything else (maps, audio, daily challenges) came later. ~16 months from prototype to Steam Early Access; [GameFeatured](https://gamefeatured.com/interviews/dinosaur-polo-club-mini-metro) ~3.5 years to mobile launch (Oct 18, 2016). [Wikipedia](https://en.wikipedia.org/wiki/Mini_Metro_(video_game))

- **Pocket City (Codebrew Games / Bobby Li):** Solo developer; the original was built in TypeScript + Phaser + Apache Cordova (HTML5 wrapped for iOS/Android). His blog post title is literally "Or, how I made a mobile game as a web developer." Launched July 31, 2018 at $4.99 (per TouchArcade's review: "Right off the bat your $4.99 will get you the full Pocket City experience"), [TouchArcade](https://toucharcade.com/2018/07/31/pocket-city-review/) [Indie Hive](https://indie-hive.com/pocket-city/) no IAP, no ads. The prototype validated that touch-based zoning and tap-to-place could deliver SimCity-style depth on a phone. Pocket City 2 (released April 8, 2023) [Pocket City Blog](https://blog.pocketcitygame.com/) was rebuilt from scratch in Unity for 3D — Bobby Li explicitly framed this as a tech reset, not an iteration: "I am using Unity this time instead of HTML5." [Pocket City Blog](https://blog.pocketcitygame.com/tag/game-development/) [Pocket City Blog](https://blog.pocketcitygame.com/)

- **Plague Inc. (Ndemic Creations / James Vaughan):** Vaughan was non-technical; hired a freelance programmer (Mario), artist (Sofia), and sound designer (Joshua). Total budget under $5,000 — Vaughan in his Modojo interview: "I made back my costs on the first day, which was nice. I was very lucky to be able to spend under $5,000, which is extremely low for a game of this quality." [Modojo](https://modojo.com/article/4998/plague_inc_interview_with_ndemic_creations_james_vaughan) Launched May 26, 2012 on iOS at $0.99 premium. The prototype focused on **algorithm-driven decision-making** — Vaughan modeled disease propagation in Excel before coding. The "is this fun?" question was: does choosing pathogen evolutions feel like meaningful trade-offs? It became the #1 paid iPhone/iPad app in the US for two weeks at launch [Wikipedia](https://en.wikipedia.org/wiki/Plague_Inc.) and has exceeded 160 million downloads. [Wikipedia](https://en.wikipedia.org/wiki/Plague_Inc.)

- **Game Dev Story (Kairosoft):** PC original 1997, mobile port 2010. The prototype-equivalent question was: can a player run a virtual game studio with just genre+type combos and staff assignments? The mobile port proved that bite-sized turn-based business sim sessions worked on a phone [Wikipedia](https://en.wikipedia.org/wiki/Construction_and_management_simulation) — and birthed a whole Kairosoft library of similar premium mgmt games.

- **Two Point Hospital (mobile, via subscription):** Console/PC team; mobile version validated that a console-quality mgmt sim UI could translate to touch.

Common thread: **every one of these was a small team or solo dev validating one core idea before scaling.**

---

## PART B — Best Practices for Prototyping WITH an AI Assistant

### B1. The source-of-truth workflow

The single biggest predictor of AI prototype quality is whether you've written a tight GDD before opening the AI. Without one, the AI invents — and its inventions are usually generic, off-tone, or copies of whatever game it last saw in training data.

**Required GDD sections for an AI-driven prototype (keep total under ~3 pages):**

1. **One-line pitch.** "A premium mobile tycoon where you run a [X]."
2. **Design pillars** (3–5 max). E.g., "Premium feel — no timers; Decision density — choice every 30 seconds; Mobile-native — one-handed portrait."
3. **The core question this prototype answers** (the sticky note from A2).
4. **Core loop, written as a numbered list** of 4–7 steps.
5. **Resources & numbers.** Starting cash, building costs, income rates, tick interval. Include a starting table of values.
6. **Out of scope.** Explicit list: "NO save system. NO settings menu. NO tutorial. NO art. NO audio. NO multiple maps."
7. **Win/lose/end states** (or "endless" if applicable).
8. **One reference image or 2–3 reference games.**

**Reading order rule:** put the GDD at the top of every conversation/session. Tell the AI: "Read this GDD. Do not invent mechanics outside it. If something is ambiguous, ask before coding."

**Rule the AI must follow** (paste this verbatim into the system prompt or project instructions):

> You are prototyping a game. The GDD is the source of truth. Rules:
> 1. Read the GDD before writing any code.
> 2. Before implementing, restate the task in your own words and propose a plan. Wait for approval.
> 3. If the GDD is ambiguous or silent on something, ASK — do not assume.
> 4. Keep all code in one file unless I explicitly ask otherwise.
> 5. Use placeholder rectangles and system fonts. Do not generate art, do not add CSS animations beyond utility tweens, do not add audio.
> 6. Implement the smallest playable version first; we will add on iteratively.
> 7. Do not add features I did not request. No save system, no settings, no analytics.
> 8. Comment numeric tuning values (`// TUNING: starting cash`) so I can find and change them.

### B2. Prompt engineering for game prototypes

**Scope each task to a single observable change.**
- ❌ "Build the game."
- ❌ "Add the economy."
- ✅ "Add a single building type called 'Shop' that costs $50 and generates $10 every 5 seconds. The player can place up to 10. Display total cash and number of shops at the top."

**Validate before executing.**
Force the AI to write the plan first: "Before writing code, list the variables, functions, and UI elements you will add or change." Read it. Correct it. Then approve. The Rephrase.io guide to AI game-dev prompting notes that strong results come from prompts that clearly separate system role, game definition, state context, and strict output format — broad single-shot prompts fail because game development is a chain of interdependent tasks with different success criteria.

**Iterate in small diffs, not rewrites.**
- ❌ "Now redo the whole loop with X, Y, Z."
- ✅ "Modify only the income tick: instead of fixed $10, make it `base * (1 + 0.1 * adjacent_shops)`. Leave the rest unchanged."

**Single-file vs. multi-file.**
For a management prototype targeting validation only: **one file.** Claude Artifacts, ChatGPT Canvas, and similar tools are designed for single-file React or HTML and iterate in seconds. The Oct 2025 Claude 4.5 update added precise diff-based artifact editing which makes this dramatically more efficient. [Matsuoka](https://hyperdev.matsuoka.com/p/claudeais-quiet-revolution-in-artifact) The moment you go multi-file, the AI loses context and breaks unrelated code on every change. Stay single-file until you migrate to an engine.

**Keep the AI focused on gameplay over visuals.**
Default behavior: AIs will add gradients, glass-morphism, animations, and emojis if not stopped. Add to your standing prompt:
> Use plain colored rectangles for buildings. No gradients. No animations except number counter rollups and progress bars. Default system font. Do not use emojis as game icons.

**When to abandon a conversation and restart.**
If you've spent more than ~10 prompts fixing the same area and it's still wrong, the context is poisoned. Save the current code, start a new chat, paste the GDD + current code + ONE specific task. Fresh context routinely outperforms "just one more fix."

### B3. The iteration loop with AI

A clean loop looks like:
1. **Specify** — one task, one observable outcome.
2. **AI plans** — list of changes, no code.
3. **Approve or correct the plan.**
4. **AI implements** — minimal diff.
5. **You run it on a real device or in-browser.** Play for 60 seconds.
6. **Capture observations** — write 1–3 bullets. "Income tick is too fast. Buildings feel too cheap. Cash counter doesn't animate."
7. **Feed observations back** — one fix at a time.

**Version control:** even for a single-file prototype, commit to git after every meaningful step that works. Tag known-good versions (`proto-loop-v1`, `proto-with-decay-v2`). When the AI breaks something, `git checkout` is faster than asking it to fix what it broke.

**When to throw away and restart:**
- Core loop fundamentally doesn't work — start over, don't refactor.
- You've added 4+ systems and can't remember why — start over with the lessons.
- The AI keeps regressing the same bug — start over with cleaner context.

Throwing away a 2-week prototype that taught you the right answer is a **success**, not a failure. The lesson is the deliverable.

### B4. Rules an AI agent should follow when building game prototypes

Distilled into a checklist you can paste as project knowledge:

```
AI PROTOTYPING RULES
1. The GDD is the source of truth. Do not invent mechanics not in the GDD.
2. Before writing code, restate the task and propose a plan. Wait for approval.
3. Ambiguity → ASK, do not assume.
4. Smallest playable change first. Add complexity only on request.
5. One file by default. Multi-file only when the human requests it.
6. No final art, no audio, no animations beyond number counters and progress bars.
7. No save systems, no settings, no tutorials, no analytics, no monetization.
8. Comment all tunable numbers with // TUNING: <name>.
9. If a change requires touching >1 system, flag it as a risk first.
10. After implementing, summarize what changed in 3 bullets.
11. Never silently delete features. If removal is needed, ask.
12. Prefer obvious, readable code over clever code. This is throwaway.
```

---

## PART C — Technical Approach Comparison & Recommendation

### C1. The candidates

| Approach | Speed of iteration | AI-friendliness | Tests mobile/touch feel | Easy to share | Path to production |
|---|---|---|---|---|---|
| **Single-file React/JSX in Claude Artifact / Vite** | ★★★★★ Seconds per iteration | ★★★★★ Native format for Claude/ChatGPT | ★★ Desktop-only by default; touch events work but feel wrong | ★★★★★ Share a URL | ★★ Throwaway — port required |
| **Single-file HTML/JS (Canvas or DOM)** | ★★★★★ | ★★★★★ Universally generated | ★★ Same as above | ★★★★★ Just an HTML file | ★★ Throwaway |
| **Phaser (HTML5 game framework)** | ★★★★ | ★★★★ Well documented; AI generates competent Phaser | ★★★ Better touch handling; can wrap with Cordova/Capacitor | ★★★★ HTML deploy | ★★★ Can ship (Pocket City did) but mobile perf is a real consideration |
| **Godot 4 (2D, GDScript or C#)** | ★★★ Compile/run cycle | ★★★ Decent — GDScript is well represented in training data, less than Unity | ★★★★★ Native mobile export; touch handled properly | ★★★ Need to export build | ★★★★★ Same engine ships the game |
| **Unity (C#)** | ★★ Heavier; longer compile | ★★★★ Heavily represented in AI training | ★★★★★ Industry standard for mobile | ★★★ Build pipeline | ★★★★★ Same engine ships |
| **GameMaker (with new Claude Code CLI integration, launched 30 April 2026 per Opera's press release)** | ★★★★ | ★★★★ Officially AI-integrated — among the first engines with AI-assisted workflows built in [Opera](https://press.opera.com/2026/04/30/gamemaker-gmrt/) [Game Developer](https://www.gamedeveloper.com/production/gamemaker-incorporates-claude-code-to-enable-ai-assisted-workflows) | ★★★★ Solid 2D mobile | ★★★ | ★★★★ |
| **Flutter / native iOS/Android** | ★★ | ★★★ AI generates Flutter well, but game patterns are not its strength | ★★★★★ Native | ★★★ | ★★★★ |

### C2. Why a staged approach beats picking one engine up front

You have two different validation jobs and they need different tools:

- **Job 1: "Is the core loop fun?"** Iterate in 5-second cycles. Don't care about mobile yet. Optimize for AI iteration speed and shareability.
- **Job 2: "Does it work on a phone?"** Iterate in 1–5 minute cycles. Build to device. Care about touch, performance, screen size, one-handed grip, battery.

Trying to do both in Unity from day one means you spend three weeks setting up the project and getting the AI to produce competent C# instead of three weeks finding the fun.

### C3. Recommended staged path

**Stage 0 — Spreadsheet (1–3 days).**
Model the economy in Google Sheets. Columns: turn, cash, income, costs, buildings, multipliers. Tune until the curve feels right — money should roughly double on a satisfying cadence (every ~3–5 minutes of equivalent play). If the spreadsheet is boring, the game will be boring. Do not skip this.

**Stage 1 — Single-file web prototype (1–3 weeks).**
- **Tool:** Claude Artifact (React/TSX) OR a single-file Vite+React project OR plain HTML+Canvas.
- **Goal:** Answer the core question from A2.
- **What to build:** The core loop, 1 building type, money counter, one progression curve, one "lose" or "soft fail" state.
- **What NOT to build:** Multiple buildings, art, audio, save, settings, tutorial.
- **Playtest:** On desktop in browser. Mobile feel doesn't matter yet.
- **Exit gate:** 3 playtesters say "one more turn" / you yourself want to keep playing. If not — iterate or kill.

**Stage 2 — Mobile feel prototype (2–4 weeks).**
- **Tool:** **Godot 4** (recommended for a 2D management game) — lightweight, free, royalty-free, excellent mobile export, AI can write competent GDScript with the GDD as context. Use Unity instead only if (a) you're already proficient in C# or (b) you plan to do heavy 3D like Pocket City 2.
- **Goal:** Validate that the core loop survives a phone — thumb zones, tap targets, one-handed grip, perf on a 3-year-old device.
- **What to port:** Just the core loop. Resist re-adding scope.
- **What to add:** Mobile-specific UX — thumb-zone button placement, ≥44pt tap targets, portrait orientation, basic touch feedback.
- **Playtest:** On at least 2 real devices (one current, one 3 years old). Hand the phone to a real human in a real environment (couch, train, café).
- **Exit gate:** Loop is as fun on the phone as it was in the browser, AND a non-genre player can pick up the phone and make a meaningful decision within 60 seconds.

**Stage 3 — Vertical slice / production (only after Stages 1 & 2 pass).**
Now you can talk to publishers, Apple Arcade, etc. Same engine as Stage 2.

### C4. The recommendation, stated plainly

**For a premium mobile management game prototype, build Stage 1 as a single-file React artifact (Claude or similar) and Stage 2 in Godot 4.** Skip Unity unless you have specific reasons (3D, existing team expertise, console targets).

Justification:
- React-in-artifact gives the **fastest possible AI iteration loop** — sub-10-second feedback cycle, shareable URL for casual playtesting, native to Claude/Codex/Cursor workflows.
- Godot 4 has **excellent 2D performance on mobile**, [Rocketbrush](https://rocketbrush.com/blog/godot-vs-unity) free with no royalty, [Rocketbrush](https://rocketbrush.com/blog/godot-vs-unity) lightweight install, [AppMakers USA](https://appmakersla.com/blog/game-development/godot-vs-unity/) and a clean node-based architecture that fits how AI structures code. GDScript is Python-like [AppMakers USA](https://appmakersla.com/blog/game-development/godot-vs-unity/) and AI-friendly. Mobile export is one click.
- **Avoid the trap of "Unity because it's industry standard"** for a prototype. Unity's setup overhead and heavier toolchain slow the AI loop. Move to Unity only if Stage 2 reveals you need 3D, advanced shaders, or a console target — and even then, only after fun is proven.
- **Phaser/HTML5 is a viable production target** (Pocket City shipped on it) but its mobile feel is "good web wrapped in Cordova" rather than native. Use it only if you're already a web developer with no other engine experience.

### C5. When to NOT follow this recommendation

- If your prototype's core question is *itself* about a 3D camera or physics, skip to Godot/Unity from day 1.
- If you already ship games in Unity and have a project template ready, the setup overhead is gone — go straight to Unity.
- If you're targeting Apple Arcade specifically and have early conversations with Apple, ask them what they want to see in a pitch (often a playable build, sometimes a vertical slice).
- If you want first-class AI-CLI integration baked into the engine, GameMaker's GMRT runtime (with Claude Code built in, [Game Developer](https://www.gamedeveloper.com/production/gamemaker-incorporates-claude-code-to-enable-ai-assisted-workflows) launched 30 April 2026) [Opera](https://press.opera.com/2026/04/30/gamemaker-gmrt/) is a credible alternative to Godot for 2D.

---

## Recommendations

**This week (if you're starting from zero):**
1. Write the GDD (≤3 pages) using the structure in B1. Include the ONE prototype question.
2. Build the economy spreadsheet (Stage 0).
3. Set up a git repo. Make `prototypes/proto-01/` your working directory.
4. Open Claude or your preferred AI with the GDD and the rules from B1/B4 pasted as project knowledge.
5. Generate Stage 1 single-file React prototype. Timebox: 1 week to first playable.

**Within 2–3 weeks:**
6. Playtest Stage 1 with 3+ humans. Apply A7 protocol.
7. Decide: iterate, pivot, or kill. Apply A6 kill criteria honestly.
8. If pass → port to Godot for Stage 2.

**Benchmarks that change the recommendation:**
- If Stage 1 is fun after 1 week → great, plan Stage 2.
- If Stage 1 is fun but the question is "does this work on touch?" rather than "is this fun on desktop?" → skip directly to Godot.
- If you can't get 3 playtesters to want a second session by week 3 → kill the prototype, write a postmortem, start a new core question.
- If Stage 2 reveals perf issues on a 3-year-old device → simplify mechanics; do NOT switch engines hoping for free perf.
- If the AI is generating broken or off-design code repeatedly → your GDD is too vague. Rewrite it before continuing.

**What to put in this project's knowledge base now:**
- The GDD (single source of truth).
- The AI prototyping rules (B4 checklist).
- The kill criteria (A6).
- The reference titles and their session-length / monetization targets (A8).
- Tap target & thumb zone constraints for Stage 2 (A8).

---

## Caveats

- **No prototype guarantees a hit.** Mini Metro, Pocket City, and Plague Inc. each had additional months-to-years of polish, marketing, and luck after the prototype. A good prototype answers "is it fun?" not "will it sell?"
- **Premium mobile is a tough market.** Robert Curry, in his PocketGamer.biz interview, said: "Across the board, the trend has been that the money going to premium titles has been declining… [PocketGamer](https://www.pocketgamer.biz/interview/72525/indie-spotlight-dinosaur-polo-club-mini-motorways/) before the Apple Arcade pitch we were discussing within the studio about maybe changing our focus away from mobile to desktop and console." [PocketGamer](https://www.pocketgamer.biz/indie-spotlight-dinosaur-polo-club-mini-motorways/) [PocketGamer](https://www.pocketgamer.biz/interview/72525/indie-spotlight-dinosaur-polo-club-mini-motorways/) Plan for Apple Arcade and/or PC/Switch ports as plausible business models, not just paid App Store.
- **AI code quality is uneven.** AIs hallucinate APIs, drift from the GDD, and silently break working code. The discipline of small diffs, plan-before-code, and version control is what makes AI prototyping faster than hand-coding, not laxer. Without that discipline it is slower.
- **Mobile-feel can only be validated on mobile.** Browser-based prototypes are great for loop validation but will mislead you about touch, screen real estate, and one-handed play. Do not skip Stage 2.
- **Conflict on the Mini Metro prototype duration:** Dinosaur Polo Club's press kit says "three-day Ludum Dare 26 Jam" [Dinopoloclub](https://old.dinopoloclub.com/press/sheet.php?p=mini_metro) (the 72-hour Jam track); Robert/Peter Curry casually call it "a weekend" [GameFeatured](https://gamefeatured.com/interviews/dinosaur-polo-club-mini-metro) and "two days" [Game Developer](https://www.gamedeveloper.com/audio/road-to-the-igf-dinosaur-polo-club-s-i-mini-metro-i-) in interviews. Most likely: submitted to the 72-hour Jam track, with effective coding time of ~2 days. Use the 72-hour figure when citing.
- **The recommendation to use Godot 4 over Unity is a bet, not a certainty.** Unity is more battle-tested for mobile [Game Dev Beginner](https://gamedevbeginner.com/godot-vs-unity-for-making-your-first-game/) and has a larger talent pool if you intend to hire. Godot wins on iteration speed [Game Dev Beginner](https://gamedevbeginner.com/godot-vs-unity-for-making-your-first-game/) and AI-friendliness for solo/small-team prototypes. If you anticipate hiring or shipping cross-platform with heavy 3D, Unity may be the right Stage 2 choice instead.
- **Session-length data is industry rule-of-thumb, not hard truth.** The 1–2 minute average iOS session length is widely cited (objc.io et al.) but premium players skew longer; design for both ends of the distribution rather than the average.