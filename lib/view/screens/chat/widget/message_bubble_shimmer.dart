import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MessageBubbleShimmer extends StatelessWidget {
final bool isMe;
const MessageBubbleShimmer({Key? key, required this.isMe}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Padding(
    padding: isMe ?  const EdgeInsets.fromLTRB(50, 5, 10, 5) : const EdgeInsets.fromLTRB(10, 5, 50, 5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Shimmer(
            duration: const Duration(seconds: 2),
            // enabled: Get.find<ChatController>().messageList == null,
            child: Container(
              height: 30, width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(Dimensions.radiusDefault),
                  bottomLeft: isMe ? const Radius.circular(Dimensions.radiusDefault) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(Dimensions.radiusDefault),
                  topRight: const Radius.circular(Dimensions.radiusDefault),
                ),
                color: isMe ? Theme.of(context).hintColor : Theme.of(context).disabledColor,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
