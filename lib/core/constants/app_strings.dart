import 'package:whichgame/core/localization/app_language.dart';

abstract final class AppStrings {
  static AppLanguage _language = AppLanguage.english;

  static AppLanguage get currentLanguage => _language;
  static bool get isArabic => _language == AppLanguage.arabic;

  static void setLanguage(AppLanguage language) => _language = language;

  static String _t(String english, String arabic) => isArabic ? arabic : english;

  static String get appName => _t('Which Game?', 'أي لعبة؟');
  static String get appTagline =>
      _t('Pick faster. Build teams. Start playing.', 'اختر أسرع. قسّم الفرق. وابدأ اللعب.');
  static String get developedBy => _t('Developed by BesherJu', 'تطوير BesherJu');
  static String get aboutTooltip => _t('About Which Game?', 'حول التطبيق');
  static String get about => _t('About', 'حول');
  static String get aboutDescription => _t(
        'Players, game selection, filters, and per-game ratings are isolated so the app can keep growing cleanly.',
        'تم فصل اللاعبين واختيار الألعاب والفلاتر وتقييمات كل لعبة بحيث يبقى التطبيق قابلاً للتوسع بشكل نظيف.',
      );
  static String get legacyTeamToolsMoved => _t(
        'Team tools moved to the Players and Teams tabs.',
        'تم نقل أدوات الفرق إلى تبويبي اللاعبين والفرق.',
      );

  static String get play => _t('Play', 'اللعب');
  static String get games => _t('Games', 'الألعاب');
  static String get players => _t('Players', 'اللاعبون');
  static String get teams => _t('Teams', 'الفرق');

  static String get languageLabel => _t('Language', 'اللغة');
  static String get english => _t('English', 'الإنجليزية');
  static String get arabic => _t('Arabic', 'العربية');

  static String get appTour => _t('App tour', 'جولة التطبيق');
  static String get startAppTour => _t('Show app tour', 'عرض جولة التطبيق');
  static String get next => _t('Next', 'التالي');
  static String get back => _t('Back', 'السابق');
  static String get skip => _t('Skip', 'تخطي');
  static String get done => _t('Done', 'تم');
  static String coachStep(int current, int total) => '$current/$total';

  static String get coachWelcomeTitle => _t('Welcome to Which Game?', 'أهلاً بك في أي لعبة؟');
  static String get coachWelcomeDescription => _t(
        'A quick tour will show you the game picker, your custom picker, personal game board, saved players, team tools, Generals armies, archives, and language controls.',
        'جولة سريعة ستعرّفك على اختيار الألعاب، الاختيار المخصص، لوحة ألعابك، اللاعبين المحفوظين، تقسيم الفرق، جيوش جنرالز، الأرشيف، وتغيير اللغة.',
      );
  static String get coachPlayTitle => _t('Pick a game instantly', 'اختر لعبة فوراً');
  static String get coachPlayDescription => _t(
        'This fixed result card chooses only from enabled, non-archived games that match your saved filters. Tap Pick again whenever you want another result.',
        'هذه البطاقة تختار فقط من الألعاب المفعّلة وغير المؤرشفة والمطابقة للفلاتر المحفوظة. اضغط اختر مجدداً للحصول على نتيجة جديدة.',
      );
  static String get coachQuickActionsTitle => _t('Your fastest shortcuts', 'أسرع اختصاراتك');
  static String get coachQuickActionsDescription => _t(
        'Jump straight to managing games, splitting teams, assigning Generals armies, or using your own custom picker.',
        'انتقل مباشرة لإدارة الألعاب أو تقسيم الفرق أو توزيع جيوش جنرالز أو استخدام الاختيار المخصص الخاص بك.',
      );
  static String get coachGameFiltersTitle => _t('Keep the library compact', 'حافظ على المكتبة مرتبة');
  static String get coachGameFiltersDescription => _t(
        'Search and filter by category, play style, and random-pool status. Clear filters anytime to see your whole board again.',
        'ابحث وفلتر حسب التصنيف ونمط اللعب وحالة العشوائي. يمكنك مسح الفلاتر في أي وقت لرؤية كامل لوحتك.',
      );
  static String get coachGameBoardTitle => _t('Enable only what you play', 'فعّل ما تلعبه فقط');
  static String get coachGameBoardDescription => _t(
        'Tap a game to enable or disable it. Use + to add your own games, and the game menu to view details, edit, remove, archive, or keep only that game enabled.',
        'اضغط على اللعبة لتفعيلها أو تعطيلها. استخدم + لإضافة ألعابك، ومن قائمة اللعبة يمكنك عرض التفاصيل أو التعديل أو الحذف أو الأرشفة أو إبقاء هذه اللعبة وحدها مفعّلة.',
      );
  static String get coachGameArchiveTitle => _t('Archive the rest', 'أرشف الباقي');
  static String get coachGameArchiveDescription => _t(
        'Archive games you do not currently use. They disappear from the board and random picker, and you can restore many of them together later.',
        'أرشف الألعاب التي لا تستخدمها حالياً. ستختفي من اللوحة والاختيار العشوائي ويمكنك استعادة عدة ألعاب معاً لاحقاً.',
      );
  static String get coachPlayersTitle => _t('Build your player roster', 'كوّن قائمة اللاعبين');
  static String get coachPlayersDescription => _t(
        'Permanent players stay cached on this device. Guests last only for the current session. Check the players who are playing today.',
        'اللاعبون الدائمون يبقون محفوظين على الجهاز، أما الضيوف فللجلسة الحالية فقط. فعّل اللاعبين الموجودين اليوم.',
      );
  static String get coachPlayerArchiveTitle => _t('Keep old players without clutter', 'احتفظ باللاعبين بدون ازدحام');
  static String get coachPlayerArchiveDescription => _t(
        'Use the archive manager to archive or restore several saved players at once instead of deleting them.',
        'استخدم مدير الأرشيف لأرشفة أو استعادة عدة لاعبين محفوظين دفعة واحدة بدلاً من حذفهم.',
      );
  static String get coachTeamsTitle => _t('Split active players into teams', 'قسّم اللاعبين النشطين إلى فرق');
  static String get coachTeamsDescription => _t(
        'Choose the number of teams and shuffle. Only players checked in the Players tab are included.',
        'اختر عدد الفرق ثم اخلط اللاعبين. لن يدخل إلا اللاعبون المفعّلون في تبويب اللاعبين.',
      );
  static String get coachGeneralsTitle => _t('Generals army picker', 'اختيار جيوش جنرالز');
  static String get coachGeneralsDescription => _t(
        'With two or more active players, assign a Zero Hour army to everyone at once with a short animated reveal.',
        'عند وجود لاعبين نشطين أو أكثر، وزّع جيش Zero Hour على الجميع دفعة واحدة مع حركة قصيرة قبل ظهور النتائج.',
      );
  static String get coachLanguageTitle => _t('Switch language instantly', 'بدّل اللغة فوراً');
  static String get coachLanguageDescription => _t(
        'Tap the globe anytime to switch between English and Arabic. The whole interface updates immediately.',
        'اضغط زر الكرة الأرضية في أي وقت للتبديل بين العربية والإنجليزية، وستتحدث الواجهة كاملة فوراً.',
      );
  static String get coachNavigationTitle => _t('Four simple spaces', 'أربعة أقسام واضحة');
  static String get coachNavigationDescription => _t(
        'Play picks the game, Games manages your board, Players manages today’s roster, and Teams handles team generation. You can replay this tour from About.',
        'اللعب للاختيار العشوائي، الألعاب لإدارة اللوحة، اللاعبون لقائمة اليوم، والفرق للتقسيم. يمكنك إعادة هذه الجولة من صفحة حول التطبيق.',
      );

