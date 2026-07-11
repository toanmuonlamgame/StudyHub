# StudyHub Product Research

## Purpose and boundaries

This note extracts product and engineering lessons from established learning platforms. It does not recommend copying their UI, branding, assets, proprietary content, ranking systems, or exact mechanics. Sources are first-party product documentation and engineering publications; recommendations for StudyHub are explicitly presented as adaptations or inferences.

## Balanced product standard

Learning apps succeed not only by being fast, but by feeling useful, engaging, polished, and motivating. StudyHub should balance learning value and modern UX with performance guardrails: preserve purposeful visual polish and valuable features, then implement them with measured startup work, smooth interaction, small payloads, lazy loading, and appropriate caching.

StudyHub applies these research lessons through the reusable feature-review and
Definition of Done in [`QUALITY_SYSTEM.md`](QUALITY_SYSTEM.md).

## Platform lessons

### Quizlet

**Observed:** Quizlet lets learners create their own term-definition sets, while Learn builds a personalized study path around a goal and familiarity with the set. It also supports multiple question styles and focused review options. ([Creating flashcard sets](https://help.quizlet.com/hc/en-us/articles/360029780752-Creating-study-sets), [Studying with Learn](https://help.quizlet.com/hc/en-us/articles/360030986971-Studying-with-Learn))

**StudyHub should learn:** Make user-owned content quick to create, browse, and reuse. Later, one Question Set can support Exam Mode, Practice Mode, and targeted review without duplicating its source questions.

**Do not copy:** Quizlet's layouts, terminology, paywall design, content catalog, or exact personalization mechanics. StudyHub should keep `Study Material` and `Question Set` as distinct domain objects.

### Duolingo

**Observed:** Duolingo combines short, progressively harder lessons with progress signals and optional motivational mechanics. ([Duolingo learning method](https://blog.duolingo.com/duolingo-teaching-method/), [Duolingo product guide](https://blog.duolingo.com/duolingo-101-how-to-learn-a-language-on-duolingo/))

Its Android team found that 39% of entry-level-device users waited more than five seconds at startup. By tracing startup, deferring non-critical work, reducing blocking requests, and using cache/offline fallbacks, it reduced that group to 8%; deferring ad initialization alone cut about 1.5 seconds from startup. ([Duolingo Android performance case study](https://blog.duolingo.com/android-app-performance/))

**StudyHub should learn:** Keep the core loop short and obvious, but treat startup latency and responsiveness as product requirements. Measure time-to-home and time-to-first-question; defer optional work, avoid blocking the UI on unrelated requests, and test on entry-level Android devices and weak networks.

**Do not copy:** The mascot, visual language, streak, XP, hearts, leagues, sounds, or reward economy. Motivation features should support learning rather than punish missed days or become the product itself.

### Khan Academy

**Observed:** Khan Academy uses self-paced mastery to let learners work on the concepts that match their needs and to track progress over time. ([Why Mastery Learning](https://support.khanacademy.org/hc/en-us/articles/360030753412), [Self-paced Mastery](https://support.khanacademy.org/hc/en-us/articles/360007253831-What-is-self-paced-Mastery))

Its engineering account also states that in-process monolith calls are fast and reliable, while service boundaries add slower, more fragile communication and operational decisions. Before its later services rewrite, Khan Academy had already introduced code boundaries and import constraints inside the monolith. ([Go + Services = One Goliath Project](https://blog.khanacademy.org/go-services-one-goliath-project/))

**StudyHub should learn:** Add concept-level progress only after the basic quiz loop is reliable. Architecturally, the StudyHub inference is to keep a modular monolith now: define clear Learning, Content, Moderation, and future Credits boundaries before considering independently deployed services.

**Do not copy:** Khan Academy's curriculum, mastery-point formula, course hierarchy, exercises, or service topology. Its migration answered constraints at a much larger scale and is not evidence that StudyHub needs microservices early.

### Coursera

**Observed:** Coursera organizes learning into structured offerings and helps learners resume from a recommended next step. ([Coursera overview](https://www.coursera.org/about), [Progress tracking](https://blog.coursera.org/new-progress-tracking-features-on-coursera/))

Coursera Engineering describes enforcing a common architecture across iOS and Android to reduce orientation and platform-switching friction. It also introduced modular architecture incrementally, one feature at a time, rather than rewriting the app. ([Learning Multiple Platforms](https://medium.com/coursera-engineering/learning-multiple-platforms-coursera-281f03beb332), [How Coursera uses Swift](https://medium.com/coursera-engineering/how-coursera-uses-swift-c0a6c68a6bfe))

**StudyHub should learn:** Keep the Flutter feature structure, repository contracts, API DTOs, loading/error states, and naming consistent. Preserve a clear "continue learning" path later, and evolve architecture feature by feature.

**Do not copy:** Coursera's catalog, certificates, institutional marketplace, course pages, or commercial model. StudyHub's near-term unit is user-contributed study content, not a full online course business.

### Anki

**Observed:** Anki centers on learner-owned notes/cards, decks, import, and cross-device synchronization. Its optional FSRS scheduler estimates forgetting to target retention while balancing review workload. ([Getting Started](https://docs.ankiweb.net/getting-started.html), [Syncing with AnkiWeb](https://docs.ankiweb.net/syncing.html), [FSRS deck options](https://docs.ankiweb.net/deck-options))

**StudyHub should learn:** Preserve ownership and portability of contributed content. In a later phase, store review history separately from question content so spaced review can evolve without changing Question Sets.

**Do not copy:** Anki's deck/card UI, scheduler implementation, terminology, file formats, or advanced configuration. A spaced-repetition engine should be adopted only when StudyHub has enough attempt history and a validated need.

### Moodle

**Observed:** Moodle separates reusable questions from quizzes. Its question banks support categories, draft/ready status, versions, author information, comments, usage data, and review signals. ([Question banks](https://docs.moodle.org/502/en/Question_banks), [Quiz activity](https://docs.moodle.org/405/en/Quiz)) Moodle also documents explicit component boundaries and optional modules/plugins. ([Component communication](https://moodledev.io/general/development/policies/component-communication))

**StudyHub should learn:** Model content lifecycle and provenance early: author, status, version, reports, and usage can later support moderation and quality rewards. Keep reusable question content separate from quiz attempts.

**Do not copy:** Moodle's full LMS role matrix, plugin ecosystem, course administration, navigation, or configuration depth. V1 needs a small content and quiz workflow, not a general-purpose LMS.

### NotebookLM-style AI study flows

**Observed:** NotebookLM can turn user-provided sources into study guides and, more recently, flashcards and quizzes. Google states that these study aids are grounded in the supplied sources and can provide explanations with citations back to original material. ([NotebookLM learning features](https://blog.google/innovation-and-ai/models-and-research/google-labs/notebooklm-student-features/), [NotebookLM source citations](https://blog.google/innovation-and-ai/products/notebooklm-beginner-tips/))

**StudyHub should learn:** Future AI generation should start from a specific uploaded source, retain source locations for every generated item, show evidence during review, and require contributor approval before publication. Generated questions need status, provenance, model/run metadata, and a human-editable draft.

**Do not copy:** NotebookLM's name, interface, generated formats, audio presentation, or assets. Do not present unsupported answers as source-grounded, and do not publish generated questions automatically.

## Feature ideas by phase

### V1: prove the core loop

- Keep the confirmed flow: browse by required Subject, open a Question Set, complete an Exam Mode quiz, review results, and create an upload metadata placeholder.
- Make loading, empty, error, and retry states consistent; keep API payloads scoped to the current screen.
- Establish basic performance measurements for startup, first content render, and quiz responsiveness.
- Keep motivation lightweight: progress and completion feedback, without streaks, currencies, or adaptive scheduling.

### V2: trusted contribution and repeated practice

- Add contributor profiles, content status, rating/report flows, duplicate detection, and moderation provenance.
- Add Practice Mode through a backend `checkAnswer` contract while preserving Exam Mode secrecy.
- Add question/content versioning and basic usage-quality signals before calculating rewards.
- Add learning history, "continue learning," and simple targeted review; evaluate pagination and read caching from measured usage.

### V3: source-grounded assistance

- Ingest user-provided study materials with ownership, access, retention, and moderation controls.
- Generate draft questions, flashcards, and study guides from selected sources; attach source evidence to each generated item.
- Require human review before community publication and log generation/review decisions.
- Evaluate spaced repetition, richer recommendations, ads/credits, and payments independently; none should be prerequisites for grounded AI review.

## Roadmap impact

- **Do not expand V1.** Research strengthens the existing browse-quiz-result-upload sequence and adds measurable performance guardrails, not more surface area.
- **Move Practice Mode and content trust ahead of gamification.** Reusable content, review history, provenance, status, reports, and quality signals are foundations for responsible rewards and personalization.
- **Keep one consistent architecture.** Flutter screens depend on repositories; backend routes depend on service contracts; PostgreSQL remains behind Prisma. Add modules within the current modular monolith before considering deployment-level services.
- **Make AI a reviewed content pipeline, not a chat shortcut.** Source ingestion, citations, draft state, validation, and human approval come before automatic publication.
- **Use evidence to trigger complexity.** Pagination, caching, offline support, adaptive review, and service extraction should follow measured payload, latency, reliability, or ownership needs.
