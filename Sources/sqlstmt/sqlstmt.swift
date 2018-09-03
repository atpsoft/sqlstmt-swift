// it appears to use the method chaining syntax we want
// we must use class instead of struct because class is a reference type
// and so can make changes, while still returning self without the mutating keyword
// when it was a struct and we tried to chain, we go this error:
// "cannot use mutating member on immutable value: function call returns immutable value"
class SqlStmt {
  var data: SqlData = SqlData()

  ////// pick statement type

  @discardableResult func select() throws -> SqlStmt {
    return try type(.select)
  }

  @discardableResult func update() throws -> SqlStmt {
    return try type(.update)
  }

  @discardableResult func insert() throws -> SqlStmt {
    return try type(.insert)
  }

  @discardableResult func delete(_ tables: String...) throws -> SqlStmt {
    try type(.delete)
    data.tables_to_delete = tables
    return self
  }

  @discardableResult func type(_ stmt_type: StmtType) throws -> SqlStmt {
    if (data.stmt_type != nil) && (stmt_type != data.stmt_type!) {
      throw StmtError.runtimeError("statement type already set to \(data.stmt_type!)")
    }
    data.stmt_type = stmt_type
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

  ////// where

  @discardableResult func no_where() -> SqlStmt {
    data.where_behavior = .exclude
    return self
  }

  @discardableResult func optional_where() -> SqlStmt {
    data.where_behavior = .optional
    return self
  }

  ////// fields & values

  // an empty string can be passed in for the field, in which case it won"t be added
  // this is only for the special case of INSERT INTO table SELECT b.* FROM blah b WHERE ...
  // where there are no specific fields listed
  func set(_ field: String, _ value: SafelySql) throws -> SqlStmt {
    if data.set_fields.contains(field) {
      throw StmtError.runtimeError("trying to set field \(field) again")
    }

    if !field.isEmpty {
      data.set_fields.append(field)
    }
    // TODO: seems like there should be a better way to do this, but it seems to work, so it's good enough for now
    let str = (value is String) ? value as! String : value.toSql()
    data.set_values.append(str)
    return self
  }

  func setq(_ field: String, _ value: SafelySql) throws -> SqlStmt {
    return try set(field, value.toSql())
  }

  /////// convert it to a string
  func to_s() throws -> String {
    let checker = MysqlChecker(data)
    // raises an exception if it finds a problem
    try checker.run()

    let builder = MysqlBuilder(data)
    return try builder.build()
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

  //////////// remaining methods are simple ones that could/should be generated instead of just duplicated (they are in the ruby version)
  //////////// they are generated in the sqlstmt ruby gem, but I don't know a good way yet to do it in Swift

  ////// simple flag keywords
  @discardableResult func distinct() -> SqlStmt { data.distinct = true; return self }
  @discardableResult func ignore() -> SqlStmt { data.ignore = true; return self }
  @discardableResult func replace() -> SqlStmt { data.replace = true; return self }
  @discardableResult func straight_join() -> SqlStmt { data.straight_join = true; return self }
  @discardableResult func with_rollup() -> SqlStmt { data.with_rollup = true; return self }

  ////// simple single value keywords
  @discardableResult func group_by(_ value: String) -> SqlStmt { data.group_by = value; return self }
  @discardableResult func into(_ value: String) -> SqlStmt { data.into = value; return self }
  @discardableResult func limit(_ value: String) -> SqlStmt { data.limit = value; return self }
  @discardableResult func offset(_ value: String) -> SqlStmt { data.offset = value; return self }
  @discardableResult func order_by(_ value: String) -> SqlStmt { data.order_by = value; return self }
  @discardableResult func outfile(_ value: String) -> SqlStmt { data.outfile = value; return self }

  ////// simple multi value keywords
  @discardableResult func get(_ values: String...) -> SqlStmt { data.gets.append(contentsOf: values); return self }
  @discardableResult func having(_ values: String...) -> SqlStmt { data.havings.append(contentsOf: values); return self }
  // the backticks around where are necessary because it is a keyword
  @discardableResult func `where`(_ values: String...) -> SqlStmt { data.wheres.append(contentsOf: values); return self }
}
