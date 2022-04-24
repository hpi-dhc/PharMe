import 'widgets/expansion_panel_item.dart';

final List<ExpansionPanelItem> pgxFacts = [
  ExpansionPanelItem(
    headerValue: 'What is Pharmacogenomics?',
    expandedValue:
        'Pharmacogenomics (PGx) is the study of how your genetics (DNA) affect your response to medications.',
  ),
  ExpansionPanelItem(
    headerValue: 'Why is Pharmacogenomics important?',
    expandedValue:
        'Pharmacogenomics is important, because we can predict those who will respond well to medications and those who may have side effects. With this information we can select the right medication and dose to avoid the unwanted responses.',
  ),
  ExpansionPanelItem(
    headerValue: 'Which medications are affected?',
    expandedValue:
        'Examples of affected medication classes include blood thinners, antidepressants, anti-cholesterol medications, acid reducers, pain killers, antifungals, medications that suppress the immune system, anti-cancer medications and medications that are used in ADHD treatment. You can find out whether a certain medication is affected in our Search.',
  ),
  ExpansionPanelItem(
    headerValue: 'What does PharMe do?',
    expandedValue:
        'PharMe provides insights into the way your body reacts to medications based on your genes. This enables you to better avoid medications that are ineffective for you or have potential side effects.',
  ),
  ExpansionPanelItem(
    headerValue:
        'Can I use PharMe\'s results without consulting a medical professional?',
    expandedValue:
        'No. Whether a medication is a good choice for you relies on a lot of other factors such as age, weight, or pre-existing condition. Please make sure to talk to your doctor before taking, stopping or adjusting any medication.',
  ),
  ExpansionPanelItem(
    headerValue: 'Will my results affect my family members?',
    expandedValue:
        'Yes, since this is a genetic test it is possible that your results were passed down to you from your parents and you will also pass it down to your children.',
  ),
  ExpansionPanelItem(
    headerValue: 'Who can I share my results with?',
    expandedValue:
        'We recommend that you share your results with your doctors, pharmacists and close family members such as parents and children.',
  ),
  ExpansionPanelItem(
    headerValue: 'Where does PharMe get its data?',
    expandedValue:
        'PharMe is showing pharmacogenomic guidelines from the Clinical Pharmacogenetics Implementation Consortium (CPIC) and retrieves medication information from DrugBank. CPIC creates, curates, and posts freely available, peer-reviewed and evidence-based gene/medication clinical practice guidelines. DrugBank is a database containing information on medication and medication targets.',
  ),
  ExpansionPanelItem(
    headerValue: 'How is the security of my personal data ensured?',
    expandedValue:
        'Once securely imported from the lab, your genetic data is re-encrypted, saved and never sent anywhere else. All computation is done locally. When fetching data from external resources, PharMe always uses generalized requests and only personalizes data locally. This provides the highest possible data security.',
  ),
];
