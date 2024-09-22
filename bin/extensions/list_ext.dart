extension ListExt<E> on List<E> {
  E? find(bool Function(E) predicate) {
    try {
      return firstWhere(predicate);
    } catch (error) {
      return null;
    }
  }

  List<E> distinct<K>(K Function(E) toKey) {
    final unique = <K>{};

    retainWhere((item) => unique.add(toKey(item)));
    return this;
  }
}
