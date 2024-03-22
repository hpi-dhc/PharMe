import '../common/module.dart';

abstract class Question {
  const Question({
    required this.question,
    required this.answer,
  });

  final String question;
  final dynamic answer;
}

class TextAnswerQuestion extends Question {
  const TextAnswerQuestion({
    required super.question,
    required String super.answer,
  });
}

class WidgetAnswerQuestion extends Question {
  const WidgetAnswerQuestion({
    required super.question,
    required Widget super.answer,
  });
}

final Map<String, List<Question>> faqList = {
  'Pharmacogenomics (PGx)': [
    TextAnswerQuestion(
      question: 'What is pharmacogenomics?',
      answer:
          'Pharmacogenomics (PGx) is the study of how your genes (DNA) affect your response to medications.',
    ),
    TextAnswerQuestion(
      question: 'Why is pharmacogenomics important?',
      answer:
          'Pharmacogenomics is important because it helps to predict those who will respond well to medications and those who may have side effects. With this information we can better select the right medication and dose to avoid side effects.',
    ),
    WidgetAnswerQuestion(
      question: 'Where can I find out more about genetics in general?',
      answer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To learn more about genetics, we recommend MedlinePlus,'
            ' a service of the National Library of Medicine:'
          ),
          SizedBox(height: PharMeTheme.smallSpace * 0.5),
          Hyperlink(
            text: geneticInformationUrl.toString(),
            onTap: openFurtherGeneticInformation,
          ),
        ],
      ),
    ),
    TextAnswerQuestion(
      question: 'Which medications are affected?',
      answer:
          'Examples of affected medication classes include anti-clotting medications (like clopidogrel and warfarin), antidepressants (like sertraline, citalopram, and paroxetine), anti-cholesterol medications (like simvastatin and atorvastatin), acid reducers (like pantoprazole and omeprazole), pain killers (like codeine, tramadol, and ibuprofen), antifungals (like voriconazole), medications that suppress the immune system (like tacrolimus), and anti-cancer medications (like fluorouracil and irinotecan). You can find out whether a certain medication is affected in the Medications tab.',
    ),
    TextAnswerQuestion(
      question: 'Will my results affect my family members?',
      answer:
          'Yes, since this is a genetic test, it is possible that your results were passed down to you and your siblings from your parents and you will also pass them down to your children.',
    ),
    TextAnswerQuestion(
      question: 'Who can I share my results with?',
      answer:
          'We recommend that you share your results with your pharmacists, doctors, and close family members such as parents, siblings, and children.',
    ),
  ],
  'PharMe App': [
    TextAnswerQuestion(
      question: 'What does PharMe do?',
      answer:
          'PharMe provides user-friendly information on how your body reacts to medications based on your genes. This enables you to better understand which medications may be ineffective for you or could have potential side effects. We recommend that you share consult your health care team before making any changes to your treatments.',
    ),
    TextAnswerQuestion(
      question:
          'Can I use PharMe\'s results without consulting a medical professional?',
      answer:
          'No. Whether a medication is a good choice for you depends on a lot of other factors such as age, weight, or pre-existing conditions. We highly recommend that you talk to your health care team (e.g., pharmacist and doctors) before taking, stopping or adjusting the dose of any medication.',
    ),
    TextAnswerQuestion(
      question: 'Where does PharMe get its data from?',
      answer:
          "PharMe is showing pharmacogenomic guidelines from the Clinical Pharmacogenetics Implementation Consortium (CPIC®) and the U.S. Food and Drug Administration (FDA). Our PGx experts adapted the language from the guidelines to make them more user-friendly and easier to understand; please note that this does only affect the guidelines' presentation, not affect the guidelines' statements.",
    ),
  ],
  'Data security': [
    TextAnswerQuestion(
      question: 'How is the security of my genetic data ensured?',
      answer:
          'Once securely imported from the lab, your genetic data is re-encrypted, saved and never sent anywhere else. All computation is done on your phone. When fetching data from external resources, PharMe always uses generalized requests and only personalizes information locally on your phone. No personal data is sent to third parties. This provides the highest level of security for your personal information.',
    ),
  ]
};
