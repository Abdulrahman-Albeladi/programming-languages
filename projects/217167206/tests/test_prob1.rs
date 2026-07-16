extern crate project7;

use project7::prob1_basics::*;

#[test]
fn gauss_handles_positive_and_negative_inputs() {
    assert_eq!(1, gauss(1));
    assert_eq!(15, gauss(5));
    assert_eq!(55, gauss(10));
    assert_eq!(190, gauss(19));
    assert_eq!(-1, gauss(-2));
    assert_eq!(-1, gauss(-400));
    assert_eq!(54_615, gauss(330));
}

#[test]
fn in_range_counts_values_within_bounds() {
    assert_eq!(3, in_range(&[5, 2, 1, 3, 9], 2, 5));
    assert_eq!(1, in_range(&[5, 2, 1, 3, 9], 3, 4));
    assert_eq!(4, in_range(&[5, 2, 1, 3, 9], 2, 10));
    assert_eq!(1, in_range(&[1, 3, 5], 2, 4));
    assert_eq!(2, in_range(&[1, 2, 3, 5, 6], 2, 4));
    assert_eq!(0, in_range(&[], 2, 10));
    assert_eq!(6, in_range(&[-4, -3, -2, -1, 0, 1, 2, 3, 4], -3, 2));

    let values: Vec<i32> = (0..100).collect();
    assert_eq!(26, in_range(&values, 25, 50));
}

#[test]
fn subset_checks_membership_without_duplicate_requirements() {
    assert!(subset(&[1, 3, 2], &[1, 2, 3, 4, 5]));
    assert!(!subset(&[1, 3, 2], &[1, 3, 4, 5]));
    assert!(subset(&["a", "c", "d", "c"], &["d", "c", "a"]));
    assert!(subset(&["a", "c", "d", "c"], &["d", "c", "a", "r"]));
    assert!(!subset(&["a", "q", "d"], &["d", "c", "a", "r"]));
    assert!(!subset(&[1, 3, 2], &[]));
    assert!(!subset(&["a", "b", "d", "e"], &[]));
    assert!(subset(&[], &[1, 3, 4, 5]));
    assert!(subset::<i32>(&[], &[]));
}

#[test]
fn mean_returns_average_or_none_for_empty_input() {
    assert_eq!(Some(10.5), mean(&[10.0, 5.0, 7.0, 20.0]));
    assert_eq!(Some(-5.0 / 3.0), mean(&[-10.0, 3.0, 2.0]));
    assert_eq!(None, mean(&[]));

    let values: Vec<f64> = (-50..=50).map(f64::from).collect();
    assert_eq!(Some(0.0), mean(&values));
}

#[test]
fn to_binstring_formats_nonnegative_integers() {
    assert_eq!("0", to_binstring(0));
    assert_eq!("1", to_binstring(1));
    assert_eq!("10", to_binstring(2));
    assert_eq!("11", to_binstring(3));
    assert_eq!("110", to_binstring(6));
    assert_eq!("1001", to_binstring(9));
    assert_eq!("100000", to_binstring(32));
    assert_eq!("100011", to_binstring(35));
    assert_eq!("111111111", to_binstring(511));
    assert_eq!("1110000100", to_binstring(900));
    assert_eq!("10000000000", to_binstring(1024));
    assert_eq!("10001001011", to_binstring(1099));
    assert_eq!("1010001111100000", to_binstring(41_952));
    assert_eq!("10010101000111111", to_binstring(76_351));
}

