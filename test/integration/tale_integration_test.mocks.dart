// Mocks generated by Mockito 5.4.4 from annotations
// in magic_book/test/integration/tale_integration_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:convert' as _i4;
import 'dart:typed_data' as _i6;

import 'package:flutter_tts/flutter_tts.dart' as _i13;
import 'package:http/http.dart' as _i2;
import 'package:magic_book/core/services/audio_service.dart' as _i12;
import 'package:magic_book/core/services/logging_service.dart' as _i7;
import 'package:magic_book/core/services/network_service.dart' as _i8;
import 'package:magic_book/core/services/storage_service.dart' as _i9;
import 'package:magic_book/shared/models/tale.dart' as _i11;
import 'package:magic_book/shared/models/user_profile.dart' as _i10;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamedResponse_1 extends _i1.SmartFake
    implements _i2.StreamedResponse {
  _FakeStreamedResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamController_2<T> extends _i1.SmartFake
    implements _i3.StreamController<T> {
  _FakeStreamController_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i2.Response> head(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #head,
          [url],
          {#headers: headers},
        ),
        returnValue: _i3.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #head,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i3.Future<_i2.Response>);

  @override
  _i3.Future<_i2.Response> get(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [url],
          {#headers: headers},
        ),
        returnValue: _i3.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #get,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i3.Future<_i2.Response>);

  @override
  _i3.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i4.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i3.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #post,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i3.Future<_i2.Response>);

  @override
  _i3.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i4.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i3.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #put,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i3.Future<_i2.Response>);

  @override
  _i3.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i4.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i3.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #patch,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i3.Future<_i2.Response>);

  @override
  _i3.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i4.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i3.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #delete,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i3.Future<_i2.Response>);

  @override
  _i3.Future<String> read(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [url],
          {#headers: headers},
        ),
        returnValue: _i3.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #read,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i3.Future<String>);

  @override
  _i3.Future<_i6.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readBytes,
          [url],
          {#headers: headers},
        ),
        returnValue: _i3.Future<_i6.Uint8List>.value(_i6.Uint8List(0)),
      ) as _i3.Future<_i6.Uint8List>);

  @override
  _i3.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #send,
          [request],
        ),
        returnValue:
            _i3.Future<_i2.StreamedResponse>.value(_FakeStreamedResponse_1(
          this,
          Invocation.method(
            #send,
            [request],
          ),
        )),
      ) as _i3.Future<_i2.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [LoggingService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLoggingService extends _i1.Mock implements _i7.LoggingService {
  MockLoggingService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void v(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #v,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void d(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #d,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void i(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #i,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void w(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #w,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void e(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #e,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void wtf(
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #wtf,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  void log(
    _i7.LogLevel? level,
    String? message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #log,
          [
            level,
            message,
          ],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [NetworkService].
///
/// See the documentation for Mockito's code generation for more information.
class MockNetworkService extends _i1.Mock implements _i8.NetworkService {
  MockNetworkService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.StreamController<_i8.NetworkStatus> get networkStatusController =>
      (super.noSuchMethod(
        Invocation.getter(#networkStatusController),
        returnValue: _FakeStreamController_2<_i8.NetworkStatus>(
          this,
          Invocation.getter(#networkStatusController),
        ),
      ) as _i3.StreamController<_i8.NetworkStatus>);

  @override
  set networkStatusController(
          _i3.StreamController<_i8.NetworkStatus>? _networkStatusController) =>
      super.noSuchMethod(
        Invocation.setter(
          #networkStatusController,
          _networkStatusController,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Stream<_i8.NetworkStatus> get networkStatusStream => (super.noSuchMethod(
        Invocation.getter(#networkStatusStream),
        returnValue: _i3.Stream<_i8.NetworkStatus>.empty(),
      ) as _i3.Stream<_i8.NetworkStatus>);

  @override
  _i8.NetworkStatus get currentStatus => (super.noSuchMethod(
        Invocation.getter(#currentStatus),
        returnValue: _i8.NetworkStatus.online,
      ) as _i8.NetworkStatus);

  @override
  bool get isOnline => (super.noSuchMethod(
        Invocation.getter(#isOnline),
        returnValue: false,
      ) as bool);

  @override
  _i3.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<_i8.NetworkStatus> getCurrentNetworkStatus() =>
      (super.noSuchMethod(
        Invocation.method(
          #getCurrentNetworkStatus,
          [],
        ),
        returnValue:
            _i3.Future<_i8.NetworkStatus>.value(_i8.NetworkStatus.online),
      ) as _i3.Future<_i8.NetworkStatus>);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [StorageService].
///
/// See the documentation for Mockito's code generation for more information.
class MockStorageService extends _i1.Mock implements _i9.StorageService {
  MockStorageService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  List<_i10.UserProfile> getAllUserProfiles() => (super.noSuchMethod(
        Invocation.method(
          #getAllUserProfiles,
          [],
        ),
        returnValue: <_i10.UserProfile>[],
      ) as List<_i10.UserProfile>);

  @override
  _i10.UserProfile? getUserProfile(String? id) =>
      (super.noSuchMethod(Invocation.method(
        #getUserProfile,
        [id],
      )) as _i10.UserProfile?);

  @override
  _i3.Future<void> saveUserProfile(_i10.UserProfile? profile) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveUserProfile,
          [profile],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> deleteUserProfile(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteUserProfile,
          [id],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  List<_i11.Tale> getAllFavoriteTales() => (super.noSuchMethod(
        Invocation.method(
          #getAllFavoriteTales,
          [],
        ),
        returnValue: <_i11.Tale>[],
      ) as List<_i11.Tale>);

  @override
  List<_i11.Tale> getFavoriteTales() => (super.noSuchMethod(
        Invocation.method(
          #getFavoriteTales,
          [],
        ),
        returnValue: <_i11.Tale>[],
      ) as List<_i11.Tale>);

  @override
  _i11.Tale? getTale(String? id) => (super.noSuchMethod(Invocation.method(
        #getTale,
        [id],
      )) as _i11.Tale?);

  @override
  _i11.Tale? getFavoriteTale(String? id) =>
      (super.noSuchMethod(Invocation.method(
        #getFavoriteTale,
        [id],
      )) as _i11.Tale?);

  @override
  _i3.Future<bool> saveFavoriteTale(_i11.Tale? tale) => (super.noSuchMethod(
        Invocation.method(
          #saveFavoriteTale,
          [tale],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i3.Future<void> deleteFavoriteTale(String? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteFavoriteTale,
          [id],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> updateTale(_i11.Tale? tale) => (super.noSuchMethod(
        Invocation.method(
          #updateTale,
          [tale],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> markTaleAsDownloaded(String? taleId) => (super.noSuchMethod(
        Invocation.method(
          #markTaleAsDownloaded,
          [taleId],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> updateTaleDownloadStatus(
    String? taleId,
    bool? isDownloaded,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTaleDownloadStatus,
          [
            taleId,
            isDownloaded,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  List<_i11.Tale> getOfflineAvailableTales() => (super.noSuchMethod(
        Invocation.method(
          #getOfflineAvailableTales,
          [],
        ),
        returnValue: <_i11.Tale>[],
      ) as List<_i11.Tale>);

  @override
  bool isTaleAvailableOffline(String? taleId) => (super.noSuchMethod(
        Invocation.method(
          #isTaleAvailableOffline,
          [taleId],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i3.Future<void> saveAppSetting(
    String? key,
    dynamic value,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveAppSetting,
          [
            key,
            value,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  dynamic getAppSetting(
    String? key, {
    dynamic defaultValue,
  }) =>
      super.noSuchMethod(Invocation.method(
        #getAppSetting,
        [key],
        {#defaultValue: defaultValue},
      ));

  @override
  _i3.Future<void> setActiveUserProfile(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #setActiveUserProfile,
          [userId],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [AudioService].
///
/// See the documentation for Mockito's code generation for more information.
class MockAudioService extends _i1.Mock implements _i12.AudioService {
  MockAudioService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set onComplete(Function? _onComplete) => super.noSuchMethod(
        Invocation.setter(
          #onComplete,
          _onComplete,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i12.AudioState get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _i12.AudioState.playing,
      ) as _i12.AudioState);

  @override
  void setTtsForTesting(_i13.FlutterTts? tts) => super.noSuchMethod(
        Invocation.method(
          #setTtsForTesting,
          [tts],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> speak(String? text) => (super.noSuchMethod(
        Invocation.method(
          #speak,
          [text],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> pause() => (super.noSuchMethod(
        Invocation.method(
          #pause,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> resume() => (super.noSuchMethod(
        Invocation.method(
          #resume,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> stop() => (super.noSuchMethod(
        Invocation.method(
          #stop,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<String?> saveToFile(
    String? text,
    String? fileName,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveToFile,
          [
            text,
            fileName,
          ],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);

  @override
  _i3.Future<List<String>> getAvailableLanguages() => (super.noSuchMethod(
        Invocation.method(
          #getAvailableLanguages,
          [],
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);

  @override
  _i3.Future<void> setSpeechRate(double? rate) => (super.noSuchMethod(
        Invocation.method(
          #setSpeechRate,
          [rate],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> setVolume(double? volume) => (super.noSuchMethod(
        Invocation.method(
          #setVolume,
          [volume],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> setPitch(double? pitch) => (super.noSuchMethod(
        Invocation.method(
          #setPitch,
          [pitch],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> setLanguage(String? language) => (super.noSuchMethod(
        Invocation.method(
          #setLanguage,
          [language],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
