using PkgEval
using FMIBuild

config = Configuration(; julia = "1.8");

package = Package(; name = "FMIBuild");

@info "PkgEval"
result = evaluate([config], [package])

@info "Result"
println(result)

@info "Log"
println(result.log)
