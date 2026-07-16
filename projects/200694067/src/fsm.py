"""Finite-state machine utilities for constructing and evaluating regular languages.

States are represented by integers or lists of integers. Empty-string transitions may
use either ``""`` or the legacy label ``"epsilon"``.
"""


class Fsm:
    """A nondeterministic finite-state machine."""

    def __init__(self, alphabet, states, start, final, transitions):
        self.sigma = alphabet
        self.states = states
        self.start = start
        self.final = final
        self.transitions = transitions

    def __str__(self):
        sigma = "Alphabet: " + str(self.sigma) + "\n"
        states = "States: " + str(self.states) + "\n"
        start = "Start: " + str(self.start) + "\n"
        final = "Final: " + str(self.final) + "\n"
        transition_header = "Transitions: [\n"
        indent = " " * len(transition_header)
        transition_list = "".join(
            indent + str(transition) + "\n" for transition in self.transitions
        )
        return (
            sigma
            + states
            + start
            + final
            + transition_header
            + transition_list
            + indent
            + "]"
        )


count = 0


def fresh():
    """Return the next globally unique state identifier."""
    global count
    count += 1
    return count


def char(string):
    """Create an FSM that recognizes a single transition label."""
    start_state = [count]
    final_state = [count + 1]
    machine = Fsm(
        [string] if string else [],
        [start_state, final_state],
        start_state,
        [final_state],
        [(start_state, string if string else "epsilon", final_state)],
    )
    fresh()
    fresh()
    return machine


def make_transition(src, letter, dest):
    """Create a transition tuple."""
    return (src, letter, dest)


def same_state(s1, s2):
    """Return whether two state collections contain the same members."""
    if len(s1) != len(s2):
        return False
    return all(state in s2 for state in s1)


def state_in_sigma(s1, states):
    """Return whether a state collection appears in ``states``."""
    return any(same_state(s1, state) for state in states)


def concat(r1, r2):
    """Construct an FSM recognizing the concatenation of two machines."""
    sigma = list(r1.sigma)
    for symbol in r2.sigma:
        if symbol not in sigma:
            sigma.append(symbol)

    transitions = list(r1.transitions) + list(r2.transitions)
    for final_state in r1.final:
        transitions.append(make_transition(final_state, "", r2.start))

    return Fsm(sigma, r1.states + r2.states, r1.start, r2.final, transitions)


def union(r1, r2):
    """Construct an FSM recognizing the union of two machines."""
    global count

    sigma = list(r1.sigma)
    for symbol in r2.sigma:
        if symbol not in sigma:
            sigma.append(symbol)

    start_state = [count]
    final_state = [count + 1]
    transitions = (
        [
            make_transition(start_state, "", r2.start),
            make_transition(start_state, "", r1.start),
        ]
        + list(r1.transitions)
        + list(r2.transitions)
    )

    for state in r1.final:
        transitions.append(make_transition(state, "", final_state))
    for state in r2.final:
        transitions.append(make_transition(state, "", final_state))

    machine = Fsm(
        sigma,
        [start_state] + r1.states + r2.states + [final_state],
        start_state,
        [final_state],
        transitions,
    )
    fresh()
    fresh()
    return machine


def star(r1):
    """Construct an FSM recognizing zero or more repetitions of ``r1``."""
    global count

    start_state = [count]
    final_state = [count + 1]
    states = list(r1.states) + [start_state, final_state]
    transitions = list(r1.transitions)
    transitions.append(make_transition(start_state, "", r1.start))
    for state in r1.final:
        transitions.append(make_transition(state, "", final_state))
    transitions.append(make_transition(start_state, "", final_state))
    transitions.append(make_transition(final_state, "", start_state))

    machine = Fsm(r1.sigma, states, start_state, [final_state], transitions)
    fresh()
    fresh()
    return machine


def _state_members(state):
    """Flatten the supported integer/list state representation."""
    if isinstance(state, int):
        return [state]

    members = []
    for item in state:
        if isinstance(item, int):
            members.append(item)
        else:
            members.extend(_state_members(item))
    return members


def _transition_matches_source(source, states):
    return any(member in states for member in _state_members(source))


def _append_unique(destination, values):
    for value in values:
        if value not in destination:
            destination.append(value)


def _is_epsilon(label):
    return label == "" or label == "epsilon"


def e_closure(states, nfa):
    """Return all states reachable from ``states`` using epsilon transitions."""
    closure = _state_members(states)
    index = 0

    while index < len(closure):
        current = closure[index]
        index += 1
        for source, label, destination in nfa.transitions:
            if _is_epsilon(label) and _transition_matches_source(source, [current]):
                _append_unique(closure, _state_members(destination))

    return closure


def e_closure_aux(states, nfa):
    """Perform one epsilon-closure expansion step.

    Retained for compatibility with code that used the original helper directly.
    """
    expanded = _state_members(states)
    for source, label, destination in nfa.transitions:
        if _is_epsilon(label) and _transition_matches_source(source, expanded):
            _append_unique(expanded, _state_members(destination))
    return expanded


def move(symbol, states, nfa):
    """Return states reachable by consuming ``symbol``."""
    if symbol not in nfa.sigma and symbol != "epsilon":
        return []

    active_states = _state_members(states)
    destination_states = []
    for source, label, destination in nfa.transitions:
        matches_epsilon = _is_epsilon(label) and symbol in ("", "epsilon")
        if (symbol == label or matches_epsilon) and _transition_matches_source(
            source, active_states
        ):
            _append_unique(destination_states, _state_members(destination))

    return destination_states


def nfa_to_dfa(nfa):
    """Construct the reachable subset DFA for ``nfa``."""
    start_state = e_closure(nfa.start, nfa)
    dfa = Fsm(list(nfa.sigma), [start_state], start_state, [], [])
    pending = [start_state]
    processed = []

    while pending:
        source = pending.pop(0)
        if source in processed:
            continue
        processed.append(source)

        for symbol in dfa.sigma:
            destination = e_closure(move(symbol, source, nfa), nfa)
            if not destination:
                continue

            dfa.transitions.append(make_transition(source, symbol, destination))
            if destination not in dfa.states:
                dfa.states.append(destination)
                pending.append(destination)

    nfa_final_states = _state_members(nfa.final)
    for state in dfa.states:
        if any(member in nfa_final_states for member in _state_members(state)):
            dfa.final.append(state)

    return dfa


def accept(nfa, string):
    """Return whether ``nfa`` accepts ``string``."""
    dfa = nfa_to_dfa(nfa)
    current = dfa.start

    for symbol in string:
        current = move(symbol, current, dfa)
        if not current:
            return False

    return any(
        current_state in final_state
        for current_state in current
        for final_state in dfa.final
    )
