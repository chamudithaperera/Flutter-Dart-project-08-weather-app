import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                // TODO: Navigate to main app
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
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _contents.length,
            itemBuilder: (context, index) {
              return OnboardingPage(content: _contents[index]);
            },
          ),
          // Page Indicators
          Positioned(
            bottom: size.height * 0.42,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _contents.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Next Button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentPage == _contents.length - 1) {
                    // TODO: Navigate to main app
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 64,
                  height: 64,
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
                      // Progress Indicator
                      Center(
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: (_currentPage + 1) / _contents.length,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.progress,
                            ),
                            backgroundColor: AppColors.progressBackground,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      // Arrow Icon
                      Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.textLight,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        const SizedBox(height: 80),
        // Image with animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.8, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Image.asset(
                content.image,
                height: size.height * 0.35,
                width: size.width * 0.8,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        const Spacer(),
        // White curved background
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
                const SizedBox(
                  height: 50,
                ), // Reduced from default center spacing
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ), // Reduced spacing between title and description
                Text(
                  content.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark.withOpacity(0.7),
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
