"""Codon encoding, decoding, and operation processing utilities.

Codon definitions use one amino-acid label per line::

    Amino: AUG, C{2}A

Evaluation definitions use the form::

    profile: L, PO

``L`` and ``R`` select sequence direction. ``PO``, ``PR``, and ``I`` define
how operation codons target neighboring decoded tokens.
"""

import re
from typing import Dict, List, Optional, Tuple

codons: Dict[str, List[str]] = {}
choices: List[Dict[str, str]] = []

_CODON_LINE = re.compile(r"([A-Z]+[a-z|A-Z]*):\s(.+)$")
_EVALUATION_LINE = re.compile(r"([A-Za-z0-9]+):\s(L|R),\s(PO|PR|I)$")
_REPEAT_CODON_BASE = re.compile(r"([AGUC])\{(\d+)\}")
_OPERATIONS = {"DEL", "EXCHANGE", "SWAP"}


def read_codons(codon_file: str) -> None:
    """Load valid codon definitions from ``codon_file``.

    A definition is retained only when every comma-separated codon contains
    RNA bases (``A``, ``G``, ``U``, or ``C``). Repetition notation such as
    ``A{3}`` is expanded before validation.
    """
    global codons

    parsed_codons: Dict[str, List[str]] = {}
    with open(codon_file, encoding="utf-8") as file:
        for line in file:
            match = _CODON_LINE.search(line.strip())
            if match is None:
                continue

            amino = match.group(1)
            codon_text = _REPEAT_CODON_BASE.sub(
                lambda repeated: repeated.group(1) * int(repeated.group(2)),
                match.group(2),
            )
            codon_list = [codon.strip() for codon in codon_text.split(",")]

            if codon_list and all(
                all(base in "AGUC" for base in codon) for codon in codon_list
            ):
                parsed_codons[amino] = codon_list

    codons = parsed_codons


def read_evals(eval_file: str) -> None:
    """Load evaluation profiles from ``eval_file``."""
    global choices

    parsed_choices: List[Dict[str, str]] = []
    with open(eval_file, encoding="utf-8") as file:
        for line in file:
            match = _EVALUATION_LINE.search(line.strip())
            if match is not None:
                parsed_choices.append(
                    {
                        "name": match.group(1),
                        "read": match.group(2),
                        "fix": match.group(3),
                    }
                )

    choices = parsed_choices


def encode(sequence: str) -> str:
    """Encode whitespace-separated amino-acid labels using their longest codon."""
    output = ""
    for amino in sequence.split():
        if amino in codons:
            output += max(codons[amino], key=len)
    return output


def decode(sequence: str) -> str:
    """Decode a nucleotide sequence, preferring the longest matching codon."""
    decoded, _ = _decode_tokens(sequence)
    return " ".join(decoded)


def operate(sequence: str, eval_name: str) -> Optional[str]:
    """Apply an evaluation profile to operation codons in ``sequence``.

    Only tokens between ``START`` and ``STOP`` markers are retained before
    operation codons are applied. ``None`` is returned when no matching
    evaluation profile has been loaded.
    """
    profile = next((choice for choice in choices if choice["name"] == eval_name), None)
    if profile is None:
        return None

    undecoded = sequence[::-1] if profile["read"] == "R" else sequence
    decoded: List[str] = []
    encoded: List[str] = []
    decode_operate(undecoded, decoded, encoded)

    running = False
    index = 0
    while index < len(decoded):
        word = decoded[index]
        if word == "START":
            running = True
            decoded.pop(index)
            encoded.pop(index)
            index -= 1
        elif word == "STOP":
            running = False
            decoded.pop(index)
            encoded.pop(index)
            index -= 1
        elif not running:
            decoded.pop(index)
            encoded.pop(index)
            index -= 1
        index += 1

    operate_aux(decoded, encoded, profile["fix"], profile["read"], 0)
    return "".join(encoded)


