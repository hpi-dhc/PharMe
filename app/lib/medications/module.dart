import '../common/module.dart';
import '../details/module.dart';

// We need to expose all pages for AutoRouter

const medicationsRoutes = AutoRoute(
  path: 'medications',
  name: 'MedicationsRouter',
  page: EmptyRouterPage,
  children: [AutoRoute(page: MedicationDetailsPage)],
);
