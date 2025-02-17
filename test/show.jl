@info "Running show tests"

const TEMPLATES_DIR = contractuser(PT.default_file())
const LICENSES_DIR = joinpath(TEMPLATES_DIR, "licenses")

function test_show(expected::AbstractString, observed::AbstractString)
    if expected == observed
        @test true
    else
        print_diff(expected, observed)
        @test :expected == :observed
    end
end

@testset "Show methods" begin
    @testset "Plugins" begin
        expected = """
            Readme:
              file: "$(joinpath(TEMPLATES_DIR, "README.md"))"
              destination: "README.md"
              inline_badges: false
              badge_order: DataType[Documenter{GitHubActions}, Documenter{GitLabCI}, Documenter{TravisCI}, GitHubActions, GitLabCI, TravisCI, AppVeyor, DroneCI, CirrusCI, Codecov, Coveralls, BlueStyleBadge, ColPracBadge, PkgEvalBadge]
              badge_off: DataType[]
            """
        test_show(rstrip(expected), sprint(show, MIME("text/plain"), Readme()))
    end

    @testset "Template" begin
        expected = """
            Template:
              authors: ["$USER"]
              dir: "$(contractuser(Pkg.devdir()))"
              host: "github.com"
              julia: v"1.0.0"
              user: "$USER"
              plugins:
                CompatHelper:
                  file: "$(joinpath(TEMPLATES_DIR, "github", "workflows", "CompatHelper.yml"))"
                  destination: "CompatHelper.yml"
                  cron: "0 0 * * *"
                Git:
                  ignore: String[]
                  name: nothing
                  email: nothing
                  branch: "main"
                  ssh: false
                  jl: true
                  manifest: false
                  gpgsign: false
                License:
                  path: "$(joinpath(LICENSES_DIR, "MIT"))"
                  destination: "LICENSE"
                ProjectFile:
                  version: v"1.0.0-DEV"
                Readme:
                  file: "$(joinpath(TEMPLATES_DIR, "README.md"))"
                  destination: "README.md"
                  inline_badges: false
                  badge_order: DataType[Documenter{GitHubActions}, Documenter{GitLabCI}, Documenter{TravisCI}, GitHubActions, GitLabCI, TravisCI, AppVeyor, DroneCI, CirrusCI, Codecov, Coveralls, BlueStyleBadge, ColPracBadge, PkgEvalBadge]
                  badge_off: DataType[]
                SrcDir:
                  file: "$(joinpath(TEMPLATES_DIR, "src", "module.jl"))"
                TagBot:
                  file: "$(joinpath(TEMPLATES_DIR, "github", "workflows", "TagBot.yml"))"
                  destination: "TagBot.yml"
                  trigger: "JuliaTagBot"
                  token: Secret("GITHUB_TOKEN")
                  ssh: Secret("DOCUMENTER_KEY")
                  ssh_password: nothing
                  changelog: nothing
                  changelog_ignore: nothing
                  gpg: nothing
                  gpg_password: nothing
                  registry: nothing
                  branches: nothing
                  dispatch: nothing
                  dispatch_delay: nothing
                Tests:
                  file: "$(joinpath(TEMPLATES_DIR, "test", "runtests.jl"))"
                  project: false
            """
        # `with_clean_gitconfig` requires Git to be installed, but if Git is not installed,
        # then we probably don't need to worry about any conflicting Git config files.
        f = () -> test_show(
            rstrip(expected),
            sprint(show, MIME("text/plain"), tpl(; authors=USER)),
        )
        if PT.git_is_installed()
            with_clean_gitconfig() do
                run(`git config user.name Tester`)
                run(`git config user.email te@st.er`)
                f()
            end
        else
            f()
        end
    end

    @testset "show as serialization" begin
        t1 = tpl()
        t2 = eval(Meta.parse(sprint(show, t1)))
        @test t1 == t2

        foreach((NoDeploy, GitHubActions)) do T
            p1 = Documenter{T}()
            p2 = eval(Meta.parse(sprint(show, p1)))
            @test p1 == p2
        end
    end
end
