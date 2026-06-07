import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/network/api_client.dart';
import '../repositories/auth_repository.dart';
import '../repositories/admin_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/property_repository.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/chat_service.dart';
import '../services/favorite_service.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';
import '../services/property_service.dart';
import 'auth_provider.dart';
import 'booking_provider.dart';
import 'chat_provider.dart';
import 'favorite_provider.dart';
import 'notification_provider.dart';
import 'property_provider.dart';
import 'settings_provider.dart';

final appProviders = <SingleChildWidget>[
  Provider<ApiClient>(create: (_) => ApiClient()),
  ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()..load()),
  ProxyProvider<ApiClient, AuthRepository>(update: (_, api, __) => AuthRepository(api)),
  ProxyProvider<ApiClient, AdminRepository>(update: (_, api, __) => AdminRepository(api)),
  ProxyProvider<ApiClient, PropertyRepository>(update: (_, api, __) => PropertyRepository(api)),
  ProxyProvider<ApiClient, BookingRepository>(update: (_, api, __) => BookingRepository(api)),
  ProxyProvider<ApiClient, ChatRepository>(update: (_, api, __) => ChatRepository(api)),
  ProxyProvider<ApiClient, NotificationRepository>(update: (_, api, __) => NotificationRepository(api)),
  ProxyProvider<ApiClient, FavoriteRepository>(update: (_, api, __) => FavoriteRepository(api)),
  ProxyProvider<ApiClient, PaymentRepository>(update: (_, api, __) => PaymentRepository(api)),
  ProxyProvider2<ApiClient, AuthRepository, AuthService>(update: (_, api, repo, __) => AuthService(api, repo)),
  ProxyProvider<PropertyRepository, PropertyService>(update: (_, repo, __) => PropertyService(repo)),
  ProxyProvider<BookingRepository, BookingService>(update: (_, repo, __) => BookingService(repo)),
  ProxyProvider<ChatRepository, ChatService>(update: (_, repo, __) => ChatService(repo)),
  ProxyProvider<NotificationRepository, NotificationService>(update: (_, repo, __) => NotificationService(repo)),
  ProxyProvider<FavoriteRepository, FavoriteService>(update: (_, repo, __) => FavoriteService(repo)),
  ProxyProvider<PaymentRepository, PaymentService>(update: (_, repo, __) => PaymentService(repo)),
  ChangeNotifierProxyProvider<AuthService, AuthProvider>(
    create: (_) => AuthProvider.empty(),
    update: (_, service, provider) => (provider ?? AuthProvider.empty())..attach(service),
  ),
  ChangeNotifierProxyProvider<PropertyService, PropertyProvider>(
    create: (_) => PropertyProvider.empty(),
    update: (_, service, provider) => (provider ?? PropertyProvider.empty())..attach(service),
  ),
  ChangeNotifierProxyProvider<BookingService, BookingProvider>(
    create: (_) => BookingProvider.empty(),
    update: (_, service, provider) => (provider ?? BookingProvider.empty())..attach(service),
  ),
  ChangeNotifierProxyProvider<ChatService, ChatProvider>(
    create: (_) => ChatProvider.empty(),
    update: (_, service, provider) => (provider ?? ChatProvider.empty())..attach(service),
  ),
  ChangeNotifierProxyProvider<NotificationService, NotificationProvider>(
    create: (_) => NotificationProvider.empty(),
    update: (_, service, provider) => (provider ?? NotificationProvider.empty())..attach(service),
  ),
  ChangeNotifierProxyProvider<FavoriteService, FavoriteProvider>(
    create: (_) => FavoriteProvider.empty(),
    update: (_, service, provider) => (provider ?? FavoriteProvider.empty())..attach(service),
  ),
];
