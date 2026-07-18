"""Small algorithms for sequence, mapping, and callable-chain exercises."""


def isPalindrome(n):
    """Return whether the string representation of *n* reads the same backward."""
    string = str(n)
    index = 0
    length = len(string)

    while index < length:
        if string[index] != string[length - index - 1]:
            return False
        index += 1
    return True


def nthmax(n, a):
    """Return the zero-based nth-largest value in *a*, mutating the input list.

    Returns ``None`` when *n* is outside the upper bound of the list.
    """
    length = len(a)
    if n >= length:
        return None

    values = a
    popped = values[0]

    if n < length // 2:
        for _ in range(n + 1):
            max_index = 0
            for index in range(1, length):
                if values[index] > values[max_index]:
                    max_index = index
            popped = values.pop(max_index)
            length -= 1
    else:
        for _ in range(length - n):
            min_index = 0
            for index in range(1, length):
                if values[index] < values[min_index]:
                    min_index = index
            popped = values.pop(min_index)
            length -= 1

    return popped


def freq(s):
    """Return the most frequent character in *s* or an empty string for empty input.

    Ties are resolved by the character that first reaches the highest frequency.
    """
    if s == "":
        return ""

    frequent = s[0]
    characters = {}
    for char in s:
        if char in characters:
            characters[char] += 1
            if characters[char] > characters[frequent]:
                frequent = char
        else:
            characters[char] = 1

    return frequent


def zipHash(arr1, arr2):
    """Return a dictionary pairing corresponding values from equally sized arrays."""
    length = len(arr1)
    if length != len(arr2):
        return None

    hashmap = {}
    for index in range(length):
        hashmap[arr1[index]] = arr2[index]
    return hashmap


def hashToArray(mapping):
    """Convert a mapping into ``[key, value]`` pairs in iteration order."""
    array = []
    for key in mapping:
        array.append([key, mapping[key]])
    return array


def maxLambdaChain(init, lambdas):
    """Return the largest value produced by ordered chains of supplied callables.

    Each callable may be used at most once, and callable order follows the input
    sequence. The initial value is included as a possible maximum.
    """
    length = len(lambdas)
    maximum = init

    for index in range(length):
        candidate = lambda_aux(init, lambdas, index, maximum, length)
        if candidate > maximum:
            maximum = candidate

    return maximum


def lambda_aux(curr, lambdas, index, maximum, length):
    """Evaluate callable chains beginning with ``lambdas[index]``."""
    current = lambdas[index](curr)
    if current > maximum:
        maximum = current

    for next_index in range(index + 1, length):
        candidate = lambda_aux(current, lambdas, next_index, maximum, length)
        if candidate > maximum:
            maximum = candidate

    return maximum
