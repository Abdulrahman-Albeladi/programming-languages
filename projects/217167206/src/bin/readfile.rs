//! Demonstrates three approaches to reading a text file line by line.
//!
//! Set `READFILE_PATH` to read a different file. When unset, the program reads
//! `test-data/gettysburg.txt` relative to the current working directory.

use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader};

const DEFAULT_FILE: &str = "test-data/gettysburg.txt";

fn main() {
    let filename = env::var("READFILE_PATH").unwrap_or_else(|_| DEFAULT_FILE.to_owned());

    println!("readlines1():");
    readlines1(&filename);
    println!();

    println!("readlines2():");
    readlines2(&filename);
    println!();

    println!("readlines3():");
    if let Err(error) = readlines3(&filename) {
        eprintln!("Could not read {filename}: {error}");
    }
}

/// Uses explicit pattern matching for each fallible I/O operation.
fn readlines1(filename: &str) {
    let file = match File::open(filename) {
        Ok(file) => file,
        Err(error) => panic!("Could not open {filename}: {error}"),
    };

    let reader = BufReader::new(file);
    for (line_number, line) in reader.lines().enumerate() {
        let text = match line {
            Ok(text) => text,
            Err(error) => panic!("Could not read line {}: {error}", line_number + 1),
        };
        println!("{}: {text}", line_number + 1);
    }
}

/// Uses `expect` to unwrap fallible I/O operations.
fn readlines2(filename: &str) {
    let file = File::open(filename).unwrap_or_else(|error| {
        panic!("Could not open {filename}: {error}");
    });

    let reader = BufReader::new(file);
    for (line_number, line) in reader.lines().enumerate() {
        let text = line.unwrap_or_else(|error| {
            panic!("Could not read line {}: {error}", line_number + 1);
        });
        println!("{}: {text}", line_number + 1);
    }
}

/// Propagates I/O errors to the caller with the `?` operator.
fn readlines3(filename: &str) -> io::Result<()> {
    let file = File::open(filename)?;
    let reader = BufReader::new(file);

    for (line_number, line) in reader.lines().enumerate() {
        println!("{}: {}", line_number + 1, line?);
    }

    Ok(())
}
