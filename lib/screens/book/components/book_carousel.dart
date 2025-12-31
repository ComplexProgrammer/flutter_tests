import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/book/components/book_card.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/ads/anchored_adaptive_example.dart';
import 'package:flutter_tests/screens/ads/fluid_example.dart';
import 'package:flutter_tests/screens/ads/inline_adaptive_example.dart';
import 'package:flutter_tests/screens/ads/main.dart';
import 'package:flutter_tests/screens/ads/native_template_example.dart';
import 'package:flutter_tests/screens/ads/reusable_inline_example.dart';
import 'package:flutter_tests/screens/ads/webview_example.dart';
import 'package:flutter_tests/screens/book/components/body.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BookCarousel extends StatefulWidget {
  final Group group;

  const BookCarousel({super.key, required this.group});
  @override
  _BookCaruselState createState() => _BookCaruselState(group);
}

class _BookCaruselState extends State<BookCarousel> {
  final Group group;
  late PageController _pageController;
  int initalPage = 1;
  List<Book> books = [];
  var loading = false;
  var adShow = true;

  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  _BookCaruselState(this.group);

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    final responseData = await http.get(
        Uri.parse("$baseUrl/tests/GetBooks?group_id=${group.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          books.add(Book.fromJson(i));
        }
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: [testDevice]));
      _createInterstitialAd();
      _createRewardedAd();
      _createRewardedInterstitialAd();
    }
    getData();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: initalPage,
    );
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-7773722896374259/2232999799'
            : 'ca-app-pub-7773722896374259/2232999799',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            if (adShow) {
              adShow = false;
              _showInterstitialAd();
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-7773722896374259/9959446576'
            : 'ca-app-pub-7773722896374259/9959446576',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-7773722896374259/3162938089'
            : 'ca-app-pub-7773722896374259/3162938089',
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

  void _showRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedInterstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: PageView.builder(
                scrollBehavior: AppScrollBehavior(),
                onPageChanged: (value) {
                  setState(() {
                    initalPage = value;
                  });
                },
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                itemCount: books.length,
                itemBuilder: (context, index) => buildGroupSlider(index),
              ),
            ),
          );
  }

  Widget buildGroupSlider(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0;
        if (_pageController.position.haveDimensions) {
          value = index - _pageController.page!;
          value = (value * 0.038).clamp(-1, 1);
        }
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: initalPage == index ? 1 : 0.4,
          child: Transform.rotate(
            angle: math.pi * value,
            child: BookCard(
              book: books[index],
              group: group,
            ),
          ),
        );
      },
    );
  }
}
