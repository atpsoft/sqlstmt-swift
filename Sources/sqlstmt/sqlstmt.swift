// it appears to use the method chaining syntax we want
// we must use class instead of struct because class is a reference type
// and so can make changes, while still returning self without the mutating keyword
// when it was a struct and we tried to chain, we go this error:
// "cannot use mutating member on immutable value: function call returns immutable value"
class SqlStmt {
  var data: SqlData = SqlData()

  func to_s() throws -> String {
    let builder = MysqlBuilder(data)
    return try builder.build()
  }

  @discardableResult func select() -> SqlStmt {
    data.stmt_type = .select
    return self
  }

  @discardableResult func get(_ key: String) -> SqlStmt {
    data.gets.append(key)
    return self
  }

  @discardableResult func no_where() -> SqlStmt {
    return self
  }

  ////// tables & joins

  @discardableResult func table(_ ref: String, use_index: String = "") -> SqlStmt {
    let new_table = include_table(ref: ref, use_index: use_index)
    data.tables.append(new_table)
    return self
  }

  @discardableResult func join(_ table: String, _ exprs: String...) -> SqlStmt {
    return any_join("JOIN", table, exprs)
  }

  @discardableResult func left_join(_ table: String, _ exprs: String...) -> SqlStmt {
    return any_join("LEFT JOIN", table, exprs)
  }

  @discardableResult func any_join(_ kwstr: String, _ ref: String, _ exprs: [String]) -> SqlStmt {
    let tbl = include_table(ref: ref)
    let onstr = exprs.joined(separator: " AND ")
    let join = SqlJoin(kwstr: kwstr, table: tbl, on_expr: "ON \(onstr)")
    data.joins.append(join)
    return self
  }


  // this is used for method calls to :table and :any_join
  // sort of awkward as it is, because it mutates and returns a value
  // look at the uses cases where it calls to see why
  // but it needs to be improved
  private func include_table(ref: String, use_index: String = "") -> SqlTable {
    var parts = ref.split(separator: " ")
    if parts.count == 3 {
      parts.remove(at: 1)
    }
    // table_ids = table_ids.union(parts)
    for str in parts {
      data.table_ids.insert(String(str))
    }

    let tbl_name = parts[0]
    let tbl_alias = (parts.count == 2) ? parts[1] : tbl_name
    return SqlTable(str: ref, name: String(tbl_name), alias: String(tbl_alias), index: use_index)
  }

  /////////////////// building stuff that will be moved elsewhere
  func join_to_str(_ join: SqlJoin) -> String {
    return [join.kwstr, join.table.str, join.on_expr].joined(separator: " ")
  }

  func build_join_clause() -> String {
    let join_strs = data.joins.map {join in join_to_str(join)}
    return join_strs.joined(separator: " ")
  }

}