  static String get gameLibrary => _t('Game library', 'مكتبة الألعاب');
  static String get clear => _t('Clear', 'مسح');
  static String get clearFilters => _t('Clear filters', 'مسح الفلاتر');
  static String get clearSearch => _t('Clear search', 'مسح البحث');
  static String get searchGames => _t('Search games…', 'ابحث عن لعبة…');
  static String get type => _t('Type', 'النوع');
  static String get category => _t('Category', 'التصنيف');
  static String get playStyle => _t('Play style', 'نمط اللعب');
  static String get poolStatus => _t('Random pool', 'قائمة العشوائي');
  static String get allCategories => _t('All categories', 'كل التصنيفات');
  static String get allPlayStyles => _t('All play styles', 'كل أنماط اللعب');
  static String get allGames => _t('All games', 'كل الألعاب');
  static String get selectedGames => _t('Enabled games', 'الألعاب المفعّلة');
  static String get unselectedGames => _t('Disabled games', 'الألعاب المعطّلة');
  static String get allShort => _t('All', 'الكل');
  static String get selectedShort => _t('On', 'مفعّل');
  static String get unselectedShort => _t('Off', 'معطّل');
  static String get videoShort => _t('Video', 'فيديو');
  static String get cardsShort => _t('Cards', 'ورق');
  static String get sportShort => _t('Sport', 'رياضة');
  static String get twoPlayersShort => _t('2P', '2');
  static String get groupShort => _t('3+', '+3');
  static String get localShort => _t('Local', 'محلي');
  static String get lanShort => 'LAN';
  static String get onlineShort => _t('Online', 'أونلاين');
  static String get selectedOnly => _t('Selected only', 'المفعّلة فقط');
  static String get filters => _t('Filters', 'الفلاتر');
  static String get bulkActions => _t('Bulk actions', 'إجراءات جماعية');
  static String get selectVisible => _t('Enable visible', 'تفعيل الظاهر');
  static String get deselectVisible => _t('Disable visible', 'تعطيل الظاهر');
  static String get archiveVisibleGames =>
      _t('Archive visible games', 'أرشفة الألعاب الظاهرة');
  static String get archiveDisabledGames =>
      _t('Archive disabled games', 'أرشفة الألعاب المعطّلة');
  static String get enableAllGames => _t('Enable all games', 'تفعيل كل الألعاب');
  static String get disableAllGames => _t('Disable all games', 'تعطيل كل الألعاب');
  static String get onlyThisGame => _t('Only this game', 'هذه اللعبة فقط');
  static String get onlyThisGameHint => _t(
        'Disable every other game and keep this one enabled.',
        'عطّل كل الألعاب الأخرى واترك هذه اللعبة مفعّلة.',
      );
  static String get gameDetails => _t('Game details', 'تفاصيل اللعبة');
  static String get noGamesMatch => _t('No games match these filters.', 'لا توجد ألعاب مطابقة لهذه الفلاتر.');
  static String get noGamesMatchHint => _t('Clear a filter or change the search.', 'امسح أحد الفلاتر أو غيّر البحث.');
  static String get removeFromRandomPool => _t('Disable', 'تعطيل');
  static String get addToRandomPool => _t('Enable', 'تفعيل');
  static String get archive => _t('Archive', 'أرشفة');
  static String get archiveGame => _t('Archive game', 'أرشفة اللعبة');
  static String get archivedGames => _t('Archived games', 'الألعاب المؤرشفة');
  static String get archivedGamesHint => _t(
        'Archived games stay out of the library and random picker until you restore them.',
        'الألعاب المؤرشفة لا تظهر في المكتبة أو الاختيار العشوائي حتى تقوم باستعادتها.',
      );
  static String get manageGameBoard =>
      _t('Manage game board', 'إدارة لوحة الألعاب');
  static String get manageGameBoardHint => _t(
        'Keep only the games you actually play on your board.',
        'أبقِ على اللوحة فقط الألعاب التي تلعبها فعلاً.',
      );
  static String get noBoardGames =>
      _t('Your board is empty. Restore games from Archive.', 'لوحتك فارغة. استعد ألعاباً من الأرشيف.');
  static String get noArchivedGames => _t('No archived games.', 'لا توجد ألعاب مؤرشفة.');
  static String get unarchive => _t('Restore', 'استعادة');
  static String get archived => _t('Archived', 'مؤرشفة');
  static String get selectAll => _t('Select all', 'تحديد الكل');
  static String get clearSelection => _t('Clear', 'إلغاء التحديد');

