use rust_text_tools::prob1_basics::count_words;

use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader};
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("usage: {} <filename>", args[0]);
        exit(1);
    }

    let filename = &args[1];
    let file = match File::open(filename) {
        Ok(file) => file,
        Err(error) => {
            eprintln!("could not open file {filename}: {error}");
            exit(1);
        }
    };

    let reader = BufReader::new(file);
    let mut line_count = 0;
    let mut word_count = 0;
    let mut char_count = 0;

    for line in reader.lines() {
        let line = match line {
            Ok(line) => line,
            Err(error) => {
                report_read_error(filename, error);
                exit(1);
            }
        };

        line_count += 1;
        word_count += count_words(&line);
        char_count += line.len() + 1;
    }

    println!(
        "{:>4} {:>4} {:>4} {}",
        line_count, word_count, char_count, filename
    );
}

fn report_read_error(filename: &str, error: io::Error) {
    eprintln!("could not read file {filename}: {error}");
}
