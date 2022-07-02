import 'package:flutter/material.dart';
import 'package:dash_mement/domain/story.dart';

class StoryListProvider extends ChangeNotifier {
  late List<Story> _storyList = [];

  StoryListProvider(this._storyList) {}

  void add(Story story) {
    _storyList.add(story);
    notifyListeners();
  }

  void remove(Story story) {
    _storyList.remove(_storyList);
    notifyListeners();
  }

  List<Story> getAll() {
    return _storyList;
  }

  void setList(List<Story> storyList) {
    _storyList = storyList;
    notifyListeners();
  }

  int getIndex(Story story) {
    return _storyList.indexOf(story);
  }

  int getLength() {
    return _storyList.length;
  }

  Story getStoryAt(int num) {
    if (_storyList.length - 1 < num) {
      throw IndexError;
    }
    return _storyList[num];
  }
}
