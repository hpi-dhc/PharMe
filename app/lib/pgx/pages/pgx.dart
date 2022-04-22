import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/theme.dart';
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
            PgxFactsList(),
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
        borderRadius: BorderRadius.circular(20),
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
}

class PgxFactsList extends StatefulWidget {
  const PgxFactsList({Key? key}) : super(key: key);

  @override
  State<PgxFactsList> createState() => _PgxFactsListState();
}

class _PgxFactsListState extends State<PgxFactsList> {
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (index, isExpanded) {
        setState(() {
          pgxFacts[index].isExpanded = !isExpanded;
        });
      },
      children: pgxFacts.map((item) {
        return ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
            title: Text(item.expandedValue),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
