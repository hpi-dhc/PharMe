import 'package:app/common/widgets/drug_list/cubit.dart';
import 'package:bloc_test/bloc_test.dart';

class MockDrugListCubit extends MockCubit<DrugListState> implements DrugListCubit {
  @override
  FilterState get filter => FilterState.initial();
}