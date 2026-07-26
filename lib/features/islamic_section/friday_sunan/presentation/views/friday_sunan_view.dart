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
      title: 'الاغتسال يوم الجمعة',
      description:
          'الحديث: قال رسول الله ﷺ: (غُسْلُ يَوْمِ الْجُمُعَةِ وَاجِبٌ عَلَى كُلِّ مُحْتَلِمٍ).\n\nالشرح: يوم الجمعة هو عيد الأسبوع، والاغتسال له يعكس اهتمامك بطهارتك وتهيؤك للوقوف بين يدي الله في أطهر الأماكن. احرص على هذا الغسل بنية خالصة لتنال الأجر العظيم، فقد أكد عليه النبي ﷺ بقوة. اجعله بداية مشرقة ومنعشة ليومك المبارك!',
      source: 'رواه البخاري ومسلم',
    ),
    SunnahEntity(
      id: 2,
      title: 'التطيب ولبس أحسن الثياب',
      description:
          'الحديث: قال رسول الله ﷺ: (لَا يَغْتَسِلُ رَجُلٌ يَوْمَ الْجُمُعَةِ، وَيَتَطَهَّرُ مَا اسْتَطَاعَ مِنْ طُهْرٍ، وَيَدَّهِنُ مِنْ دُهْنِهِ، أَوْ يَمَسُّ مِنْ طِيبِ بَيْتِهِ، ثُمَّ يَخْرُجُ فَلَا يُفَرِّقُ بَيْنَ اثْنَيْنِ، ثُمَّ يُصَلِّي مَا كُتِبَ لَهُ، ثُمَّ يُنْصِتُ إِذَا تَكَلَّمَ الْإِمَامُ، إِلَّا غُفِرَ لَهُ مَا بَيْنَهُ وَبَيْنَ الْجُمُعَةِ الْأُخْرَى).\n\nالشرح: الله جميل يحب الجمال؛ أظهر نعمة الله عليك في هذا اليوم العظيم وتزين بأفضل ما تملك من ثياب، وتعطر بأطيب الروائح، ولا تنسَ السواك. تخيل أنك ذاهب للقاء ملك الملوك، هكذا يجب أن تكون في بيت الله، لتشعر بالبهجة والوقار وتنشر السرور من حولك.',
      source: 'رواه البخاري',
    ),
    SunnahEntity(
      id: 3,
      title: 'التبكير إلى صلاة الجمعة',
      description:
          'الحديث: قال رسول الله ﷺ: (مَنِ اغْتَسَلَ يَوْمَ الجُمُعَةِ غُسْلَ الجَنَابَةِ ثُمَّ رَاحَ فَكَأنَّما قَرَّبَ بَدَنَةً، وَمَنْ رَاحَ فِي السَّاعَةِ الثَّانِيَةِ فَكَأَنَّمَا قَرَّبَ بَقَرَةً...).\n\nالشرح: تخيل أن الملائكة تقف على أبواب المسجد تسجل من يحضر أولاً بأول! فمن يبكر كمن يتصدق ببدنة (جمل)، ثم كمن يتصدق ببقرة، وهكذا حتى تصبح كمن يتصدق ببيضة. لا تفوت هذا السباق الأسبوعي العظيم نحو الجنات، وابدأ يومك بحيوية لتحجز مكانك في الصفوف الأولى.',
      source: 'رواه البخاري ومسلم',
    ),
    SunnahEntity(
      id: 4,
      title: 'المشي إلى المسجد بسكينة ووقار',
      description:
          'الحديث: قال رسول الله ﷺ: (إِذَا أُقِيمَتِ الصَّلَاةُ فَلَا تَأْتُوهَا تَسْعَوْنَ، وَأْتُوهَا تَمْشُونَ وَعَلَيْكُمُ السَّكِينَةُ).\n\nالشرح: اجعل خطواتك إلى المسجد هادئة ومطمئنة، فكل خطوة تخطوها ترفعك درجة وتحط عنك خطيئة. امشِ بسكينة ووقار مستشعراً عظمة المكان الذي تقصده، فهذا المشي الهادئ يهيئ قلبك وعقلك للدخول في جو العبادة والخشوع التام.',
      source: 'رواه البخاري ومسلم',
    ),
    SunnahEntity(
      id: 5,
      title: 'قراءة سورة الكهف',
      description:
          'الحديث: قال رسول الله ﷺ: (مَنْ قَرَأَ سُورَةَ الْكَهْفِ فِي يَوْمِ الْجُمُعَةِ أَضَاءَ لَهُ مِنَ النُّورِ مَا بَيْنَ الْجُمُعَتَيْنِ).\n\nالشرح: اجعل سورة الكهف رفيقك الأسبوعي لتنير دربك وتضيء حياتك بين الجمعتين. قراءتها تعصمك من الفتن وتجدد إيمانك بالقصص العظيمة التي تحويها. خصص لها وقتاً يسيراً لتكون حصناً ونوراً يمتد أثره في أيامك كلها. لا تحرم نفسك هذا النور!',
      source: 'رواه الحاكم والبيهقي وحسّنه الألباني',
    ),
    SunnahEntity(
      id: 6,
      title: 'الإكثار من الصلاة على النبي ﷺ',
      description:
          'الحديث: قال رسول الله ﷺ: (إِنَّ مِنْ أَفْضَلِ أَيَّامِكُمْ يَوْمَ الْجُمُعَةِ... فَأَكْثِرُوا عَلَيَّ مِنَ الصَّلَاةِ فِيهِ، فَإِنَّ صَلَاتَكُمْ مَعْرُوضَةٌ عَلَيَّ).\n\nالشرح: يوم الجمعة هو أفضل الأيام للإكثار من الصلاة والسلام على حبيبنا وشفيعنا محمد ﷺ، فصلاتك تُعرض عليه في هذا اليوم. وكل صلاة تصليها عليه يردها الله عليك عشراً! اجعل لسانك رطباً بالصلاة عليه لتنال شفاعته ويُكفى همك ويُغفر ذنبك.',
      source: 'رواه أبو داود وابن ماجه، وحسّنه الألباني',
    ),
    SunnahEntity(
      id: 7,
      title: 'تحري ساعة الإجابة والدعاء',
      description:
          'الحديث: ذكر رسول الله ﷺ يوم الجمعة فقال: (فِيهِ سَاعَةٌ لَا يُوَافِقُهَا عَبْدٌ مُسْلِمٌ، وَهُوَ قَائِمٌ يُصَلِّي يَسْأَلُ اللَّهَ تَعَالَى شَيْئًا إِلَّا أَعْطَاهُ إِيَّاهُ) وأشار بيده يُقَلِّلُهَا.\n\nالشرح: هناك كنز عظيم مخبأ في يوم الجمعة؛ ساعة لا يوافقها عبد مسلم يسأل الله شيئاً إلا أعطاه إياه! غالباً ما تكون آخر ساعة بعد العصر وقبل المغرب. جهّز قائمة أمنياتك، واختلِ بنفسك، وارفع يديك بقلب موقن بالإجابة، فربك كريم يستحي أن يرد يديك صفراً.',
      source: 'رواه البخاري ومسلم',
    ),
    SunnahEntity(
      id: 8,
      title: 'الإنصات لسماع الخطبة',
      description:
          'الحديث: قال رسول الله ﷺ: (إِذَا قُلْتَ لِصَاحِبِكَ يَوْمَ الْجُمُعَةِ: أَنْصِتْ، وَالْإِمَامُ يَخْطُبُ، فَقَدْ لَغَوْتَ).\n\nالشرح: خطبة الجمعة هي زادك الروحي، فاستمع لها بقلبك قبل أذنيك. الإنصات واجب، حتى مجرد إرشاد شخص آخر للسكوت قد يُفقدك ثواب الجمعة وتصبح مجرد صلاة ظهر. ركّز انتباهك مع الإمام، واترك مشتتات الدنيا خلفك لتخرج بقلب حيّ ومجدد.',
      source: 'رواه البخاري ومسلم',
    ),
    SunnahEntity(
      id: 9,
      title: 'عدم تخطي رقاب الناس',
      description:
          'الحديث: رأى النبي ﷺ رجلاً يتخطى رقاب الناس يوم الجمعة فقال له: (اجْلِسْ فَقَدْ آذَيْتَ وَآنَيْتَ).\n\nالشرح: من كمال الأدب واحترام الآخرين ألا تتخطى رقاب المصلين لتصل إلى مكان متقدم. اجلس حيث ينتهي بك المجلس ولا تؤذِ إخوانك بإزعاجهم أو تشتيت خشوعهم. تذكر أن احترامك للمصلين هو من تعظيمك لشعائر الله، والتبكير هو الحل الأمثل للوصول للصف الأول.',
      source: 'رواه أبو داود والنسائي',
    ),
    SunnahEntity(
      id: 10,
      title: 'صلاة تحية المسجد قبل الجلوس',
      description:
          'الحديث: قال رسول الله ﷺ: (إِذَا جَاءَ أَحَدُكُمْ يَوْمَ الْجُمُعَةِ وَالْإِمَامُ يَخْطُبُ فَلْيَرْكَعْ رَكْعَتَيْنِ وَلْيَتَجَوَّزْ فِيهِمَا).\n\nالشرح: من حقوق بيت الله ألا تجلس فيه حتى تصلي ركعتين خفيفتين تحية له. هذه السنة مؤكدة جداً، فاحرص على أدائها بخفة وخشوع حتى لو كان الإمام يخطب، لتجمع بين احترام المسجد والأدب مع بيت الله وسماع الخطبة.',
      source: 'رواه البخاري ومسلم',
    ),
    SunnahEntity(
      id: 11,
      title: 'قص الأظافر وإزالة ما يحتاج إزالته',
      description:
          'الحديث: من هدي النبي ﷺ أنه (كَانَ يَقُصُّ أَظَافِرَهُ وَيَقُصُّ شَارِبَهُ يَوْمَ الْجُمُعَةِ قَبْلَ أَنْ يَخْرُجَ إِلَى الصَّلَاةِ).\n\nالشرح: الإسلام دين النظافة والرقي، ويوم الجمعة فرصة عظيمة لتجديد هذه العناية بالجسد. قص الأظافر وتهذيب الشعر يمنحك شعوراً بالراحة والانتعاش والطاقة الإيجابية. اجعل من يوم الجمعة محطة أسبوعية لتنظيف ظاهرك كما تنظف باطنك بالطاعات.',
      source: 'من عمومات النظافة والتزين المستحب',
    ),
    SunnahEntity(
      id: 12,
      title: 'الجلوس قريباً من الإمام',
      description:
          'الحديث: قال رسول الله ﷺ: (احْضُرُوا الذِّكْرَ، وَادْنُوا مِنَ الْإِمَامِ، فَإِنَّ الرَّجُلَ لَا يَزَالُ يَتَبَاعَدُ حَتَّى يُؤَخَّرَ فِي الْجَنَّةِ وَإِنْ دَخَلَهَا).\n\nالشرح: القرب من الإمام يجعلك في قلب الحدث الروحاني، حيث يزداد تركيزك وتتضاعف استفادتك وتبتعد عن أي مشتتات. بادر بالتبكير والجلوس في الصفوف الأمامية لتنال أجر القرب وتستشعر رهبة الموقف. كلما اقتربت، كان قلبك أرق وأكثر تأثراً.',
      source: 'رواه أبو داود',
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
