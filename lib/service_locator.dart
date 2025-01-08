import 'package:blog/core/configs/constants/hive_constants/hive_constants.dart';
import 'package:blog/data/models/hive/blog_model.dart';
import 'package:blog/data/repository/auth/auth_repo_impl.dart';
import 'package:blog/data/repository/cloud_storage/images/image_repository_impl.dart';
import 'package:blog/data/repository/cloud_storage/images/storage/storage_repository_impl.dart';
import 'package:blog/data/repository/firestore/firestore_repository_imp.dart';
import 'package:blog/data/repository/hive/hive_repository_impl.dart';
import 'package:blog/data/sources/auth/auth_firebase_service.dart';
import 'package:blog/data/sources/cloud_storage/images/image_picker_service.dart';
import 'package:blog/data/sources/cloud_storage/storage/storage_service.dart';
import 'package:blog/data/sources/firestore/firestore_service.dart';
import 'package:blog/data/sources/hive/hive_service.dart';
import 'package:blog/domain/repository/auth/auth_repo.dart';
import 'package:blog/domain/repository/blog/blog_repository.dart';
import 'package:blog/domain/repository/cloud_storage/images/image_repository.dart';
import 'package:blog/domain/repository/cloud_storage/storage/storage_repository.dart';
import 'package:blog/domain/repository/firestore/firestore_repository.dart';
import 'package:blog/domain/services/markdown_service.dart';
import 'package:blog/domain/usecases/auth/logout_usecase.dart';
import 'package:blog/domain/usecases/auth/signin_usecase.dart';
import 'package:blog/domain/usecases/auth/signup_usecase.dart';
import 'package:blog/domain/usecases/cloud_storage/upload_image_usecase.dart';
import 'package:blog/domain/usecases/firestore/follow_usecase.dart';
import 'package:blog/domain/usecases/firestore/get_profile_blogs_usecase.dart';
import 'package:blog/domain/usecases/firestore/get_profile_usecase.dart';
import 'package:blog/domain/usecases/hive/add_usecase.dart';
import 'package:blog/domain/usecases/hive/clear_data_usecase.dart';
import 'package:blog/domain/usecases/hive/get_all_usecase.dart';
import 'package:blog/domain/usecases/hive/update_usecase.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/blog/blog_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/image/image_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'domain/usecases/cloud_storage/pick_image_usecase.dart';

final GetIt sl = GetIt.instance;

void getDependencies() {
  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImplementation(),
  );
  sl.registerSingleton<FirestoreService>(FirestoreServiceImplementation());
  sl.registerSingleton<FirestoreRepository>(FirestoreRepositoryImp());

  // Then register AuthRepository
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImplementation(),
  );

  sl.registerSingleton<StorageService>(StorageServiceImplementation());
  sl.registerSingleton<StorageRepository>(StorageRepositoryImpl());

  sl.registerLazySingleton<SignupUsecase>(
    () => SignupUsecase(),
  );
  sl.registerLazySingleton<SigninUsecase>(
    () => SigninUsecase(),
  );
  sl.registerLazySingleton<LogoutUsecase>(
    () => LogoutUsecase(),
  );
  sl.registerLazySingleton<ClearDataUsecase>(
    () => ClearDataUsecase(),
  );

  sl.registerFactory(() => AuthBloc(sl<SignupUsecase>(), sl<SigninUsecase>(),
      sl<LogoutUsecase>(), sl<ClearDataUsecase>())); //new instance each time

  final blogBox = Hive.box<BlogModel>(HiveConstants.blogsBox);
  sl.registerSingleton<HiveService>(HiveServiceImpl(blogBox: blogBox));

  sl.registerSingleton<BlogRepository>(BlogRepositoryImplementation());

  //hive crud usecase
  sl.registerLazySingleton<AddUsecase>(() => AddUsecase());
  sl.registerLazySingleton<UpdateUsecase>(() => UpdateUsecase());
  sl.registerLazySingleton<GetAllUsecase>(() => GetAllUsecase());

  //firestore usecases
  sl.registerLazySingleton<GetProfileUsecase>(() => GetProfileUsecase());
  sl.registerLazySingleton<FollowUsecase>(() => FollowUsecase());

  // Services
  sl.registerLazySingleton<MarkdownService>(
    () => MarkdownServiceImpl(),
  );

  // Blocs
  sl.registerFactory(() => BlogBloc(
        markDownService: sl(),
      ));
  sl.registerFactory(() => ImageBloc(pickImageUseCase: sl()));
  sl.registerFactory(() => UploadBloc());
  sl.registerFactory(() => PublishBloc());

  //usecases
  sl.registerLazySingleton(() => PickImageUsecase());
  sl.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(),
  );
  sl.registerLazySingleton<ImageLocalService>(
    () => ImageLocalServiceImplementation(),
  );

  sl.registerLazySingleton(() => UploadImageUsecase());
  sl.registerLazySingleton(() => GetProfileBlogsUsecase());

  /*
  Singletons - 
    Used for stateless services
    Same instance shared across app
    Repository patterns
    Network clients
    Database connections
*/

  /*
  Factory - 
    Used for stateful components
    New instance each time
    Prevents state sharing between screens
    Avoids memory leaks
    Clean state management
  */
}
