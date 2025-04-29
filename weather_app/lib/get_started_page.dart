import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'home_page.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  double _currentPageValue = 0.0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Detailed Hourly\nForecast',
      description: 'Get in-depth weather\ninformation.',
      image: 'assets/images/getStart1.png',
    ),
    OnboardingContent(
      title: 'Real-Time\nWeather Map',
      description: 'Watch the progress of the\nprecipitation to stay informed',
      image: 'assets/images/getStart2.png',
    ),
    OnboardingContent(
      title: 'Weather Around\nthe World',
      description: 'Add any location you want and\nswipe easily to change.',
      image: 'assets/images/getStart3.png',
    ),
    OnboardingContent(
      title: 'Detailed Hourly\nForecast',
      description: 'Get in-depth weather\ninformation.',
      image: 'assets/images/getStart4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85)..addListener(() {
      setState(() {
        _currentPageValue = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final availableHeight = size.height - (size.height * 0.4);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.backgroundGradient,
              ),
            ),
          ),
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: availableHeight,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // 3D Carousel PageView
                    SizedBox(
                      height: availableHeight * 0.7,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _contents.length,
                        itemBuilder: (context, index) {
                          double value = (index - _currentPageValue);
                          value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);

                          return Transform(
                            transform:
                                Matrix4.identity()
                                  ..translate(
                                    (1 - value) *
                                        50 *
                                        (index > _currentPageValue ? 1 : -1),
                                  )
                                  ..scale(0.9 + (value * 0.1)),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Image.asset(
                                  _contents[index].image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _contents.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color:
                                _currentPage == index
                                    ? AppColors.textLight
                                    : AppColors.textLight.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // White bottom container
              Container(
                height: size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _contents[_currentPage].title,
                          key: ValueKey<String>(_contents[_currentPage].title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _contents[_currentPage].description,
                          key: ValueKey<String>(
                            _contents[_currentPage].description,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textDark.withOpacity(0.7),
                            fontSize: 18,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Centered Next Button
                      GestureDetector(
                        onTap: () {
                          if (_currentPage == _contents.length - 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryDark,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: CircularProgressIndicator(
                                    value:
                                        (_currentPage + 1) / _contents.length,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.progress,
                                    ),
                                    backgroundColor:
                                        AppColors.progressBackground,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}
