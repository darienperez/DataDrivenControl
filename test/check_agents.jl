using Test

include(joinpath(@__DIR__, "..", "scripts", "check_agents.jl"))

function fixture_git(repo, args...)
    command = Cmd(["git", "--no-pager", "--no-optional-locks", "-C", repo,
        "-c", "user.name=Policy checker test", "-c", "user.email=policy-test@example.invalid",
        "-c", "commit.gpgsign=false", "-c", "core.hooksPath=/dev/null", args...])
    return read(command, String)
end

function policy_fixture(action)
    mktempdir() do temporary
        repo = joinpath(temporary, "repository with spaces")
        mkpath(repo)
        fixture_git(repo, "init", "--quiet", "--initial-branch=main")
        fixture_git(repo, "commit", "--quiet", "--allow-empty", "-m", "Empty repository")
        fixture_git(repo, "branch", "without-policy")
        policy = "# Repository policy\n\nKeep task records.\n"
        write(joinpath(repo, "AGENTS.md"), policy)
        write(joinpath(repo, "tracked.txt"), "Preserve this work.\n")
        fixture_git(repo, "add", "AGENTS.md", "tracked.txt")
        fixture_git(repo, "commit", "--quiet", "-m", "Initial policy")
        fixture_git(repo, "update-ref", "refs/remotes/origin/main", "HEAD")
        action(repo, policy)
    end
end

function check_policy(args...)
    output, errors = IOBuffer(), IOBuffer()
    code = AgentsPolicyCheck.main(collect(args); out=output, err=errors)
    return (; code, output=String(take!(output)), errors=String(take!(errors)))
end

function repository_snapshot(repo)
    files = Dict{String,Tuple{Symbol,Vector{UInt8}}}()
    for (directory, directories, names) in walkdir(repo; follow_symlinks=false)
        for name in Iterators.flatten((directories, names))
            path = joinpath(directory, name)
            if islink(path)
                files[relpath(path, repo)] = (:symlink, collect(codeunits(readlink(path))))
            elseif isfile(path)
                files[relpath(path, repo)] = (:file, read(path))
            end
        end
    end
    return files
end

function check_cli(args...; directory=pwd())
    project = normpath(joinpath(@__DIR__, ".."))
    script = joinpath(project, "scripts", "check_agents.jl")
    command = `$(Base.julia_cmd()) --startup-file=no --project=$project $script $args`
    output, errors = IOBuffer(), IOBuffer()
    process = run(pipeline(ignorestatus(Cmd(command; dir=directory)); stdout=output, stderr=errors))
    return (; code=process.exitcode, output=String(take!(output)), errors=String(take!(errors)))
end

