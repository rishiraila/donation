import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'donors.dart';

class DonorDetailsAdminPage extends StatefulWidget {
  @override
  State<DonorDetailsAdminPage> createState() => _DonorDetailsAdminPageState();
}

class _DonorDetailsAdminPageState extends State<DonorDetailsAdminPage> {
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> filteredData = [];

  final searchController = TextEditingController();
  String selectedSearchField = 'name';

  final Map<String, String> searchOptions = {
    'name': 'Name',
    'mobile': 'Mobile',
    'email': 'Email',
    'donation_purpose': 'Purpose',
    'created_at': 'Date',
  };

  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();
  ScrollController _horizontalScrollController = ScrollController();
  ScrollController _verticalScrollController = ScrollController();

  int rowsPerPage = 10;
  final List<int> rowsPerPageOptions = [5, 10, 25, 50];
  String sortBy = 'id';
  bool sortAsc = true;
  int currentPage = 0;
  int totalRows = 0;

  String selectedSortDuration = 'All';

  @override
  void initState() {
    super.initState();
    fetchAllDonors();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchAllDonors() async {
    int currentPage = 1;
    int pageSize = 100;
    bool hasMore = true;
    List<Map<String, dynamic>> allFetchedData = [];

    while (hasMore) {
      final res = await http.get(
        Uri.parse(
          'https://backend-owxp.onrender.com/api/admin/donors?page=$currentPage&limit=$pageSize',
        ),
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final donors = List<Map<String, dynamic>>.from(jsonData['donors']);

        allFetchedData.addAll(donors);

        if (donors.length < pageSize) {
          hasMore = false;
        } else {
          currentPage++;
        }
      } else {
        print("Failed to fetch donors");
        hasMore = false;
      }
    }

    setState(() {
      allData = allFetchedData;
      totalRows = allFetchedData.length;
      applyFilters();
    });
  }

  void downloadInvoice(String donationId) async {
    final url =
        'https://backend-owxp.onrender.com/api/donations/invoice?donationId=$donationId';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (kIsWeb) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: downloadUrl)
              ..setAttribute("download", "invoice_$donationId.pdf")
              ..click();
        html.Url.revokeObjectUrl(downloadUrl);
      } else {
        print("❗ Invoice download via blob is only for Flutter Web.");
      }
    } else {
      print("❌ Failed to download invoice: ${response.body}");
    }
  }

  void applyFilters() {
    double? minAmount = double.tryParse(minCtrl.text);
    double? maxAmount = double.tryParse(maxCtrl.text);
    final now = DateTime.now();

    DateTime? startDate =
        startDateCtrl.text.isNotEmpty
            ? DateTime.tryParse(startDateCtrl.text)
            : null;
    DateTime? endDate =
        endDateCtrl.text.isNotEmpty
            ? DateTime.tryParse(endDateCtrl.text)
            : null;

    // Fix: Include the full end date by setting time to 23:59:59
    if (endDate != null) {
      endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    }

    String searchValue = searchController.text.toLowerCase();

    filteredData =
        allData.where((d) {
          final amount = double.tryParse(d['amount'].toString()) ?? 0;
          final createdAt = DateTime.tryParse(d['created_at'] ?? '');

          bool matchesDuration = true;
          if (createdAt != null) {
            switch (selectedSortDuration) {
              case 'This Week':
                final startOfWeek = now.subtract(
                  Duration(days: now.weekday - 1),
                );
                final endOfWeek = startOfWeek.add(
                  Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
                );
                matchesDuration =
                    createdAt.isAfter(
                      startOfWeek.subtract(Duration(seconds: 1)),
                    ) &&
                    createdAt.isBefore(endOfWeek.add(Duration(seconds: 1)));
                break;
              case 'This Month':
                matchesDuration =
                    createdAt.month == now.month && createdAt.year == now.year;
                break;
              case 'This Year':
                matchesDuration = createdAt.year == now.year;
                break;
            }
          }

          bool matchesCustomDate = true;
          if (createdAt != null) {
            if (startDate != null && createdAt.isBefore(startDate))
              matchesCustomDate = false;
            if (endDate != null && createdAt.isAfter(endDate))
              matchesCustomDate = false;
          }

          bool matchesSearch = true;
          if (searchValue.isNotEmpty) {
            final fieldValue =
                (d[selectedSearchField] ?? '').toString().toLowerCase();
            matchesSearch = fieldValue.contains(searchValue);
          }

          return matchesDuration &&
              matchesCustomDate &&
              matchesSearch &&
              (minAmount == null || amount >= minAmount) &&
              (maxAmount == null || amount <= maxAmount);
        }).toList();
    currentPage = 0;
    applySorting();
  }

  void applySorting() {
    filteredData.sort((a, b) {
      final aVal = a[sortBy];
      final bVal = b[sortBy];
      if (aVal is num && bVal is num) {
        return sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      } else {
        return sortAsc
            ? aVal.toString().compareTo(bVal.toString())
            : bVal.toString().compareTo(aVal.toString());
      }
    });
    setState(() {});
  }

  void sortByColumn(String key) {
    setState(() {
      if (sortBy == key) {
        sortAsc = !sortAsc;
      } else {
        sortBy = key;
        sortAsc = true;
      }
      applySorting();
    });
  }

  Future<void> exportFilteredData(String format) async {
    final uri = Uri.parse('https://backend-owxp.onrender.com/api/admin/export');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'format': format, 'data': filteredData}),
    );

    if (response.statusCode == 200) {
      final blob = response.bodyBytes;
      final contentType =
          response.headers['content-type'] ?? 'application/octet-stream';
      final blobUrl = Uri.dataFromBytes(blob, mimeType: contentType).toString();
      await launchUrl(Uri.parse(blobUrl));
    } else {
      print('Export failed');
    }
  }

  Widget buildCompactDatePicker(
    BuildContext context,
    TextEditingController controller,
    String label,
  ) {
    return SizedBox(
      width: 160,
      height: 48,
      child: TextField(
        controller: controller,
        readOnly: true,
        style: TextStyle(fontSize: 14),
        cursorColor: Colors.red,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.red),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: Icon(Icons.calendar_today, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          isDense: true,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        onTap: () async {
          DateTime initialDate = DateTime.now();
          if (controller.text.isNotEmpty) {
            final parsedDate = DateTime.tryParse(controller.text);
            if (parsedDate != null) initialDate = parsedDate;
          }

          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.text = picked.toIso8601String().substring(0, 10);
            applyFilters();
          }
        },
      ),
    );
  }

  int getSortIndex() {
    switch (sortBy) {
      case 'id':
        return 0;
      case 'name':
        return 1;
      case 'mobile':
        return 2;
      case 'email':
        return 3;
      case 'amount':
        return 4;
      case 'donation_purpose':
        return 5;
      case 'address':
        return 6;
      case 'created_at':
        return 7;
      case 'status':
        return 8;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.volunteer_activism, color: Colors.red, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Donated Donors Details',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),

            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 48,
                  child: TextField(
                    controller: searchController,
                    cursorColor: Colors.red,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: TextStyle(color: Colors.red),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  applyFilters();
                                },
                              )
                              : null,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                    onChanged: (val) {
                      applyFilters();
                    },
                  ),
                ),

                SizedBox(
                  width: 160,
                  height: 48,
                  child: DropdownButtonFormField<String>(
                    value: selectedSearchField,
                    decoration: InputDecoration(
                      labelText: 'Search By',
                      labelStyle: TextStyle(color: Colors.red),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    iconEnabledColor: Colors.red,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    items:
                        searchOptions.entries
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSearchField = value;
                        });
                        applyFilters();
                      }
                    },
                  ),
                ),

                SizedBox(
                  width: 140,
                  height: 48,
                  child: TextField(
                    controller: minCtrl,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.red,
                    decoration: InputDecoration(
                      labelText: 'Min Amount',
                      labelStyle: TextStyle(color: Colors.red),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                    onChanged: (val) {
                      applyFilters();
                    },
                  ),
                ),

                SizedBox(
                  width: 140,
                  height: 48,
                  child: TextField(
                    controller: maxCtrl,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.red,
                    decoration: InputDecoration(
                      labelText: 'Max Amount',
                      labelStyle: TextStyle(color: Colors.red),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    style: TextStyle(fontSize: 16),
                    onChanged: (val) {
                      applyFilters();
                    },
                  ),
                ),
                buildCompactDatePicker(context, startDateCtrl, 'Start Date'),
                buildCompactDatePicker(context, endDateCtrl, 'End Date'),

                SizedBox(
                  width: 140,
                  height: 48,
                  child: DropdownButtonFormField<String>(
                    value: selectedSortDuration,
                    decoration: InputDecoration(
                      labelText: 'Duration',
                      labelStyle: TextStyle(color: Colors.red),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    iconEnabledColor: Colors.red,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    items:
                        ['All', 'This Week', 'This Month', 'This Year']
                            .map(
                              (d) => DropdownMenuItem<String>(
                                value: d,
                                child: Text(d),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSortDuration = value;
                        });
                        applyFilters();
                      }
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dropdown for rows per page
                    SizedBox(
                      width: 140,
                      height: 48,
                      child: DropdownButtonFormField<int>(
                        value: rowsPerPage,
                        decoration: const InputDecoration(
                          labelText: 'Rows Per Page',
                          labelStyle: TextStyle(color: Colors.red),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        iconEnabledColor: Colors.red,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        items:
                            rowsPerPageOptions
                                .map(
                                  (n) => DropdownMenuItem<int>(
                                    value: n,
                                    child: Text('$n'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              rowsPerPage = value;
                            });
                          }
                        },
                      ),
                    ),

                    // Export buttons
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => exportFilteredData("excel"),
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text(
                            'Export Excel',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            Expanded(
              child: Scrollbar(
                controller: _verticalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: getSortIndex(),
                        sortAscending: sortAsc,
                        columns: [
                          DataColumn(
                            label: const Text('ID'),
                            onSort: (columnIndex, _) => sortByColumn('id'),
                          ),
                          DataColumn(
                            label: const Text('Name'),
                            onSort: (columnIndex, _) => sortByColumn('name'),
                          ),
                          DataColumn(
                            label: const Text('Mobile'),
                            onSort: (columnIndex, _) => sortByColumn('mobile'),
                          ),
                          DataColumn(
                            label: const Text('Email'),
                            onSort: (columnIndex, _) => sortByColumn('email'),
                          ),
                          DataColumn(
                            label: const Text('Amount'),
                            numeric: true,
                            onSort: (columnIndex, _) => sortByColumn('amount'),
                          ),
                          DataColumn(
                            label: const Text('Purpose'),
                            onSort:
                                (columnIndex, _) =>
                                    sortByColumn('donation_purpose'),
                          ),
                          DataColumn(
                            label: const Text('Address'),
                            onSort: (columnIndex, _) => sortByColumn('address'),
                          ),
                          DataColumn(
                            label: const Text('Date'),
                            onSort:
                                (columnIndex, _) => sortByColumn('created_at'),
                          ),
                          DataColumn(
                            label: const Text('Status'),
                            onSort: (columnIndex, _) => sortByColumn('status'),
                          ),
                          const DataColumn(label: Text('Invoice')),
                        ],
                        rows:
                            filteredData
                                .skip(currentPage * rowsPerPage)
                                .take(rowsPerPage)
                                .map((d) {
                                  final status =
                                      (d['status'] ?? '')
                                          .toString()
                                          .toLowerCase();
                                  final isSuccess = status == 'success';

                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<
                                      Color
                                    >((Set<MaterialState> states) {
                                      return isSuccess
                                          ? Colors.green.shade50
                                          : Colors.red.shade50;
                                    }),
                                    cells: [
                                      DataCell(Text(d['id'].toString())),
                                      DataCell(Text(d['name'] ?? '')),
                                      DataCell(Text(d['mobile'] ?? '')),
                                      DataCell(Text(d['email'] ?? '')),
                                      DataCell(Text(d['amount'].toString())),
                                      DataCell(
                                        Text(d['donation_purpose'] ?? ''),
                                      ),
                                      DataCell(Text(d['address'] ?? '')),
                                      DataCell(Text(d['created_at'] ?? '')),
                                      DataCell(
                                        Text(
                                          status[0].toUpperCase() +
                                              status.substring(1),
                                          style: TextStyle(
                                            color:
                                                isSuccess
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        isSuccess
                                            ? IconButton(
                                              icon: Icon(
                                                Icons.picture_as_pdf,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                downloadInvoice(
                                                  d['id'].toString(),
                                                );
                                              },
                                            )
                                            : Text(
                                              "N/A",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                      ),
                                    ],
                                  );
                                })
                                .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.first_page),
                    onPressed:
                        currentPage == 0
                            ? null
                            : () {
                              setState(() {
                                currentPage = 0;
                              });
                            },
                    color: Colors.red,
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed:
                        currentPage == 0
                            ? null
                            : () {
                              setState(() {
                                currentPage--;
                              });
                            },
                    color: Colors.red,
                  ),
                  Text(
                    'Page ${currentPage + 1} of ${(filteredData.length / rowsPerPage).ceil()}',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed:
                        (currentPage + 1) * rowsPerPage >= filteredData.length
                            ? null
                            : () {
                              setState(() {
                                currentPage++;
                              });
                            },
                    color: Colors.red,
                  ),
                  IconButton(
                    icon: Icon(Icons.last_page),
                    onPressed:
                        (currentPage + 1) * rowsPerPage >= filteredData.length
                            ? null
                            : () {
                              setState(() {
                                currentPage =
                                    (filteredData.length / rowsPerPage).ceil() -
                                    1;
                              });
                            },
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
