import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/service_catalog.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/storage/session_store.dart';
import '../../../../core/theme/app_theme.dart';

/// Home: LM banner, search, categories, trust strip and how it works.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();

  /// Confirmation shown after a request is sent from All services.
  String? _toast;

  static const _gutter = 20.0;

  static const _steps = [
    (
      icon: Icons.chat_bubble_outline,
      title: 'Tell us what you need',
      body: 'In your own words. No forms to hunt through.',
    ),
    (
      icon: Icons.how_to_reg_outlined,
      title: 'Your Lifestyle Manager takes it on',
      body: 'One person who knows your family and follows it through.',
    ),
    (
      icon: Icons.check_circle_outline,
      title: 'You see it done',
      body: 'Updates as things actually happen, with proof when it matters.',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// First two comma-separated parts of the address line (e.g. "Outer Ring
  /// Road, Bangalore"), else the society.
  static String? _locationOf(UserAddress? address) {
    final parts = (address?.addressLine ?? '')
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty);
    if (parts.isNotEmpty) return parts.take(2).join(', ');
    final society = address?.society?.trim() ?? '';
    return society.isEmpty ? null : society;
  }

  Future<void> _openServices([int? category]) async {
    setState(() => _toast = null);
    final result = await context.push<String>(Routes.services, extra: category);
    if (result != null && mounted) setState(() => _toast = result);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider)?.user;
    final firstName = user?.firstName ?? '';
    final location = _locationOf(user?.defaultAddress);
    final textTheme = Theme.of(context).textTheme;
    final headingStyle = textTheme.titleLarge?.copyWith(fontSize: 19);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.heroTop, AppColors.background],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 32),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(
                          location: location,
                          greeting: firstName.isEmpty
                              ? _greeting
                              : '$_greeting, $firstName',
                          onProfile: () => context.push(Routes.account),
                        ),
                        const SizedBox(height: 18),
                        const _LmBanner(),
                        const SizedBox(height: 16),
                        _SearchField(controller: _search),
                        if (_toast != null) ...[
                          const SizedBox(height: 14),
                          _RequestSentBanner(message: _toast!),
                        ],
                        const SizedBox(height: 26),
                        Text(
                          'What do you need help with?',
                          style: headingStyle,
                        ),
                        const SizedBox(height: 14),
                        _CategoryGrid(onTap: _openServices),
                        const SizedBox(height: 12),
                        _BrowseButton(onPressed: _openServices),
                        const SizedBox(height: 22),
                        const _TrustStrip(),
                        const SizedBox(height: 28),
                        Text('How PadosiPro works', style: headingStyle),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                  // Bleeds to the screen edges, so outside the gutter.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: _gutter),
                    physics: const _SnapScrollPhysics(
                      extent: _StepCard.width + 10,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _steps.length; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            _StepCard(
                              number: i + 1,
                              icon: _steps[i].icon,
                              title: _steps[i].title,
                              body: _steps[i].body,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.location,
    required this.greeting,
    required this.onProfile,
  });

  final String? location;
  final String greeting;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (location != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.locationInk,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.locationInk,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        const SizedBox(width: 12),
        DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x141E5B4A),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: AppColors.surface,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.heroBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onProfile,
              child: const Tooltip(
                message: 'Profile',
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    Icons.person_outline,
                    size: 22,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LmBanner extends StatelessWidget {
  const _LmBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lmCardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR LIFESTYLE MANAGER',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 11.5 * 0.07,
                    color: AppColors.lmLabel,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilot LM is ready when you are',
                  style: TextStyle(
                    fontFamily: AppTheme.headingFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                    height: 1.3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  // TODO: open chat with the Lifestyle Manager.
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    fixedSize: const Size.fromHeight(40),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 17),
                  label: const Text('Chat now'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // TODO: use the LM's photo once the API exposes it.
            child: Image.asset(
              'assets/images/lm-placeholder.png',
              width: 104,
              height: 104,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide(color: color, width: width),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D18202B),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        // TODO: send free-text requests once the API exists.
        decoration: InputDecoration(
          hintText: 'AC leaking, cook for weekends...',
          constraints: const BoxConstraints.tightFor(height: 54),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.muted,
          ),
          border: outline(AppColors.cardBorder),
          enabledBorder: outline(AppColors.cardBorder),
          focusedBorder: outline(AppColors.primary, 1.5),
        ),
      ),
    );
  }
}

/// Tile tints (background, icon ink), in [ServiceCatalog.categories] order.
const _categoryTints = [
  (bg: Color(0xFFE3F2EC), ink: Color(0xFF1E5B4A)),
  (bg: Color(0xFFFDEBD8), ink: Color(0xFFA5541B)),
  (bg: Color(0xFFE6ECFB), ink: Color(0xFF3552A8)),
  (bg: Color(0xFFFBE4E6), ink: Color(0xFFA83246)),
  (bg: Color(0xFFEDE6F7), ink: Color(0xFF5E3C99)),
  (bg: Color(0xFFFFF1C2), ink: Color(0xFF8A6A00)),
];

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onTap});

  final ValueChanged<int> onTap;

  static const _columns = 3;
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    const count = ServiceCatalog.homeTileCount;
    return Column(
      children: [
        for (var row = 0; row * _columns < count; row++) ...[
          if (row > 0) const SizedBox(height: _gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < _columns; col++) ...[
                  if (col > 0) const SizedBox(width: _gap),
                  Expanded(
                    child: row * _columns + col < count
                        ? _CategoryTile(
                            category:
                                ServiceCatalog.categories[row * _columns + col],
                            tint: _categoryTints[row * _columns + col],
                            onTap: () => onTap(row * _columns + col),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({
    required this.category,
    required this.tint,
    required this.onTap,
  });

  final ServiceCategory category;
  final ({Color bg, Color ink}) tint;
  final VoidCallback onTap;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: widget.tint.bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 112),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.category.icon,
                      size: 20,
                      color: widget.tint.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.category.label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrowseButton extends StatelessWidget {
  const _BrowseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text('Browse everything we do')),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward, size: 15),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  // TODO: replace the placeholder figures with real ones.
  static const _items = [
    (
      icon: Icons.verified_user_outlined,
      value: 'Verified',
      label: 'Background-checked pros',
    ),
    (icon: Icons.star_border, value: '4.8', label: 'Average rating'),
    (icon: Icons.schedule, value: 'Same day', label: 'For most requests'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0)
                const VerticalDivider(width: 1, color: AppColors.divider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      Icon(_items[i].icon, size: 20, color: AppColors.primary),
                      const SizedBox(height: 6),
                      Text(
                        _items[i].value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.headingFont,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  static const width = 220.0;

  final int number;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, size: 19, color: AppColors.primary),
              ),
              Text(
                number.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontFamily: AppTheme.headingFont,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: AppColors.stepNumber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestSentBanner extends StatelessWidget {
  const _RequestSentBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.mintBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Pilot LM will reach out shortly to take this forward.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Snaps a horizontal list to multiples of [extent] (one card plus gap).
class _SnapScrollPhysics extends ScrollPhysics {
  const _SnapScrollPhysics({required this.extent, super.parent});

  final double extent;

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnapScrollPhysics(extent: extent, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    var page = position.pixels / extent;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    final target = (page.roundToDouble() * extent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
