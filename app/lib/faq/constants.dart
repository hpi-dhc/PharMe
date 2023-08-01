class Question {
  const Question({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

final Map<String, List<Question>> faqList = {
  'Pharmacogenetics (PGx)': [
    Question(
      question: 'What is pharmacogenetics?',
      answer:
          'Pharmacogenetics (PGx) is the study of how your genetics (DNA) affect your response to drugs.',
    ),
    Question(
      question: 'Why is pharmacogenetics important?',
      answer:
          'Pharmacogenetics is important, because we can predict those who will respond well to drugs and those who may have side effects. With this information we can select the right drug and dose to avoid the unwanted responses.',
    ),
    Question(
      question: 'Which drugs are affected?',
      answer:
          'Examples of affected drug classes include blood thinners, antidepressants, anti-cholesterol drugs, acid reducers, pain killers, antifungals, drugs that suppress the immune system, anti-cancer drugs and drugs that are used in ADHD treatment. You can find out whether a certain drug is affected in our Search.',
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
  ],
  'PharMe App': [
    Question(
      question: 'What does PharMe do?',
      answer:
          'PharMe provides insights into the way your body reacts to drugs based on your genes. This enables you to better avoid drugs that are ineffective for you or have potential side effects.',
    ),
    Question(
      question:
          'Can I use PharMe\'s results without consulting a medical professional?',
      answer:
          'No. Whether a drug is a good choice for you relies on a lot of other factors such as age, weight, or pre-existing condition. Please make sure to talk to your doctor before taking, stopping or adjusting any drug.',
    ),
    Question(
      question: 'Where does PharMe get its data?',
      answer:
          'PharMe is showing pharmacogenomic guidelines from the Clinical Pharmacogenetics Implementation Consortium (CPIC®) and the U.S. Food and Drug Administration (FDA). The guidelines were shortened by our PGx experts to make them easier to display and understand.',
    ),
  ],
  'Data security': [
    Question(
      question: 'How is the security of my genetic data ensured?',
      answer:
          'Once securely imported from the lab, your genetic data is re-encrypted, saved and never sent anywhere else. All computation is done locally. When fetching data from external resources, PharMe always uses generalized requests and only personalizes data locally. This provides the highest possible data security.',
    ),
  ]
};
