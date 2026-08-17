import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_radius.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

class DsMarkdownBody extends StatelessWidget {
  const DsMarkdownBody({super.key, required this.data});

  final String data;

  static MarkdownStyleSheet styleSheet() {
    final body = AppTextStyle.body();
    final title = AppTextStyle.titleSm();
    final caption = AppTextStyle.caption();
    final codeStyle = caption.copyWith(
      fontFamily: 'monospace',
      backgroundColor: AppColor.composerFill,
    );

    return MarkdownStyleSheet(
      p: body,
      pPadding: EdgeInsets.zero,
      h1: title.copyWith(fontSize: 20),
      h2: title,
      h3: title.copyWith(fontSize: 15),
      strong: body.copyWith(fontWeight: FontWeight.w600),
      em: body.copyWith(fontStyle: FontStyle.italic),
      a: body.copyWith(color: AppColor.accentVoice),
      blockquote: body.copyWith(color: AppColor.textMedium),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColor.border, width: 3)),
      ),
      listBullet: body,
      listIndent: AppSpace.md,
      code: codeStyle,
      codeblockPadding: const EdgeInsets.all(AppSpace.sm),
      codeblockDecoration: BoxDecoration(
        color: AppColor.composerFill,
        border: Border.all(color: AppColor.border),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColor.divider)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: styleSheet(),
      shrinkWrap: true,
    );
  }
}
