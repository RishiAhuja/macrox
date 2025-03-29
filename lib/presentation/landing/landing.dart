import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/common/widgets/appbar/basic_button.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/home', extra: state.userEntity);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? NexusColors.darkBackground : Colors.white,
        appBar: BasicAppBar(
          isLanding: true,
          customActionWidgetSuffix: Row(
            children: [
              BasicButton(
                onPressed: () {
                  context.go('/signin');
                },
                text: 'Login',
                color: Colors.transparent,
                textColor: isDark ? Colors.white : Colors.black87,
                dynamic: true,
                noBorder: true,
              ),
              BasicButton(
                onPressed: () {
                  context.go('/signup');
                },
                text: 'Sign up',
                dynamic: true,
                color: NexusColors.primaryBlue,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            NexusColors.darkBackground,
                            const Color(0xFF1A1A2E),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFF8F9FA),
                          ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 80,
                    vertical: isMobile ? 40 : 100,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: isMobile ? 1 : 5,
                            child: Column(
                              crossAxisAlignment: isMobile
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connect. Create.\nCollaborate.',
                                  textAlign: isMobile
                                      ? TextAlign.center
                                      : TextAlign.left,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: isMobile ? 36 : 56,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Nexus is where ideas transform into signals that resonate across the network.',
                                  textAlign: isMobile
                                      ? TextAlign.center
                                      : TextAlign.left,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: isMobile ? 16 : 20,
                                    height: 1.4,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                if (isMobile)
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: BasicButton(
                                          onPressed: () {
                                            context.go('/signup');
                                          },
                                          text: 'Join Nexus',
                                          color: NexusColors.primaryBlue,
                                          textColor: Colors.white,
                                          fontSize: 16,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: BasicButton(
                                          onPressed: () {
                                            // Scroll to features
                                          },
                                          text: 'Learn More',
                                          color: Colors.transparent,
                                          textColor: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 16,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          borderColor: isDark
                                              ? Colors.white24
                                              : Colors.black12,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      BasicButton(
                                        onPressed: () {
                                          context.go('/signup');
                                        },
                                        text: 'Join Nexus',
                                        color: NexusColors.primaryBlue,
                                        textColor: Colors.white,
                                        fontSize: 16,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 32),
                                      ),
                                      const SizedBox(width: 16),
                                      BasicButton(
                                        onPressed: () {
                                          // Scroll to features
                                        },
                                        text: 'Learn More',
                                        color: Colors.transparent,
                                        textColor: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 32),
                                        borderColor: isDark
                                            ? Colors.white24
                                            : Colors.black12,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (!isMobile) ...[
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 4,
                              child: _buildHeroImage(isDark),
                            ),
                          ],
                        ],
                      ),
                      if (isMobile) ...[
                        const SizedBox(height: 60),
                        _buildHeroImage(isDark, isMobile: true),
                      ],
                    ],
                  ),
                ),
              ),

              // Signal Feature Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 80,
                  vertical: 80,
                ),
                child: Column(
                  children: [
                    Text(
                      'Amplify Your Signal',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isMobile ? 28 : 40,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connect with minds that resonate on your frequency',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isMobile ? 16 : 18,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildFeatureGrid(context, isDark, isMobile),
                  ],
                ),
              ),

              // Testimonials Section
              Container(
                width: double.infinity,
                color: isDark
                    ? const Color(0xFF1A1A2E)
                    : NexusColors.primaryBlue.withOpacity(0.05),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 80,
                  vertical: 80,
                ),
                child: Column(
                  children: [
                    Text(
                      'What Our Network Says',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isMobile ? 28 : 40,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildTestimonials(context, isDark, isMobile),
                  ],
                ),
              ),

              // Call To Action Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 80,
                  vertical: isMobile ? 60 : 100,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 32 : 64),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            NexusColors.primaryBlue,
                            NexusColors.primaryBlue.withBlue(220),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: NexusColors.primaryBlue.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to Join the Network?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: isMobile ? 24 : 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start creating, connecting, and amplifying your signal today.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: isMobile ? 16 : 18,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BasicButton(
                                onPressed: () {
                                  context.go('/signup');
                                },
                                text: 'Create Account',
                                color: Colors.white,
                                textColor: NexusColors.primaryBlue,
                                fontSize: 16,
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: isMobile ? 24 : 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              BasicButton(
                                onPressed: () {
                                  context.go('/signin');
                                },
                                text: 'Sign In',
                                color: Colors.transparent,
                                textColor: Colors.white,
                                fontSize: 16,
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: isMobile ? 24 : 32,
                                ),
                                borderColor: Colors.white.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                width: double.infinity,
                color: isDark ? Colors.black : Color(0xFFF1F3F5),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 80,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isMobile ? 1 : 2,
                          child: Column(
                            crossAxisAlignment: isMobile
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: isMobile
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          NexusColors.gradientStart,
                                          NexusColors.gradientEnd,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.hub,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'NEXUS',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Amplify your signal in the digital universe',
                                textAlign: isMobile
                                    ? TextAlign.center
                                    : TextAlign.left,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (!isMobile)
                                Row(
                                  children: [
                                    _buildSocialIcon(
                                      LucideIcons.github,
                                      isDark,
                                      url:
                                          'https://github.com/RishiAhuja/nexus',
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isMobile) ...[
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(LucideIcons.facebook, isDark,
                              url: 'https://facebook.com'),
                          const SizedBox(width: 24),
                          _buildSocialIcon(LucideIcons.twitter, isDark,
                              url: 'https://twitter.com'),
                          const SizedBox(width: 24),
                          _buildSocialIcon(Icons.discord, isDark,
                              url: 'https://discord.com'),
                          const SizedBox(width: 24),
                          _buildSocialIcon(Icons.telegram, isDark,
                              url: 'https://telegram.org'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildFooterLink('About', isDark),
                          _buildFooterLink('Features', isDark),
                          _buildFooterLink('Pricing', isDark),
                          _buildFooterLink('FAQ', isDark),
                          _buildFooterLink('Blog', isDark),
                          _buildFooterLink('Support', isDark),
                        ],
                      ),
                    ],
                    const SizedBox(height: 40),
                    Divider(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '© ${DateTime.now().year} Nexus. All rights reserved.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(bool isDark, {bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.asset(
              'assets/screenshots/nexus/dashboard.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      NexusColors.primaryBlue.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Network active',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isDark, bool isMobile) {
    final features = [
      {
        'icon': Icons.edit_note_rounded,
        'title': 'Create Signals',
        'description':
            'Publish your thoughts, ideas, and code snippets that resonate with the network.'
      },
      {
        'icon': Icons.people_alt_outlined,
        'title': 'Connect',
        'description':
            'Find like-minded individuals and build your personal network of collaborators.'
      },
      {
        'icon': Icons.hub_outlined,
        'title': 'Collaborate',
        'description':
            'Work together on projects, exchange feedback, and amplify each other\'s signals.'
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Grow',
        'description':
            'Track your impact, build your audience, and expand your digital footprint.'
      },
    ];

    if (isMobile) {
      return Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: _buildFeatureCard(
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
              isDark,
            ),
          );
        }).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 40,
      crossAxisSpacing: 40,
      childAspectRatio: 3.2,
      children: features.map((feature) {
        return _buildFeatureCard(
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['description'] as String,
          isDark,
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF212134) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NexusColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: NexusColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials(BuildContext context, bool isDark, bool isMobile) {
    final testimonials = [
      {
        'quote':
            'Nexus changed how I collaborate on projects. The signal-network approach is brilliant!',
        'author': 'Sarah Johnson',
        'title': 'Software Engineer'
      },
      {
        'quote':
            'I\'ve found an incredible community of developers here. My coding skills have leveled up!',
        'author': 'Michael Chen',
        'title': 'Full-Stack Developer'
      },
      {
        'quote':
            'As a tech writer, Nexus gives me the platform to share and get meaningful feedback.',
        'author': 'Priya Sharma',
        'title': 'Technical Writer'
      },
    ];

    if (isMobile) {
      return Column(
        children: testimonials.map((testimonial) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _buildTestimonialCard(
              testimonial['quote'] as String,
              testimonial['author'] as String,
              testimonial['title'] as String,
              isDark,
            ),
          );
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: testimonials.map((testimonial) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTestimonialCard(
              testimonial['quote'] as String,
              testimonial['author'] as String,
              testimonial['title'] as String,
              isDark,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTestimonialCard(
      String quote, String author, String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF212134) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote,
            color: NexusColors.primaryBlue,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            quote,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: NexusColors.primaryBlue.withOpacity(0.2),
                child: Text(
                  author[0],
                  style: GoogleFonts.spaceGrotesk(
                    color: NexusColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, bool isDark, {String? url}) {
    return InkWell(
      onTap: url != null ? () => _launchUrl(url) : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white70 : Colors.black54,
          size: 18,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildFooterLink(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }
}
