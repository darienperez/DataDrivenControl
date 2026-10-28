"""
Read-only comparison of repository instruction files with a canonical commit.

Run `julia --startup-file=no --project=. scripts/check_agents.jl --help` for usage.
The checker uses only Julia Base and Git; it never refreshes or repairs policy.
"""
module AgentsPolicyCheck

struct CheckError <: Exception
    message::String
end

Base.showerror(io::IO, error::CheckError) = print(io, error.message)

const USAGE = """
Usage: julia --startup-file=no --project=. scripts/check_agents.jl [options]

Compare root AGENTS.md and all repository AGENTS.md/AGENTS.override.md files
with a canonical commit, byte for byte. Working inventory includes untracked
and ignored files; .git directories and directory symlinks are not traversed.
Canonical instruction files must be regular files. Candidate instruction-file
symlinks are reported as drift without reading their targets.

Options:
  --canonical-ref REF  Canonical commit/ref (default: refs/remotes/origin/main).
  --candidate-ref REF  Compare this commit/ref instead of the working file.
  --repo PATH          Repository or a directory inside it (default: current directory).
  -h, --help           Show this help.

Refs are resolved using local Git objects. Remote-tracking refs are cached;
their freshness is unverified. No fetch or repository mutation is performed.

Exit status: 0 match/help; 1 policy mismatch; 2 invalid options, repository,
refs, or missing/unreadable AGENTS.md.
"""

struct InstructionFile
    kind::Symbol
    data::Vector{UInt8}
end

Base.:(==)(left::InstructionFile, right::InstructionFile) =
    left.kind == right.kind && left.data == right.data

is_instruction(path::AbstractString) = basename(path) in ("AGENTS.md", "AGENTS.override.md")

function parse_options(args)
    options = Dict{String,String}()
    help_requested = false
    index = 1
    while index <= length(args)
        option = args[index]
        if option in ("-h", "--help")
            help_requested = true
            index += 1
            continue
        end
        option in ("--repo", "--canonical-ref", "--candidate-ref") ||
            throw(CheckError("Unknown option: $option"))
        haskey(options, option) && throw(CheckError("Repeated option: $option"))
        index < length(args) || throw(CheckError("Missing value for $option"))
        value = args[index + 1]
        isempty(value) && throw(CheckError("Empty value for $option"))
        options[option] = value
        index += 2
    end
    return help_requested ? nothing : options
end

function git_result(repo::AbstractString, args::AbstractString...)
    command = Cmd(["git", "--no-pager", "--no-optional-locks", "-C", repo, args...])
    command = addenv(command,
        "GIT_NO_LAZY_FETCH" => "1",
        "GIT_TERMINAL_PROMPT" => "0",
        "GIT_NO_REPLACE_OBJECTS" => "1",
    )
    output = IOBuffer()
    errors = IOBuffer()
    process = try
        run(pipeline(ignorestatus(command); stdout=output, stderr=errors))
    catch error
        throw(CheckError("Could not run Git: $(sprint(showerror, error))"))
    end
    return (; code=process.exitcode, output=take!(output), errors=String(take!(errors)))
end

function repository_root(path::AbstractString)
    result = git_result(abspath(path), "rev-parse", "--show-toplevel")
    result.code == 0 || throw(CheckError("Not a working-tree Git repository: $path\n$(strip(result.errors))"))
    return chomp(String(result.output))
end

function resolve_commit(repo::AbstractString, ref::AbstractString)
    result = git_result(repo, "rev-parse", "--verify", "--end-of-options", "$ref^{commit}")
    result.code == 0 || throw(CheckError("Cannot resolve commit/ref $(repr(ref)): $(strip(result.errors))"))
    commit = strip(String(result.output))
    occursin(r"^(?:[0-9a-f]{40}|[0-9a-f]{64})$", commit) ||
        throw(CheckError("Git returned an invalid commit ID for $(repr(ref))."))
    return commit
end

