class MessageModel {
  List<String?> getMessageLink(String message) {
    RegExp regExp = RegExp(r"(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+");

    List<String?> links =
        regExp.allMatches(message).map((match) => match.group(0)).toList();

    return links; // Output: ["https://example.com"]
  }
}
