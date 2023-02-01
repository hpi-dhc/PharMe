import '../../common/module.dart';

class GenePage extends StatelessWidget {
  const GenePage(this.phenotype);
  final CpicPhenotype phenotype;

  @override
  Widget build(BuildContext context) {
    return pageScaffold(title: phenotype.geneSymbol, body: []);
  }
}
