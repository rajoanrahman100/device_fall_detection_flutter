import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController? textEditingController;
  final int? maxLength;
  final Function(String)? onChanged;
  final FormFieldSetter<String>? onSave;
  final String? Function(String?)? validation;
  final String? hintTex;
  final TextInputType? inputType;
  final Widget? suffixWidget;
  final bool? isSuffix;
  final bool? isObsecure;
  final String? labelText;
  final int? maxLine;
  final bool? isEnable;
  final TextInputAction? textInputAction;

  TextFieldWidget(
      {this.textEditingController,
      this.textInputAction,
      this.maxLength,
      this.onChanged,
      this.onSave,
      this.validation,
      this.hintTex,
      this.inputType,
      this.suffixWidget,
      this.isSuffix = false,
      this.isObsecure = false,
      this.labelText,
      this.maxLine,
      this.isEnable = true});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      autofocus: false,
      enabled: isEnable,
      keyboardType: inputType,
      textInputAction: textInputAction ?? TextInputAction.next,
      maxLines: maxLine ?? 1,
      onChanged: onChanged,
      validator: validation,
      onSaved: onSave,
      obscureText: isObsecure ?? true,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(10.0)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(10.0)),
          border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(10.0)),
          errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10.0)),
          suffixIcon: isSuffix == true ? suffixWidget : null,
          hintText: hintTex),
    );
  }
}
