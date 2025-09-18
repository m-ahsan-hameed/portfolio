import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/modals/services.dart';

/// HomeView
///
/// Root widget for the portfolio's home screen. It is a StatefulWidget so
/// that we can manage entrance animations, scrolling behavior, and internal
/// UI state. This file keeps the UI declarative by delegating sections to
/// private `_buildXxx` helper methods (hero, about, services, skills,
/// contact, etc.).
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  // Animation controller used to animate the hero section on entry. Using
  // a single controller keeps timing consistent between fade & slide.
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  // Controller used for programmatic scrolling when the user clicks
  // navigation items in the app bar or drawer.
  final List<GlobalKey> _sectionKeys = [
    // Keys corresponding to each major section of the page. These are used
    // with `Scrollable.ensureVisible` to scroll to a precise section.
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  final List<String> _menuList = [
    // Labels for the top navigation; index aligns with `_sectionKeys`.
    "Home",
    "About",
    "Services",
    "Skills",
    "Contact",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      // Safely resolve the BuildContext for the requested section and
      // animate the viewport to make it visible. This keeps navigation
      // smooth and avoids abrupt jumps.
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Open an external URL in the platform browser/app.
  ///
  /// This helper uses `url_launcher` to open links. Replace placeholder
  /// URLs below with your actual social/profile links.
  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        webOnlyWindowName: '_blank', // opens in new browser tab
      )) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }
  // Removed redundant _launchURL in favor of _openUrl above.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          bool isDesktop = screenWidth > 1024;
          bool isTablet = screenWidth > 768 && screenWidth <= 1024;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(isDesktop, isTablet),
              _buildHeroSection(isDesktop, isTablet),
              _buildAboutSection(isDesktop, isTablet),
              _buildServicesSection(isDesktop, isTablet),
              _buildSkillsSection(isDesktop, isTablet),
              _buildContactSection(isDesktop, isTablet),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isDesktop, bool isTablet) {
    return SliverAppBar(
      // Prevent Flutter from inserting a default leading (hamburger) icon
      // when a (end)drawer is present. We provide our own menu button in
      // the flexibleSpace for mobile layouts to control placement and
      // visibility precisely.
      automaticallyImplyLeading: false,
      // For mobile size screens we show a single, explicit menu button in
      // the `leading` slot that opens the start drawer. On larger screens
      // we do not show a leading icon.
      leading: (!isDesktop && !isTablet)
          ? Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
            )
          : null,
      actions: const [],
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A).withOpacity(0.95),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 100 : (isTablet ? 40 : 20),
            vertical: 20,
          ),
          child: Row(
            // Desktop navigation row. Each item scrolls to a corresponding
            // section. On mobile we omit the inline menu button — the menu
            // is accessible via the `leading` icon above.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(),
              if (isDesktop || isTablet)
                _buildDesktopNav()
              else
                const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFF00D4FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        "Ahsan",
        style: TextStyle(
          fontSize: 28,
          fontFamily: "playfair",
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDesktopNav() {
    return Row(
      children: [
        ...List.generate(_menuList.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              onPressed: () => _scrollToSection(index),
              child: Text(
                _menuList[index],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 20),
        _buildHireMeButton(),
      ],
    );
  }

  Widget _buildHireMeButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),

        /// Hero section wrapper. Applies entrance animations and delegates to
        /// screen-specific hero layouts (desktop/tablet vs mobile).
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _scrollToSection(4), // Contact section
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text(
          "Hire Me",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        key: _sectionKeys[0],
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : (isTablet ? 40 : 20),
          vertical: 80,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: isDesktop || isTablet
                ? _buildDesktopHero(isDesktop, isTablet)
                : _buildMobileHero(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHero(bool isDesktop, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 2, child: _buildHeroContent(isDesktop, isTablet)),
        const SizedBox(width: 60),
        Expanded(flex: 1, child: _buildProfileImage()),
      ],
    );
  }

  Widget _buildMobileHero() {
    return Column(
      children: [
        _buildProfileImage(isMobile: true),
        const SizedBox(height: 40),
        _buildHeroContent(false, false),
      ],
    );
  }

  Widget _buildHeroContent(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hi, I'm",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white60,
            fontFamily: "lato",
          ),
        ),

        /// Compact hero layout that stacks image and content vertically for
        /// small screens.
        const SizedBox(height: 8),
        const Text(
          "Muhammad Ahsan Hameed",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "lato",
          ),
        ),

        /// Main hero content (greeting, name, role, short bio, links, actions).
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFF00D4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Flutter Developer",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "playfair",
            ),
          ),

          /// Circular profile image placeholder. Replace the Icon with an Image
          /// widget (e.g., `ClipOval`) to show a real photo.
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: isDesktop ? 500 : (isTablet ? 400 : double.infinity),
          child: const Text(
            "Passionate about creating beautiful, functional, and user-friendly mobile applications. With expertise in Flutter development, I bring ideas to life through clean code and innovative solutions.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontFamily: "lato",
              height: 1.6,
            ),
          ),

          /// Row of social icon buttons. Each button currently has a no-op
          /// callback; wire these to the real remote profiles.
        ),
        const SizedBox(height: 32),
        _buildSocialLinks(),
        const SizedBox(height: 32),
        _buildActionButtons(isDesktop, isTablet),
        const SizedBox(height: 40),
        _buildStatsCard(isDesktop, isTablet),
      ],
    );
  }

  Widget _buildProfileImage({bool isMobile = false}) {
    return Container(
      width: isMobile ? 250 : 400,
      height: isMobile ? 250 : 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFF00D4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1A1A1A),
        ),
        child: const Icon(Icons.person, size: 120, color: Colors.white54),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Row(
      children: [
        _buildSocialButton(
          FontAwesomeIcons.github,
          () => _openUrl(context, 'https://www.github.com/m-ahsan-hameed'),
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          FontAwesomeIcons.linkedin,
          () => _openUrl(
            context,
            'https://www.linkedin.com/in/muhammad-ahsan-hameed',
          ),
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          FontAwesomeIcons.twitter,
          () => _openUrl(context, 'https://x.com/Ahsan_flutter?s=09'),
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          FontAwesomeIcons.instagram,
          () => _openUrl(
            context,
            'https://instagram.com/m_ahsan_hameed?igsh=bmRqc3duYTZteHJ3',
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: IconButton(
        /// Action buttons below the hero (contact and CV download). Keep
        /// primary action prominent and secondary action subtle.
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white70, size: 20),
      ),
    );

    /// Small stats card that quickly communicates experience, projects and
    /// clients. Designed to be skimmed by recruiters.
  }

  Widget _buildActionButtons(bool isDesktop, bool isTablet) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _scrollToSection(4),
          child: const Text(
            "Get In Touch",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            "Download CV",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(bool isDesktop, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("1+", "Years Experience"),
          _buildStatDivider(),
          _buildStatItem("10+", "Projects Completed"),
          _buildStatDivider(),
          _buildStatItem("5+", "Happy Clients"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildAboutSection(bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        key: _sectionKeys[1],
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : (isTablet ? 40 : 20),
          vertical: 80,
        ),
        child: Column(
          children: [
            const Text(
              "About Me",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "playfair",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Passionate Flutter Developer crafting seamless cross-platform experiences",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: "lato",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            isDesktop || isTablet
                ? _buildDesktopAbout(isDesktop, isTablet)
                : _buildMobileAbout(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopAbout(bool isDesktop, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildAboutImage()),
        const SizedBox(width: 60),
        Expanded(flex: 1, child: _buildAboutContent(isDesktop, isTablet)),
      ],
    );
  }

  Widget _buildMobileAbout() {
    return Column(
      children: [
        _buildAboutImage(isMobile: true),
        const SizedBox(height: 40),
        _buildAboutContent(false, false),
      ],
    );
  }

  Widget _buildAboutImage({bool isMobile = false}) {
    return Container(
      width: isMobile ? 300 : 400,
      height: isMobile ? 300 : 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFF00D4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          /// Mobile variation for the About section.
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A1A),
        ),
        child: const Icon(Icons.code, size: 120, color: Colors.white54),
      ),
    );
  }

  Widget _buildAboutContent(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Passionate Flutter Developer with 1+ Years of Experience",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "lato",
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: isDesktop ? 500 : (isTablet ? 400 : double.infinity),
          child: const Text(
            "I'm a Flutter developer with a passion for creating beautiful, functional, and user-friendly mobile applications. With over 2 years of experience in mobile development, I've worked on a wide range of projects from small startups to large enterprises.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: "lato",
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: isDesktop ? 500 : (isTablet ? 400 : double.infinity),
          child: const Text(
            "My journey with Flutter began in August 2024, and I've been in love with the framework ever since. I enjoy solving complex problems and creating seamless user experiences that work flawlessly across platforms.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: "lato",
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          child: const Text(
            "Download CV",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        key: _sectionKeys[2],
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : (isTablet ? 40 : 20),
          vertical: 80,
        ),
        child: Column(
          children: [
            const Text(
              "Services",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "playfair",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Building trust through professional services",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: "lato",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            isDesktop || isTablet
                ? _buildDesktopServices(isDesktop, isTablet)
                : _buildMobileServices(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopServices(bool isDesktop, bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: serviceModal.length,

      /// Horizontal scrollable services list used on mobile.
      itemBuilder: (context, index) => _buildServiceCard(index),
    );
  }

  Widget _buildMobileServices() {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: serviceModal.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _buildServiceCard(index),
      ),
    );
  }

  Widget _buildServiceCard(int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              serviceModal[index].icon,
              color: const Color(0xFFFF6B35),
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            serviceModal[index].title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "lato",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            serviceModal[index].subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontFamily: "lato",
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        key: _sectionKeys[3],
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : (isTablet ? 40 : 20),
          vertical: 80,
        ),
        child: Column(
          children: [
            const Text(
              "Skills",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "playfair",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Technologies I work with",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: "lato",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            _buildSkillsGrid(isDesktop, isTablet),
            const SizedBox(height: 40),
            _buildAdditionalSkills(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsGrid(bool isDesktop, bool isTablet) {
    final skills = [
      {
        'name': 'Flutter',
        'level': 0.9,
        'icon': FontAwesomeIcons.mobile,
        'color': const Color(0xFF00D4FF),
      },
      {
        'name': 'Dart',
        'level': 0.85,
        'icon': FontAwesomeIcons.code,
        'color': const Color(0xFF00D4FF),
      },
      {
        'name': 'Firebase',
        'level': 0.8,
        'icon': FontAwesomeIcons.fire,
        'color': const Color(0xFFFF6B35),
      },
      {
        'name': 'Git',
        'level': 0.75,
        'icon': FontAwesomeIcons.gitAlt,
        'color': const Color(0xFF00D4FF),
      },
      {
        'name': 'REST API',
        'level': 0.8,
        'icon': FontAwesomeIcons.globe,
        'color': const Color(0xFFFF6B35),
      },
      {
        'name': 'UI/UX',
        'level': 0.7,
        'icon': FontAwesomeIcons.palette,
        'color': const Color(0xFF00D4FF),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: isDesktop ? 1.5 : 2.5,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) => _buildSkillCard(skills[index]),
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> skill) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(skill['icon'], color: skill['color'], size: 32),
          const SizedBox(height: 16),
          Text(
            skill['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: skill['level'],
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(skill['color']),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            '${(skill['level'] * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSkills() {
    final additionalSkills = [
      "Provider",
      "REST API",
      "App Store",
      "Google Play Store",
      "Responsive Design",
      "HTML",
      "CSS",
      "JavaScript",
    ];

    return Column(
      children: [
        const Text(
          "Additional Skills",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "lato",
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: additionalSkills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                skill,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactSection(bool isDesktop, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        key: _sectionKeys[4],
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 100 : (isTablet ? 40 : 20),
          vertical: 80,
        ),
        child: Column(
          children: [
            const Text(
              "Get In Touch",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "playfair",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Let's work together to bring your ideas to life",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: "lato",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            isDesktop || isTablet
                ? _buildDesktopContact()
                : _buildMobileContact(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopContact() {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildContactInfo()),
        const SizedBox(width: 60),
        Expanded(flex: 1, child: _buildContactForm()),
      ],
    );
  }

  Widget _buildMobileContact() {
    return Column(
      children: [
        _buildContactInfo(),
        const SizedBox(height: 40),
        _buildContactForm(),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Let's Connect",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "lato",
          ),
        ),

        /// Contact layout optimized for small screens.
        const SizedBox(height: 24),
        _buildContactItem(Icons.email, "Email", "ahsan@example.com"),
        const SizedBox(height: 20),
        _buildContactItem(Icons.phone, "Phone", "+92 300 123 4567"),
        const SizedBox(height: 20),
        _buildContactItem(Icons.location_on, "Location", "Lahore, Pakistan"),
        const SizedBox(height: 32),
        _buildSocialLinks(),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: "lato",
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: "lato",
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF6B35)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Email",
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF6B35)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Message",
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF6B35)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                "Send Message",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