  static String get gamesEnabled => _t('Games enabled', 'الألعاب المفعّلة');
  static String get inRandomPool => _t('In random pool', 'ضمن الاختيار');
  static String get playersReady => _t('Players ready', 'اللاعبون الجاهزون');
  static String get recentlyPicked => _t('Recently picked', 'الاختيارات الأخيرة');
  static String get manageGames => _t('Manage games', 'إدارة الألعاب');
  static String get noRecentPicks => _t('Your recent picks will appear here.', 'ستظهر اختياراتك الأخيرة هنا.');
  static String get chooseGamePool => _t('Choose game pool', 'اختيار قائمة الألعاب');
  static String get splitTeams => _t('Split teams', 'تقسيم الفرق');
  static String get customPicker => _t('Custom picker', 'اختيار مخصص');
  static String get customPickerShort => _t('Custom', 'خياراتي');
  static String get customPickerDescription => _t(
        'Add any choices you want, keep them saved, then let the app pick one for you.',
        'أضف أي خيارات تريدها واحفظها، ثم دع التطبيق يختار واحداً منها عشوائياً.',
      );
  static String get customPickerResult => _t('Your pick', 'اختيارك');
  static String get addCustomOption => _t('Add option', 'إضافة خيار');
  static String get customOptionHint => _t('Write an option…', 'اكتب خياراً…');
  static String get editCustomOption => _t('Edit option', 'تعديل الخيار');
  static String get customOptions => _t('Options', 'الخيارات');
  static String get enabledOptions => _t('Enabled options', 'الخيارات المفعّلة');
  static String get enableAllOptions => _t('Enable all', 'تفعيل الكل');
  static String get disableAllOptions => _t('Disable all', 'تعطيل الكل');
  static String get pickCustomOption => _t('Pick one', 'اختر واحداً');
  static String get pickCustomAgain => _t('Pick again', 'اختر من جديد');
  static String get choosingCustomOption => _t('Choosing…', 'جاري الاختيار…');
  static String get noCustomOptions => _t(
        'Add your first option to start.',
        'أضف أول خيار للبدء.',
      );
  static String get customPickerNeedsOptions => _t(
        'Enable at least two options first.',
        'فعّل خيارين على الأقل أولاً.',
      );
  static String get customPickerSavedHint => _t(
        'Your options are saved on this device for next time.',
        'خياراتك محفوظة على هذا الجهاز للمرة القادمة.',
      );
  static String get pickGame => _t('Pick a game', 'اختر لعبة');
  static String get pickAgain => _t('Pick again', 'اختر من جديد');
  static String get emptyHeroTitle => _t('What are we playing?', 'ماذا سنلعب؟');
  static String get emptyHeroSubtitle => _t('One tap. No 20-minute argument.', 'ضغطة واحدة، بلا نقاش عشرين دقيقة.');
  static String get randomPoolHint => _t(
        'Enabled games + saved filters decide the random pool.',
        'الألعاب المفعّلة والفلاتر المحفوظة تحدد قائمة الاختيار العشوائي.',
      );
  static String get noGameMatches => _t(
        'No game matches the current selection and filters.',
        'لا توجد لعبة مطابقة للاختيار والفلاتر الحالية.',
      );
  static String get openGeneralsPicker => _t('Generals armies', 'جيوش جنرالز');
  static String get generalsFactionPicker => _t('Generals army picker', 'موزّع جيوش جنرالز');
  static String get generalsFactionPickerDescription => _t(
        'Randomly assign a Zero Hour army to every active player at once.',
        'وزّع جيشاً عشوائياً من Zero Hour على كل لاعب فعّال دفعة واحدة.',
      );
  static String get pickFaction => _t('Pick an army', 'اختر جيشاً');
  static String get assignArmies => _t('Assign armies', 'توزيع الجيوش');
  static String get assignAgain => _t('Assign again', 'إعادة التوزيع');
  static String get rollingArmies => _t('Shuffling armies…', 'جاري خلط الجيوش…');
  static String get generalsNeedsPlayers => _t(
        'Select at least two active players first.',
        'اختر لاعبين فعّالين على الأقل أولاً.',
      );
  static String get generalsResults => _t('Army assignments', 'توزيع الجيوش');

