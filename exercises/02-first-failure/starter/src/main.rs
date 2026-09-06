fn main() {
    for event in first_failure_starter::scheduler::demo() {
        println!("{event}");
    }
}
