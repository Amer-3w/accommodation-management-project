import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_list_screen.dart';
import 'features/booking/bookings_dashboard_screen.dart';
import 'features/booking/booking_success_screen.dart';
import 'features/booking/booking_screen.dart';
import 'features/booking/edit_booking_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/chatbot_screen.dart';
import 'features/chat/inbox_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/onboarding_screen.dart';
import 'features/home/splash_screen.dart';
import 'features/map/map_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/owner/owner_dashboard_screen.dart';
import 'features/owner/owner_properties_screen.dart';
import 'features/owner/owner_property_form_screen.dart';
import 'features/owner/owner_profile_screen.dart';
import 'features/owner/owner_reviews_screen.dart';
import 'features/map/location_picker_screen.dart';
import 'features/property/listings_screen.dart';
import 'features/payment/payment_screen.dart';
import 'features/payment/payment_history_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/property/property_details_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shell/EduStay_shell.dart';
import 'features/support/help_support_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';

class EduStayApp extends StatelessWidget {
  const EduStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SettingsProvider>(
      builder: (context, auth, settings, _) => MaterialApp(
        title: 'EduStay',
        debugShowCheckedModeBanner: false,
        locale: settings.locale,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        builder: (context, child) => Directionality(
          textDirection:
              settings.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        initialRoute: SplashScreen.route,
        routes: {
          SplashScreen.route: (_) => const SplashScreen(),
          OnboardingScreen.route: (_) => const OnboardingScreen(),
          LoginScreen.route: (_) => const LoginScreen(),
          RegisterScreen.route: (_) => const RegisterScreen(),
          ForgotPasswordScreen.route: (_) => const ForgotPasswordScreen(),
          AdminDashboardScreen.route: (_) => const AdminDashboardScreen(),
          AdminListScreen.route: (_) => const AdminListScreen(),
          AdminUserFormScreen.route: (_) => const AdminUserFormScreen(),
          EduStayShell.route: (_) => const EduStayShell(),
          HomeScreen.route: (_) => const HomeScreen(),
          SearchScreen.route: (_) => const SearchScreen(),
          ListingsScreen.route: (_) => const ListingsScreen(),
          PropertyDetailsScreen.route: (_) => const PropertyDetailsScreen(),
          BookingScreen.route: (_) => const BookingScreen(),
          EditBookingScreen.route: (_) => const EditBookingScreen(),
          BookingsDashboardScreen.route: (_) => const BookingsDashboardScreen(),
          BookingSuccessScreen.route: (_) => const BookingSuccessScreen(),
          PaymentScreen.route: (_) => const PaymentScreen(),
          PaymentHistoryScreen.route: (_) => const PaymentHistoryScreen(),
          ChatScreen.route: (_) => const ChatScreen(),
          ChatbotScreen.route: (_) => const ChatbotScreen(),
          InboxScreen.route: (_) => const InboxScreen(),
          NotificationsScreen.route: (_) => const NotificationsScreen(),
          FavoritesScreen.route: (_) => const FavoritesScreen(),
          MapScreen.route: (_) => const MapScreen(),
          ProfileScreen.route: (_) => const ProfileScreen(),
          EditProfileScreen.route: (_) => const EditProfileScreen(),
          MyReviewsScreen.route: (_) => const MyReviewsScreen(),
          SettingsScreen.route: (_) => const SettingsScreen(),
          HelpSupportScreen.route: (_) => const HelpSupportScreen(),
          OwnerDashboardScreen.route: (_) => const OwnerDashboardScreen(),
          OwnerPropertiesScreen.route: (_) => const OwnerPropertiesScreen(),
          OwnerPropertyFormScreen.route: (_) => const OwnerPropertyFormScreen(),
          OwnerProfileScreen.route: (_) => const OwnerProfileScreen(),
          OwnerReviewsScreen.route: (_) => const OwnerReviewsScreen(),
          LocationPickerScreen.route: (_) => const LocationPickerScreen(),
        },
      ),
    );
  }
}