  static String get factionSuperweapon => _t('Superweapon', 'السوبر ويبن');
  static String get factionAirForce => _t('Air Force', 'القوات الجوية');
  static String get factionLaser => _t('Laser', 'الليزر');
  static String get factionStealth => _t('Stealth', 'التخفي');
  static String get factionToxin => _t('Toxin', 'السموم');
  static String get factionDemolition => _t('Demolition', 'التفجير');
  static String get factionGla => 'GLA';
  static String get factionNuke => _t('Nuke', 'النووي');
  static String get factionInfantry => _t('Infantry', 'المشاة');
  static String get factionTank => _t('Tank', 'الدبابات');

  static String get factionSuperweaponShort => _t('Super', 'سوبر');
  static String get factionAirForceShort => _t('Air', 'جوي');
  static String get factionLaserShort => _t('Laser', 'ليزر');
  static String get factionStealthShort => _t('Stealth', 'تخفي');
  static String get factionToxinShort => _t('Toxin', 'سموم');
  static String get factionDemolitionShort => _t('Demo', 'تفجير');
  static String get factionGlaShort => 'GLA';
  static String get factionNukeShort => _t('Nuke', 'نووي');
  static String get factionInfantryShort => _t('Inf', 'مشاة');
  static String get factionTankShort => _t('Tank', 'دبابات');


