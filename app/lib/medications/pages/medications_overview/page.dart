import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/post.dart';
import 'cubit.dart';

class MedicationsOverviewPage extends StatefulWidget {
  const MedicationsOverviewPage({Key? key}) : super(key: key);

  @override
  State<MedicationsOverviewPage> createState() =>
      _MedicationsOverviewPageState();
}

class _MedicationsOverviewPageState extends State<MedicationsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationsOverviewCubit(),
      child: BlocBuilder<MedicationsOverviewCubit, MedicationsOverviewState>(
        builder: (context, state) {
          return state.when(
            initial: () => Container(),
            loading: () => Center(child: CircularProgressIndicator()),
            error: () => Center(child: Text('Error!')),
            loaded: (posts) => _buildPostsList(context, posts),
          );
        },
      ),
    );
  }

  ListView _buildPostsList(BuildContext context, List<Post> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          child: ListTile(
            title: Text(post.title),
            onTap: () =>
                context.router.pushNamed('main/medications/${post.id}'),
          ),
        );
      },
    );
  }
}