@testset "AGENTS.md policy checker" begin
    @testset "Working file, canonical source, and preservation" begin
        policy_fixture() do repo, policy
            before = repository_snapshot(repo)
            matched = check_policy("--repo", repo)
            @test matched.code == 0
            @test isempty(matched.errors)
            @test occursin("matches the canonical policy exactly", matched.output)
            @test occursin("cached remote-tracking ref; freshness unverified", matched.output)
            @test occursin(strip(fixture_git(repo, "rev-parse", "main")), matched.output)
            @test occursin("Candidate: working file", matched.output)
            @test repository_snapshot(repo) == before
            alias = check_policy("--repo", repo, "--canonical-ref", "origin/main")
            @test alias.code == 0
            @test occursin("cached remote-tracking ref; freshness unverified", alias.output)

            write(joinpath(repo, "AGENTS.md"), replace(policy, "Keep task records." => "Skip task records."))
            write(joinpath(repo, "tracked.txt"), "Uncommitted user work.\n")
            write(joinpath(repo, "untracked notes.txt"), "Preserve untracked work too.\n")
            before = repository_snapshot(repo)
            mismatch = check_policy("--repo", repo)
            @test mismatch.code == 1
            @test isempty(mismatch.errors)
            @test occursin("--- canonical:AGENTS.md", mismatch.output)
            @test occursin("+++ working:AGENTS.md", mismatch.output)
            @test occursin("@@ -", mismatch.output)
            @test occursin("-Keep task records.\n+Skip task records.", mismatch.output)
            @test repository_snapshot(repo) == before

            # An explicit commit candidate must not accidentally inspect the working file.
            committed = check_policy("--repo", repo, "--canonical-ref", "main", "--candidate-ref", "HEAD")
            @test committed.code == 0
            @test occursin("Candidate commit:", committed.output)
            @test repository_snapshot(repo) == before
        end
    end

    @testset "Ref comparison detects drift hidden by a synthetic merge" begin
        policy_fixture() do repo, policy
            fixture_git(repo, "branch", "research")
            write(joinpath(repo, "AGENTS.md"), policy * "Read the task record before resuming.\n")
            fixture_git(repo, "add", "AGENTS.md")
            fixture_git(repo, "commit", "--quiet", "-m", "Update canonical policy")
            fixture_git(repo, "update-ref", "refs/remotes/origin/main", "HEAD")
            fixture_git(repo, "checkout", "--quiet", "research")
            write(joinpath(repo, "research.txt"), "Independent research checkpoint.\n")
            fixture_git(repo, "add", "research.txt")
            fixture_git(repo, "commit", "--quiet", "-m", "Research work")
            fixture_git(repo, "checkout", "--quiet", "-b", "synthetic-merge", "main")
            fixture_git(repo, "merge", "--quiet", "--no-ff", "research", "-m", "Synthetic merge")
            before = repository_snapshot(repo)
            research = check_policy("--repo", repo, "--candidate-ref", "research")
            merged = check_policy("--repo", repo, "--candidate-ref", "synthetic-merge")
            @test research.code == 1
            @test occursin("+++ research:AGENTS.md", research.output)
            @test merged.code == 0
            @test repository_snapshot(repo) == before
        end
    end

    @testset "Untracked and ignored instruction additions" begin
        policy_fixture() do repo, _
            write(joinpath(repo, "AGENTS.override.md"), "Root override.\n")
            before = repository_snapshot(repo)
            root_override = check_policy("--repo", repo)
            @test root_override.code == 1
            @test occursin("Added instruction file: AGENTS.override.md", root_override.output)
            @test occursin("+++ working:AGENTS.override.md", root_override.output)
            @test repository_snapshot(repo) == before
            rm(joinpath(repo, "AGENTS.override.md"))

            nested = joinpath(repo, "research notes")
            mkpath(nested)
            write(joinpath(nested, "AGENTS.md"), "Nested policy.\n")
            before = repository_snapshot(repo)
            addition = check_policy("--repo", repo)
            @test addition.code == 1
            @test occursin("Added instruction file: research notes/AGENTS.md", addition.output)
            @test repository_snapshot(repo) == before
            rm(joinpath(nested, "AGENTS.md"))

            ignored = joinpath(repo, "ignored policies")
            mkpath(ignored)
            write(joinpath(repo, ".gitignore"), "ignored policies/\n")
            write(joinpath(ignored, "AGENTS.override.md"), "Ignored policy still affects instructions.\n")
            before = repository_snapshot(repo)
            addition = check_policy("--repo", repo)
            @test addition.code == 1
            @test occursin("Added instruction file: ignored policies/AGENTS.override.md", addition.output)
            @test repository_snapshot(repo) == before
            rm(joinpath(ignored, "AGENTS.override.md"))

            # Git administration is outside the repository instruction inventory.
            administrative = joinpath(repo, ".git", "not-repository-policy")
            mkpath(administrative)
            write(joinpath(administrative, "AGENTS.md"), "Must not be scanned.\n")
            before = repository_snapshot(repo)
            @test check_policy("--repo", repo).code == 0
            @test repository_snapshot(repo) == before
        end
    end

    @testset "Canonical nested files and committed override candidates" begin
        policy_fixture() do repo, _
            nested = joinpath(repo, "research")
            mkpath(nested)
            write(joinpath(nested, "AGENTS.md"), "Canonical nested instructions.\n")
            write(joinpath(nested, "AGENTS.override.md"), "Canonical nested override.\n")
            fixture_git(repo, "add", "research/AGENTS.md", "research/AGENTS.override.md")
            fixture_git(repo, "commit", "--quiet", "-m", "Approve nested instructions")
            fixture_git(repo, "update-ref", "refs/remotes/origin/main", "HEAD")
            before = repository_snapshot(repo)
            @test check_policy("--repo", repo).code == 0
            @test check_policy("--repo", repo, "--candidate-ref", "HEAD").code == 0
            @test repository_snapshot(repo) == before

            write(joinpath(nested, "AGENTS.md"), "Modified nested instructions.\n")
            before = repository_snapshot(repo)
            modified = check_policy("--repo", repo)
            @test modified.code == 1
            @test occursin("Instruction file contents differ: research/AGENTS.md", modified.output)
            @test occursin("-Canonical nested instructions.\n+Modified nested instructions.", modified.output)
            @test repository_snapshot(repo) == before
            rm(joinpath(nested, "AGENTS.override.md"))
            before = repository_snapshot(repo)
            removed = check_policy("--repo", repo)
            @test removed.code == 1
            @test occursin("Missing instruction file: research/AGENTS.override.md", removed.output)
            @test repository_snapshot(repo) == before

            write(joinpath(repo, "AGENTS.override.md"), "Committed root override.\n")
            fixture_git(repo, "add", "AGENTS.override.md", "research")
            fixture_git(repo, "commit", "--quiet", "-m", "Change instruction inventory")
            before = repository_snapshot(repo)
            committed = check_policy("--repo", repo, "--candidate-ref", "HEAD")
            @test committed.code == 1
            @test occursin("Added instruction file: AGENTS.override.md", committed.output)
            @test occursin("Missing instruction file: research/AGENTS.override.md", committed.output)
            @test repository_snapshot(repo) == before
        end
    end

    @testset "Symlinks never expose outside instructions" begin
        policy_fixture() do repo, policy
            mktempdir() do external
                write(joinpath(external, "AGENTS.override.md"), "Outside repository.\n")
                symlink(external, joinpath(repo, "linked directory"))
                before = repository_snapshot(repo)
                @test check_policy("--repo", repo).code == 0
                @test repository_snapshot(repo) == before

                rm(joinpath(repo, "AGENTS.md"))
                symlink(joinpath(external, "AGENTS.override.md"), joinpath(repo, "AGENTS.md"))
                before = repository_snapshot(repo)
                linked = check_policy("--repo", repo)
                @test linked.code == 1
                @test occursin("Instruction file type differs: AGENTS.md (canonical file; candidate symlink)", linked.output)
                @test !occursin("Outside repository.", linked.output)
                @test repository_snapshot(repo) == before
                fixture_git(repo, "add", "AGENTS.md")
                fixture_git(repo, "commit", "--quiet", "-m", "Symlink candidate")
                before = repository_snapshot(repo)
                @test check_policy("--repo", repo, "--candidate-ref", "HEAD").code == 1
                invalid = check_policy("--repo", repo, "--canonical-ref", "HEAD")
                @test invalid.code == 2
                @test occursin("Canonical instruction file must be a regular file", invalid.errors)
                @test repository_snapshot(repo) == before

                # A dangling instruction symlink is still drift, rather than a read
                # of a missing target or a reason to silently omit the instruction.
                rm(joinpath(repo, "AGENTS.md"))
                write(joinpath(repo, "AGENTS.md"), policy)
                symlink(joinpath(external, "missing"), joinpath(repo, "AGENTS.override.md"))
                before = repository_snapshot(repo)
                dangling = check_policy("--repo", repo)
                @test dangling.code == 1
                @test occursin("Added instruction file: AGENTS.override.md", dangling.output)
                @test repository_snapshot(repo) == before
            end
        end
    end

    @testset "Invalid inputs and missing policy" begin
        policy_fixture() do repo, policy
            invalid = [
                ("--canonical-ref", "does-not-exist"),
                ("--candidate-ref", "does-not-exist"),
                ("--canonical-ref", "--help"),
                ("--candidate-ref", "--output=unexpected-file"),
                ("--canonical-ref", "without-policy"),
                ("--candidate-ref", "without-policy"),
                ("--unknown",),
                ("--help", "--unknown"),
                ("--candidate-ref",),
                ("--canonical-ref", ""),
                ("--canonical-ref", "main", "--canonical-ref", "HEAD"),
            ]
            before = repository_snapshot(repo)
            for args in invalid
                result = check_policy("--repo", repo, args...)
                @test result.code == 2
                @test occursin("AGENTS.md check error:", result.errors)
            end
            @test repository_snapshot(repo) == before
            rm(joinpath(repo, "AGENTS.md"))
            before = repository_snapshot(repo)
            missing = check_policy("--repo", repo)
            @test missing.code == 2
            @test occursin("Missing root working file", missing.errors)
            @test repository_snapshot(repo) == before
            write(joinpath(repo, "AGENTS.md"), policy)
        end
        mktempdir() do nonrepo
            @test check_policy("--repo", nonrepo).code == 2
            @test check_policy("--repo", joinpath(nonrepo, "missing path")).code == 2
        end
    end

    @testset "Exact bytes and valid unified diff boundaries" begin
        policy_fixture() do repo, policy
            write(joinpath(repo, "AGENTS.md"), chomp(policy))
            newline = check_policy("--repo", repo)
            @test newline.code == 1
            @test occursin("\\ No newline at end of file", newline.output)
            write(joinpath(repo, "AGENTS.md"), replace(policy, "\n" => "\r\n"))
            @test check_policy("--repo", repo).code == 1
            write(joinpath(repo, "AGENTS.md"), "")
            empty_candidate = check_policy("--repo", repo)
            @test empty_candidate.code == 1
            @test occursin("+0,0 @@", empty_candidate.output)
            fixture_git(repo, "add", "AGENTS.md")
            fixture_git(repo, "commit", "--quiet", "-m", "Empty policy")
            write(joinpath(repo, "AGENTS.md"), policy)
            empty_canonical = check_policy("--repo", repo, "--canonical-ref", "HEAD")
            @test empty_canonical.code == 1
            @test occursin("@@ -0,0 +1,3 @@", empty_canonical.output)
        end
    end

    @testset "Standalone CLI, paths with spaces, and subdirectories" begin
        policy_fixture() do repo, policy
            subdirectory = joinpath(repo, "nested directory")
            mkpath(subdirectory)
            before = repository_snapshot(repo)
            matched = check_cli(; directory=subdirectory)
            @test matched.code == 0
            @test occursin("Repository: $(realpath(repo))", matched.output)
            @test check_cli("--repo", subdirectory).code == 0
            @test check_cli("--canonical-ref", "missing"; directory=subdirectory).code == 2
            @test check_cli("--unknown"; directory=subdirectory).code == 2
            help = check_cli("--help"; directory=dirname(repo))
            @test help.code == 0
            @test occursin("Usage:", help.output)
            @test repository_snapshot(repo) == before
            write(joinpath(repo, "AGENTS.md"), policy * "Changed locally.\n")
            before = repository_snapshot(repo)
            mismatch = check_cli("--repo", repo)
            @test mismatch.code == 1
            @test occursin("+Changed locally.", mismatch.output)
            @test repository_snapshot(repo) == before
        end
    end
end