def operate_aux(
    decoded: List[str], undecoded: List[str], fix: str, read: str, index: int
) -> None:
    """Apply operation tokens to aligned decoded labels and encoded codons."""
    if fix == "PR" and index < len(decoded) - 1:
        operate_aux(decoded, undecoded, fix, read, index + 1)

    if index >= len(decoded):
        return

    if decoded[index] == "DEL":
        if fix == "PO" and index > 0 and decoded[index - 1] not in _OPERATIONS:
            decoded.pop(index - 1)
            decoded.pop(index - 1)
            undecoded.pop(index - 1)
            undecoded.pop(index - 1)
            index -= 2
        elif (
            fix == "PR"
            and index < len(decoded) - 1
            and decoded[index + 1] not in _OPERATIONS
        ):
            decoded.pop(index + 1)
            decoded.pop(index)
            undecoded.pop(index + 1)
            undecoded.pop(index)
        elif fix == "I" and index < len(decoded) - 1:
            if decoded[index + 1] in _OPERATIONS:
                operate_aux(decoded, undecoded, fix, read, index + 1)
            if index < len(decoded) - 1 and decoded[index + 1] not in _OPERATIONS:
                decoded.pop(index + 1)
                decoded.pop(index)
                undecoded.pop(index + 1)
                undecoded.pop(index)
                index -= 1
            else:
                decoded.pop(index)
                undecoded.pop(index)
                index -= 1
        else:
            decoded.pop(index)
            undecoded.pop(index)
            if fix in {"PO", "I"}:
                index -= 1

    elif decoded[index] == "EXCHANGE":
        if fix == "PO" and index > 0 and decoded[index - 1] not in _OPERATIONS:
            _exchange_codon(decoded[index - 1], undecoded, index - 1)
        elif (
            fix == "PR"
            and index < len(decoded) - 1
            and decoded[index + 1] not in _OPERATIONS
        ):
            _exchange_codon(decoded[index + 1], undecoded, index + 1)
        elif fix == "I" and index < len(decoded) - 1:
            if decoded[index + 1] in _OPERATIONS:
                operate_aux(decoded, undecoded, fix, read, index + 1)
            if index < len(decoded) - 1 and decoded[index + 1] not in _OPERATIONS:
                _exchange_codon(decoded[index + 1], undecoded, index + 1)

        decoded.pop(index)
        undecoded.pop(index)
        if fix in {"PO", "I"}:
            index -= 1

    elif decoded[index] == "SWAP":
        if (
            fix == "PO"
            and index > 1
            and decoded[index - 1] not in _OPERATIONS
            and decoded[index - 2] not in _OPERATIONS
        ):
            decoded[index - 1], decoded[index - 2] = (
                decoded[index - 2],
                decoded[index - 1],
            )
            undecoded[index - 1], undecoded[index - 2] = (
                undecoded[index - 2],
                undecoded[index - 1],
            )
        elif (
            fix == "PR"
            and index < len(decoded) - 2
            and decoded[index + 1] not in _OPERATIONS
            and decoded[index + 2] not in _OPERATIONS
        ):
            decoded[index + 1], decoded[index + 2] = (
                decoded[index + 2],
                decoded[index + 1],
            )
            undecoded[index + 1], undecoded[index + 2] = (
                undecoded[index + 2],
                undecoded[index + 1],
            )
        elif fix == "I" and index > 0 and index < len(decoded) - 1:
            if decoded[index + 1] in _OPERATIONS:
                operate_aux(decoded, undecoded, fix, read, index + 1)
            if (
                index > 0
                and index < len(decoded) - 1
                and decoded[index - 1] not in _OPERATIONS
                and decoded[index + 1] not in _OPERATIONS
            ):
                decoded[index - 1], decoded[index + 1] = (
                    decoded[index + 1],
                    decoded[index - 1],
                )
                undecoded[index - 1], undecoded[index + 1] = (
                    undecoded[index + 1],
                    undecoded[index - 1],
                )

        decoded.pop(index)
        undecoded.pop(index)
        if fix in {"PO", "I"}:
            index -= 1

    if fix in {"PO", "I"} and index < len(decoded) - 1:
        operate_aux(decoded, undecoded, fix, read, index + 1)


def decode_operate(sequence: str, decoded: List[str], encoded: List[str]) -> None:
    """Append decoded labels and their matched codons for operation processing."""
    decoded_tokens, encoded_tokens = _decode_tokens(sequence)
    decoded.extend(decoded_tokens)
    encoded.extend(encoded_tokens)


def _decode_tokens(sequence: str) -> Tuple[List[str], List[str]]:
    """Return decoded labels and matched codons using longest-match parsing."""
    sorted_codons = sorted(
        (codon for codon_list in codons.values() for codon in codon_list),
        key=len,
        reverse=True,
    )
    decoded: List[str] = []
    encoded: List[str] = []
    sequence = sequence.strip()
    start = 0

    while start < len(sequence):
        for codon in sorted_codons:
            if sequence.startswith(codon, start):
                encoded.append(codon)
                start += len(codon)
                for amino, amino_codons in codons.items():
                    if codon in amino_codons:
                        decoded.append(amino)
                break
        else:
            start += 1

    return decoded, encoded


def _exchange_codon(amino: str, encoded: List[str], index: int) -> None:
    """Replace an encoded codon with the alternate codon when one is available."""
    amino_codons = codons[amino]
    if len(amino_codons) > 1:
        encoded[index] = (
            amino_codons[1] if amino_codons[0] == encoded[index] else amino_codons[0]
        )
