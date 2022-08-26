class ErrorModel {
  String? status;
  int? statusCode;
  List? message;
  String? response;

  ErrorModel({this.status, this.response});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    response = json['response'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['response'] = response;
    return data;
  }
}

