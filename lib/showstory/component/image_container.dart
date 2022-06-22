import 'dart:io';
import 'package:dash_mement/showstory/component/date_widget.dart';
import 'package:flutter/material.dart';
import 'package:dash_mement/domain/story.dart';

enum StoryType { Story, Input, File, Basic }

class ImageContainer extends StatelessWidget {
  late double _height;
  late double _width;
  String? _imagePath;
  File? _imageFile;
  Story? _story;
  late final StoryType _storyType;

  // 기본 생성자
  ImageContainer(Size size, this._imagePath) {
    _storyType = StoryType.Basic;
    _height = size.height;
    _width = size.width;
  }

  // 스토리 생성자
  ImageContainer.story(Size size, this._story) {
    _storyType = StoryType.Story;
    _height = size.height;
    _width = size.width;
  }

  // 파일 생성자
  ImageContainer.file(Size size, this._imageFile) {
    _storyType = StoryType.File;
    _height = size.height;
    _width = size.width;
  }

  // 텍스트 입력 있는 것
  ImageContainer.textInput(Size size, this._imageFile) {
    _storyType = StoryType.Input;
    _height = size.height;
    _width = size.width;
  }

  ImageProvider<Object> _getCurrentImage() {
    if (_story != null) {
      return AssetImage(_story!.img);
    } else if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else {
      return AssetImage(_imagePath!);
    }
  }

  Widget _getChild() {
    return Container(child: DateWidget());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: _storyType == StoryType.Story
            ? EdgeInsets.fromLTRB(10, 24, 10, 24)
            : EdgeInsets.all(24),
        height: _height,
        width: _width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
                image: _getCurrentImage(), // 여기 api 삽입시 변경
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), BlendMode.darken))),
        child: _getChild());
  }
}
