import 'package:flutter/material.dart';

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
      image: 'assets/images/getStart1.png',
    ),
    OnboardingContent(
      title: 'Weather Around\nthe World',
      description: 'Add any location you want and\nswipe easily to change.',
      image: 'assets/images/getStart1.png',
    ),
    OnboardingContent(
      title: 'Detailed Hourly\nForecast',
      description: 'Get in-depth weather\ninformation.',
      image: 'assets/images/getStart1.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF494D5F),
      body: Stack(
        children: [
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to main app
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
            bottom: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _contents.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2D2F3A),
                    border: Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Progress Indicator
                      Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: (_currentPage + 1) / _contents.length,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF6B6B),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      // Arrow Icon
                      const Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
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
    return Column(
      children: [
        const SizedBox(height: 100),
        // Image
        Image.asset(content.image, height: 200, width: 200),
        const Spacer(),
        // White curved background
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2D2F3A),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  content.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF2D2F3A).withOpacity(0.7),
                    fontSize: 16,
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