function ref_description(repo::AbstractString, ref::AbstractString)
    result = git_result(repo, "rev-parse", "--symbolic-full-name", "--verify", "--end-of-options", ref)
    symbolic = result.code == 0 ? strip(String(result.output)) : ""
    cached = startswith(symbolic, "refs/remotes/") || startswith(ref, "refs/remotes/")
    return cached ? "$ref (cached remote-tracking ref; freshness unverified)" : ref
end

function committed_policy(repo::AbstractString, commit::AbstractString, ref::AbstractString)
    # Only the resolved, validated hexadecimal commit ID reaches the object lookup.
    result = git_result(repo, "cat-file", "blob", "$commit:AGENTS.md")
    result.code == 0 || throw(CheckError("Cannot read root AGENTS.md at $(repr(ref)) ($commit): $(strip(result.errors))"))
    return result.output
end

function committed_inventory(repo::AbstractString, commit::AbstractString, ref::AbstractString;
        require_regular::Bool=false)
    # This also requires a root policy blob, including for an explicit candidate ref.
    committed_policy(repo, commit, ref)
    result = git_result(repo, "ls-tree", "-r", "--full-tree", "-z", commit)
    result.code == 0 || throw(CheckError("Cannot list instruction files at $(repr(ref)): $(strip(result.errors))"))
    inventory = Dict{String,InstructionFile}()
    for entry in split(String(result.output), '\0'; keepempty=false)
        metadata, path = split(entry, '\t'; limit=2)
        is_instruction(path) || continue
        mode, object_type, object = split(metadata, ' ')
        object_type == "blob" || throw(CheckError("Instruction path is not a file at $(repr(ref)): $path"))
        require_regular && !(mode in ("100644", "100755")) &&
            throw(CheckError("Canonical instruction file must be a regular file: $path at $(repr(ref))"))
        occursin(r"^(?:[0-9a-f]{40}|[0-9a-f]{64})$", object) ||
            throw(CheckError("Git returned an invalid instruction object ID at $path."))
        policy = git_result(repo, "cat-file", "blob", object)
        policy.code == 0 || throw(CheckError("Cannot read instruction file $path at $(repr(ref)): $(strip(policy.errors))"))
        kind = mode == "120000" ? :symlink : :file
        inventory[path] = InstructionFile(kind, policy.output)
    end
    return inventory
end

function working_inventory(repo::AbstractString)
    inventory = Dict{String,InstructionFile}()
    try
        for (directory, directories, files) in walkdir(repo; follow_symlinks=false)
            # A directory symlink can itself have an instruction basename, so inspect
            # its literal target before excluding all directory symlinks from traversal.
            for name in Iterators.flatten((directories, files))
                is_instruction(name) || continue
                path = joinpath(directory, name)
                relative = relpath(path, repo)
                if islink(path)
                    inventory[relative] = InstructionFile(:symlink, collect(codeunits(readlink(path))))
                elseif isfile(path)
                    inventory[relative] = InstructionFile(:file, read(path))
                end
            end
            filter!(name -> name != ".git" && !islink(joinpath(directory, name)), directories)
        end
    catch error
        throw(CheckError("Cannot inspect repository instruction files: $(sprint(showerror, error))"))
    end
    haskey(inventory, "AGENTS.md") || throw(CheckError("Missing root working file: $(joinpath(repo, "AGENTS.md"))"))
    return inventory
end

function print_diff_line(io::IO, prefix::Char, line::AbstractString)
    print(io, prefix, line)
    if !endswith(line, '\n')
        println(io)
        println(io, "\\ No newline at end of file")
    end
end

