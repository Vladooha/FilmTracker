enum ClauseJoinOperator {
  AND, OR
}

class CompareOperator {
  static const EQUALS = CompareOperator._("=");
  static const NOT_EQUALS = CompareOperator._("!=");
  static const IN = CompareOperator._("IN");
  static const NOT_IN = CompareOperator._("NOT IN");
  static const LIKE = CompareOperator._("LIKE");

  final String sqlSign;

  const CompareOperator._(this.sqlSign);

  @override
  String toString() => sqlSign;
}

class ComparedValue {
  final value;
  final CompareOperator compareOperator;

  ComparedValue(this.value, this.compareOperator);

  @override
  String toString() {
    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write(compareOperator);
    stringBuffer.write(" ");
    if (value is List) {
      stringBuffer.write("(${value.join(", ")})");
    } else {
      stringBuffer.write(value);
    }

    return stringBuffer.toString();
  }
}

class QueryFilter {
  final Map<String, ComparedValue> conditions =
    <String, ComparedValue>{};

  add(String name, ComparedValue condition) {
    conditions[name] = condition;
  }

  remove(String name) {
    conditions.remove(name);
  }

  /// Creates SQL 'WHERE' (without 'WHERE' itself) clause by added [conditions].
  ///
  /// All conditions joined by [joinType]. Default type is [ClauseJoinType.AND]
  ///
  /// Returns [null] if [conditions] is empty
  getSql([ClauseJoinOperator joinOperator = ClauseJoinOperator.AND]) {
    if (conditions.isEmpty) {
      return null;
    }

    StringBuffer sqlBuffer = StringBuffer();
    conditions.forEach((name, condition) {
      if (sqlBuffer.isNotEmpty) {
        sqlBuffer.write((" ${joinOperator.toString()} "));
      }
      sqlBuffer.write(name);
      sqlBuffer.write(" ");
      sqlBuffer.write(conditions);
    });

    return sqlBuffer.toString();
  }
}

// class DatabaseQueryUtils {
//   String mapToWhereClause(
//       QueryFilter queryFilter,
//       [ClauseJoinOperator joinType = ClauseJoinOperator.AND]) {
//     if (null == queryFilter) {
//       return null;
//     }
//
//     return whereClauseBuffer;
//   }
//
//   /// Joins some SQL 'WHERE' clauses from [clauses] into
//   /// one WHERE clause without 'WHERE' itself.
//   /// All clauses joined by [joinType]. Default type is [ClauseJoinType.OR]
//   ///
//   /// This method can work only with [clauses] created by
//   /// [DatabaseQueryUtils.mapToWhereClause] method,
//   /// any others can produce unexpected errors
//   ///
//   /// Returns [null] if [clauses] is empty
//   String joinWhereClauses(
//       List<String> clauses,
//       [ClauseJoinOperator joinType = ClauseJoinOperator.OR]) {
//     if (null == clauses || clauses.isEmpty) {
//       return null;
//     } else if (1 == clauses.length) {
//       return clauses[0];
//     } else {
//       return clauses.join(" ${joinType.toString()} ");
//     }
//   }
// }