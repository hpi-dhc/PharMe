import '../common/module.dart';
import 'pages/faq.dart';

// We need to expose all pages for AutoRouter
export 'pages/faq.dart';

const faqRoutes = AutoRoute(
  path: 'faq',
  name: 'FaqRouter',
  page: FaqPage,
);
