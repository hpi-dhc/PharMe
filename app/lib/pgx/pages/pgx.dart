import '../../common/module.dart';
import '../constants.dart';

class PgxPage extends StatelessWidget {
  const PgxPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildHeaderCard(context),
            SizedBox(height: 8),
            ...pgxFacts.map((item) => _buildPgxFact(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      height: 150,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PharmeTheme.primaryColor.shade500,
            PharmeTheme.primaryColor.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SvgPicture.asset(
              'assets/images/pgx_faq.svg',
              width: 120,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pharmacogenomics',
                  style: context.textTheme.headline6!
                      .copyWith(color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  'On this page we will answer common questions regarding PGx',
                  style: context.textTheme.bodyText2!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPgxFact(BuildContext context, PgxFact fact) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: context.theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(fact.header),
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              title: Text(fact.description),
            ),
          ],
        ),
      ),
    );
  }
}
