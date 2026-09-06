fn main() {
    for event in first_claim_starter::scheduler::demo() {
        println!("{event}");
    }
}
