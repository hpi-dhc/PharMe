import 'package:provider/provider.dart';

import '../../module.dart';

Widget withFilterData({
  required DrugListCubit cubit,
  required Widget Function(
    BuildContext context,
    DrugListCubit cubit,
    DrugListState state,
    ActiveDrugs activeDrugs,
  ) builder,
}) => Consumer<ActiveDrugs>(
  builder: (context, activeDrugs, child) => BlocProvider(
    create: (context) => cubit,
    child: BlocBuilder<DrugListCubit, DrugListState>(
      builder: (context, state) => builder(context, cubit, state, activeDrugs),
    ),
  ),
);