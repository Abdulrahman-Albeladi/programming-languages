# programming-languages-projects

Recovered programming-language exercises and small implementations from university and research-adjacent files. Each project is isolated under `projects/<id>/` and retains its original language-specific build layout where available.

## Repository layout

| Project | Language | Summary |
| --- | --- | --- |
| `192072839` | Python | Basic functions, higher-order functions, and roster-related code. |
| `195897064` | Python | Ribosome/codon processing implementation with text input fixtures. |
| `200694067` | Python | Finite-state-machine implementation and visualization assets. |
| `203994191` | OCaml | Basic OCaml functions and interface-based modules. |
| `208179876` | OCaml | Sets, regular expressions, nondeterministic finite automata, and a visualization executable. |
| `214149253` | OCaml | Lexer, parser, evaluator, and types for an LCC-language implementation. |
| `217167206` | Rust | Rust basics plus command-line/file-processing programs, including word-count-related code. |

## Setup

Install only the toolchain required for the project being used:

- Python 3 for projects `192072839`, `195897064`, and `200694067`.
- OCaml, Dune, and the dependencies declared by project files for projects `203994191`, `208179876`, and `214149253`.
- Rust and Cargo for project `217167206`.

No repository-wide package manager or shared build command is present. Run commands from the individual project directory.

## Validation status

Validation has not been run as part of this repository reconstruction. The repository includes public tests and build configuration for several projects, but their current results are not asserted here. Suggested commands are listed in the project index and validation section below.

## Data and privacy

No external private dataset is identified by the recovered file list. Included fixtures are stored with the relevant projects, including codon-order inputs in `195897064` and text fixtures in `217167206`.

If these projects are extended with research or institutional data, keep source data outside the repository unless it is approved for publication. Use configuration, documented paths, or synthetic fixtures rather than committing private inputs.

## Scope and limitations

- Project directories retain recovered numeric identifiers because descriptive original project names were not available.
- Some directories include public, student, property-based, or utility test files from their recovered layouts. Their presence does not establish that all tests are suitable for public distribution or that they currently pass.
- `208179876/test/pbt/#pbt.ml#` appears to be an editor backup artifact and should not be treated as source code.
- The repository does not provide a unified API, package, benchmark suite, or cross-project integration layer.
- Project descriptions below are based on recovered file names and build structure; they do not claim behavior beyond what the recovered source organization supports.

## Provenance

These projects were recovered as publish-eligible material from a source collection identified as `330`. The preserved provenance available in this repository is the per-project `metadata.yml` file and the original project directory identifier. Original assignment text, grading instructions, hidden tests, private paths, credentials, and other non-portable scaffolding are not represented in this index.

See [PROJECT_INDEX.md](PROJECT_INDEX.md) for per-project notes.

<!-- portfolio-public-release-license:start -->

## License and public-release status

This repository is published under an all-rights-reserved
portfolio license. Viewing the repository does not grant permission to reuse its code,
documentation, datasets, or assets. Third-party and collaborator materials retain
their original rights.

Before changing visibility from private to public, the owner must complete the
ownership checklist in `LICENSE_REVIEW.md`.

<!-- portfolio-public-release-license:end -->

<!-- programming-languages-course-tests:start -->

## Academic-integrity cleanup

Course test directories with uncertain ownership were removed from the public portfolio copy and preserved in a private quarantine. See `REMOVED_COURSE_TESTS.md`.

<!-- programming-languages-course-tests:end -->

<!-- release-license:start -->

## License and public-release status

This repository uses an all-rights-reserved portfolio license. Review `LICENSE_REVIEW.md` and `THIRD_PARTY_NOTICES.md` before changing visibility to public.

<!-- release-license:end -->

<!-- course-test-cleanup:start -->

## Academic-integrity cleanup

Test directories with uncertain ownership were removed and preserved in a private quarantine. See `REMOVED_COURSE_TESTS.md`.

<!-- course-test-cleanup:end -->
