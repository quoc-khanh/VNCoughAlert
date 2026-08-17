import 'package:flutter/material.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/components/ds_voice_waveform.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_radius.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

class DsVoiceDraftCard extends StatelessWidget {
  const DsVoiceDraftCard({
    super.key,
    required this.duration,
    required this.onRemove,
  });

  final Duration duration;
  final VoidCallback onRemove;

  static const double cardSize = 88;
  static const double badgeInset = 4;
  static const double extentWidth = cardSize + badgeInset;
  static const double extentHeight = cardSize + badgeInset;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedSuperellipseBorder(
      side: const BorderSide(color: AppColor.border),
      borderRadius: BorderRadius.circular(AppRadius.control),
    );
    return Padding(
      padding: const EdgeInsets.only(top: badgeInset, right: badgeInset),
      child: SizedBox(
        width: cardSize,
        height: cardSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Material(
                color: AppColor.canvas,
                shape: shape,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.xs),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice',
                        style: AppTextStyle.caption(
                          color: AppColor.textPlaceholder,
                        ),
                      ),
                      IconfyIconWidget(
                        IconfyIcons.audio.song.outline.regular,
                        size: 22,
                        color: AppColor.iconDefault,
                      ),
                      Text(
                        formatVoiceDuration(duration),
                        style: AppTextStyle.caption(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -badgeInset,
              right: -badgeInset,
              child: Material(
                color: AppColor.canvas,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColor.border),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: IconfyIconWidget(
                        IconfyIcons.alert.closeRemove.bold.regular,
                        size: 10,
                        color: AppColor.iconDefault,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