  static String get add => _t('Add', 'إضافة');
  static String get addPlayer => _t('Add player', 'إضافة لاعب');
  static String get addGame => _t('Add game', 'إضافة لعبة');
  static String get editGame => _t('Edit game', 'تعديل اللعبة');
  static String get removeGame => _t('Remove game', 'حذف اللعبة');
  static String get saveGame => _t('Save game', 'حفظ اللعبة');
  static String get gameName => _t('Game name', 'اسم اللعبة');
  static String get gameNameHint => _t('e.g. Rocket League', 'مثلاً: Rocket League');
  static String get gameDescription => _t('Description', 'الوصف');
  static String get gameDescriptionHint => _t('Short optional description', 'وصف مختصر اختياري');
  static String get minimumPlayers => _t('Minimum players', 'أقل عدد لاعبين');
  static String get maximumPlayers => _t('Maximum players', 'أكبر عدد لاعبين');
  static String get noMaximum => _t('No maximum', 'بدون حد أعلى');
  static String get gameModes => _t('Play modes', 'أنماط اللعب');
  static String get customGame => _t('Custom', 'مخصصة');
  static String get gameSavedLocally => _t(
        'Saved locally on this device.',
        'تم الحفظ محلياً على هذا الجهاز.',
      );
  static String get gameImage => _t('Game image', 'صورة اللعبة');
  static String get gameImageHint => _t(
        'Optional. The selected image is copied into app storage and kept for next time.',
        'اختيارية. تُنسخ الصورة إلى تخزين التطبيق وتبقى محفوظة للمرة القادمة.',
      );
  static String get chooseGameImage => _t('Choose image', 'اختر صورة');
  static String get changeGameImage => _t('Change image', 'تغيير الصورة');
  static String get removeGameImage => _t('Remove image', 'حذف الصورة');
  static String get gameImageTooLarge => _t(
        'Choose an image smaller than 12 MB.',
        'اختر صورة بحجم أقل من 12 ميغابايت.',
      );
  static String get gameImageReadFailed => _t(
        'Could not read this image. Try another JPG, PNG, or WebP file.',
        'تعذر قراءة هذه الصورة. جرّب ملف JPG أو PNG أو WebP آخر.',
      );
  static String get gameSaveFailed => _t(
        'Could not save the game. Please try again.',
        'تعذر حفظ اللعبة. حاول مرة أخرى.',
      );
  static String get chooseGameMode => _t(
        'Choose at least one play mode.',
        'اختر نمط لعب واحداً على الأقل.',
      );
  static String get invalidPlayerRange => _t(
        'Maximum players must be greater than or equal to minimum players.',
        'يجب أن يكون الحد الأعلى للاعبين أكبر من أو يساوي الحد الأدنى.',
      );
  static String removeGameTitle(String name) =>
      isArabic ? 'حذف $name؟' : 'Remove $name?';
  static String get removeGameWarning => _t(
        'This removes the game from this device. You can archive a game instead if you only want to hide it temporarily.',
        'سيتم حذف اللعبة من هذا الجهاز. إذا كنت تريد إخفاءها مؤقتاً فقط فاستخدم الأرشفة بدلاً من الحذف.',
      );
  static String get editPlayer => _t('Edit player', 'تعديل اللاعب');
  static String get delete => _t('Delete', 'حذف');
  static String get edit => _t('Edit', 'تعديل');
  static String get cancel => _t('Cancel', 'إلغاء');
  static String get saveChanges => _t('Save changes', 'حفظ التعديلات');
  static String get playerName => _t('Player name', 'اسم اللاعب');
  static String get playerNameHint => _t('e.g. Besher', 'مثلاً: بشير');
  static String get permanentPlayer => _t('Permanent player', 'لاعب دائم');
  static String get guestPlayer => _t('Guest player', 'لاعب ضيف');
  static String get permanentPlayerHint => _t('Saved locally for your next session.', 'يُحفظ محلياً للجلسات القادمة.');
  static String get guestPlayerHint => _t('Available now, but not saved to cache.', 'متاح لهذه الجلسة فقط ولا يُحفظ.');
  static String get playerCacheHint => _t(
        'Permanent players are cached on this device. Guests disappear after the app session.',
        'اللاعبون الدائمون محفوظون على الجهاز، بينما يختفي الضيوف بعد إغلاق التطبيق.',
      );
  static String get rosterHint => _t(
        'Check the players who are here today. Team generation uses only checked players.',
        'فعّل اللاعبين الموجودين اليوم؛ توليد الفرق يستخدم اللاعبين المفعّلين فقط.',
      );
  static String get selectAllSavedPlayers => _t('Select all saved players', 'تحديد كل اللاعبين المحفوظين');
  static String get deselectAllSavedPlayers => _t('Deselect all saved players', 'إلغاء تحديد اللاعبين المحفوظين');
  static String get clearAllGuests => _t('Clear all guests', 'حذف كل الضيوف');
  static String get managePlayerArchive =>
      _t('Manage player archive', 'إدارة أرشيف اللاعبين');
  static String get managePlayerArchiveHint => _t(
        'Archive regular players you do not need now and restore them anytime.',
        'أرشف اللاعبين الذين لا تحتاجهم الآن واستعدهم في أي وقت.',
      );
  static String get noSavedPlayers =>
      _t('No saved players on the current roster.', 'لا يوجد لاعبون محفوظون في القائمة الحالية.');
  static String get noArchivedPlayers =>
      _t('No archived players.', 'لا يوجد لاعبون مؤرشفون.');
  static String get savedPlayers => _t('Saved players', 'اللاعبون المحفوظون');
  static String get cachedOnDevice => _t('Cached on this device', 'محفوظون على هذا الجهاز');
  static String get guests => _t('Guests', 'الضيوف');
  static String get guest => _t('guest', 'ضيف');
  static String get guestBadge => _t('GUEST', 'ضيف');
  static String get guestsSessionOnly => _t('Session only • not cached', 'لهذه الجلسة فقط • غير محفوظ');
  static String get quickAddGuest => _t('Quick add guest', 'إضافة ضيف سريعاً');
  static String get includedInTeams => _t('Included in team generation', 'مشارك في توليد الفرق');
  static String get notPlayingThisSession => _t('Not playing this session', 'غير مشارك في هذه الجلسة');
  static String get buildPlayerCache => _t('Build your player cache', 'أنشئ قائمة لاعبيك');
  static String get buildPlayerCacheHint => _t(
        'Add your regular players once, then just check who is playing.',
        'أضف اللاعبين الدائمين مرة واحدة، ثم فعّل الموجودين في كل جلسة.',
      );
  static String get addFirstPlayer => _t('Add first player', 'أضف أول لاعب');
  static String get deleteGuestHint => _t('This guest will be removed from the current session.', 'سيتم حذف هذا الضيف من الجلسة الحالية.');
  static String get deletePermanentHint => _t('This player will be removed from the device cache.', 'سيتم حذف هذا اللاعب من ذاكرة الجهاز.');

  static String get teamBuilder => _t('Team builder', 'تقسيم الفرق');
  static String get fairTeamsTitle => _t('Fair-sized teams in one tap', 'فرق متوازنة بالحجم بضغطة واحدة');
  static String get numberOfTeams => _t('Number of teams', 'عدد الفرق');
  static String get generateTeams => _t('Generate teams', 'توليد الفرق');
  static String get shuffleAgain => _t('Shuffle again', 'خلط من جديد');
  static String get teamBuilderHint => _t(
        'Choose the team count and generate. Team sizes stay as even as possible.',
        'اختر عدد الفرق ثم ولّدها؛ نحافظ على تقارب أحجام الفرق قدر الإمكان.',
      );
  static String get teamRatingsNext => _t(
        'Next: balance teams using each player’s rating for the selected game.',
        'لاحقاً: موازنة الفرق باستخدام تقييم كل لاعب في اللعبة المختارة.',
      );
  static String get selectAtLeastTwoPlayers => _t('Select at least two players', 'اختر لاعبين على الأقل');
  static String get selectPlayersHint => _t(
        'Go to Players, add your regulars or guests, then check who is playing.',
        'اذهب إلى اللاعبين، أضف الدائمين أو الضيوف ثم فعّل المشاركين.',
      );