#[test]
fn count_words_splits_on_whitespace() {
    assert_eq!(1, count_words(&String::from("hello")));
    assert_eq!(2, count_words(&String::from("hello world")));
    assert_eq!(5, count_words(&String::from("every good boy does fine")));
    assert_eq!(
        20,
        count_words(&String::from(
            "1 2 3 4 5 6 7 8 911 10 11 12 13 14 15 16 17 18 19 20",
        )),
    );
    assert_eq!(0, count_words(&String::from("")));
    assert_eq!(0, count_words(&String::from("       ")));
    assert_eq!(1, count_words(&String::from("  SPACEY    ")));
    assert_eq!(2, count_words(&String::from("  wide        separation  ")));
    assert_eq!(
        3,
        count_words(&String::from("again,  wide        separation   "))
    );
    assert_eq!(
        6,
        count_words(&String::from("ALL ... NON - whitespace !! "))
    );
    assert_eq!(
        7,
        count_words(&String::from("tabs\tor spaces\tor\ttabs\tor spaces"))
    );
    assert_eq!(4, count_words(&String::from("there\nis\nanother\nline\n")));
    assert_eq!(
        21,
        count_words(&String::from(
            "I saw the best minds\tof my .... generation\nDESTROYED  \t  \n by madness , , , starving !! hysterical ?? naked, ...",
        )),
    );
}

fn matrix_string<T: std::fmt::Display>(matrix: &[Vec<T>]) -> String {
    let width = matrix
        .iter()
        .flatten()
        .map(|value| value.to_string().len())
        .max()
        .unwrap_or(0);

    let mut output = String::new();
    for row in matrix {
        for value in row {
            output.push_str(&format!("{value:width$} "));
        }
        output.push('\n');
    }
    output
}

fn vector_string<T: std::fmt::Display>(values: &[T]) -> String {
    let width = values
        .iter()
        .map(|value| value.to_string().len())
        .max()
        .unwrap_or(0);

    let mut output = String::from("[");
    for value in values {
        output.push_str(&format!("{value:width$} "));
    }
    output.push(']');
    output
}

fn circulant_error<T: std::fmt::Display>(
    input: &[T],
    expected: &[Vec<T>],
    actual: &[Vec<T>],
) -> String {
    format!(
        "circulant({}) produced an unexpected matrix\nexpected:\n{}\nactual:\n{}",
        vector_string(input),
        matrix_string(expected),
        matrix_string(actual),
    )
}

fn assert_circulant<T>(input: Vec<T>, expected: Vec<Vec<T>>)
where
    T: std::fmt::Display + PartialEq,
{
    let actual = circulant(&input);
    assert!(
        expected == actual,
        "{}",
        circulant_error(&input, &expected, &actual)
    );
}

#[test]
fn circulant_rotates_three_element_vector() {
    assert_circulant(
        vec![1, 2, 3],
        vec![vec![1, 2, 3], vec![2, 3, 1], vec![3, 1, 2]],
    );
}

#[test]
fn circulant_rotates_string_vector() {
    assert_circulant(
        vec!["a", "b", "c", "d"],
        vec![
            vec!["a", "b", "c", "d"],
            vec!["b", "c", "d", "a"],
            vec!["c", "d", "a", "b"],
            vec!["d", "a", "b", "c"],
        ],
    );
}

#[test]
fn circulant_rotates_symbol_vector() {
    assert_circulant(
        vec!["**", "--", "//", "%%", "@@"],
        vec![
            vec!["**", "--", "//", "%%", "@@"],
            vec!["--", "//", "%%", "@@", "**"],
            vec!["//", "%%", "@@", "**", "--"],
            vec!["%%", "@@", "**", "--", "//"],
            vec!["@@", "**", "--", "//", "%%"],
        ],
    );
}

#[test]
fn circulant_rotates_ten_element_vector() {
    assert_circulant(
        (10..=100).step_by(10).collect(),
        vec![
            vec![10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
            vec![20, 30, 40, 50, 60, 70, 80, 90, 100, 10],
            vec![30, 40, 50, 60, 70, 80, 90, 100, 10, 20],
            vec![40, 50, 60, 70, 80, 90, 100, 10, 20, 30],
            vec![50, 60, 70, 80, 90, 100, 10, 20, 30, 40],
            vec![60, 70, 80, 90, 100, 10, 20, 30, 40, 50],
            vec![70, 80, 90, 100, 10, 20, 30, 40, 50, 60],
            vec![80, 90, 100, 10, 20, 30, 40, 50, 60, 70],
            vec![90, 100, 10, 20, 30, 40, 50, 60, 70, 80],
            vec![100, 10, 20, 30, 40, 50, 60, 70, 80, 90],
        ],
    );
}
