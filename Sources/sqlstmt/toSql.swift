// this is necessary in order to use the String method replacingOccurrences,
// which seems insane to me, so maybe there's something I'm missing, but for now it works
import Foundation

protocol SafelySql {
  func toSql() -> String
}

extension String: SafelySql {
  func toSql() -> String {
    var retval = self.replacingOccurrences(of: "\\", with: "\\\\")
    retval = retval.replacingOccurrences(of: "'", with: "\\'")
    retval = retval.replacingOccurrences(of: "\"", with: "\\\"")
    return "\'\(retval)\'"
  }
}

extension Bool: SafelySql {
  func toSql() -> String {
    if self == true {
      return "1"
    }
    return "0"
  }
}
