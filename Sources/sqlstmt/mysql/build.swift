class MysqlBuilder {
  var data: SqlData

  init(_ data: SqlData) {
    self.data = data
  }

  func combine_parts(_ parts: [String]) -> String {
    let useful_parts = parts.filter { !$0.isEmpty }
    return useful_parts.joined(separator: " ")
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

  func build() throws -> String {
    if data.stmt_type == nil {
      throw StmtError.runtimeError("must pick a statement type")
    }
    var parts: [String] = []
    parts.append(data.stmt_type!.rawValue.uppercased())
    parts.append(data.gets.joined(separator: ","))
    parts.append("FROM")
    parts.append(build_table_list())
    parts.append(build_join_clause())
    return combine_parts(parts)
  }

  func join_to_str(_ join: SqlJoin) -> String {
    return [join.kwstr, join.table.str, join.on_expr].joined(separator: " ")
  }

  func build_join_clause() -> String {
    let join_strs = data.joins.map {join in join_to_str(join)}
    return join_strs.joined(separator: " ")
  }
}