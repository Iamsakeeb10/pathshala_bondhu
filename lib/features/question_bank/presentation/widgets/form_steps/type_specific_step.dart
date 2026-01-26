/// Type Specific Step
/// Third step - shows type-specific inputs based on selected question type

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/question_model.dart';
import '../../../presentation/providers/question_bank_form_provider.dart';
import 'types/creative_question_step.dart';
import 'types/essay_step.dart';
import 'types/fill_blank_step.dart';
import 'types/matching_step.dart';
import 'types/math_problem_step.dart';
import 'types/mcq_options_step.dart';
import 'types/short_answer_step.dart';
import 'types/true_false_step.dart';

class TypeSpecificStep extends StatelessWidget {
  const TypeSpecificStep({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<QuestionBankFormProvider>();
    final selectedType = formProvider.selectedType;

    if (selectedType == null) {
      return const Center(child: Text('Please select a question type first'));
    }

    return switch (selectedType) {
      QuestionType.mcq => const MCQOptionsStep(),
      QuestionType.trueFalse => const TrueFalseStep(),
      QuestionType.shortAnswer => const ShortAnswerStep(),
      QuestionType.essay => const EssayStep(),
      QuestionType.matching => const MatchingStep(),
      QuestionType.fillBlank => const FillBlankStep(),
      QuestionType.mathProblem => const MathProblemStep(),
      QuestionType.creative => const CreativeQuestionStep(),
    };
  }
}
