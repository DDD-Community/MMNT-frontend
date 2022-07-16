import 'dart:io';
import 'package:dash_mement/component/story/date_widget.dart';
import 'package:dash_mement/component/story/input_column.dart';
import 'package:dash_mement/component/story/story_column.dart';
import 'package:dash_mement/providers/pushstory_provider.dart';
import 'package:flutter/material.dart';
import 'package:dash_mement/domain/story.dart';
import 'package:provider/provider.dart';

/*
 enum StoryType
 Story: 보여주는 스토리일 경우
 Input: 입력하는 스트리일 경우
 File: 이미지 파일 삽입인 경우
 Basic: 
*/
enum StoryType { Story, Input, File, Basic, Check }

class ImageContainer extends StatelessWidget {
  late double _height;
  late double _width;
  String? _imagePath;
  File? _imageFile;
  Story? _story;
  late final StoryType _storyType;
  late Widget _childStory;
  late InputColumn _childInput;
  PushStoryProvider? _pushStory;

  // 기본 생성자
  ImageContainer(Size size, this._imagePath) {
    _storyType = StoryType.Basic;
    _height = size.height;
    _width = size.width;
    _childStory = _getChild();
  }

  // 스토리 생성자
  ImageContainer.story(Size size, this._story) {
    _storyType = StoryType.Story;
    _height = size.height;
    _width = size.width;
    _childStory = _getChild();
  }

  // 파일 생성자
  ImageContainer.file(Size size, this._imageFile) {
    _storyType = StoryType.File;
    _height = size.height;
    _width = size.width;
    _childStory = _getChild();
  }

  // 텍스트 입력 있는 것
  ImageContainer.textInput(Size size, this._imageFile) {
    _storyType = StoryType.Input;
    _height = size.height;
    _width = size.width;
    _childInput = _getInputColumn();
  }

  ImageContainer.check(Size size, this._imageFile, Story story) {
    _storyType = StoryType.Check;
    _height = size.height;
    _width = size.width;
    _story = story;
    _childStory = _getChild();
  }

  ImageProvider<Object> _getCurrentImage() {
    if (_storyType == StoryType.Story) {
      return AssetImage(_story!.img);
    } else if ((_storyType == StoryType.File) ||
        (_storyType == StoryType.Input) ||
        (_storyType == StoryType.Check)) {
      return FileImage(_imageFile!);
    } else {
      return AssetImage(_imagePath!);
    }
  }

  Widget _getChild() {
    if (_storyType == StoryType.Story) {
      return StoryColumn(_story!);
    } else if (_storyType == StoryType.File) {
      return Container();
    } else if (_storyType == StoryType.Input) {
      return InputColumn();
    } else if (_storyType == StoryType.Check) {
      return StoryColumn(_story!);
    } else {
      return StoryColumn(_story!);
    }
  }

  InputColumn _getInputColumn() {
    return InputColumn();
  }

  // 데이터 제출 critical
  Map<String, dynamic> submitInput() {
    assert(_storyType == StoryType.Input, "Not StoryType Input");
    Map<String, dynamic> hi = {};
    print("imageContainer");
    return hi;
  }

  @override
  Widget build(BuildContext context) {
    if (StoryType.Input == _storyType) {
      _pushStory = Provider.of<PushStoryProvider>(context);
      _pushStory!.dateTime = DateTime.now();
    }
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
        child: StoryType.Input == _storyType ? _childInput : _childStory);
  }
}
