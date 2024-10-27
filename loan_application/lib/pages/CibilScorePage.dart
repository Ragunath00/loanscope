import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loan_application/pages/LoanPage.dart';
class CibilScorePage extends StatefulWidget {
  const CibilScorePage({super.key});
  @override
  _CibilScorePageState createState() => _CibilScorePageState();
}
class _CibilScorePageState extends State<CibilScorePage> {
  String panNumber = ''; // Replace with the actual PAN number input
  Map<String, dynamic>? cibilData;
  Future<void> fetchCibilData() async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/get_cibil'), // Replace with your Flask server address
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"pan": panNumber}),
    );

    if (response.statusCode == 200) {
      setState(() {
        cibilData = json.decode(response.body)['data'];
      });
    } else {
      // Handle error
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CIBIL Score"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Enter PAN Number'),
              onChanged: (value) {
                panNumber = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchCibilData,
              child: const Text('Fetch CIBIL Score'),
            ),
            const SizedBox(height: 20),
            cibilData != null ? buildCibilDetails() : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildCibilDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name: ${cibilData!['name']}'),
        Text('PAN: ${cibilData!['pan']}'),
        Text('CIBIL Score: ${cibilData!['cibil']}'),
        Text('DOB: ${cibilData!['dob']}'),
        const SizedBox(height: 20),
        const Text('Loan Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        if (cibilData!['loanDetails']['personalLoan'] != null)
          Text('Personal Loan: ${cibilData!['loanDetails']['personalLoan']['sanctionedAmount']} - Current: ${cibilData!['loanDetails']['personalLoan']['currentAmount']}'),
        if (cibilData!['loanDetails']['goldLoans'].isNotEmpty)
          ...cibilData!['loanDetails']['goldLoans'].map((loan) {
            return Text('Gold Loan: ${loan['sanctionedAmount']} - Current: ${loan['currentAmount']}');
          }).toList(),
        if (cibilData!['loanDetails']['consumerLoans'].isNotEmpty)
          ...cibilData!['loanDetails']['consumerLoans'].map((loan) {
            return Text('Consumer Loan: ${loan['sanctionedAmount']} - Current: ${loan['currentAmount']}');
          }).toList(),
        Text('Credit Card: ${cibilData!['loanDetails']['creditCard']}'),
        Text('Late Payments: ${cibilData!['loanDetails']['latePayments']}'),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: ()
        {
          _showPredictionOptions(context);
        }, 
        child: const Text("Predict CIBIL"),
        ),
      ],
    );
  }
  void _showPredictionOptions(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Choose an Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Loan'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoanPage(
                      userPanNumber : panNumber,
                      currentCibilScore: cibilData!['cibil'],
                ),
                ),
                ); // Close the dialog
              },
            ),

            
            // ListTile(
            //   title: Text('EMI'),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmiPage()));
            //      // Close the dialog
            //   },
            // ),
          ],
        ),
      );
    },
  );
}
}
