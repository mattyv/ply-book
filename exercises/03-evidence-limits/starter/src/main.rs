fn main() {
    for event in evidence_limits_starter::scheduler::demo() {
        println!("{event}");
    }
}
