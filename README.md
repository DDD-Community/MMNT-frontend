# DASH_MMNT

DDD7 크로스 플랫폼팀 DASH

## 시작하기
```
git clone https://github.com/DDD-Community/MMNT-frontend.git
cd MMNT-frontend
flutter pub get
flutter run
```

## API key
### 구글맵
안드로이드와 IOS 각각 API key값 입력
```
[안드로이드]
path: /android/local.properties
key: googleMapsApiKey=API-KEY

[IOS]
path: /ios/Runner/Storage.swift
let googleMapApiKey = "API-KEY"
```