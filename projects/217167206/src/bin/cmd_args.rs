// Demonstrates accessing command-line arguments.

use std::env;

fn main() {
    for (index, argument) in env::args().enumerate() {
        println!("arg[{index}]: {argument}");
    }

    let arguments: Vec<String> = env::args().collect();
    println!("{} total args", arguments.len());
}
