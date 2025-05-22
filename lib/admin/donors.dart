import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DonorsPage extends StatefulWidget {
  @override
  _DonorsPageState createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  List<Map<String, dynamic>> donors = [];
  List<Map<String, dynamic>> filtered = [];
  Map<String, List<Map<String, dynamic>>> transactions = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchDonors();
  }

  Future<void> fetchDonors() async {
    final url = Uri.parse(
      'https://backend-owxp.onrender.com/api/admin/unique-donor',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      donors = data.map((d) => Map<String, dynamic>.from(d)).toList();

      // Fetch transactions in parallel for all donors to reduce loading time
      await Future.wait(
        donors.map((donor) => fetchTransactions(donor['mobile'])).toList(),
      );

      applyFilter();
    } else {
      print("Error fetching donors");
    }
  }

  Future<void> fetchTransactions(String mobile) async {
    if (transactions.containsKey(mobile)) return;

    final url = Uri.parse(
      'https://backend-owxp.onrender.com/api/admin/transactions/$mobile',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      transactions[mobile] = List<Map<String, dynamic>>.from(data);
    }
  }

  void applyFilter() {
    filtered = donors
        .where(
          (d) => d['name'].toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
    setState(() {});
  }

  void showTransactionDialog(String name, String mobile) {
    final txns = transactions[mobile] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // White background for dialog
        title: Text('Transactions of $name'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: txns.isEmpty
              ? Text('No transactions found.')
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Txn ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: txns.map((txn) {
                        final isSuccess =
                            txn['status']?.toString().toLowerCase() == 'success';
                        final bgColor =
                            isSuccess ? Colors.green.shade100 : Colors.red.shade100;
                        final statusText = isSuccess ? 'Success' : 'Failed Payment';
                        return DataRow(
                          color: MaterialStateProperty.all(bgColor),
                          cells: [
                            DataCell(
                              Text(
                                txn['created_at']?.toString().split('T')[0] ?? '-',
                              ),
                            ),
                            DataCell(Text('₹${txn['amount'] ?? '-'}')),
                            DataCell(Text(txn['razorpay_payment_id']?.toString() ?? '-')),
                            DataCell(Text(txn['name']?.toString() ?? '-')),
                            DataCell(Text(txn['email']?.toString() ?? '-')),
                            DataCell(Text(statusText)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => exportTransactionsToExcel(name, mobile),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Red text
            ),
            child: Text('Export Excel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Red text
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void exportToExcel() async {
    final url = Uri.parse('https://backend-owxp.onrender.com/api/admin/export');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "format": "excel",
        "data": filtered
            .map((d) => {
                  "id": d["id"],
                  "name": d["name"],
                  "mobile": d["mobile"],
                  "amount": d["total_amount"],
                  "donation_purpose": d["purpose"] ?? '',
                  "created_at": d["last_donated"],
                })
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      final blob = html.Blob([response.bodyBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "donors.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      print("Export failed: ${response.body}");
    }
  }

  void exportTransactionsToExcel(String name, String mobile) async {
    final txns = transactions[mobile] ?? [];
    final response = await http.post(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/export'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "format": "excel",
        "data": txns
            .map((txn) => {
                  "name": txn['name'],
                  "mobile": mobile,
                  "email": txn['email'],
                  "amount": txn['amount'],
                  "status": txn['status'],
                  "payment_id": txn['razorpay_payment_id'],
                  "date": txn['created_at'],
                })
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      final blob = html.Blob([response.bodyBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "$name-transactions.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      print("Failed to export transactions for $name");
    }
  }

  Widget buildDataTable(BoxConstraints constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: DataTable(
          columnSpacing: 30,
          headingRowColor:
              MaterialStateProperty.all(Colors.blueGrey.shade50), // Fixed typo here
          columns: [
            DataColumn(
              label: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Mobile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Total Donated",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Transactions",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Action",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: List<DataRow>.generate(filtered.length, (index) {
            final donor = filtered[index];
            final mobile = donor['mobile'];
            final donorTxns = transactions[mobile] ?? [];
            final successTxns = donorTxns.where(
              (t) => t['status']?.toString().toLowerCase() == 'success',
            );
            final totalAmount = successTxns.fold<double>(0, (sum, t) {
              final amountRaw = t['amount'];
              final amount = amountRaw is String
                  ? double.tryParse(amountRaw) ?? 0
                  : (amountRaw ?? 0).toDouble();
              return sum + amount;
            });

            final txnCount = donorTxns.length;

            return DataRow(
              color: MaterialStateProperty.all(
                index % 2 == 0 ? Colors.white : Colors.grey.shade100,
              ),
              cells: [
                DataCell(Text(donor['name'])),
                DataCell(Text(mobile)),
                DataCell(Text("₹$totalAmount")),
                DataCell(Text("$txnCount")),
                DataCell(
                  ElevatedButton(
                    onPressed: () => showTransactionDialog(donor['name'], mobile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    child: Text("View", style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for the whole page
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              constraints.maxWidth > 600
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Theme(
                            data: Theme.of(context).copyWith(primaryColor: Colors.red),
                            child: TextField(
                              cursorColor: Colors.red,
                              decoration: InputDecoration(
                                labelText: "Search by name",
                                labelStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                border: UnderlineInputBorder(),
                              ),
                              onChanged: (value) {
                                searchQuery = value;
                                applyFilter();
                              },
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: exportToExcel,
                          icon: Icon(Icons.file_download),
                          label: Text("Export Excel"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(primaryColor: Colors.red),
                            child: TextField(
                              cursorColor: Colors.red,
                              decoration: InputDecoration(
                                labelText: "Search by name",
                                labelStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                border: UnderlineInputBorder(),
                              ),
                              onChanged: (value) {
                                searchQuery = value;
                                applyFilter();
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: exportToExcel,
                          icon: Icon(Icons.file_download),
                          label: Text("Export Excel"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 16),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: buildDataTable(constraints),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
