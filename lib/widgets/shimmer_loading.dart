import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../core/constants.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  });

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class PremiumLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const PremiumLoader({super.key, this.size = 50, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.twistingDots(
        leftDotColor: color ?? AppColors.primary,
        rightDotColor: AppColors.secondary,
        size: size,
      ),
    );
  }
}

class QuizCardSkeleton extends StatelessWidget {
  const QuizCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget.rectangular(height: 100),
          SizedBox(height: 20),
          ShimmerWidget.rectangular(height: 24, width: 200),
          SizedBox(height: 8),
          ShimmerWidget.rectangular(height: 16, width: double.infinity),
          SizedBox(height: 4),
          ShimmerWidget.rectangular(height: 16, width: 150),
          SizedBox(height: 20),
          Row(
            children: [
              ShimmerWidget.rectangular(height: 16, width: 80),
              Spacer(),
              ShimmerWidget.circular(width: 16, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class MaterialCardSkeleton extends StatelessWidget {
  const MaterialCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          ShimmerWidget.rectangular(
            width: 56,
            height: 56,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(height: 18, width: 150),
                SizedBox(height: 8),
                ShimmerWidget.rectangular(height: 14, width: double.infinity),
                SizedBox(height: 8),
                ShimmerWidget.rectangular(height: 14, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget.rectangular(width: 44, height: 44),
          SizedBox(height: 12),
          ShimmerWidget.rectangular(height: 24, width: 60),
          SizedBox(height: 8),
          ShimmerWidget.rectangular(height: 14, width: 80),
        ],
      ),
    );
  }
}

class LeaderboardSkeletonItem extends StatelessWidget {
  const LeaderboardSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          ShimmerWidget.circular(width: 40, height: 40),
          SizedBox(width: 16),
          Expanded(
            child: ShimmerWidget.rectangular(height: 16, width: 100),
          ),
          SizedBox(width: 16),
          ShimmerWidget.rectangular(height: 24, width: 60),
        ],
      ),
    );
  }
}

class ResultCardSkeleton extends StatelessWidget {
  const ResultCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          ShimmerWidget.circular(width: 60, height: 60),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(height: 18, width: 150),
                SizedBox(height: 8),
                ShimmerWidget.rectangular(height: 14, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
