import 'package:flutter/material.dart';

import '../../models/invoice.dart';
import '../../widgets/studio_app_bar.dart';
import 'create_invoice_form.dart';

class EstimateScreen extends StatelessWidget {
  const EstimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const StudioAppBar(
              title: 'Estimated Cost',
              subtitle: 'Quotation before confirmation',
            ),
            Expanded(
              child: CreateInvoiceForm(
                documentType: InvoiceDocumentType.estimate,
                onSaved: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
