import 'package:Ombro_Plus/viewmodels/shared/unread_messages_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnreadMessagesSummary extends StatefulWidget {
  const UnreadMessagesSummary({super.key});

  @override
  State<UnreadMessagesSummary> createState() => _UnreadMessagesSummaryState();
}

class _UnreadMessagesSummaryState extends State<UnreadMessagesSummary> {
  final UnreadMessagesViewmodel _viewModel = UnreadMessagesViewmodel();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchSummary();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final summary = _viewModel.summary;

        return InkWell(
          onTap: () =>
              Navigator.pushReplacementNamed(context, '/patient-main-chat'),
          child: Container(
            color: const Color(0xFFF4F7F6),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mensagens',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),

                      if (_viewModel.isLoading)
                        Text(
                          'Carregando...',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                summary.lastUnreadMessage,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (summary.lastUnreadTime.isNotEmpty)
                              Text(
                                " · ${summary.lastUnreadTime}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.red,
                      size: 28,
                    ),
                    if (summary.totalUnread > 0)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              summary.totalUnread > 99
                                  ? '99+'
                                  : summary.totalUnread.toString(),
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
