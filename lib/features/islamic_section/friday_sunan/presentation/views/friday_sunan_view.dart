// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/friday_sunan/domain/entities/sunnah_entity.dart';
import 'package:s/features/islamic_section/friday_sunan/presentation/views/widgets/sunnah_card.dart';

class FridaySunanView extends StatefulWidget {
  const FridaySunanView({super.key});

  @override
  State<FridaySunanView> createState() => _FridaySunanViewState();
}

class _FridaySunanViewState extends State<FridaySunanView> {
  List<SunnahEntity> _sunanList() => const [
    SunnahEntity(
      id: 1,
      title: 'مكانة يوم الجمعة في الإسلام',
      description:
          'يعتبر يوم الجمعة من أعظم الأيام وأجلها في ميزان الشريعة الإسلامية. وقد خصه الله تعالى بمزايا وخصائص لم تُمنح لغيره من الأيام. هو سيد الأيام، وسُمي بهذا الاسم لاجتماع الناس فيه.\nعن أبي هريرة رضي الله عنه قال، قال رسول الله ﷺ: «نَحْنُ الآخِرُونَ الأَوَّلُونَ يَوْمَ الْقِيَامَةِ، وَنَحْنُ أَوَّلُ مَنْ يَدْخُلُ الْجَنَّةَ، بَيْدَ أَنَّهُمْ أُوتُوا الْكِتَابَ مِنْ قَبْلِنَا وَأُوتِينَاهُ مِنْ بَعْدِهِمْ، فَاخْتَلَفُوا، فَهَدَانَا اللَّهُ لِمَا اخْتَلَفُوا فِيهِ مِنَ الْحَقِّ، فَهَذَا يَوْمُهُمُ الَّذِي اخْتَلَفُوا فِيهِ (أي يوم الجمعة) هَدَانَا اللَّهُ لَهُ»',
      source: 'رواه البخاري ومسلم',
    ),
    SunnahEntity(
      id: 2,
      title: 'خير أيام الدنيا',
      description:
          'فيه أحداث كونية وتاريخية عظمى؛ فهو يوم بداية الخلق البشري، وفيه تقوم الساعة.\nقال ﷺ: «خَيْرُ يَوْمٍ طَلَعَتْ عَلَيْهِ الشَّمْسُ يَوْمُ الْجُمُعَةِ، فِيهِ خُلِقَ آدَمُ، وَفِيهِ أُدْخِلَ الْجَنَّةَ، وَفِيهِ أُخْرِجَ مِنْهَا، وَلَا تَقُومُ السَّاعَةُ إِلَّا فِي يَوْمِ الْجُمُعَةِ».',
      source: 'رواه مسلم',
    ),
    SunnahEntity(
      id: 3,
      title: 'تكفير الذنوب',
      description:
          'من أدى صلاة الجمعة بشروطها وآدابها، غُفر له ما بينها وبين الجمعة الأخرى.\nقال ﷺ: «مَنْ تَوَضَّأَ فَأَحْسَنَ الْوُضُوءَ، ثُمَّ أَتَى الْجُمُعَةَ فَاسْتَمَعَ وَأَنْصَتَ، غُفِرَ لَهُ مَا بَيْنَهُ وَبَيْنَ الْجُمُعَةِ وَزِيَادَةُ ثَلَاثَةِ أَيَّامٍ».',
      source: 'رواه مسلم',
    ),
    SunnahEntity(
      id: 4,
      title: 'ساعة الاستجابة',
      description:
          'هي نفحة ربانية أسبوعية لا يُرد فيها الدعاء. وأرجح الأقوال في وقتها أنها من بعد صلاة العصر حتى غروب الشمس.\nقال ﷺ: «فِيهِ سَاعَةٌ لَا يُوَافِقُهَا عَبْدٌ مُسْلِمٌ وَهُوَ قَائِمٌ يُصَلِّي يَسْأَلُ اللَّهَ تَعَالَى شَيْئًا إِلَّا أَعْطَاهُ إِيَّاهُ».',
      source: 'متفق عليه',
    ),
    SunnahEntity(
      id: 5,
      title: 'الوقاية من فتنة القبر',
      description:
          'من مات يوم الجمعة أو ليلتها، وقاه الله فتنة القبر، كدليل على حسن الخاتمة.\nقال ﷺ: «مَا مِنْ مُسْلِمٍ يَمُوتُ يَوْمَ الْجُمُعَةِ أَوْ لَيْلَةَ الْجُمُعَةِ إِلَّا وَقَاهُ اللَّهُ فِتْنَةَ الْقَبْرِ».',
      source: 'رواه الترمذي وحسنه الألباني',
    ),
    SunnahEntity(
      id: 6,
      title: 'حكم صلاة الجمعة والتحذير من تركها',
      description:
          'صلاة الجمعة فرض عين على كل مسلم ذكر، بالغ، عاقل، حر، مقيم، وقادر صحياً. وقد حذر النبي ﷺ تحذيراً شديداً من التخلف عنها بلا عذر شرعي.\nقال رسول الله ﷺ: «لَيَنْتَهِيَنَّ أَقْوَامٌ عَنْ وَدْعِهِمُ الْجُمُعَاتِ، أَوْ لَيَخْتِمَنَّ اللهُ عَلَى قُلُوبِهِمْ، ثُمَّ لَيَكُونُنَّ مِنَ الْغَافِلِينَ». ومن ترك ثلاث جُمع تهاوناً بها، طُبع على قلبه.',
      source: 'رواه مسلم',
    ),
    SunnahEntity(
      id: 7,
      title: 'السُّنة: النظافة والتطيب',
      description:
          'الاغتسال، وتقليم الأظافر، واستخدام السواك، ولبس أحسن الثياب، ومس الطيب للرجال.',
      source:
          '«غُسْلُ يَوْمِ الْجُمُعَةِ وَاجِبٌ عَلَى كُلِّ مُحْتَلِمٍ، وَسِوَاكٌ، وَيَمَسُّ مِنَ الطِّيبِ مَا قَدَرَ عَلَيْهِ» حديث صحيح رواه أبو سعيد الخدري عن النبي ﷺ',
    ),
    SunnahEntity(
      id: 8,
      title: 'السُّنة: التبكير للمسجد',
      description:
          'الذهاب مبكراً للصلاة، والمشي على الأقدام بسكينة ووقار لمن استطاع.',
      source:
          '«مَنِ اغْتَسَلَ يَوْمَ الجُمُعَةِ غُسْلَ الجَنَابَةِ، ثُمَّ رَاحَ فَكَأَنَّمَا قَرَّبَ بَدَنَةً، وَمَنْ رَاحَ فِي السَّاعَةِ الثَّانِيَةِ فَكَأَنَّمَا قَرَّبَ بَقَرَةً، وَمَنْ رَاحَ فِي السَّاعَةِ الثَّالِثَةِ فَكَأنَّمَا قَرَّبَ كَبْشًا أَقْرَنَ، وَمَنْ رَاحَ فِي السَّاعَةِ الرَّابِعَةِ فَكَأَنَّمَا قَرَّبَ دَجَاجَةً، وَمَنْ رَاحَ فِي السَّاعَةِ الخَامِسَةِ فَكَأَنَّمَا قَرَّبَ بَيْضَةً، فَإِذَا خَرَجَ الإِمَامُ حَضَرَتِ المَلَائِكَةُ يَسْتَمِعُونَ الذِّكْرَ» حديث صحيح رواه أبو هريرة رضي الله عنه عن النبي صلى الله عليه وسلم',
    ),
    SunnahEntity(
      id: 9,
      title: 'السُّنة: تحية المسجد',
      description:
          'صلاة ركعتين عند دخول المسجد حتى وإن كان الإمام يخطب، مع تخفيفهما.',
      source:
          '«إِذَا جَاءَ أَحَدُكُمْ يَوْمَ الْجُمُعَةِ وَالْإِمَامُ يَخْطُبُ فَلْيَرْكَعْ رَكْعَتَيْنِ وَلْيَتَجَوَّزْ فِيهِمَا»  رواه الإمام مسلم',
    ),
    SunnahEntity(
      id: 10,
      title: 'السُّنة: الإنصات للخطبة',
      description:
          'الاستماع الجيد وعدم الانشغال بالهاتف أو الحديث مع الآخرين مطلقاً.',
      source:
          '«إِذَا قُلْتَ لِصَاحِبِكَ يَوْمَ الْجُمُعَةِ: أَنْصِتْ، وَالْإِمَامُ يَخْطُبُ، فَقَدْ لَغَوْتَ»',
    ),
    SunnahEntity(
      id: 11,
      title: 'السُّنة: قراءة سورة الكهف',
      description:
          'قراءتها في ليلة الجمعة أو نهارها ليكون له نور وبركة طوال الأسبوع.',
      source:
          '«مَنْ قَرَأَ سُورَةَ الْكَهْفِ فِي يَوْمِ الْجُمُعَةِ أَضَاءَ لَهُ مِنَ النُّورِ مَا بَيْنَ الْجُمُعَتَيْنِ»',
    ),
    SunnahEntity(
      id: 12,
      title: 'السُّنة: الصلاة على النبي',
      description: 'الإكثار من الصلاة على محمد ﷺ لنيل شفاعته ومغفرة الذنوب.',
      source:
          '«أَكْثِرُوا الصَّلَاةَ عَلَيَّ يَوْمَ الْجُمُعَةِ... فَإِنَّ صَلَاتَكُمْ مَعْرُوضَةٌ عَلَيَّ»',
    ),
    SunnahEntity(
      id: 13,
      title: 'مخالفة شائعة: تخطي الرقاب',
      description:
          'وهو أن يمشي المصلي متخطياً رقاب الجالسين ليصل إلى الصفوف الأولى المتأخرة، وهو أمر منهي عنه؛ فقد قال النبي ﷺ لرجل يتخطى رقاب الناس يوم الجمعة: «اجْلِسْ فَقَدْ آذَيْتَ وَآنَيْتَ» (أي آذيت الناس وتأخرت في المجيء).',
    ),
    SunnahEntity(
      id: 14,
      title: 'مخالفة شائعة: العبث أثناء الخطبة',
      description:
          'الانشغال بالسبحة، أو السجاد، أو الجوال، أو تشبيك الأصابع؛ كل هذا من "اللغو" الذي يُحبط ثواب الجمعة.',
    ),
    SunnahEntity(
      id: 15,
      title: 'مخالفة شائعة: إفراد يوم الجمعة بالصيام',
      description:
          'يُكره صيام يوم الجمعة منفرداً إلا إذا صام يوماً قبله (الخميس) أو يوماً بعده (السبت)، أو وافق يوم عرفة أو عاشوراء.',
    ),
    SunnahEntity(
      id: 16,
      title: 'خاتمة',
      description:
          'يوم الجمعة مدرسة أسبوعية متكاملة، شرعها الله لتنظيم حياة المسلم روحياً واجتماعياً. فمن خلال الغسل والنظافة يرتقي المظهر، ومن خلال الإنصات للخطبة يرتقي الفكر، ومن خلال الدعاء وقراءة القرآن ترتقي الروح. المؤمن الحق يستثمر كل دقيقة في هذا اليوم المبارك ليكون زاداً له.',
    ),
  ];
  double _readingProgress = 0;
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 18;
  @override
  void initState() {
    super.initState();
    _fontSize =
        (CacheHelper.getData(CacheKeys.fridaySunnahFontSize) as num?)
            ?.toDouble() ??
        18;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.position.maxScrollExtent;
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max == 0) return;

