// it appears to use the method chaining syntax we want
// we must use class instead of struct because class is a reference type
// and so can make changes, while still returning self without the mutating keyword
// when it was a struct and we tried to chain, we go this error:
// "cannot use mutating member on immutable value: function call returns immutable value"
class SqlStmt {
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

  struct SqlData {
    var stmt_type: StmtType?
    var tables: [SqlTable] = []
    var table_ids: Set<String> = []
    var gets: [String] = []

    init() {
      self.stmt_type = nil
    }
  }


  var data: SqlData = SqlData()

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
    let table_refs = data.tables.map { table in table_to_str(table) }
    return table_refs.joined(separator: ",")
  }

  func to_s() throws -> String {
    if data.stmt_type == nil {
      throw StmtError.runtimeError("must pick a statement type")
    }
    var parts: [String] = []
    parts.append(data.stmt_type!.rawValue.uppercased())
    parts.append(data.gets.joined(separator: ","))
    parts.append("FROM")
    parts.append(build_table_list())
    return combine_parts(parts)
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
}
