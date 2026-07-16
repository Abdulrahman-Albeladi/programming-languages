"""Import smoke tests for the finite-state-machine API."""

from src.fsm import Fsm, accept, char, concat, e_closure, move, nfa_to_dfa, star, union


def test_fsm_api_exports_are_available():
    """Verify that the public FSM symbols can be imported."""
    exports = (char, concat, union, star, nfa_to_dfa, move, e_closure, accept, Fsm)
    assert all(export is not None for export in exports)  # nosec B101
