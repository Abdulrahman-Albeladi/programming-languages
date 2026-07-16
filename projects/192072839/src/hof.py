"""Small higher-order function utilities.

The functions in this module operate on ordinary Python sequences and preserve
in-place behavior where applicable.
"""


def uniq(values):
    """Return values in first-occurrence order, removing later duplicates."""
    unique_values = []
    for value in values:
        if value not in unique_values:
            unique_values.append(value)
    return unique_values


def find_max(matrix):
    """Return the largest value in a non-empty nested sequence."""
    values = [value for row in matrix for value in row]
    return max(values)


def count_ones(matrix):
    """Count values equal to ``1`` across a nested sequence."""
    return sum(value == 1 for row in matrix for value in row)


def addgenerator(x):
    """Return a function that adds ``x`` to its argument."""
    return lambda a: a + x


def apply_to_self():
    """Return a function that adds a value to a function applied to that value."""
    return lambda a, b: a + b(a)


def map2(matrix, f):
    """Apply ``f`` to every matrix element in place and return ``matrix``."""
    for row in matrix:
        for index, value in enumerate(row):
            row[index] = f(value)
    return matrix
