// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GitError {
  String get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) io,
    required TResult Function(String field0) git,
    required TResult Function(String field0) auth,
    required TResult Function(String field0) other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? io,
    TResult? Function(String field0)? git,
    TResult? Function(String field0)? auth,
    TResult? Function(String field0)? other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? io,
    TResult Function(String field0)? git,
    TResult Function(String field0)? auth,
    TResult Function(String field0)? other,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GitError_Io value) io,
    required TResult Function(GitError_Git value) git,
    required TResult Function(GitError_Auth value) auth,
    required TResult Function(GitError_Other value) other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GitError_Io value)? io,
    TResult? Function(GitError_Git value)? git,
    TResult? Function(GitError_Auth value)? auth,
    TResult? Function(GitError_Other value)? other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GitError_Io value)? io,
    TResult Function(GitError_Git value)? git,
    TResult Function(GitError_Auth value)? auth,
    TResult Function(GitError_Other value)? other,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GitErrorCopyWith<GitError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GitErrorCopyWith<$Res> {
  factory $GitErrorCopyWith(GitError value, $Res Function(GitError) then) =
      _$GitErrorCopyWithImpl<$Res, GitError>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$GitErrorCopyWithImpl<$Res, $Val extends GitError>
    implements $GitErrorCopyWith<$Res> {
  _$GitErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _value.copyWith(
            field0: null == field0
                ? _value.field0
                : field0 // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GitError_IoImplCopyWith<$Res>
    implements $GitErrorCopyWith<$Res> {
  factory _$$GitError_IoImplCopyWith(
    _$GitError_IoImpl value,
    $Res Function(_$GitError_IoImpl) then,
  ) = __$$GitError_IoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$GitError_IoImplCopyWithImpl<$Res>
    extends _$GitErrorCopyWithImpl<$Res, _$GitError_IoImpl>
    implements _$$GitError_IoImplCopyWith<$Res> {
  __$$GitError_IoImplCopyWithImpl(
    _$GitError_IoImpl _value,
    $Res Function(_$GitError_IoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$GitError_IoImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GitError_IoImpl extends GitError_Io {
  const _$GitError_IoImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'GitError.io(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GitError_IoImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GitError_IoImplCopyWith<_$GitError_IoImpl> get copyWith =>
      __$$GitError_IoImplCopyWithImpl<_$GitError_IoImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) io,
    required TResult Function(String field0) git,
    required TResult Function(String field0) auth,
    required TResult Function(String field0) other,
  }) {
    return io(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? io,
    TResult? Function(String field0)? git,
    TResult? Function(String field0)? auth,
    TResult? Function(String field0)? other,
  }) {
    return io?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? io,
    TResult Function(String field0)? git,
    TResult Function(String field0)? auth,
    TResult Function(String field0)? other,
    required TResult orElse(),
  }) {
    if (io != null) {
      return io(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GitError_Io value) io,
    required TResult Function(GitError_Git value) git,
    required TResult Function(GitError_Auth value) auth,
    required TResult Function(GitError_Other value) other,
  }) {
    return io(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GitError_Io value)? io,
    TResult? Function(GitError_Git value)? git,
    TResult? Function(GitError_Auth value)? auth,
    TResult? Function(GitError_Other value)? other,
  }) {
    return io?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GitError_Io value)? io,
    TResult Function(GitError_Git value)? git,
    TResult Function(GitError_Auth value)? auth,
    TResult Function(GitError_Other value)? other,
    required TResult orElse(),
  }) {
    if (io != null) {
      return io(this);
    }
    return orElse();
  }
}

abstract class GitError_Io extends GitError {
  const factory GitError_Io(final String field0) = _$GitError_IoImpl;
  const GitError_Io._() : super._();

  @override
  String get field0;

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GitError_IoImplCopyWith<_$GitError_IoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GitError_GitImplCopyWith<$Res>
    implements $GitErrorCopyWith<$Res> {
  factory _$$GitError_GitImplCopyWith(
    _$GitError_GitImpl value,
    $Res Function(_$GitError_GitImpl) then,
  ) = __$$GitError_GitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$GitError_GitImplCopyWithImpl<$Res>
    extends _$GitErrorCopyWithImpl<$Res, _$GitError_GitImpl>
    implements _$$GitError_GitImplCopyWith<$Res> {
  __$$GitError_GitImplCopyWithImpl(
    _$GitError_GitImpl _value,
    $Res Function(_$GitError_GitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$GitError_GitImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GitError_GitImpl extends GitError_Git {
  const _$GitError_GitImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'GitError.git(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GitError_GitImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GitError_GitImplCopyWith<_$GitError_GitImpl> get copyWith =>
      __$$GitError_GitImplCopyWithImpl<_$GitError_GitImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) io,
    required TResult Function(String field0) git,
    required TResult Function(String field0) auth,
    required TResult Function(String field0) other,
  }) {
    return git(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? io,
    TResult? Function(String field0)? git,
    TResult? Function(String field0)? auth,
    TResult? Function(String field0)? other,
  }) {
    return git?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? io,
    TResult Function(String field0)? git,
    TResult Function(String field0)? auth,
    TResult Function(String field0)? other,
    required TResult orElse(),
  }) {
    if (git != null) {
      return git(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GitError_Io value) io,
    required TResult Function(GitError_Git value) git,
    required TResult Function(GitError_Auth value) auth,
    required TResult Function(GitError_Other value) other,
  }) {
    return git(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GitError_Io value)? io,
    TResult? Function(GitError_Git value)? git,
    TResult? Function(GitError_Auth value)? auth,
    TResult? Function(GitError_Other value)? other,
  }) {
    return git?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GitError_Io value)? io,
    TResult Function(GitError_Git value)? git,
    TResult Function(GitError_Auth value)? auth,
    TResult Function(GitError_Other value)? other,
    required TResult orElse(),
  }) {
    if (git != null) {
      return git(this);
    }
    return orElse();
  }
}

