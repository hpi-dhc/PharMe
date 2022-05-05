class Question {
  const Question({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

final List<Question> faqList = [
  Question(
    question: 'What is Pharmacogenomics?',
    answer:
        'Pharmacogenomics (PGx) is the study of how your genetics (DNA) affect your response to medications.',
  ),
  Question(
    question: 'Why is Pharmacogenomics important?',
    answer:
        'Pharmacogenomics is important, because we can predict those who will respond well to medications and those who may have side effects. With this information we can select the right medication and dose to avoid the unwanted responses.',
  ),
  Question(
    question: 'Which medications are affected?',
    answer:
        'Examples of affected medication classes include blood thinners, antidepressants, anti-cholesterol medications, acid reducers, pain killers, antifungals, medications that suppress the immune system, anti-cancer medications and medications that are used in ADHD treatment. You can find out whether a certain medication is affected in our Search.',
  ),
  Question(
    question: 'What does PharMe do?',
    answer:
        'PharMe provides insights into the way your body reacts to medications based on your genes. This enables you to better avoid medications that are ineffective for you or have potential side effects.',
  ),
  Question(
    question:
        'Can I use PharMe\'s results without consulting a medical professional?',
    answer:
        'No. Whether a medication is a good choice for you relies on a lot of other factors such as age, weight, or pre-existing condition. Please make sure to talk to your doctor before taking, stopping or adjusting any medication.',
  ),
  Question(
    question: 'Will my results affect my family members?',
    answer:
        'Yes, since this is a genetic test it is possible that your results were passed down to you from your parents and you will also pass it down to your children.',
  ),
  Question(
    question: 'Who can I share my results with?',
    answer:
        'We recommend that you share your results with your doctors, pharmacists and close family members such as parents and children.',
  ),
  Question(
    question: 'Where does PharMe get its data?',
    answer:
        'PharMe is showing pharmacogenomic guidelines from the Clinical Pharmacogenetics Implementation Consortium (CPIC) and retrieves medication information from DrugBank. CPIC creates, curates, and posts freely available, peer-reviewed and evidence-based gene/medication clinical practice guidelines. DrugBank is a database containing information on medication and medication targets.',
  ),
  Question(
    question: 'How is the security of my personal data ensured?',
    answer:
        'Once securely imported from the lab, your genetic data is re-encrypted, saved and never sent anywhere else. All computation is done locally. When fetching data from external resources, PharMe always uses generalized requests and only personalizes data locally. This provides the highest possible data security.',
  ),
];
