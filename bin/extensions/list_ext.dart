extension ListExt<E> on List<E> {

  E? find(bool Function(E) predicate) {
    try {
      return firstWhere(predicate);
    } catch (error) {
      return null;
    }
  }

}
