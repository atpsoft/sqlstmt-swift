enum StmtType: String { case select, update, insert, delete }
enum WhereBehavior { case require, exclude, optional }

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
  var stmt_type: StmtType? = nil
  var tables: [SqlTable] = []
  var table_ids: Set<String> = []
  var joins: [SqlJoin] = []
  var tables_to_delete: [String] = []
  var where_behavior: WhereBehavior = .require
  var set_fields: [String] = []
  var set_values: [String] = []

  // simple flag keywords
  var distinct: Bool = false
  var ignore: Bool = false
  var replace: Bool = false
  var straight_join: Bool = false
  var with_rollup: Bool = false

  // simple single value keywords
  var group_by: String = ""
  var into: String = ""
  var limit: String = ""
  var offset: String = ""
  var order_by: String = ""
  var outfile: String = ""

  // simple multi value keywords
  var gets: [String] = []
  var havings: [String] = []
  var wheres: [String] = []
}
