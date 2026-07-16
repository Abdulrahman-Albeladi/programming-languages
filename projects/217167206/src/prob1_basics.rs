use regex::Regex;

/// Returns the sum of the integers from 1 through `n`.
///
/// Returns `-1` when `n` is negative.
pub fn gauss(n: i32) -> i32 {
    if n < 0 {
        -1
    } else {
        n * (n + 1) / 2
    }
}

/// Counts values in `slice` that satisfy `lo <= value <= hi`.
pub fn in_range(slice: &[i32], lo: i32, hi: i32) -> i32 {
    slice
        .iter()
        .filter(|&&value| value >= lo && value <= hi)
        .count() as i32
}

/// Returns the arithmetic mean of `slice`, or `None` when it is empty.
pub fn mean(slice: &[f64]) -> Option<f64> {
    if slice.is_empty() {
        None
    } else {
        Some(slice.iter().sum::<f64>() / slice.len() as f64)
    }
}

/// Returns whether every element of `slicea` occurs in `sliceb`.
///
/// Repeated elements in `slicea` do not require matching multiplicities in
/// `sliceb`.
pub fn subset<T>(slicea: &[T], sliceb: &[T]) -> bool
where
    T: PartialEq,
{
    slicea.iter().all(|element| sliceb.contains(element))
}

/// Returns the binary representation of an unsigned integer without leading
/// zeros, except that zero is represented as `"0"`.
pub fn to_binstring(num: u32) -> String {
    if num == 0 {
        return "0".to_string();
    }

    let mut digits = Vec::new();
    let mut quotient = num;

    while quotient > 0 {
        digits.push((quotient % 2).to_string());
        quotient /= 2;
    }

    digits.reverse();
    digits.join("")
}

/// Constructs a circulant matrix whose first row is `r0_slice`.
///
/// Each successive row is the preceding row rotated left by one element.
pub fn circulant<T>(r0_slice: &[T]) -> Vec<Vec<T>>
where
    T: Clone,
{
    (0..r0_slice.len())
        .map(|offset| {
            r0_slice
                .iter()
                .cycle()
                .skip(offset)
                .take(r0_slice.len())
                .cloned()
                .collect()
        })
        .collect()
}

/// Counts whitespace-delimited words in `text`.
pub fn count_words(text: &String) -> i32 {
    let word_regex = Regex::new(r"\S+").expect("word-count regex must be valid");
    word_regex.find_iter(text).count() as i32
}
