import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServicesModal {
  final IconData icon;
  final String title;
  final String subtitle;

  ServicesModal({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

List<ServicesModal> serviceModal = [
  ServicesModal(
    icon: FontAwesomeIcons.mobile,
    title: "Cross‑platform App Development",
    subtitle: "iOS, Android, Web, Desktop using a single codebase",
  ),
  ServicesModal(
    icon: FontAwesomeIcons.fire,
    title: "Firebase Integration",
    subtitle: "Auth, Firestore, Realtime Database, Storage, FCM, Analytics",
  ),
  ServicesModal(
    icon: FontAwesomeIcons.palette,
    title: "UI/UX Implementation in Flutter",
    subtitle: "Pixel‑perfect, responsive and modern UI",
  ),
  ServicesModal(
    icon: FontAwesomeIcons.gear,
    title: "Third-Party SDKs",
    subtitle: "Stripe, Razorpay, PayPal, Google Maps, etc.",
  ),
  ServicesModal(
    icon: FontAwesomeIcons.cogs,
    title: "APIs",
    subtitle: "REST, GraphQL, gRPC, WebSockets, etc.",
  ),
  ServicesModal(
    icon: FontAwesomeIcons.rocket,
    title: "App Performance Optimization",
    subtitle: "Smooth, fast and memory‑efficient apps.",
  ),
];
