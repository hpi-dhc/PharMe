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
          'Pharmacogenetics (PGx) is the study of how your genes (DNA) affect your response to drugs.',
    ),
    Question(
      question: 'Why is pharmacogenetics important?',
      answer:
          'Pharmacogenetics is important, because we can predict those who will respond well to drugs and those who may have side effects. With this information we can select the right drug and dose to avoid side effects.',
    ),
    Question(
      question: 'Which drugs are affected?',
      answer:
          'Examples of affected drug classes include anti-clotting medications (like clopidogrel and warfarin), antidepressants (like sertraline, citalopram, and paroxetine), anti-cholesterol drugs (like simvastatin and atorvastatin), acid reducers (like pantoprazole and omeprazole), pain killers (like codeine, tramadol, and ibuprofen), antifungals (like voriconazole), drugs that suppress the immune system (like tacrolimus), and anti-cancer drugs (like fluorouracil and irinotecan). You can find out whether a certain drug is affected in the Search tab.',
    ),
    Question(
      question: 'Will my results affect my family members?',
      answer:
          'Yes, since this is a genetic test, it is possible that your results were passed down to you from your parents and you will also pass them down to your children.',
    ),
    Question(
      question: 'Who can I share my results with?',
      answer:
          'We recommend that you share your results with your pharmacists, doctors, and close family members such as parents and children.',
    ),
  ],
  'PharMe App': [
    Question(
      question: 'What does PharMe do?',
      answer:
          'PharMe provides user-friendly information on how your body reacts to drugs based on your genes. This enables you to better understand which drugs may be ineffective for you or could have potential side effects. We recommend that you share consult your health care team before making any changes to your treatments.',
    ),
    Question(
      question:
          'Can I use PharMe\'s results without consulting a medical professional?',
      answer:
          'No. Whether a drug is a good choice for you depends on a lot of other factors such as age, weight, or pre-existing conditions. We highly recommend that you talk to your health care team (e.g., pharmacist and doctors) before taking, stopping or adjusting the dose of any drug.',
    ),
    Question(
      question: 'Where does PharMe get its data?',
      answer:
          'PharMe is showing pharmacogenomic guidelines from the Clinical Pharmacogenetics Implementation Consortium (CPIC®) and the U.S. Food and Drug Administration (FDA). The language from the guidelines has been shortened by our PGx experts to make them more user-friendly and easier to understand.',
    ),
  ],
  'Data security': [
    Question(
      question: 'How is the security of my genetic data ensured?',
      answer:
          'Once securely imported from the lab, your genetic data is re-encrypted, saved and never sent anywhere else. All computation is done on your phone. When fetching data from external resources, PharMe always uses generalized requests and only personalizes information locally on your phone. No personal data is sent to third parties. This provides the highest level of security for your personal information.',
    ),
  ]
};
