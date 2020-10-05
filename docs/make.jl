Pkg.activate("./docs")

using Documenter, ModelObjectsLH
import FilesLH.deploy_docs

makedocs(
    modules = [ModelObjectsLH],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "hendri54",
    sitename = "ModelObjectsLH.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

pkgDir = rstrip(normpath(@__DIR__, ".."), '/');
@assert endswith(pkgDir, "ModelObjectsLH")
deploy_docs(pkgDir);

Pkg.activate(".")

# -------------