  static String get categoryVideo => _t('Video games', 'ألعاب فيديو');
  static String get categoryCard => _t('Card games', 'ألعاب ورق');
  static String get categorySport => _t('Sport & racing', 'رياضة وسباقات');
  static String get modeTwoPlayers => _t('2 players', 'لاعبان');
  static String get modeGroup => _t('3+ players', '3 لاعبين فأكثر');
  static String get modeLocal => _t('Local / couch', 'محلي / نفس الجهاز');
  static String get modeLan => 'LAN';
  static String get modeOnline => _t('Online', 'أونلاين');

  static String get gameAWayOutTitle => 'A Way Out';
  static String get gameAWayOutDescription => _t('Story-driven co-op built specifically for two players.', 'تجربة تعاونية قصصية مصممة خصيصاً للاعبين.');
  static String get gameAmongUsTitle => 'Among Us';
  static String get gameAmongUsDescription => _t('Social deduction for a group: complete tasks and find the impostors.', 'لعبة خداع اجتماعي جماعية: أنجزوا المهام واكتشفوا المحتالين.');
  static String get gameBack4BloodTitle => 'Back 4 Blood';
  static String get gameBack4BloodDescription => _t('Four-player co-op shooter built around team coordination.', 'تصويب تعاوني لأربعة لاعبين يعتمد على تنسيق الفريق.');
  static String get gameBattlefieldBadCompany2Title => 'Battlefield: Bad Company 2';
  static String get gameBattlefieldBadCompany2Description => _t('Classic squad-based Battlefield multiplayer.', 'باتلفيلد كلاسيكية تعتمد على اللعب الجماعي ضمن فرق.');
  static String get gameBattlefield2Title => 'Battlefield 2';
  static String get gameBattlefield2Description => _t('Classic Battlefield with excellent LAN support for larger local sessions.', 'باتلفيلد كلاسيكية ممتازة لجلسات LAN الكبيرة.');
  static String get gameBattlefield3Title => 'Battlefield 3';
  static String get gameBattlefield3Description => _t('Large-scale squad combat with vehicles and infantry.', 'معارك واسعة بالمركبات والمشاة ضمن فرق.');
  static String get gameBattlefield6Title => 'Battlefield 6';
  static String get gameBattlefield6Description => _t('Modern Battlefield sessions for larger online groups.', 'جلسات باتلفيلد حديثة للمجموعات الكبيرة أونلاين.');
  static String get gameBloodStrikeTitle => 'Blood Strike';
  static String get gameBloodStrikeDescription => _t('Fast free-to-play battle royale and squad shooter.', 'باتل رويال وتصويب جماعي سريع ومجاني.');
  static String get gameBorderlands2Title => 'Borderlands 2';
  static String get gameBorderlands2Description => _t('Loot-shooter campaign that works especially well with a co-op squad.', 'تصويب ونهب بقصة ممتازة للعب التعاوني ضمن مجموعة.');
  static String get gameBuckshotRouletteTitle => 'Buckshot Roulette';
  static String get gameBuckshotRouletteDescription => _t('Short, tense multiplayer rounds built around risk and bluffing.', 'جولات قصيرة ومتوترة تعتمد على المخاطرة والخداع.');
  static String get gameChainedTogetherTitle => 'Chained Together';
  static String get gameChainedTogetherDescription => _t('Co-op platforming where everyone succeeds or falls together.', 'منصات تعاونية ينجح فيها الجميع أو يسقطون معاً.');
  static String get gameGeneralsZeroHourTitle => 'C&C: Generals – Zero Hour';
  static String get gameGeneralsZeroHourDescription => _t('The classic RTS pick for LAN matches, free-for-all, and team battles.', 'خيار الاستراتيجية الكلاسيكي لمباريات LAN والكل ضد الكل والفرق.');
  static String get gameGeneralsShockWaveTitle => 'Generals: ShockWave';
  static String get gameGeneralsShockWaveDescription => _t('Zero Hour with extra factions, units, and chaotic LAN matchups.', 'Zero Hour مع جيوش ووحدات إضافية ومباريات LAN أكثر جنوناً.');
  static String get gameCounterStrike16Title => 'Counter-Strike 1.6';
  static String get gameCounterStrike16Description => _t('Fast classic Counter-Strike for local servers and LAN nights.', 'كاونتر سترايك الكلاسيكية للسيرفرات المحلية وليالي LAN.');
  static String get gameCounterStrikeSourceTitle => 'Counter-Strike: Source';
  static String get gameCounterStrikeSourceDescription => _t('Classic team-based Counter-Strike with excellent LAN support.', 'كاونتر سترايك جماعية كلاسيكية بدعم ممتاز لـ LAN.');
  static String get gameEmberKnightsTitle => 'Ember Knights';
  static String get gameEmberKnightsDescription => _t('Quick co-op roguelite runs for up to four players.', 'جولات Roguelite تعاونية سريعة حتى أربعة لاعبين.');
  static String get gameFarCry2Title => 'Far Cry 2';
  static String get gameFarCry2Description => _t('Classic competitive multiplayer for old-school LAN sessions.', 'تنافس كلاسيكي مناسب لجلسات LAN القديمة.');
  static String get gameGtaVTitle => 'Grand Theft Auto V / Online';
  static String get gameGtaVDescription => _t('Open-world multiplayer sessions, races, missions, and custom modes.', 'عالم مفتوح متعدد اللاعبين مع سباقات ومهمات وأنماط مخصصة.');
  static String get gameItTakesTwoTitle => 'It Takes Two';
  static String get gameItTakesTwoDescription => _t('Purpose-built two-player co-op with constantly changing mechanics.', 'تعاونية مصممة للاعبين مع أفكار وآليات تتغير باستمرار.');
  static String get gameLeft4Dead2Title => 'Left 4 Dead 2';
  static String get gameLeft4Dead2Description => _t('A four-player co-op classic for campaigns, versus, and LAN sessions.', 'كلاسيكية تعاونية لأربعة لاعبين للحملات والمواجهة وLAN.');
  static String get gameLockdownProtocolTitle => 'LOCKDOWN Protocol';
  static String get gameLockdownProtocolDescription => _t('Social deduction and co-op objectives for a medium-sized group.', 'خداع اجتماعي ومهام تعاونية لمجموعة متوسطة.');
  static String get gameMortalKombat11Title => 'Mortal Kombat 11';
  static String get gameMortalKombat11Description => _t('One-on-one fighting for quick local or online challenges.', 'قتال واحد ضد واحد لتحديات محلية أو أونلاين سريعة.');
  static String get gameNarutoNinjaWorldBattle2Title => 'Naruto Ninja World Battle 2';
  static String get gameNarutoNinjaWorldBattle2Description => _t('Local Naruto battles from your multiplayer collection.', 'معارك ناروتو محلية من مجموعة ألعابك.');
  static String get gameNarutoStorm4Title => 'Naruto Shippuden: Ultimate Ninja Storm 4';
  static String get gameNarutoStorm4Description => _t('Anime arena battles with fast two-player versus matches.', 'قتال أنمي سريع في الحلبة لمواجهات لاعبين.');
  static String get gameNarutoUltimateNinja2Title => 'Naruto: Ultimate Ninja 2';
  static String get gameNarutoUltimateNinja2Description => _t('Local two-player Naruto fighting for short head-to-head matches.', 'قتال ناروتو محلي للاعبين ومواجهات قصيرة مباشرة.');
  static String get gameRoadRedemptionTitle => 'Road Redemption';
  static String get gameRoadRedemptionDescription => _t('Combat racing with local split-screen and multiplayer options.', 'سباقات قتالية مع شاشة منقسمة وخيارات متعددة اللاعبين.');
  static String get gameSamuraiWarriors5Title => 'Samurai Warriors 5';
  static String get gameSamuraiWarriors5Description => _t('Hack-and-slash battles that can be played cooperatively.', 'معارك Hack-and-slash يمكن لعبها بشكل تعاوني.');
  static String get gameSonsOfTheForestTitle => 'Sons of the Forest';
  static String get gameSonsOfTheForestDescription => _t('Survival, building, and exploration for an online co-op group.', 'بقاء وبناء واستكشاف لمجموعة تعاونية أونلاين.');
  static String get gameTmntBattleNexus2Title => 'TMNT 2: Battle Nexus';
  static String get gameTmntBattleNexus2Description => _t('Couch co-op Ninja Turtles action for a small local group.', 'أكشن تعاوني محلي لسلاحف النينجا لمجموعة صغيرة.');
  static String get gameTmntMutantNightmare3Title => 'TMNT 3: Mutant Nightmare';
  static String get gameTmntMutantNightmare3Description => _t('Local couch co-op with the Ninja Turtles.', 'تعاوني محلي مع سلاحف النينجا.');
  static String get gameTwistedMetal2Title => 'Twisted Metal 2';
  static String get gameTwistedMetal2Description => _t('Old-school local vehicular combat for two players.', 'قتال مركبات كلاسيكي محلي للاعبين.');
  static String get gameValorantTitle => 'VALORANT';
  static String get gameValorantDescription => _t('Competitive tactical 5v5 for an online squad.', 'تنافس تكتيكي 5 ضد 5 لفريق أونلاين.');
  static String get gameWarcraft3FrozenThroneTitle => 'Warcraft III: The Frozen Throne';
  static String get gameWarcraft3FrozenThroneDescription => _t('Classic RTS and custom maps for LAN or online groups.', 'استراتيجية كلاسيكية وخرائط مخصصة لمجموعات LAN أو أونلاين.');
  static String get gameWormsUltimateMayhemTitle => 'Worms Ultimate Mayhem';
  static String get gameWormsUltimateMayhemDescription => _t('Turn-based chaos for couch or online groups.', 'فوضى تبادل أدوار للمجموعات المحلية أو الأونلاين.');
  static String get gamePes2010Title => 'PES 2010';
  static String get gamePes2010Description => _t('Classic local football matches and mini tournaments.', 'مباريات كرة قدم محلية كلاسيكية وبطولات صغيرة.');
  static String get gamePes2016Title => 'PES 2016';
  static String get gamePes2016Description => _t('Fast local football matches with classic PES couch multiplayer.', 'مباريات كرة قدم محلية سريعة بطابع PES الكلاسيكي.');
  static String get gamePes2019Title => 'PES 2019';
  static String get gamePes2019Description => _t('Local football matches for head-to-head games and tournaments.', 'مباريات كرة قدم محلية للمواجهات والبطولات.');
  static String get gamePes2021Title => 'eFootball PES 2021';
  static String get gamePes2021Description => _t('A strong local football option for quick matches and tournaments.', 'خيار قوي لكرة القدم المحلية للمباريات والبطولات السريعة.');
  static String get gameNfsCarbonTitle => 'Need for Speed: Carbon';
  static String get gameNfsCarbonDescription => _t('Arcade street racing from your multiplayer collection.', 'سباقات شوارع أركيد من مجموعة ألعابك.');
  static String get gameNfsMostWantedTitle => 'Need for Speed: Most Wanted';
  static String get gameNfsMostWantedDescription => _t('Arcade street racing from your classic multiplayer rotation.', 'سباقات شوارع أركيد من قائمة ألعابك الكلاسيكية.');
  static String get gameUnoTitle => 'UNO';
  static String get gameUnoDescription => _t('Fast card rounds that work with almost any group.', 'جولات ورق سريعة تناسب تقريباً أي مجموعة.');
  static String get gameTarneebTitle => _t('Tarneeb', 'طرنيب');
  static String get gameTarneebDescription => _t('Traditional four-player trick-taking card game.', 'لعبة الورق الشامية المعروفة لأربعة لاعبين بنظام اللمات.');
  static String get gameTarneeb41Title => _t('Tarneeb 41', 'طرنيب 41');
  static String get gameTarneeb41Description => _t('A familiar Tarneeb variant for a four-player table.', 'نسخة طرنيب 41 المعروفة لأربعة لاعبين.');
  static String get gameTrixTitle => _t('Trix', 'تركس');
  static String get gameTrixDescription => _t('Classic Levantine Trix with kingdoms and multiple contracts.', 'تركس الشامية الكلاسيكية بنظام الممالك والعقود المتعددة.');
  static String get gameCoupTitle => 'Coup';
  static String get gameCoupDescription => _t('Fast bluffing and social deduction for 2–6 players.', 'لعبة خداع وقراءة خصوم سريعة من لاعبين إلى 6 لاعبين.');
  static String get gameIstimarTitle => _t('Istimar', 'استعمار');
  static String get gameIstimarDescription => _t('Three-player Tarneeb-derived card game with rotating trick targets and strategic card exchanges.', 'لعبة ورق لثلاثة لاعبين مشتقة من الطرنيب، تعتمد على أهداف لمّات متغيّرة وتبادل الأوراق بشكل استراتيجي.');

