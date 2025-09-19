import 'dart:html' as html;

void downloadCV() {
  final cvUrl = "Muhammad_Ahsan_Hameed_CV.pdf";
  // Logic to download the CV from the provided URL
  final anchor = html.AnchorElement(href: cvUrl)
    ..target = 'blank'
    ..download = "Muhammad_Ahsan_Hameed_CV.pdf"
    ..click();
}
