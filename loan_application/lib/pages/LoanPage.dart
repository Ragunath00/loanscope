import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class LoanPage extends StatefulWidget {
  final String userPanNumber;
  final int currentCibilScore;
  const LoanPage({super.key, required this.userPanNumber, required this.currentCibilScore});
  @override
  _LoanPageState createState() => _LoanPageState();
}
class _LoanPageState extends State<LoanPage> {
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _loanDurationController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _monthsPaidCorrectlyController = TextEditingController();
  final TextEditingController _latePaymentsController = TextEditingController();
  int? _predictedScore;
  int? _futureCibilScore;
  Future<void> _predictCibil() async {
    final requestBody = {
      'current_score': widget.currentCibilScore,
      'loan_amount': int.parse(_loanAmountController.text),
      'loan_duration': int.parse(_loanDurationController.text),
      'monthly_income': int.parse(_monthlyIncomeController.text),
      'pan': widget.userPanNumber,
    };
    final response = await http.post(
      Uri.parse('http://localhost:5000/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _predictedScore = data['predicted_score'];
      });
    }
  }
  Future<void> _calculateFutureCibil() async {
    final requestBody = {
      'predicted_score': _predictedScore,
      'interest_rate': double.parse(_interestRateController.text),
      'months_paid_correctly': int.parse(_monthsPaidCorrectlyController.text),
      'late_payments': int.parse(_latePaymentsController.text),
      'pan': widget.userPanNumber,
    };
    final response = await http.post(
      Uri.parse('http://localhost:5000/calculate_future_cibil'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _futureCibilScore = data['future_cibil_score'];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _loanAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Loan Amount'),
            ),
            TextField(
              controller: _loanDurationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Loan Duration (months)'),
            ),
            TextField(
              controller: _monthlyIncomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly Income'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predictCibil,
              child: const Text('Predict CIBIL Score'),
            ),
            if (_predictedScore != null)
              Column(
                children: [
                  Text('Predicted CIBIL Score: $_predictedScore'),
                  TextField(
                    controller: _interestRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Interest Rate'),
                  ),
                  TextField(
                    controller: _monthsPaidCorrectlyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Months Paid Correctly'),
                  ),
                  TextField(
                    controller: _latePaymentsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Late Payments'),
                  ),
                  ElevatedButton(
                    onPressed: _calculateFutureCibil,
                    child: const Text('Calculate Future CIBIL Score'),
                  ),
                  if (_futureCibilScore != null)
                    Text('Future CIBIL Score: $_futureCibilScore'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}