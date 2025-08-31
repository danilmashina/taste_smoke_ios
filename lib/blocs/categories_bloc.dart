import 'package:flutter_bloc/flutter_bloc.dart';
import './categories_event.dart';
import './categories_state.dart';
import '../../data/category.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc() : super(CategoriesInitial()) {
    on<FetchCategories>(_onFetchCategories);
  }

  void _onFetchCategories(
    FetchCategories event,
    Emitter<CategoriesState> emit,
  ) {
    emit(CategoriesLoading());
    // In a real app, this would come from a repository, which might fetch from a server.
    // For now, we just return the hardcoded list.
    final List<Category> categories = [
      const Category(name: 'Фрукты'),
      const Category(name: 'Ягоды'),
      const Category(name: 'Цитрусовые'),
      const Category(name: 'Десерты'),
      const Category(name: 'Напитки'),
      const Category(name: 'Мятные'),
      const Category(name: 'Пряные'),
      const Category(name: 'Кислые'),
      const Category(name: 'Необычные'),
    ];
    emit(CategoriesLoaded(categories));
  }
}