"""Print a unified diff with three context lines and one encompassing change hunk."""
function print_policy_diff(io::IO, canonical::Vector{UInt8}, candidate::Vector{UInt8}, source::AbstractString;
        path::AbstractString="AGENTS.md")
    old = readlines(IOBuffer(canonical); keep=true)
    new = readlines(IOBuffer(candidate); keep=true)
    old_length, new_length = length(old), length(new)
    prefix = 0
    while prefix < min(old_length, new_length) && old[prefix + 1] == new[prefix + 1]
        prefix += 1
    end
    suffix = 0
    while suffix < min(old_length, new_length) - prefix && old[end - suffix] == new[end - suffix]
        suffix += 1
    end
    start = max(1, prefix - 2)
    old_end = min(old_length, old_length - suffix + 3)
    new_end = min(new_length, new_length - suffix + 3)
    old_count, new_count = old_end - start + 1, new_end - start + 1
    println(io, "--- canonical:", path)
    println(io, "+++ ", source)
    println(io, "@@ -", old_count == 0 ? 0 : start, ",", old_count,
        " +", new_count == 0 ? 0 : start, ",", new_count, " @@")
    for index in start:prefix
        print_diff_line(io, ' ', old[index])
    end
    for index in (prefix + 1):(old_length - suffix)
        print_diff_line(io, '-', old[index])
    end
    for index in (prefix + 1):(new_length - suffix)
        print_diff_line(io, '+', new[index])
    end
    for index in (old_length - suffix + 1):old_end
        print_diff_line(io, ' ', old[index])
    end
end

"""Run the checker without exiting Julia. Return its CLI exit status."""
function main(args=ARGS; out::IO=stdout, err::IO=stderr)
    try
        options = parse_options(args)
        if isnothing(options)
            print(out, USAGE)
            return 0
        end
        repo = repository_root(get(options, "--repo", pwd()))
        canonical_ref = get(options, "--canonical-ref", "refs/remotes/origin/main")
        canonical_commit = resolve_commit(repo, canonical_ref)
        canonical = committed_inventory(repo, canonical_commit, canonical_ref; require_regular=true)
        println(out, "Repository: ", repo)
        println(out, "Canonical: ", ref_description(repo, canonical_ref))
        println(out, "Canonical commit: ", canonical_commit)
        candidate = if haskey(options, "--candidate-ref")
            candidate_ref = options["--candidate-ref"]
            candidate_commit = resolve_commit(repo, candidate_ref)
            println(out, "Candidate: ", ref_description(repo, candidate_ref))
            println(out, "Candidate commit: ", candidate_commit)
            committed_inventory(repo, candidate_commit, candidate_ref)
        else
            candidate_path = joinpath(repo, "AGENTS.md")
            println(out, "Candidate: working file ", candidate_path)
            working_inventory(repo)
        end
        println(out, "No live remote verification performed; no repository changes made.")
        if canonical == candidate
            println(out, "AGENTS.md matches the canonical policy exactly.")
            println(out, "All repository instruction files match the canonical inventory.")
            return 0
        end
        println(out, "Repository instruction files differ from the canonical policy.")
        paths = sort!(collect(union(keys(canonical), keys(candidate))))
        for path in paths
            old = get(canonical, path, nothing)
            new = get(candidate, path, nothing)
            old == new && continue
            if isnothing(old)
                println(out, "Added instruction file: ", path)
            elseif isnothing(new)
                println(out, "Missing instruction file: ", path)
            elseif old.kind != new.kind
                println(out, "Instruction file type differs: ", path,
                    " (canonical ", old.kind, "; candidate ", new.kind, ")")
            else
                println(out, "Instruction file contents differ: ", path)
            end
            old_data = isnothing(old) ? UInt8[] : old.data
            new_data = isnothing(new) ? UInt8[] : new.data
            if old_data != new_data
                source = haskey(options, "--candidate-ref") ? "$(options["--candidate-ref"]):$path" : "working:$path"
                print_policy_diff(out, old_data, new_data, source; path)
            end
        end
        return 1
    catch error
        error isa InterruptException && rethrow()
        println(err, "AGENTS.md check error: ", sprint(showerror, error))
        return 2
    end
end

end # module AgentsPolicyCheck

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    exit(AgentsPolicyCheck.main())
end