  static String enabledPoolSummary(int enabled, int pool) => isArabic
      ? '$enabled مفعّلة • $pool ضمن العشوائي'
      : '$enabled enabled • $pool currently in random pool';

  static String gamesInPool(int count) => isArabic
      ? '$count لعبة ضمن القائمة'
      : '$count game${count == 1 ? '' : 's'} in the pool';

  static String activePlayersReady(int count) => isArabic
      ? '$count لاعب جاهز'
      : '$count ready to play';

  static String savedAndGuestPlayers(int saved, int guests) => isArabic
      ? '$saved محفوظ • $guests ضيف'
      : '$saved saved • $guests guest${guests == 1 ? '' : 's'}';

  static String deletePlayerTitle(String name) =>
      isArabic ? 'حذف $name؟' : 'Delete $name?';

  static String customOptionsEnabled(int enabled, int total) => isArabic
      ? '$enabled من $total مفعّل'
      : '$enabled of $total enabled';

  static String selectedPlayers(int count) => isArabic
      ? '$count لاعب محدد. الضيوف يعملون مثل اللاعبين المحفوظين خلال هذه الجلسة.'
      : '$count selected player${count == 1 ? '' : 's'}. Guests work exactly like saved players for this session.';

  static String selectAtLeastPlayers(int count) =>
      isArabic ? 'اختر $count لاعبين على الأقل أولاً.' : 'Select at least $count players first.';