    setState(() {
      _readingProgress = (_scrollController.offset / max).clamp(0.0, 1.0);
    });
  }

  void _updateFontSize(
    double value,
    void Function(void Function()) setModalState,
  ) {
    setState(() {
      _fontSize = value.clamp(18, 48);
    });

    setModalState(() {});

    CacheHelper.saveData(
      key: CacheKeys.fridaySunnahFontSize,
      value: _fontSize,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          title: Text(
            'سنن يوم الجمعة',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.amiri,
              fontSize: (_fontSize + 2).sp,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.text_fields_rounded,
                color: AppColors.buttonColor.withAlpha(150),
                size: 24.r,
              ),
              onPressed: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  builder: (_) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('حجم الخط'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _updateFontSize(
                                        _fontSize - 2,
                                        setModalState,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.primaryColor.withAlpha(
                                        100,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Slider(
                                      activeColor: AppColors.primaryColor,
                                      value: _fontSize,
                                      min: 18,
                                      max: 48,
                                      divisions: 15,
                                      label: _fontSize.toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _fontSize = value;
                                        });
                                        setModalState(() {});
                                      },
                                      onChangeEnd: (value) {
                                        _updateFontSize(
                                          value,
                                          setModalState,
                                        );
                                      },
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      _updateFontSize(
                                        _fontSize + 2,
                                        setModalState,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.primaryColor.withAlpha(
                                        100,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              20.verticalSpace,
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            InkWell(
              borderRadius: BorderRadius.circular(320),
              child: SizedBox(
                width: 24.w,
                height: 24.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _readingProgress,
                      strokeWidth: 1,
                      backgroundColor: AppColors.buttonColor.withAlpha(20),
                      color: AppColors.buttonColor.withAlpha(150),
                    ),
                    Text(
                      '${(_readingProgress * 100).round()}',
                      style: AppTextStyle.style9W700.copyWith(
                        color: AppColors.buttonColor.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                await showModalBottomSheet<void>(
                  context: context,
                  builder: (_) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('مستوى التقدم'),
                              Slider(
                                activeColor: AppColors.primaryColor,
                                value: _readingProgress,
                                onChanged: (value) {
                                  setModalState(() {
                                    _readingProgress = value;
                                  });
                                  final max = _scrollController
                                      .position
                                      .maxScrollExtent;
                                  _scrollController.animateTo(
                                    value * max,
                                    duration: const Duration(
                                      milliseconds: 150,
                                    ),
                                    curve: Curves.easeOut,
                                  );
                                },
                              ),
                              10.verticalSpace,
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            20.horizontalSpace,
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                'مجموعة من السنن والآداب المستحبة يوم الجمعة، مستندة إلى السنة النبوية الصحيحة',
                style: AppTextStyle.style14W500.copyWith(
                  fontFamily: AppFonts.amiri,
                  fontSize: (_fontSize - 4).sp,
                  color: Colors.white.withAlpha(200),
                  height: 1.5,
                ),
              ),
            ),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30.r),
                  ),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.all(20.r),
                  itemCount: _sunanList().length,
                  separatorBuilder: (context, index) => 16.verticalSpace,
                  itemBuilder: (context, index) {
                    final sunnah = _sunanList()[index];
                    return SunnahCard(sunnah: sunnah, fontSize: _fontSize);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
