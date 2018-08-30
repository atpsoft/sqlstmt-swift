class MysqlChecker {
  let data: SqlData

  init(_ data: SqlData) {
    self.data = data
  }

  func run() throws {
    try check_basics()
    try check_where()
    try check_statement_type_specific()
  }

  func check_basics() throws {
    if data.stmt_type == nil {
      throw StmtError.runtimeError("must call :select, :update, :insert or :delete")
    }
    if data.tables.isEmpty {
      throw StmtError.runtimeError("must call :table")
    }
  }

  func check_where() throws {
    if (data.where_behavior == .require) && data.wheres.isEmpty {
      throw StmtError.runtimeError("must call :where, :no_where, or :optional_where")
    } else if (data.where_behavior == .exclude) && !data.wheres.isEmpty {
      throw StmtError.runtimeError(":where and :no_where must not both be called, consider :optional_where instead")
    }
  }

  func check_statement_type_specific() throws {
    switch data.stmt_type! {
      case .select:
        try check_select()
      case .update:
        try check_update()
      case .insert:
        try check_insert()
      case .delete:
        try check_delete()
    }

    if data.stmt_type != .select {
      if !data.gets.isEmpty {
        throw StmtError.runtimeError("must not call :get on \(data.stmt_type!) statement")
      }
    }
  }

  func check_select() throws {
    if data.gets.isEmpty { throw StmtError.runtimeError("must call :get on select statement") }
    if !data.set_values.isEmpty { throw StmtError.runtimeError("must not call :set on select statement") }
  }

  func check_update() throws {
    if data.set_values.isEmpty { throw StmtError.runtimeError("must call :set on update statement") }
  }

  func check_insert() throws {
    if data.set_values.isEmpty { throw StmtError.runtimeError("must call :set on insert statement") }
    if data.into.isEmpty { throw StmtError.runtimeError("must call :into on insert statement") }
  }

  func check_delete() throws {
    if !data.set_values.isEmpty { throw StmtError.runtimeError("must not call :set on delete statement") }
    if data.tables_to_delete.isEmpty && ((data.tables.count + data.joins.count) > 1) {
      throw StmtError.runtimeError("must specify tables to delete when including multiple tables")
    }
  }
}
