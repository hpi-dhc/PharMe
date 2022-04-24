class PgxFact {
  const PgxFact({
    required this.header,
    required this.description,
  });

  final String header;
  final String description;
}

final List<PgxFact> pgxFacts = [
  PgxFact(
    header: 'What is Pharmacogenomics?',
    description:
        'Pharmacogenomics (PGx) is the study of how your genetics (DNA) affect your response to medications.',
  ),
  PgxFact(
    header: 'Why is Pharmacogenomics important?',
    description:
        'Pharmacogenomics is important, because we can predict those who will respond well to medications and those who may have side effects. With this information we can select the right medication and dose to avoid the unwanted responses.',
  ),
  PgxFact(
    header: 'Which medications are affected?',
    description:
        'Examples of affected medication classes include blood thinners, antidepressants, anti-cholesterol medications, acid reducers, pain killers, antifungals, medications that suppress the immune system, anti-cancer medications and medications that are used in ADHD treatment. You can find out whether a certain medication is affected in our Search.',
  ),
  PgxFact(
    header: 'What does PharMe do?',
    description:
        'PharMe provides insights into the way your body reacts to medications based on your genes. This enables you to better avoid medications that are ineffective for you or have potential side effects.',
  ),
  PgxFact(
    header:
        'Can I use PharMe\'s results without consulting a medical professional?',
    description:
        'No. Whether a medication is a good choice for you relies on a lot of other factors such as age, weight, or pre-existing condition. Please make sure to talk to your doctor before taking, stopping or adjusting any medication.',
  ),
  PgxFact(
    header: 'Will my results affect my family members?',
    description:
        'Yes, since this is a genetic test it is possible that your results were passed down to you from your parents and you will also pass it down to your children.',
  ),
  PgxFact(
    header: 'Who can I share my results with?',
    description:
        'We recommend that you share your results with your doctors, pharmacists and close family members such as parents and children.',
  ),
  PgxFact(
    header: 'Where does PharMe get its data?',
    description:
        'PharMe is showing pharmacogenomic guidelines from the Clinical Pharmacogenetics Implementation Consortium (CPIC) and retrieves medication information from DrugBank. CPIC creates, curates, and posts freely available, peer-reviewed and evidence-based gene/medication clinical practice guidelines. DrugBank is a database containing information on medication and medication targets.',
  ),
  PgxFact(
    header: 'How is the security of my personal data ensured?',
    description:
        'Once securely imported from the lab, your genetic data is re-encrypted, saved and never sent anywhere else. All computation is done locally. When fetching data from external resources, PharMe always uses generalized requests and only personalizes data locally. This provides the highest possible data security.',
  ),
];
