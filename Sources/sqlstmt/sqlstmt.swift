struct SqlStmt {
  enum StmtError: Error {
    case runtimeError(String)
  }
  enum StmtType: String { case select, update, insert, delete }

  struct SqlTable {
    var str: String = ""
    var name: String = ""
    var alias: String = ""
    var index: String = ""
  }


  var stmt_type: StmtType?
  var tables: [SqlTable] = []
  var table_ids: Set<String> = []
  var gets: [String] = []

  init() {
    stmt_type = nil
  }

  func combine_parts(_ parts: [String]) -> String {
    return parts.joined(separator: " ")
  }

  func table_to_str(_ table: SqlTable) -> String {
    if !table.index.isEmpty {
      return "\(table.str) USE INDEX (\(table.index))"
    }
    return table.str
  }

  func build_table_list() -> String {
    let table_refs = tables.map { table in table_to_str(table) }
    return table_refs.joined(separator: ",")
  }

  func to_s() throws -> String {
    if stmt_type == nil {
      throw StmtError.runtimeError("must pick a statement type")
    }
    var parts: [String] = []
    parts.append(stmt_type!.rawValue.uppercased())
    parts.append(gets.joined(separator: ""))
    parts.append("FROM")
    parts.append(build_table_list())
    return combine_parts(parts)
  }

  @discardableResult mutating func select() -> SqlStmt {
    stmt_type = .select
    return self
  }

  @discardableResult mutating func table(_ ref: String, use_index: String = "") -> SqlStmt {
    let new_table = include_table(ref: ref, use_index: use_index)
    tables.append(new_table)
    return self
  }

  // this is used for method calls to :table and :any_join
  // sort of awkward as it is, because it mutates and returns a value
  // look at the uses cases where it calls to see why
  // but it needs to be improved
  private mutating func include_table(ref: String, use_index: String = "") -> SqlTable {
    var parts = ref.split(separator: " ")
    if parts.count == 3 {
      parts.remove(at: 1)
    }
    // table_ids = table_ids.union(parts)
    for str in parts {
      table_ids.insert(String(str))
    }

    let tbl_name = parts[0]

    // see if there is a way to use let here as well, but have it visible outside the if scope
    var tbl_alias = tbl_name
    if parts.count == 2 {
      tbl_alias = parts[1]
    }
    return SqlTable(str: ref, name: String(tbl_name), alias: String(tbl_alias), index: use_index)
  }

  @discardableResult mutating func get(_ key: String) -> SqlStmt {
    gets.append(key)
    return self
  }

  @discardableResult mutating func no_where() -> SqlStmt {
    return self
  }
}
