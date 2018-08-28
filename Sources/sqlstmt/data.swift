enum StmtType: String { case select, update, insert, delete }

struct SqlTable {
  var str: String = ""
  var name: String = ""
  var alias: String = ""
  var index: String = ""
}

struct SqlJoin {
  var kwstr: String = ""
  var table: SqlTable = SqlTable()
  var on_expr: String = ""
}

struct SqlData {
  var stmt_type: StmtType?
  var tables: [SqlTable] = []
  var table_ids: Set<String> = []
  var gets: [String] = []
  var joins: [SqlJoin] = []
  var tables_to_delete: [String] = []

  init() {
    self.stmt_type = nil
  }
}