abstract class GitError_Git extends GitError {
  const factory GitError_Git(final String field0) = _$GitError_GitImpl;
  const GitError_Git._() : super._();

  @override
  String get field0;

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GitError_GitImplCopyWith<_$GitError_GitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GitError_AuthImplCopyWith<$Res>
    implements $GitErrorCopyWith<$Res> {
  factory _$$GitError_AuthImplCopyWith(
    _$GitError_AuthImpl value,
    $Res Function(_$GitError_AuthImpl) then,
  ) = __$$GitError_AuthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$GitError_AuthImplCopyWithImpl<$Res>
    extends _$GitErrorCopyWithImpl<$Res, _$GitError_AuthImpl>
    implements _$$GitError_AuthImplCopyWith<$Res> {
  __$$GitError_AuthImplCopyWithImpl(
    _$GitError_AuthImpl _value,
    $Res Function(_$GitError_AuthImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$GitError_AuthImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GitError_AuthImpl extends GitError_Auth {
  const _$GitError_AuthImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'GitError.auth(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GitError_AuthImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GitError_AuthImplCopyWith<_$GitError_AuthImpl> get copyWith =>
      __$$GitError_AuthImplCopyWithImpl<_$GitError_AuthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) io,
    required TResult Function(String field0) git,
    required TResult Function(String field0) auth,
    required TResult Function(String field0) other,
  }) {
    return auth(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? io,
    TResult? Function(String field0)? git,
    TResult? Function(String field0)? auth,
    TResult? Function(String field0)? other,
  }) {
    return auth?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? io,
    TResult Function(String field0)? git,
    TResult Function(String field0)? auth,
    TResult Function(String field0)? other,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GitError_Io value) io,
    required TResult Function(GitError_Git value) git,
    required TResult Function(GitError_Auth value) auth,
    required TResult Function(GitError_Other value) other,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GitError_Io value)? io,
    TResult? Function(GitError_Git value)? git,
    TResult? Function(GitError_Auth value)? auth,
    TResult? Function(GitError_Other value)? other,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GitError_Io value)? io,
    TResult Function(GitError_Git value)? git,
    TResult Function(GitError_Auth value)? auth,
    TResult Function(GitError_Other value)? other,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }
}

abstract class GitError_Auth extends GitError {
  const factory GitError_Auth(final String field0) = _$GitError_AuthImpl;
  const GitError_Auth._() : super._();

  @override
  String get field0;

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GitError_AuthImplCopyWith<_$GitError_AuthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GitError_OtherImplCopyWith<$Res>
    implements $GitErrorCopyWith<$Res> {
  factory _$$GitError_OtherImplCopyWith(
    _$GitError_OtherImpl value,
    $Res Function(_$GitError_OtherImpl) then,
  ) = __$$GitError_OtherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$GitError_OtherImplCopyWithImpl<$Res>
    extends _$GitErrorCopyWithImpl<$Res, _$GitError_OtherImpl>
    implements _$$GitError_OtherImplCopyWith<$Res> {
  __$$GitError_OtherImplCopyWithImpl(
    _$GitError_OtherImpl _value,
    $Res Function(_$GitError_OtherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$GitError_OtherImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GitError_OtherImpl extends GitError_Other {
  const _$GitError_OtherImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'GitError.other(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GitError_OtherImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GitError_OtherImplCopyWith<_$GitError_OtherImpl> get copyWith =>
      __$$GitError_OtherImplCopyWithImpl<_$GitError_OtherImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) io,
    required TResult Function(String field0) git,
    required TResult Function(String field0) auth,
    required TResult Function(String field0) other,
  }) {
    return other(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? io,
    TResult? Function(String field0)? git,
    TResult? Function(String field0)? auth,
    TResult? Function(String field0)? other,
  }) {
    return other?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? io,
    TResult Function(String field0)? git,
    TResult Function(String field0)? auth,
    TResult Function(String field0)? other,
    required TResult orElse(),
  }) {
    if (other != null) {
      return other(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GitError_Io value) io,
    required TResult Function(GitError_Git value) git,
    required TResult Function(GitError_Auth value) auth,
    required TResult Function(GitError_Other value) other,
  }) {
    return other(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GitError_Io value)? io,
    TResult? Function(GitError_Git value)? git,
    TResult? Function(GitError_Auth value)? auth,
    TResult? Function(GitError_Other value)? other,
  }) {
    return other?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GitError_Io value)? io,
    TResult Function(GitError_Git value)? git,
    TResult Function(GitError_Auth value)? auth,
    TResult Function(GitError_Other value)? other,
    required TResult orElse(),
  }) {
    if (other != null) {
      return other(this);
    }
    return orElse();
  }
}

abstract class GitError_Other extends GitError {
  const factory GitError_Other(final String field0) = _$GitError_OtherImpl;
  const GitError_Other._() : super._();

  @override
  String get field0;

  /// Create a copy of GitError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GitError_OtherImplCopyWith<_$GitError_OtherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