  static String teamLabel(int index) => isArabic ? 'الفريق $index' : 'Team $index';

  static String gameLibrarySummary(int shown, int enabled, int inPool) => isArabic
      ? '$shown ظاهرة • $enabled مفعّلة • $inPool بالعشوائي'
      : '$shown shown • $enabled enabled • $inPool in pool';

  static String archivedCount(int count) =>
      isArabic ? '$count مؤرشفة' : '$count archived';

  static String archivedPlayersCount(int count) =>
      isArabic ? '$count مؤرشف' : '$count archived';

  static String onBoardCount(int count) =>
      isArabic ? 'على اللوحة ($count)' : 'On board ($count)';

  static String rosterCount(int count) =>
      isArabic ? 'القائمة ($count)' : 'Roster ($count)';

  static String selectedCount(int count) =>
      isArabic ? '$count محدد' : '$count selected';

  static String archiveSelected(int count) => isArabic
      ? 'أرشفة المحدد ($count)'
      : 'Archive selected ($count)';

  static String restoreSelected(int count) => isArabic
      ? 'استعادة المحدد ($count)'
      : 'Restore selected ($count)';

  static String minPlayers(int min) => isArabic ? '$min+ لاعبين' : '$min+ players';
  static String exactPlayers(int count) => isArabic ? '$count لاعبين' : '$count players';
  static String playerRange(int min, int max) => isArabic ? '$min–$max لاعبين' : '$min–$max players';
}
