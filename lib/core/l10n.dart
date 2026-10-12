import 'package:flutter/widgets.dart';
import 'package:flutter_tests/core/app_state.dart';

enum AppLang {
  uz('Oʻzbekcha', Locale('uz')),
  uzCrl('Ўзбекча', Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl')),
  ru('Русский', Locale('ru')),
  en('English', Locale('en'));

  final String label;
  final Locale locale;
  const AppLang(this.label, this.locale);
}

extension Tr on BuildContext {
  /// Translates [key] into the current app language. `{name}` placeholders
  /// are replaced from [args].
  String tr(String key, [Map<String, String>? args]) {
    // Registers a dependency so widgets rebuild when the language changes.
    Localizations.maybeLocaleOf(this);
    return translate(AppState.instance.lang, key, args);
  }
}

String translate(AppLang lang, String key, [Map<String, String>? args]) {
  final row = _strings[key];
  var s = row == null ? key : row[lang.index];
  args?.forEach((k, v) => s = s.replaceAll('{$k}', v));
  return s;
}

// [uz (Latin), uz (Cyrillic), ru, en]
const Map<String, List<String>> _strings = {
  'app_name': ['Maktab testlari', 'Мактаб тестлари', 'Школьные тесты', 'School Tests'],
  'app_tagline': ['Bilimingizni sinang', 'Билимингизни синанг', 'Проверьте свои знания', 'Test your knowledge'],
  'home': ['Bosh sahifa', 'Бош саҳифа', 'Главная', 'Home'],
  'stats': ['Statistika', 'Статистика', 'Статистика', 'Statistics'],
  'settings': ['Sozlamalar', 'Созламалар', 'Настройки', 'Settings'],
  'telegram': ['Telegram kanal', 'Телеграм канал', 'Telegram-канал', 'Telegram channel'],
  'share_app': ['Doʻstlarga ulashish', 'Дўстларга улашиш', 'Поделиться с друзьями', 'Share with friends'],
  'share_app_text': ['Maktab testlari — sinf va fanlar boʻyicha testlar. Bilimingizni sinab koʻring!', 'Мактаб тестлари — синф ва фанлар бўйича тестлар. Билимингизни синаб кўринг!', 'Школьные тесты — тесты по классам и предметам. Проверьте свои знания!', 'School Tests — quizzes by grade and subject. Test your knowledge!'],
  'rate_app': ['Ilovani baholash', 'Иловани баҳолаш', 'Оценить приложение', 'Rate the app'],
  'feedback': ['Fikr bildirish', 'Фикр билдириш', 'Обратная связь', 'Send feedback'],
  'feedback_subject': ['Maktab testlari: taklif', 'Мактаб тестлари: таклиф', 'Школьные тесты: отзыв', 'School Tests: feedback'],
  'privacy': ['Maxfiylik siyosati', 'Махфийлик сиёсати', 'Политика конфиденциальности', 'Privacy policy'],
  'about': ['Dastur haqida', 'Дастур ҳақида', 'О приложении', 'About'],
  'version': ['Versiya', 'Версия', 'Версия', 'Version'],

  // Onboarding
  'skip': ['Oʻtkazib yuborish', 'Ўтказиб юбориш', 'Пропустить', 'Skip'],
  'next': ['Keyingi', 'Кейинги', 'Далее', 'Next'],
  'start': ['Boshlash', 'Бошлаш', 'Начать', 'Get started'],
  'onb_lang_title': ['Tilni tanlang', 'Тилни танланг', 'Выберите язык', 'Choose a language'],
  'onb_lang_text': ['Savollar va ilova shu tilda koʻrsatiladi. Keyin sozlamalardan oʻzgartirish mumkin.', 'Саволлар ва илова шу тилда кўрсатилади. Кейин созламалардан ўзгартириш мумкин.', 'Вопросы и интерфейс будут на этом языке. Его можно изменить в настройках.', 'Questions and the app will use this language. You can change it later in settings.'],
  'onb1_title': ['Mashq rejimi', 'Машқ режими', 'Режим практики', 'Practice mode'],
  'onb1_text': ['Har bir javobdan soʻng toʻgʻri javob va izoh darhol koʻrsatiladi. Progress avtomatik saqlanadi.', 'Ҳар бир жавобдан сўнг тўғри жавоб ва изоҳ дарҳол кўрсатилади. Прогресс автоматик сақланади.', 'После каждого ответа сразу видно правильный вариант и пояснение. Прогресс сохраняется.', 'See the correct answer and explanation right after each answer. Progress is saved automatically.'],
  'onb2_title': ['Imtihon rejimi', 'Имтиҳон режими', 'Режим экзамена', 'Exam mode'],
  'onb2_text': ['Vaqt cheklangan, savollar aralashtirilgan, natija faqat oxirida. Haqiqiy imtihonga tayyorlaning.', 'Вақт чекланган, саволлар аралаштирилган, натижа фақат охирида. Ҳақиқий имтиҳонга тайёрланинг.', 'Ограниченное время, перемешанные вопросы, результат в конце. Готовьтесь к настоящему экзамену.', 'Timed, shuffled questions, results only at the end. Prepare for the real exam.'],
  'onb3_title': ['Natijalaringizni kuzating', 'Натижаларингизни кузатинг', 'Следите за успехами', 'Track your progress'],
  'onb3_text': ['Kunlik seriya, yutuqlar, statistika va xatolar ustida ishlash — barchasi bir joyda.', 'Кунлик серия, ютуқлар, статистика ва хатолар устида ишлаш — барчаси бир жойда.', 'Серии дней, достижения, статистика и работа над ошибками — всё в одном месте.', 'Daily streaks, achievements, statistics and mistake review — all in one place.'],

  // Home
  'streak_days': ['kun', 'кун', 'дн.', 'days'],
  'today': ['Bugun', 'Бугун', 'Сегодня', 'Today'],
  'accuracy': ['Aniqlik', 'Аниқлик', 'Точность', 'Accuracy'],
  'favorites': ['Sevimli mavzular', 'Севимли мавзулар', 'Избранные темы', 'Favorite topics'],
  'choose_class': ['Sinfni tanlang', 'Синфни танланг', 'Выберите класс', 'Choose a grade'],
  'continue_test': ['Davom ettirish', 'Давом эттириш', 'Продолжить', 'Continue'],
  'search_subject': ['Fanni qidirish', 'Фанни қидириш', 'Поиск предмета', 'Search subjects'],
  'search_topic': ['Mavzuni qidirish', 'Мавзуни қидириш', 'Поиск темы', 'Search topics'],
  'nothing_found': ['Hech narsa topilmadi', 'Ҳеч нарса топилмади', 'Ничего не найдено', 'Nothing found'],
  'clear': ['Tozalash', 'Тозалаш', 'Очистить', 'Clear'],
  'offline_mode': ['Internet yoʻq — saqlangan maʼlumotlar koʻrsatilmoqda', 'Интернет йўқ — сақланган маълумотлар кўрсатилмоқда', 'Нет интернета — показаны сохранённые данные', 'Offline — showing saved data'],

  // Topics
  'book_progress': ['Fan boʻyicha progress', 'Фан бўйича прогресс', 'Прогресс по предмету', 'Subject progress'],
  'topics_done': ['{done} / {total} mavzu yakunlangan', '{done} / {total} мавзу якунланган', 'Пройдено тем: {done} из {total}', '{done} of {total} topics completed'],
  'filter_all': ['Hammasi', 'Ҳаммаси', 'Все', 'All'],
  'filter_new': ['Boshlanmagan', 'Бошланмаган', 'Не начатые', 'Not started'],
  'filter_progress': ['Jarayonda', 'Жараёнда', 'В процессе', 'In progress'],
  'filter_done': ['Yakunlangan', 'Якунланган', 'Пройденные', 'Completed'],
  'status_new': ['Boshlanmagan', 'Бошланмаган', 'Не начата', 'Not started'],
  'status_started': ['{answered} ta savol yechildi', '{answered} та савол ечилди', 'Решено вопросов: {answered}', '{answered} questions answered'],
  'status_progress': ['{answered} / {total} savol yechildi', '{answered} / {total} савол ечилди', 'Решено {answered} из {total}', '{answered} of {total} answered'],
  'status_done': ['Yakunlangan · {percent}% toʻgʻri', 'Якунланган · {percent}% тўғри', 'Пройдена · {percent}% верно', 'Completed · {percent}% correct'],
  'fav_add': ['Sevimlilarga qoʻshish', 'Севимлиларга қўшиш', 'В избранное', 'Add to favorites'],
  'fav_remove': ['Sevimlilardan olib tashlash', 'Севимлилардан олиб ташлаш', 'Убрать из избранного', 'Remove from favorites'],

  // Mode sheet
  'mode_practice': ['Mashq rejimi', 'Машқ режими', 'Практика', 'Practice'],
  'mode_practice_desc': ['Javob darhol tekshiriladi, izoh koʻrsatiladi', 'Жавоб дарҳол текширилади, изоҳ кўрсатилади', 'Ответ проверяется сразу, есть пояснения', 'Instant feedback with explanations'],
  'mode_exam': ['Imtihon rejimi', 'Имтиҳон режими', 'Экзамен', 'Exam'],
  'mode_exam_desc': ['Vaqt cheklangan, natija oxirida', 'Вақт чекланган, натижа охирида', 'На время, результат в конце', 'Timed, results at the end'],
  'mode_exam_desc_min': ['{min} daqiqa, natija oxirida', '{min} дақиқа, натижа охирида', '{min} мин, результат в конце', '{min} min, results at the end'],
  'restart_practice': ['Qaytadan boshlash', 'Қайтадан бошлаш', 'Начать заново', 'Start over'],
  'review_answers': ['Javoblarni koʻrish', 'Жавобларни кўриш', 'Посмотреть ответы', 'Review answers'],

  // Quiz
  'question_of': ['Savol {n} / {total}', 'Савол {n} / {total}', 'Вопрос {n} из {total}', 'Question {n} of {total}'],
  'answered_of': ['Belgilandi: {n}/{total}', 'Белгиланди: {n}/{total}', 'Отмечено: {n}/{total}', 'Answered: {n}/{total}'],
  'all_questions': ['Barcha savollar', 'Барча саволлар', 'Все вопросы', 'All questions'],
  'next_question': ['Keyingi savol', 'Кейинги савол', 'Следующий', 'Next question'],
  'previous': ['Oldingi', 'Олдинги', 'Назад', 'Previous'],
  'finish': ['Yakunlash', 'Якунлаш', 'Завершить', 'Finish'],
  'finish_confirm_title': ['Testni yakunlaysizmi?', 'Тестни якунлайсизми?', 'Завершить тест?', 'Finish the test?'],
  'finish_confirm_text': ['{n} ta savol belgilanmagan. Ular xato hisoblanadi.', '{n} та савол белгиланмаган. Улар хато ҳисобланади.', 'Без ответа: {n}. Они будут засчитаны как неверные.', '{n} questions are unanswered and will count as incorrect.'],
  'keep_going': ['Davom etish', 'Давом этиш', 'Продолжить', 'Keep going'],
  'exit': ['Chiqish', 'Чиқиш', 'Выйти', 'Leave'],
  'exit_exam_title': ['Imtihondan chiqasizmi?', 'Имтиҳондан чиқасизми?', 'Выйти из экзамена?', 'Leave the exam?'],
  'exit_exam_text': ['Javoblaringiz saqlanmaydi.', 'Жавобларингиз сақланмайди.', 'Ваши ответы не сохранятся.', 'Your answers will not be saved.'],
  'restart': ['Qayta boshlash', 'Қайта бошлаш', 'Начать заново', 'Restart'],
  'restart_confirm': ['Bu mavzudagi barcha javoblaringiz oʻchiriladi.', 'Бу мавзудаги барча жавобларингиз ўчирилади.', 'Все ваши ответы по этой теме будут удалены.', 'All your answers in this topic will be cleared.'],
  'cancel': ['Bekor qilish', 'Бекор қилиш', 'Отмена', 'Cancel'],
  'time_up': ['Vaqt tugadi!', 'Вақт тугади!', 'Время вышло!', 'Time is up!'],
  'topic_completed_hint': ['Bu mavzu yakunlangan. Javoblarni koʻrib chiqishingiz mumkin.', 'Бу мавзу якунланган. Жавобларни кўриб чиқишингиз мумкин.', 'Тема пройдена. Можно просмотреть ответы.', 'This topic is complete. You can review your answers.'],
  'see_result': ['Natija', 'Натижа', 'Результат', 'Result'],
  'feedback_right': ['Toʻgʻri! Barakalla 🎉', 'Тўғри! Баракалла 🎉', 'Верно! Отлично 🎉', 'Correct! Well done 🎉'],
  'feedback_wrong': ['Notoʻgʻri. Toʻgʻri javob: {letter}', 'Нотўғри. Тўғри жавоб: {letter}', 'Неверно. Правильный ответ: {letter}', 'Incorrect. The right answer is {letter}'],
  'explanation': ['Izoh', 'Изоҳ', 'Пояснение', 'Explanation'],
  'selected': ['tanlangan', 'танланган', 'выбрано', 'selected'],
  'zoom_image': ['Rasmni kattalashtirish', 'Расмни катталаштириш', 'Увеличить изображение', 'Zoom image'],
  'report': ['Xato haqida xabar berish', 'Хато ҳақида хабар бериш', 'Сообщить об ошибке', 'Report a problem'],
  'report_question': ['Savolda xato bormi?', 'Саволда хато борми?', 'Ошибка в вопросе?', 'Problem with this question?'],
  'report_subject': ['Savolda xato', 'Саволда хато', 'Ошибка в вопросе', 'Question problem'],
  'report_body': ['Xatoni tasvirlab bering:', 'Хатони тасвирлаб беринг:', 'Опишите ошибку:', 'Describe the problem:'],
  'legend_right': ['Toʻgʻri', 'Тўғри', 'Верно', 'Correct'],
  'legend_wrong': ['Xato', 'Хато', 'Ошибки', 'Wrong'],
  'legend_empty': ['Belgilanmagan', 'Белгиланмаган', 'Без ответа', 'Unanswered'],
  'legend_answered': ['Belgilangan', 'Белгиланган', 'Отвечено', 'Answered'],

  // Result
  'result': ['Natija', 'Натижа', 'Результат', 'Result'],
  'time': ['Vaqt', 'Вақт', 'Время', 'Time'],
  'grade_excellent': ['Aʼlo natija!', 'Аъло натижа!', 'Отлично!', 'Excellent!'],
  'grade_good': ['Yaxshi natija!', 'Яхши натижа!', 'Хороший результат!', 'Good job!'],
  'grade_ok': ['Yomon emas', 'Ёмон эмас', 'Неплохо', 'Not bad'],
  'grade_low': ['Yana bir bor urinib koʻring', 'Яна бир бор уриниб кўринг', 'Попробуйте ещё раз', 'Give it another try'],
  'review_mistakes': ['Xatolar ustida ishlash ({n})', 'Хатолар устида ишлаш ({n})', 'Работа над ошибками ({n})', 'Review mistakes ({n})'],
  'review_all': ['Barcha javoblarni koʻrish', 'Барча жавобларни кўриш', 'Все ответы', 'Review all answers'],
  'next_topic': ['Keyingi mavzu', 'Кейинги мавзу', 'Следующая тема', 'Next topic'],
  'back_to_topics': ['Mavzularga qaytish', 'Мавзуларга қайтиш', 'К списку тем', 'Back to topics'],
  'share': ['Ulashish', 'Улашиш', 'Поделиться', 'Share'],
  'share_result': ['Men "{subject}" fanidan "{topic}" mavzusida {correct}/{total} ({percent}%) natija koʻrsatdim! Siz ham sinab koʻring: {url}', 'Мен "{subject}" фанидан "{topic}" мавзусида {correct}/{total} ({percent}%) натижа кўрсатдим! Сиз ҳам синаб кўринг: {url}', 'Я набрал {correct}/{total} ({percent}%) по теме «{topic}» ({subject})! Попробуйте и вы: {url}', 'I scored {correct}/{total} ({percent}%) on "{topic}" ({subject})! Try it too: {url}'],
  'review_title': ['Javoblarni tahlil qilish', 'Жавобларни таҳлил қилиш', 'Разбор ответов', 'Answer review'],
  'review_empty': ['Bu yerda savollar yoʻq — ajoyib!', 'Бу ерда саволлар йўқ — ажойиб!', 'Здесь нет вопросов — отлично!', 'Nothing here — great!'],

  // Stats
  'streak_current': ['Joriy seriya (kun)', 'Жорий серия (кун)', 'Текущая серия (дн.)', 'Current streak (days)'],
  'streak_best': ['Eng uzun seriya', 'Энг узун серия', 'Лучшая серия', 'Best streak'],
  'tests_taken': ['Testlar', 'Тестлар', 'Тестов', 'Tests'],
  'questions_answered': ['Savollar', 'Саволлар', 'Вопросов', 'Questions'],
  'last_7_days': ['Soʻnggi 7 kun', 'Сўнгги 7 кун', 'Последние 7 дней', 'Last 7 days'],
  'weekdays_short': ['Du,Se,Ch,Pa,Ju,Sh,Ya', 'Ду,Се,Чо,Па,Жу,Ша,Як', 'Пн,Вт,Ср,Чт,Пт,Сб,Вс', 'Mon,Tue,Wed,Thu,Fri,Sat,Sun'],
  'achievements': ['Yutuqlar', 'Ютуқлар', 'Достижения', 'Achievements'],
  'history': ['Soʻnggi natijalar', 'Сўнгги натижалар', 'Последние результаты', 'Recent results'],
  'history_empty': ['Hali test yechilmagan. Birinchi testni boshlang!', 'Ҳали тест ечилмаган. Биринчи тестни бошланг!', 'Тестов пока нет. Начните первый!', 'No tests yet. Start your first one!'],
  'ach_first': ['Ilk qadam', 'Илк қадам', 'Первый шаг', 'First step'],
  'ach_first_desc': ['Birinchi testni yakunlang', 'Биринчи тестни якунланг', 'Завершите первый тест', 'Finish your first test'],
  'ach_perfect': ['Mukammal', 'Мукаммал', 'Идеально', 'Perfect'],
  'ach_perfect_desc': ['100% natija oling', '100% натижа олинг', 'Наберите 100%', 'Score 100%'],
  'ach_streak3': ['3 kunlik seriya', '3 кунлик серия', 'Серия 3 дня', '3-day streak'],
  'ach_streak3_desc': ['3 kun ketma-ket shugʻullaning', '3 кун кетма-кет шуғулланинг', 'Занимайтесь 3 дня подряд', 'Practice 3 days in a row'],
  'ach_streak7': ['Haftalik seriya', 'Ҳафталик серия', 'Неделя подряд', '7-day streak'],
  'ach_streak7_desc': ['7 kun ketma-ket shugʻullaning', '7 кун кетма-кет шуғулланинг', 'Занимайтесь 7 дней подряд', 'Practice 7 days in a row'],
  'ach_q100': ['100 savol', '100 савол', '100 вопросов', '100 questions'],
  'ach_q100_desc': ['100 ta savolga javob bering', '100 та саволга жавоб беринг', 'Ответьте на 100 вопросов', 'Answer 100 questions'],
  'ach_q500': ['500 savol', '500 савол', '500 вопросов', '500 questions'],
  'ach_q500_desc': ['500 ta savolga javob bering', '500 та саволга жавоб беринг', 'Ответьте на 500 вопросов', 'Answer 500 questions'],
  'ach_exam': ['Imtihon ustasi', 'Имтиҳон устаси', 'Мастер экзаменов', 'Exam master'],
  'ach_exam_desc': ['Imtihonda 80%+ oling', 'Имтиҳонда 80%+ олинг', 'Наберите 80%+ на экзамене', 'Score 80%+ in an exam'],
  'ach_topics10': ['Bilimdon', 'Билимдон', 'Знаток', 'Scholar'],
  'ach_topics10_desc': ['10 ta mavzuni yakunlang', '10 та мавзуни якунланг', 'Пройдите 10 тем', 'Complete 10 topics'],

  // Settings
  'settings_language': ['Til', 'Тил', 'Язык', 'Language'],
  'settings_appearance': ['Koʻrinish', 'Кўриниш', 'Оформление', 'Appearance'],
  'settings_quiz': ['Test', 'Тест', 'Тест', 'Quiz'],
  'settings_data': ['Maʼlumotlar', 'Маълумотлар', 'Данные', 'Data'],
  'theme_system': ['Tizim', 'Тизим', 'Система', 'System'],
  'theme_light': ['Yorugʻ', 'Ёруғ', 'Светлая', 'Light'],
  'theme_dark': ['Tungi', 'Тунги', 'Тёмная', 'Dark'],
  'text_size': ['Matn oʻlchami', 'Матн ўлчами', 'Размер текста', 'Text size'],
  'text_preview': ['Namuna: Oʻzbekiston poytaxti qaysi shahar?', 'Намуна: Ўзбекистон пойтахти қайси шаҳар?', 'Пример: Какой город — столица Узбекистана?', 'Sample: Which city is the capital of Uzbekistan?'],
  'sound': ['Tovush effektlari', 'Товуш эффектлари', 'Звуковые эффекты', 'Sound effects'],
  'haptics': ['Tebranish', 'Тебраниш', 'Вибрация', 'Vibration'],
  'auto_next': ['Keyingi savolga avtomatik oʻtish', 'Кейинги саволга автоматик ўтиш', 'Автопереход к следующему', 'Auto-advance'],
  'auto_next_desc': ['Toʻgʻri javobdan soʻng', 'Тўғри жавобдан сўнг', 'После правильного ответа', 'After a correct answer'],
  'shuffle': ['Javoblarni aralashtirish', 'Жавобларни аралаштириш', 'Перемешивать ответы', 'Shuffle answers'],
  'shuffle_desc': ['Mashq rejimida ham', 'Машқ режимида ҳам', 'Также в режиме практики', 'Also in practice mode'],
  'reminders': ['Kunlik eslatma', 'Кунлик эслатма', 'Ежедневное напоминание', 'Daily reminder'],
  'reminders_desc': ['Har kuni shugʻullanishni eslatamiz', 'Ҳар куни шуғулланишни эслатамиз', 'Напомним позаниматься', 'We will remind you to practice'],
  'clear_cache': ['Keshni tozalash', 'Кешни тозалаш', 'Очистить кэш', 'Clear cache'],
  'clear_cache_desc': ['Saqlangan testlar qayta yuklanadi', 'Сақланган тестлар қайта юкланади', 'Сохранённые тесты загрузятся заново', 'Saved tests will be downloaded again'],
  'reset_progress': ['Progressni oʻchirish', 'Прогрессни ўчириш', 'Сбросить прогресс', 'Reset progress'],
  'reset_progress_desc': ['Javoblar, natijalar va statistika', 'Жавоблар, натижалар ва статистика', 'Ответы, результаты и статистика', 'Answers, results and statistics'],
  'reset_progress_confirm': ['Barcha javoblar, natijalar va statistika oʻchiriladi. Buni qaytarib boʻlmaydi.', 'Барча жавоблар, натижалар ва статистика ўчирилади. Буни қайтариб бўлмайди.', 'Все ответы, результаты и статистика будут удалены. Это нельзя отменить.', 'All answers, results and statistics will be deleted. This cannot be undone.'],
  'delete': ['Oʻchirish', 'Ўчириш', 'Удалить', 'Delete'],
  'done': ['Bajarildi', 'Бажарилди', 'Готово', 'Done'],
  'close': ['Yopish', 'Ёпиш', 'Закрыть', 'Close'],

  // Errors
  'retry': ['Qayta urinish', 'Қайта уриниш', 'Повторить', 'Try again'],
  'err_network': ['Internet aloqasi yoʻq', 'Интернет алоқаси йўқ', 'Нет подключения к интернету', 'No internet connection'],
  'err_timeout': ['Server javob bermadi', 'Сервер жавоб бермади', 'Сервер не ответил', 'The server did not respond'],
  'err_server': ['Serverda xatolik yuz berdi', 'Серверда хатолик юз берди', 'Ошибка сервера', 'Server error'],
  'err_empty': ['Hozircha bu yerda maʼlumot yoʻq', 'Ҳозирча бу ерда маълумот йўқ', 'Здесь пока ничего нет', 'Nothing here yet'],
  'err_unknown': ['Nimadir xato ketdi', 'Нимадир хато кетди', 'Что-то пошло не так', 'Something went wrong'],
  'err_hint': ['Internetni tekshirib, qayta urinib koʻring', 'Интернетни текшириб, қайта уриниб кўринг', 'Проверьте интернет и попробуйте снова', 'Check your connection and try again'],
  'err_open_link': ['Havolani ochib boʻlmadi', 'Ҳаволани очиб бўлмади', 'Не удалось открыть ссылку', 'Could not open the link'],
};

/// Keys that exist, used by tests to catch typos.
Iterable<String> get translationKeys => _strings.keys;
