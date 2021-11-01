import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../pages/main.dart';
import '../pages/test.dart';

part 'router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: TestPage, initial: true)
    // AutoRoute(path: '/', page: MainPage, children: <AutoRoute>[
    //   AutoRoute(
    //     path: 'test',
    //     name: 'TestRouter',
    //     page: TestPage,
    //   ),
    // ]),
  ],
)
class AppRouter extends _$AppRouter {}
