# Project Index

## `projects/192072839` — Python basics, higher-order functions, and roster code

**Contents**

- `src/basics.py`
- `src/hof.py`
- `src/roster.py`
- Public Python tests under `test/public/`
- `metadata.yml`

**Setup**

Requires Python 3. Run commands from `projects/192072839`.

**Suggested validation**

```sh
python -m unittest discover -s test/public
```

**Validation status**

Not run during reconstruction.

**Data requirements**

No external or private data files are identified.

**Limitations**

The recovered layout exposes modules and public tests but does not include a package manifest, command-line interface, or project-level documentation. Behavior should be reviewed directly in the source before reuse.

**Provenance**

Recovered from source collection `330`; retained project identifier `192072839` and `metadata.yml` provide the available project-level provenance.

---

## `projects/195897064` — Python ribosome and codon processing

**Contents**

- `src/ribosome.py`
- Public tests under `test/public/`
- Codon and order input fixtures under `test/public/inputs/`
- `metadata.yml`

**Setup**

Requires Python 3. Run commands from `projects/195897064`.

**Suggested validation**

```sh
python -m unittest discover -s test/public
```

**Validation status**

Not run during reconstruction.

**Data requirements**

The recovered project includes small text fixtures for codons and ordering. No external or private biological dataset is identified. Larger or proprietary sequence data should be supplied outside version control through documented configuration or synthetic examples.

**Limitations**

The project is represented by a single source module and fixture-based public tests. The file list does not establish support for full biological data formats, external databases, or production-scale sequence processing.

**Provenance**

Recovered from source collection `330`; retained project identifier `195897064` and `metadata.yml` provide the available project-level provenance.

---

## `projects/200694067` — Python finite-state machine

**Contents**

- `src/fsm.py`
- Visualization helper at `test/visualizer.py`
- Images at `images/m_viz.png` and `images/n_viz.png`
- Public and student test directories
- `metadata.yml`

**Setup**

Requires Python 3. Run commands from `projects/200694067`.

**Suggested validation**

```sh
python -m unittest discover -s test/public
```

**Validation status**

Not run during reconstruction.

**Data requirements**

No external or private data is identified. The included images appear to be project visualization assets.

**Limitations**

The available files indicate an FSM implementation and visualization support, but no dependency declaration or standalone CLI is present. The `test/student/` directory should be reviewed before treating it as a public validation suite.

**Provenance**

Recovered from source collection `330`; retained project identifier `200694067` and `metadata.yml` provide the available project-level provenance.

---

## `projects/203994191` — OCaml basics and functions

**Contents**

- `src/basics.ml` and `src/basics.mli`
- `src/funs.ml` and `src/funs.mli`
- Dune configuration in the project, source, and test directories
- Public and student test directories
- `metadata.yml`

**Setup**

Requires OCaml and Dune. Run commands from `projects/203994191`.

**Suggested validation**

```sh
dune test
```

**Validation status**

Not run during reconstruction.

**Data requirements**

No external or private data is identified.

**Limitations**

The project is a small OCaml codebase organized around module interfaces and implementations. The recovered materials do not provide an application executable or external package documentation. Test-suite scope should be inspected because both public and student test directories are present.

**Provenance**

Recovered from source collection `330`; retained project identifier `203994191` and `metadata.yml` provide the available project-level provenance.

---

## `projects/208179876` — OCaml sets, regular expressions, and NFAs

**Contents**

- Set implementation and interface: `src/sets.ml`, `src/sets.mli`
- Regular-expression implementation and interface: `src/regexp.ml`, `src/regexp.mli`
- NFA implementation and interface: `src/nfa.ml`, `src/nfa.mli`
- Visualization executable source: `bin/viz.ml`
- Visualization wrapper script: `viz.sh`
- Public, student, and property-based test directories
- `metadata.yml`

**Setup**

Requires OCaml and Dune. Run commands from `projects/208179876`. The visualization script may require local tools or runtime assumptions not evident from the recovered file list; inspect `viz.sh` before use.

**Suggested validation**

```sh
dune test
```

A property-based test target may also be available through the Dune configuration under `test/pbt/`.

**Validation status**

Not run during reconstruction.

**Data requirements**

No external or private data is identified.

**Limitations**

The recovered project includes a property-based test directory and an editor-backup file, `test/pbt/#pbt.ml#`. The backup file should be removed or ignored in a cleaned working tree. Visualization behavior and dependencies should be confirmed locally rather than assumed from the presence of `viz.sh` and `bin/viz.ml`.

**Provenance**

Recovered from source collection `330`; retained project identifier `208179876` and `metadata.yml` provide the available project-level provenance.

---

## `projects/214149253` — OCaml lexer, parser, evaluator, and LCC types

**Contents**

- Lexer: `src/lexer.ml`, `src/lexer.mli`
- Parser: `src/parser.ml`, `src/parser.mli`
- Evaluator: `src/eval.ml`, `src/eval.mli`
- Types: `src/lccTypes.ml`
- Dune configuration and `lcc.opam`
- Public test directory
- `metadata.yml`

**Setup**

Requires OCaml, Dune, and dependencies declared in `lcc.opam` or the Dune files. Run commands from `projects/214149253`.

**Suggested validation**

```sh
dune test
```

If the local environment uses opam, install or pin dependencies according to the project’s `lcc.opam` file before building.

**Validation status**

Not run during reconstruction.

**Data requirements**

No external or private data is identified.

**Limitations**

The project contains front-end and evaluation components but no recovered top-level executable entry point. Supported syntax, semantics, error handling, and dependency versions should be determined from the source and package metadata before use.

**Provenance**

Recovered from source collection `330`; retained project identifier `214149253` and `metadata.yml` provide the available project-level provenance.

---

## `projects/217167206` — Rust basics and command-line text processing

**Contents**

- Library source: `src/lib.rs`
- Basic Rust source: `src/prob1_basics.rs`
- Executable sources: `src/bin/cmd_args.rs`, `src/bin/readfile.rs`, `src/bin/prob2_wc.rs`
- Cargo manifest: `Cargo.toml`
- Rust integration tests under `tests/`
- Text fixtures under `test-data/` and `tests/`
- Shell scripts and executable helper files: `test_prob2_wc.sh`, `test_post_filter`, `testy`
- `metadata.yml`

**Setup**

Requires a Rust toolchain with Cargo. Run commands from `projects/217167206`.

**Suggested validation**

```sh
cargo test
cargo build --bins
```

Inspect shell helpers before executing them, including their assumptions about paths, executable permissions, and local shell environment.

**Validation status**

Not run during reconstruction.

**Data requirements**

The project includes text fixtures such as `howl.txt`, `bruce.txt`, `dijkstra.txt`, and `gettysburg.txt`. No external or private data requirement is identified. Any replacement corpus should be provided outside the repository when licensing, privacy, or size prevents publication.

**Limitations**

The recovered code contains multiple binaries but no repository-level usage guide for their command-line arguments. The shell-based checks may be platform-dependent. The presence of a word-count binary does not establish compatibility with a particular system utility or exact output format without inspecting the source and tests.

**Provenance**

Recovered from source collection `330`; retained project identifier `217167206` and `metadata.yml` provide the available project-level provenance.
