import Foundation

class MysqlBuilder {
  let data: SqlData

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
    switch data.stmt_type! {
      case .select:
        return build_select()
      case .update:
        return build_update()
      case .insert:
        return build_insert()
      case .delete:
        return build_delete()
    }
  }

  func build_select() -> String {
    var parts: [String] = []
    parts.append(contentsOf: shared_select(data.gets))
    if !data.outfile.isEmpty {
      parts.append("INTO OUTFILE \(data.outfile)")
    }
    return combine_parts(parts)
  }

  func build_update() -> String {
    let parts: [String] = [
      "UPDATE",
      build_table_list(),
      build_join_clause(),
      "SET",
      build_set_clause(),
      build_where_clause(),
      simple_clause("LIMIT", data.limit),
    ]
    return combine_parts(parts)
  }

  func build_insert() -> String {
    var parts: [String] = []
    if data.replace {
      parts.append("REPLACE")
    } else {
      parts.append("INSERT")
    }
    if data.ignore { parts.append("IGNORE") }

    parts.append("INTO \(data.into)")
    if !data.set_fields.isEmpty {
      let field_list = data.set_fields.joined(separator: ",")
      parts.append("(\(field_list))")
    }
    parts.append(contentsOf: shared_select(data.set_values))
    return combine_parts(parts)
  }

  func build_delete() -> String {
    var parts: [String] = ["DELETE"]
    if !data.tables_to_delete.isEmpty {
      parts.append(data.tables_to_delete.joined(separator: ","))
    }
    parts.append(build_from_clause())
    return combine_parts(parts)
  }

  func shared_select(_ fields: [String]) -> [String] {
    var parts: [String] = ["SELECT"]
    if data.straight_join {
      parts.append("STRAIGHT_JOIN")
    }
    if data.distinct {
      parts.append("DISTINCT")
    }
    parts.append(fields.joined(separator: ","))
    parts.append(build_from_clause())
    return parts
  }

  func join_to_str(_ join: SqlJoin) -> String {
    return [join.kwstr, join.table.str, join.on_expr].joined(separator: " ")
  }

  func build_join_clause() -> String {
    let join_strs = data.joins.map {join in join_to_str(join)}
    let uniqueOrdered = NSOrderedSet(array: join_strs).array.map {$0 as! String}
    return uniqueOrdered.joined(separator: " ")
  }

  func simple_clause(_ keywords: String, _ value: String) -> String {
    if value.isEmpty {
      return ""
    }
    return "\(keywords) \(value)"
  }

  func build_where_clause() -> String {
    if data.wheres.isEmpty {
      return ""
    }
    let exprs = data.wheres.joined(separator: " AND ")
    return "WHERE \(exprs)"
  }

  func build_from_clause() -> String {
    var parts = ["FROM"]
    parts.append(build_table_list())
    parts.append(build_join_clause())
    parts.append(build_where_clause())
    parts.append(simple_clause("GROUP BY", data.group_by))
    if data.with_rollup {
      parts.append("WITH ROLLUP")
    }
    if !data.havings.isEmpty {
      let exprs = data.havings.joined(separator: " AND ")
      parts.append("HAVING \(exprs)")
    }
    parts.append(simple_clause("ORDER BY", data.order_by))
    parts.append(simple_clause("LIMIT", data.limit))
    return combine_parts(parts)
  }

  func build_set_clause() -> String {
    var set_exprs: [String] = []
    for index in 0...(data.set_fields.count - 1) {
      let field = data.set_fields[index]
      let value = data.set_values[index]
      set_exprs.append("\(field) = \(value)")
    }
    return set_exprs.joined(separator: ", ")
  }
}
